using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Lead
{
    public class LeadConfiguration
    {
        public static void FieldMetaTermSetAllowance(SqlConnection con, long termID, bool isAllowed)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadFieldMetaTermSetAllowance]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TermID", termID);
                cmd.Parameters.AddWithValue("@isAllowed", isAllowed);

                cmd.ExecuteNonQuery();
            }
        }

        public static bool FieldMetaTermIsAllowed(SqlConnection con, long termID)
        {
            bool result = false;

            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadFieldMetaTermIsAllowed]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TermID", termID);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@isAllowed";
                outputParameter.SqlDbType = SqlDbType.Bit;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(outputParameter.Value);
            }

            return result;
        }
    }
}
