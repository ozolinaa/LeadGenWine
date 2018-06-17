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
    public class Session
    {
        public static string GenerateNewSessionID(SqlConnection con, long loginID)
        {
            string SessionID;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[User.Login.Session.Create]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@loginID", loginID);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@sessionID";
                outputParameter.SqlDbType = SqlDbType.NVarChar;
                outputParameter.Size = 255;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                SessionID = outputParameter.Value.ToString();
            }

            return SessionID;
        }

        public static bool Delete(SqlConnection con, string sessionID, long loginID) 
        {
            bool result = false;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[User.Login.Session.Delete]";

                cmd.Parameters.AddWithValue("@sessionID", sessionID);
                cmd.Parameters.AddWithValue("@loginID", loginID);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@result";
                outputParameter.SqlDbType = SqlDbType.Bit;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                result = (bool)outputParameter.Value;
            }

            return result;
    }


        public static Login GetLoginBySessionID(SqlConnection con, string sessionID)
        {
            Login login = null;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[User.Login.Session.SelectLoginDetailsBySessionID]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@sessionID", sessionID);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);

                if (dt.Rows.Count > 0)
                    login = new Login(dt.Rows[0]);
            }

            return login;
        }

    }
}
