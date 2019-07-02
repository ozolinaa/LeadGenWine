using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace LeadGen.Code.Sys
{
    public class Log
    {
        public static void Insert(string value)
        {
            using (SqlConnection con = new SqlConnection(Helpers.SysHelper.AppSettings.SQLConnectionString))
            {
                con.Open();
                Insert(con, value);
            }
        }

        public static void Insert(SqlConnection con, string value)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[SystemLogInsert]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Value", value);

                cmd.ExecuteNonQuery();
            }
        }
    }
}
