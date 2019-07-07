using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

using System.Net.Mail;
using LeadGen.Code.Helpers;
using System.Configuration;
using LeadGen.Code.Sys;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using LeadGen.Code.Tokens;

namespace LeadGen.Code
{
    public class Login
    {
        public enum UserRoles { system_admin = 1, business_admin = 2 };

        //public class Role
        //{
        //    public int ID { get; set; }
        //    public string name { get; set; }
        //    public string code { get; set; }

        //    public Role() //Need parametress constructor to make ModelBinder work
        //    {
        //    }

        //    public Role(DataRow row)
        //    {
        //        ID = (int)row["RoleID"];
        //        name = row["RoleName"].ToString();
        //        code = row["RoleCode"].ToString();
        //    }
        //}

        public class NewPassword
        {
            [DataType(DataType.Password)]
            [Required]
            [Display(Name = "New Password")]
            public string password { get; set; }

            
            [DataType(DataType.Password)]
            [Required]
            [Display(Name = "New Password Confirmation")]
            public string passwordConfirmation { get; set; }
        }

        public long ID { get; set; }
        public UserRoles role { get; set; }
        public DateTime registrationDate { get; set; }
        public DateTime? emailConfirmationDate { get; set; }

        [Required]
        [EmailAddress]
        [Display(Name = "E-mail")]
        public string email { get; set; }

        [Required]
        [DataType(DataType.Password)]
        [Display(Name = "Password")]
        public string password { get; set; }
        public NewPassword newPassword { get; set; }

        public Business.Business business { get; set; }


        public Login() //Need parametress constructor to make ModelBinder work
        {
        }

        public Login(DataRow row)
        {
            ID = (long)row["LoginID"];
            email = row["Email"].ToString();
            role = (UserRoles)(int)row["RoleID"];
            registrationDate = (DateTime) row["RegistrationDate"];

            if (!String.IsNullOrEmpty(row["EmailConfirmationDate"].ToString()))
                emailConfirmationDate = (DateTime)(row["EmailConfirmationDate"]);

            if (row.Table.Columns.Contains("BusinessID") && !String.IsNullOrEmpty(row["BusinessID"].ToString()))
                business = new Business.Business(row);

        }

        public bool Logout(SqlConnection con, string sessionID)
        {
            return Session.Delete(con, sessionID, ID);
        }

        public static Login Authenticate(SqlConnection con, string email, string password)
        {
            Login login = null;

            using (SqlCommand cmd = new SqlCommand("dbo.[UserLoginAuthenticate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                string passwordHash = GeneratePasswordHash(password);

                cmd.Parameters.AddWithValue("@email", email);
                cmd.Parameters.AddWithValue("@passwordHash", passwordHash);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                if (dt.Rows.Count > 0)
                    login = new Login(dt.Rows[0]);
            }

            return login;
        }

        public static Login SelectOne(SqlConnection con, string email = "", long? loginID = null)
        {
            Login login = null;

            using (SqlCommand cmd = new SqlCommand("dbo.[UserLoginSelectOne]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@loginID", (object)loginID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@email", String.IsNullOrEmpty(email) ? (object)DBNull.Value : email);
                
                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                if (dt.Rows.Count > 0)
                    login = new Login(dt.Rows[0]);
            }

            return login;
        }


        private static string GeneratePasswordHash (string password)
        {
            return password;
        }

        public static Login Create(SqlConnection con, UserRoles role, string email, string password)
        {
            long loginID;
            string passwordHash = GeneratePasswordHash(password);
            email = email.ToLower();

            SqlCommand cmd = new SqlCommand("[dbo].[UserLoginCreate]", con);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@roleID", (int)role);
            cmd.Parameters.AddWithValue("@email", email);
            cmd.Parameters.AddWithValue("@passwordHash", passwordHash);

            SqlParameter outputParameter = new SqlParameter();
            outputParameter.ParameterName = "@loginID";
            outputParameter.SqlDbType = SqlDbType.BigInt;
            outputParameter.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(outputParameter);

            cmd.ExecuteNonQuery();
            cmd.Dispose();

            if (long.TryParse(outputParameter.Value.ToString(), out loginID))
                return new Login {
                    ID = loginID,
                    role = role,
                    email = email,
                    password = password
                };

            return null;
        }

        public static void EmailConfirm(SqlConnection con, long loginID)
        {
            SqlCommand cmd = new SqlCommand("[dbo].[UserLoginEmailConfirm]", con)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@loginID", loginID);

            cmd.ExecuteNonQuery();
            cmd.Dispose();
        }

        public static bool SetNewPassword(SqlConnection con, long loginID, string sessionID, NewPassword newPassword)
        {
            bool result = false;

            using (SqlCommand cmd = new SqlCommand("[dbo].[UserLoginPasswordHashUpdate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                string passwordHash = GeneratePasswordHash(newPassword.password);

                cmd.Parameters.AddWithValue("@loginID", loginID);
                cmd.Parameters.AddWithValue("@sessionID", sessionID.ToString());
                cmd.Parameters.AddWithValue("@passwordHash", GeneratePasswordHash(newPassword.password));

                SqlParameter returnParameter = cmd.Parameters.Add("RetVal", SqlDbType.Bit);
                returnParameter.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(returnParameter.Value);
            }

            return result;
        }


        public void PasswordRecoverySendEmail(SqlConnection con)
        {
            string mailSubject = "Восстановление пароля";
            string viewPath = "~/Views/Login/E-mails/_PasswordRecovery.cshtml";

            LoginRecoverPasswordToken token = new LoginRecoverPasswordToken(ID);
            token.CreateInDB(con);

            ViewDataDictionary viewDataDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary()) { { "tokenKey", token.Key } };

            MailMessageLeadGen message = new MailMessageLeadGen(email);

            message.Subject = mailSubject;
            message.Body = ViewHelper.RenderViewToString(viewPath, this, viewDataDictionary);

            SmtpClientLeadGen.SendSingleMessage(message);
        }
    }
}
