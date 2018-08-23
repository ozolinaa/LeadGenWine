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
    public class BusinessLocation : Map.Location
    {
        public long locationID { get; set; }
        public bool isAprovedByAdmin { get; set; }
        private long _businessID;
        public long businessID { get { return _businessID; } }


        public BusinessLocation()
        {
        }

        public BusinessLocation(SqlDataReader row)
        {
            locationID = (long)row["LocationID"];
            _businessID = (long)row["BusinessID"];

            isAprovedByAdmin = (bool)row["IsAprovedByAdmin"];
            address = (string)row["LocationAddress"];
            name = (string)row["LocationName"];
            radiusInMeters = (int)row["RadiusMeters"];
            //createdDateTime = (int)row["CreatedDateTime"];



            SqlGeography location = (SqlGeography)row["Location"];

            lat = (double)location.Lat;
            lng = (double)location.Long;
        }


        public void CreateInDB(SqlConnection con, long businessID)
        {
            locationID = 0;
            isAprovedByAdmin = false;

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLocationCreate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.Add(new SqlParameter("@Location", SqlGeography.Point(lat, lng, 4326)) { UdtTypeName = "Geography" });
                cmd.Parameters.AddWithValue("@RadiusMeters", radiusInMeters);
                cmd.Parameters.AddWithValue("@LocationAddress", address);
                cmd.Parameters.AddWithValue("@LocationName", name);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@LocationID";
                outputParameter.SqlDbType = SqlDbType.BigInt;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                locationID = long.Parse(outputParameter.Value.ToString());
                isAprovedByAdmin = false;
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

        public void UpdateInDB(SqlConnection con, long businessID)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLocationUpdate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LocationID", locationID);
                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.Add(new SqlParameter("@Location", SqlGeography.Point(lat, lng, 4326)) { UdtTypeName = "Geography" });
                cmd.Parameters.AddWithValue("@RadiusMeters", radiusInMeters);
                cmd.Parameters.AddWithValue("@LocationAddress", address);
                cmd.Parameters.AddWithValue("@LocationName", name);

                cmd.ExecuteNonQuery();
            }
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

                cmd.Parameters.AddWithValue("@LocationID", locationID);
                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.AddWithValue("@Approve", approve);
                cmd.Parameters.AddWithValue("@LoginID", adminLoginID);

                cmd.ExecuteNonQuery();
            }
        }

    }
}
