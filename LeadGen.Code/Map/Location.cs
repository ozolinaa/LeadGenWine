using Microsoft.SqlServer.Types;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Map
{
    public class Location
    {
        public long ID { get; set; }
        public double Lat { get; set; }
        public double Lng { get; set; }
        public int AccuracyMeters { get; set; }
        public int RadiusMeters { get; set; }
        public string StreetAddress { get; set; }
        public string City { get; set; }
        public string Region { get; set; }
        public string Country { get; set; }
        public string PostalCode { get; set; }
        public int Zoom { get; set; }
        public string Name { get; set; }
        public DateTime CreatedDateTime { get; set; }
        public DateTime? UpdatedDateTime { get; set; }

        public long CreateInDB(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[LocationCreate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add(new SqlParameter("@Location", Microsoft.SqlServer.Types.SqlGeography.Point(Lat, Lng, 4326)) { UdtTypeName = "Geography" });
                cmd.Parameters.AddWithValue("@AccuracyMeters", AccuracyMeters);
                cmd.Parameters.AddWithValue("@RadiusMeters", RadiusMeters);
                cmd.Parameters.AddWithValue("@StreetAddress", string.IsNullOrEmpty(StreetAddress) ? (object)DBNull.Value : StreetAddress);
                cmd.Parameters.AddWithValue("@PostalCode", string.IsNullOrEmpty(PostalCode) ? (object)DBNull.Value : PostalCode);
                cmd.Parameters.AddWithValue("@City", string.IsNullOrEmpty(City) ? (object)DBNull.Value : City);
                cmd.Parameters.AddWithValue("@Region", string.IsNullOrEmpty(Region) ? (object)DBNull.Value : Region);
                cmd.Parameters.AddWithValue("@Country", string.IsNullOrEmpty(Country) ? (object)DBNull.Value : Country);
                cmd.Parameters.AddWithValue("@Zoom", Zoom > 0 ? Zoom : (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Name", string.IsNullOrEmpty(Name) ? (object)DBNull.Value : Name);

                SqlParameter LocationIDParameter = cmd.Parameters.Add("@LocationId", SqlDbType.BigInt);
                LocationIDParameter.Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();

                ID = (long)LocationIDParameter.Value;
            }
            return ID;
        }

        public void UpdateInDB(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[LocationUpdate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LocationID", ID);
                cmd.Parameters.Add(new SqlParameter("@Location", Microsoft.SqlServer.Types.SqlGeography.Point(Lat, Lng, 4326)) { UdtTypeName = "Geography" });
                cmd.Parameters.AddWithValue("@AccuracyMeters", AccuracyMeters);
                cmd.Parameters.AddWithValue("@RadiusMeters", RadiusMeters);
                cmd.Parameters.AddWithValue("@StreetAddress", string.IsNullOrEmpty(StreetAddress) ? (object)DBNull.Value : StreetAddress);
                cmd.Parameters.AddWithValue("@PostalCode", string.IsNullOrEmpty(PostalCode) ? (object)DBNull.Value : PostalCode);
                cmd.Parameters.AddWithValue("@City", string.IsNullOrEmpty(City) ? (object)DBNull.Value : City);
                cmd.Parameters.AddWithValue("@Region", string.IsNullOrEmpty(Region) ? (object)DBNull.Value : Region);
                cmd.Parameters.AddWithValue("@Country", string.IsNullOrEmpty(Country) ? (object)DBNull.Value : Country);
                cmd.Parameters.AddWithValue("@Zoom", Zoom > 0 ? Zoom : (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Name", string.IsNullOrEmpty(Name) ? (object)DBNull.Value : Name);


                cmd.ExecuteNonQuery();
            }
        }

        public Location()
        {

        }

        public Location(SqlDataReader row)
        {
            ID = (long)row["LocationID"];
            SqlGeography sqlLocation = (SqlGeography)row["Location"];
            Lat = (double)sqlLocation.Lat;
            Lng = (double)sqlLocation.Long;
            AccuracyMeters = (int)row["AccuracyMeters"];
            RadiusMeters = (int)row["RadiusMeters"];
            StreetAddress = row["StreetAddress"].ToString();
            City = row["City"].ToString();
            Region = row["Region"].ToString();
            Country = row["Country"].ToString();
            PostalCode = row["PostalCode"].ToString();
            Zoom = Int32.Parse(row["Zoom"].ToString());
            Name = row["Name"].ToString();
            CreatedDateTime = (DateTime)row["CreatedDateTime"];
            if (row["UpdatedDateTime"] != DBNull.Value)
                UpdatedDateTime = (DateTime)row["UpdatedDateTime"];
        }

    }
}
