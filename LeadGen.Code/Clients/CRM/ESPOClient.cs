using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using MySql.Data.MySqlClient;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

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

            string query = @"select id, `name`, location_parent_id, lat, lng, radius_meters, term_u_r_l, deleted FROM location";
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
                        string term_url = reader["term_u_r_l"].ToString();

                        result.Add(id,
                            new ESPOLocation() {
                                ID = id,
                                Name = name,
                                ParentID = location_parent_id,
                                Lat = lat,
                                Lng = lng,
                                RadiusMeters = radius_meters,
                                TermURL = term_url,
                                Active = !deleted
                            }
                        ); ;
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

        private List<Location> getLocationsByOrgId(string orgId)
        {
            if (!organizationLocationMap.ContainsKey(orgId))
                return new List<Location>();
            return organizationLocationMap[orgId].Select(x => locations[x].GetLocation(locations)).ToList();
        }

        private IEnumerable<Organization> _getOrganizations(string where = null)
        {
            string query = @"SELECT a.id, a.deleted, a.`name`, 
                a.website, a.website_public, p.`name` as phone_number, phone_number_public, a.lg_post_i_d, a.lg_business_i_d, 
                e.`name` as email, a.email_public, IFNULL(e.opt_out,0) as crm_email_opt_out, a.lg_opt_out_lead_notifications
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
                            yield return _createOrganization(reader);
                        }
                    }
                }

            }
        }

        private string _sanitizeURL(string url)
        {
            if (string.IsNullOrEmpty(url))
                return null;
            if (url.ToLower().StartsWith("http://") || url.ToLower().StartsWith("https://"))
                return url;
            return "http://" + url;
        }

        private Organization _createOrganization(MySqlDataReader reader)
        {
            return new Organization()
            {
                ID = reader["id"].ToString(),
                isActive = !Convert.ToBoolean(reader["deleted"]),
                Name = reader["name"].ToString(),
                EmailNotification = reader["email"].ToString(),
                EmailPublic = reader["email_public"].ToString(),
                PhoneNotification = reader["phone_number"].ToString(),
                PhonePublic = reader["phone_number_public"].ToString(),
                WebsitePublic = _sanitizeURL(reader["website_public"].ToString()),
                WebsiteOther = _sanitizeURL(reader["website"].ToString()),
                OptOutEmailPromoNotifications = Convert.ToBoolean(reader["crm_email_opt_out"]),
                OptOutEmailLeadNotifications = Convert.ToBoolean(reader["lg_opt_out_lead_notifications"]),
                LeadGenBusinessID = reader["lg_business_i_d"] == DBNull.Value ? null : (int?)reader["lg_business_i_d"],
                LeadGenPostID = reader["lg_post_i_d"] == DBNull.Value ? null : (int?)reader["lg_post_i_d"],
                Locations = getLocationsByOrgId(reader["id"].ToString())
            };
        }

        public IEnumerable<Location> GetLocations()
        {
            return locations.Values.Select(x => x.GetLocation(locations));
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
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
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
            public string TermURL { get; set; }

            public Location GetLocation(Dictionary<string, ESPOLocation> locations)
            {
                return new Location() { 
                    ID = ID,
                    Lat = Lat,
                    Lng = Lng,
                    RadiusMeters = RadiusMeters,
                    Name = Name,
                    TermURL = TermURL,
                    Parent = string.IsNullOrEmpty(ParentID) ? null : locations[ParentID].GetLocation(locations),
                    Zoom = 8 
                };
            }
        }



        public string InsertOrganization(Organization org)
        {
            if (string.IsNullOrEmpty(org.Name))
                throw new Exception("Org name is empty");
            string emailId = InsertEmail(org.EmailNotification);
            string phoneId = InsertPhone(org.PhoneNotification);
            string orgId = InsertOrganizationRow(org);
            if (!string.IsNullOrEmpty(emailId))
                LinkOrgIdWithEmailId(orgId, emailId);
            if (!string.IsNullOrEmpty(phoneId))
                LinkOrgIdWithPhoneId(orgId, phoneId);

            if (org.Locations == null)
                org.Locations = new List<Location>();
            foreach (Location location in org.Locations)
                LinkOrgIdWithLocationId(orgId, location.ID);
            organizationLocationMap.Add(orgId, org.Locations.Select(x => x.ID).ToList());

            return orgId;
        }





        private string InsertEmail(string email)
        {
            if (string.IsNullOrEmpty(email))
                return null;

            email = SanitizeEmail(email);
            string id = GetEmailID(email);
            if (!string.IsNullOrEmpty(id))
                return id;
            id = GenerateID();
            string query = string.Format("INSERT INTO email_address SET `id` = '{0}', `name` = '{1}', `lower` = '{2}', `deleted` = 0, `invalid` = 0, `opt_out` = 0",
                id,
                email,
                email.ToLower()
                );
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
            return id;
        }

        private string SanitizeEmail(string email)
        {
            email = email.ToLower();
            var addr = new System.Net.Mail.MailAddress(email);
            if (addr.Address != email)
                throw new Exception("Invalid Email");
            return email;
        }

        private string GetEmailID(string email)
        {
            string query = $"SELECT id FROM email_address WHERE `lower` = '{email}'";
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        return reader["id"].ToString();
                    }
                }
            }
            return null;
        }

        private void LinkOrgIdWithEmailId(string orgId, string emailId)
        {
            string query = string.Format("INSERT INTO entity_email_address SET `entity_id` = '{0}', `email_address_id` = '{1}', `entity_type` = 'Account', `primary` = 1, `deleted` = 0",
                orgId,
                emailId
                );
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
        }

        private string InsertPhone(string number)
        {
            if (string.IsNullOrEmpty(number))
                return null;

            string id = GetPhoneID(number);
            if (!string.IsNullOrEmpty(id))
                return id;
            id = GenerateID();
            string numeric = string.Join("", Regex.Split(number, @"[^\d]"));

            if (string.IsNullOrEmpty(number))
                throw new Exception("Ivalid phone number");

            string query = string.Format("INSERT INTO phone_number SET `id` = '{0}', `name` = '{1}', `numeric` = '{2}', `type` = 'Office', `deleted` = 0, `invalid` = 0, `opt_out` = 0",
                id,
                number,
                numeric
                );
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
            return id;
        }

        private string GetPhoneID(string number)
        {
            string numeric = string.Join("", Regex.Split(number, @"[^\d]"));
            string query = $"SELECT id FROM phone_number WHERE `numeric` = '{numeric}'";
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        return reader["id"].ToString();
                    }
                }
            }
            return null;
        }

        private void LinkOrgIdWithPhoneId(string orgId, string phoneId)
        {
            string query = string.Format("INSERT INTO entity_phone_number SET `entity_id` = '{0}', `phone_number_id` = '{1}', `entity_type` = 'Account', `primary` = 1, `deleted` = 0",
                orgId,
                phoneId
                );
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
        }

        public void LinkOrgIdWithLocationId(string orgId, string LocationId)
        {
            string query = string.Format("INSERT INTO location_account SET `account_id` = '{0}', `location_id` = '{1}', `deleted` = 0",
                orgId,
                LocationId
                );
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
        }


        private string InsertOrganizationRow(Organization org)
        {
            string id = GenerateID();
            string queryFormat = @"INSERT INTO account SET 
`id` = '{0}', `name` = '{1}', `lg_post_i_d` = {2}, `lg_business_i_d` = {3}, 
`website` = {4}, `website_public` = {5}, `phone_number_public` = {6}, `email_public` = {7}, 
`created_at` = '{8}', `modified_at` = '{8}', `created_by_id` = '{9}', `modified_by_id` = '{9}', `assigned_user_id` = '{9}', `deleted` = 0";

            string query = string.Format(queryFormat,
                id, org.Name, 
                org.LeadGenPostID == null ? "NULL" : "'"+ org.LeadGenPostID + "'",
                org.LeadGenBusinessID == null ? "NULL" : "'" + org.LeadGenBusinessID + "'",
                string.IsNullOrEmpty(org.WebsiteOther) ? "NULL" : "'" + org.WebsiteOther + "'",
                string.IsNullOrEmpty(org.WebsitePublic) ? "NULL" : "'" + org.WebsitePublic + "'",
                string.IsNullOrEmpty(org.PhonePublic) ? "NULL" : "'" + org.PhonePublic + "'",
                string.IsNullOrEmpty(org.EmailPublic) ? "NULL" : "'" + org.EmailPublic + "'",
                DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), "1");
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
            return id;
        }

        private static string GenerateID()
        {
            // PHP uniqid() . substr(md5(rand()), 0, 4);
            Random random = new Random(DateTime.Now.Millisecond);
            return GetPHPUniqID() + GetMd5Hash(random.Next(Int32.MinValue, Int32.MaxValue).ToString()).Substring(0, 4);
        }

        private static string GetPHPUniqID()
        {
            var ts = (DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0));
            double t = ts.TotalMilliseconds / 1000;

            int a = (int)Math.Floor(t);
            int b = (int)((t - Math.Floor(t)) * 1000000);

            return a.ToString("x8") + b.ToString("x5");
        }

        private static string GetMd5Hash(string input)
        {
            using (MD5 md5Hash = MD5.Create())
            {
                // Convert the input string to a byte array and compute the hash.
                byte[] data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(input));

                // Create a new Stringbuilder to collect the bytes
                // and create a string.
                StringBuilder sBuilder = new StringBuilder();

                // Loop through each byte of the hashed data 
                // and format each one as a hexadecimal string.
                for (int i = 0; i < data.Length; i++)
                {
                    sBuilder.Append(data[i].ToString("x2"));
                }

                // Return the hexadecimal string.
                return sBuilder.ToString();
            }
        }


    }
}
