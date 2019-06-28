using LeadGen.Code.Helpers;
using Microsoft.SqlServer.Types;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Business
{
    public class BusinessLocation
    {
        private long _businessID;
        public long BusinessID { get { return _businessID; } }

        public Map.Location Location { get; set; }

        public DateTime? ApprovedByAdminDateTime { get; set; }


        public BusinessLocation()
        {
        }

        public BusinessLocation(SqlDataReader row)
        {
            _businessID = (long)row["BusinessID"];
            if(row["ApprovedByAdminDateTime"] != DBNull.Value)
                ApprovedByAdminDateTime = (DateTime)row["ApprovedByAdminDateTime"];
            Location = new Map.Location(row);
        }


        public void CreateInDB(SqlConnection con, long businessID)
        {
            long locationID = Location.CreateInDB(con);

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLocationCreate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.AddWithValue("@LocationID", locationID);

                cmd.ExecuteNonQuery();
            }
        }

        public static List<BusinessLocation> SelectFromDbForBusinessID (SqlConnection con, long businessID)
        {
            List<BusinessLocation> result = new List<BusinessLocation>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLocationSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        result.Add(new BusinessLocation(reader));
                    }
                }
            }

            return result;
        }

        public static void DeleteFromDB(SqlConnection con, long locationID, long businessID)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLocationDelete]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LocationID", locationID);
                cmd.Parameters.AddWithValue("@BusinessID", businessID);

                cmd.ExecuteNonQuery();
            }
        }

        public void ApprovalSetByAdmin(SqlConnection con, long adminLoginID, bool approve)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLocationAdminApprovalSet]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LocationID", Location.ID);
                cmd.Parameters.AddWithValue("@BusinessID", BusinessID);
                cmd.Parameters.AddWithValue("@ApprovedByAdminDateTime", approve ? DateTime.UtcNow : (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@LoginID", adminLoginID);

                cmd.ExecuteNonQuery();
            }
        }

    }
}
