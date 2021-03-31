using LeadGen.Code.Helpers;
using LeadGen.Code.Sys;
using LeadGen.Code.Tokens;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace LeadGen.Code.Business
{
    public class LoginManager
    {
        public enum LoginStatus { linked = 1, peding_email_verification = 2};


        private Login _curLogin;
        private SqlConnection con;

        public LoginManager(SqlConnection con, Login curlogin)
        {
            this.con = con;
            _curLogin = curlogin;

            if (SelectLogins().Find(x => x.LoginID == curlogin.ID && x.Role == Login.UserRole.business_admin) == null) 
            {
                throw new UnauthorizedAccessException();
            }

        }

        public List<BusinessLogin> SelectLogins()
        {
            List<BusinessLogin> result = new List<BusinessLogin>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLoginSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", _curLogin.business.ID);

                foreach (DataRow row in DBHelper.ExecuteCommandToDataTable(cmd).Rows)
                {
                    result.Add(new BusinessLogin(row));
                }
            }

            return result;
        }

        public void EmailAdd(string email, bool isAdmin) 
        {
            Login newLogin = Login.Create(con, email);
            //Login newLogin = Login.SelectOne(con, loginID: 10006);
            if (newLogin == null)
            {
                throw new Exception("this email already used");
            }
            _curLogin.business.LoginLink(con, newLogin, isAdmin);
            newLogin.business = _curLogin.business;

            MailMessageLeadGen message = MailMessageBuilder.BuildCompanyLoginLinkVerifyMailMessage(newLogin, con);

            SmtpClientLeadGen.SendSingleMessage(message);
        }

        //public void EmailRemove(string email)
        //{
        //    _BusinessLoginManagementRemoveFromDB(email);
        //}

        //public void _BusinessLoginManagementRemoveFromDB(string email)
        //{
        //    bool result = false;
        //    string _email = email.TrimStart().TrimEnd().ToLower();

        //    using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLoginManagementRemove]", con))
        //    {
        //        cmd.CommandType = CommandType.StoredProcedure;W

        //        cmd.Parameters.AddWithValue("@byLoginID", loginID);
        //        cmd.Parameters.AddWithValue("@businessID", businessID);
        //        cmd.Parameters.AddWithValue("@email", _email);

        //        SqlParameter returnParameter = new SqlParameter();
        //        returnParameter.ParameterName = "@Result";
        //        returnParameter.SqlDbType = SqlDbType.Bit;
        //        returnParameter.Direction = ParameterDirection.ReturnValue;
        //        cmd.Parameters.Add(returnParameter);

        //        cmd.ExecuteNonQuery();
        //        result = Convert.ToBoolean(returnParameter.Value);
        //    }

        //    if (result == false)
        //    {
        //        throw new Exception("[dbo].[BusinessLoginManagementRemove] exception");
        //    }
        //}
    }
}
