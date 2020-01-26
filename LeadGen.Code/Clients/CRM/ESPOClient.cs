using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using MySql.Data.MySqlClient;

namespace LeadGen.Code.Clients.CRM
{
    public class ESPOClient : ICRMClient
    {
        private string connectionString = null;
        public MySqlConnection conn = null;

        private Dictionary<string, ESPOLocation> locations = null;
        private Dictionary<string, List<string>> organizationLocationMap = null;

        public ESPOClient(string connectionString)
        {
            this.connectionString = connectionString;
            conn = new MySqlConnection(connectionString);
            conn.Open();

            MySqlCommand cmd = new MySqlCommand("SET NAMES 'utf8'", conn);
            cmd.ExecuteNonQuery();

            locations = _getAllLocations();
            organizationLocationMap = getOrganizationLocationMap();
        }

        private Dictionary<string, ESPOLocation> _getAllLocations()
        {
            Dictionary<string, ESPOLocation> result = new Dictionary<string, ESPOLocation>();

            string query = @"select id, `name`, location_parent_id, lat, lng, radius_meters, deleted FROM location";
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string id = reader["id"].ToString();
                        string name = reader["name"].ToString();
                        string location_parent_id = reader["location_parent_id"].ToString();
                        bool deleted = Convert.ToBoolean(reader["deleted"]);
                        double lat = (double)reader["lat"];
                        double lng = (double)reader["lng"];
                        int radius_meters = (int)reader["radius_meters"];


                        result.Add(id, 
                            new ESPOLocation() { 
                                ID = id, 
                                Name = name, 
                                ParentID = location_parent_id, 
                                Lat = lat,
                                Lng = lng,
                                RadiusMeters = radius_meters,
                                Active = !deleted}
                        );
                    }
                }
            }

            return result;
        }

        private Dictionary<string, List<string>> getOrganizationLocationMap()
        {
            Dictionary<string, List<string>> result = new Dictionary<string, List<string>>();

            string query = @"select account_id, location_id from location_account";

            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string id = reader["account_id"].ToString();
                        string location_id = reader["location_id"].ToString();

                        if (result.ContainsKey(id))
                            result[id].Add(location_id);
                        else
                            result.Add(id, new List<string>() { location_id });
                    }
                }
            }

            return result;
        }

        private IEnumerable<Location> getLocationsByOrgId(string orgId)
        {
            if (!organizationLocationMap.ContainsKey(orgId))
                return new List<Location>();
            return organizationLocationMap[orgId].Select(x => locations[x].GetLocation());
        }

        private IEnumerable<Organization> _getOrganizations (string where = null)
        {
            string query = @"SELECT a.id, a.deleted, a.`name`, a.website, p.`name` as phone, a.lg_post_i_d, a.lg_business_i_d, 
                e.`name` as email, IFNULL(e.opt_out,0) as crm_email_opt_out, a.lg_opt_out_lead_notifications
                FROM account a
                LEFT OUTER JOIN entity_email_address eea ON eea.entity_id = a.id AND eea.entity_type = 'account'
                LEFT OUTER JOIN email_address e ON e.id = eea.email_address_id
                LEFT OUTER JOIN entity_phone_number epn ON epn.entity_id = a.id AND eea.entity_type = 'account'
                LEFT OUTER JOIN phone_number p ON p.id = epn.phone_number_id AND p.`type` = 'Office'";
            if (!string.IsNullOrEmpty(where))
                query = query + " " + where;

            using (MySqlConnection new_conn = new MySqlConnection(connectionString))
            {
                new_conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(query, new_conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string id = reader["id"].ToString();
                            yield return new Organization()
                            {
                                ID = id,
                                isActive = !Convert.ToBoolean(reader["deleted"]),
                                Name = reader["name"].ToString(),
                                Email = reader["email"].ToString(),
                                Website = reader["website"].ToString(),
                                LeadGenBusinessID = reader["lg_business_i_d"] == DBNull.Value ? null : (int?)reader["lg_business_i_d"],
                                LeadGenPostID = reader["lg_post_i_d"] == DBNull.Value ? null : (int?)reader["lg_post_i_d"],
                                Phone = reader["phone"].ToString(),
                                OptOutEmailPromoNotifications = Convert.ToBoolean(reader["crm_email_opt_out"]),
                                OptOutEmailLeadNotifications = Convert.ToBoolean(reader["lg_opt_out_lead_notifications"]),
                                Locations = getLocationsByOrgId(id)
                            };
                        }
                    }
                }

            }
        }

        public IEnumerable<Organization> GetOrganizations()
        {
            return _getOrganizations();
        }

        public Organization GetOrganizationByID(string OrgID)
        {
            return _getOrganizations("where a.id == " + OrgID).FirstOrDefault();
        }

        public void SetPostID(string OrgID, long? PostID)
        {
            string query = string.Format("UPDATE account SET lg_post_i_d = {0} WHERE id = '{1}'",
                PostID.HasValue ? PostID.ToString() : "NULL",
                OrgID
                );
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
        }

        public void SetBusinessID(string OrgID, long? BusinessID)
        {
            string query = string.Format("UPDATE account SET lg_business_i_d = {0} WHERE id = '{1}'",
                BusinessID.HasValue ? BusinessID.ToString() : "NULL",
                OrgID
                );
            MySqlCommand cmd = new MySqlCommand(query, conn);
            cmd.ExecuteNonQuery();
        }

        public void SetOptOutEmailLeadNotifications(string OrgID, bool optOut)
        {
            string query = string.Format("UPDATE account SET lg_opt_out_lead_notifications = {0} WHERE id = '{1}'",
                optOut ? "1" : "0",
                OrgID
                );
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
        }

        public void Dispose()
        {
            if (conn == null)
                return;
            conn.Dispose();
        }

        private class ESPOLocation
        {
            public string ID { get; set; }
            public string Name { get; set; }
            public string ParentID { get; set; }
            public bool Active { get; set; }

            public double Lat { get; set; }
            public double Lng { get; set; }
            public int RadiusMeters { get; set; }

            public Location GetLocation()
            {
                return new Location() { Lat = Lat, Lng = Lng, RadiusMeters = RadiusMeters, Name = Name, Zoom = 8 };
            }
        }
    }
}
