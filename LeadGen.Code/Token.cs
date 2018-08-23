using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code
{
    public class Token
    {
        public string key { get; set; }
        public string action { get; set; }
        public string value { get; set; }
        public DateTime dateCreated { get; set; }

        public enum Action
        {
            LoginEmailConfirmation,
            LoginRecoverPassword,
            LeadEmailConfirmation,
            LeadReviewCreate,
            LeadRemoveByUser
        };

        public Token(DataRow row)
        {
            key = row["TokenKey"].ToString();
            action = row["TokenAction"].ToString();
            value = row["TokenValue"].ToString();
            dateCreated = Convert.ToDateTime(row["TokenDateCreated"]);
        }


        public Token(SqlConnection con, string tokenAction, string tokenValue, string tokenKey = "")
        {
            action = tokenAction;
            value = tokenValue;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[SysTokenCreate]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@tokenAction", action);
                cmd.Parameters.AddWithValue("@tokenValue", value);
                cmd.Parameters.AddWithValue("@tokenKeySet", string.IsNullOrEmpty(tokenKey) ? (object)DBNull.Value : tokenKey);


                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@tokenKey";
                outputParameter.SqlDbType = SqlDbType.NVarChar;
                outputParameter.Size = 255;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                key = outputParameter.Value.ToString();
            }
        }

        public static Token Find(SqlConnection con, string tokenKey)
        {
            Token token = null;

            SqlCommand cmd = new SqlCommand("[dbo].[SysTokenSelect]", con);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@tokenKey", tokenKey);

            DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
            if (dt.Rows.Count > 0)
                token = new Token(dt.Rows[0]);

            return token;
        }

        public void Delete(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[SysTokenDelete]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@tokenKey", key);

                cmd.ExecuteNonQuery();
            }
        }
        

    }
}
