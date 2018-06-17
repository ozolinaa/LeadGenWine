using LeadGen.Code.CMS;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace LeadGen.Importer.WordPress
{
    public class WpBusiness
    {
        public ulong ID { get; set; }
        public string email { get; set; }
        public DateTime registeredDateTime { get; set; }

        public string public_company_name { get; set; }
        public string represent_fio { get; set; }
        public string represent_tel { get; set; }
        public string represent_email { get; set; }
        public string represent_skype { get; set; }
        public string represent_site { get; set; }
        public string notification_mode { get; set; }
        public string notification_email1 { get; set; }
        public string notification_email2 { get; set; }
        public string jur_name { get; set; }
        public string jur_inn { get; set; }
        public string jur_kpp { get; set; }
        public string jur_address { get; set; }
        public string real_address { get; set; }

        public List<string> cities_requested { get; set; }
        public List<string> cities_internet_requested { get; set; }
        public List<string> cities_approved { get; set; }
        public List<string> cities_internet_approved { get; set; }

        public WpBusiness() { }

        public WpBusiness(DataRow row)
        {
            ID = (ulong)row["ID"];
            email = row["user_email"].ToString().ToLower().Trim();
            registeredDateTime = (DateTime)row["user_registered"];
            public_company_name = row["field_public_company_name"].ToString().Trim();
            represent_fio = row["field_company_represent_fio"].ToString().Trim();
            represent_tel = row["field_company_represent_tel"].ToString().Trim();
            represent_email = row["field_company_represent_email"].ToString().Trim();
            represent_skype = row["field_company_represent_skype"].ToString().Trim();
            represent_site = row["field_company_represent_site"].ToString().Trim();
            notification_mode = row["field_company_notification_mode"].ToString().Trim();
            notification_email1 = row["field_company_notification_email1"].ToString().Trim();
            notification_email2 = row["field_company_notification_email2"].ToString().Trim();
            jur_name = row["field_company_jur_name"].ToString().Trim();
            jur_inn = row["field_company_jur_inn"].ToString().Trim();
            jur_kpp = row["field_company_jur_kpp"].ToString().Trim();
            jur_address = row["field_company_jur_address"].ToString().Trim();
            real_address = row["field_company_real_address"].ToString().Trim();
        }

        public static List<WpBusiness> SelectFromDB(MySqlConnection conn, string prefix)
        {
            string[] fields = new string[] {
                "public_company_name",
                "company_represent_fio",
                "company_represent_tel",
                "company_represent_email",
                "company_represent_skype",
                "company_represent_site",
                "company_notification_mode",
                "company_notification_email1",
                "company_notification_email2",
                "company_jur_name",
                "company_jur_inn",
                "company_jur_kpp",
                "company_jur_address",
                "company_real_address"
            };

            List<WpBusiness> results = new List<WpBusiness>();

            string sql = "SELECT u.ID, u.user_email, ";

            if (fields != null)
                foreach (string field in fields)
                    sql += string.Format("field_{0}.meta_value as field_{0}, ", field);

            sql += "u.user_registered ";

            sql += "FROM wp_" + prefix + "users u ";

            if (fields != null)
                foreach (string field in fields)
                    sql += string.Format("LEFT OUTER JOIN wp_" + prefix + "usermeta field_{0} ON field_{0}.user_id = u.ID AND field_{0}.meta_key = '{0}' ", field);

            //sql += "WHERE u.ID = 248 ";
            sql += "GROUP BY u.ID ";
            //sql += "LIMIT 10";

            MySqlDataAdapter adapter = new MySqlDataAdapter(sql, conn);
            DataSet dataset = new DataSet("TableData");
            adapter.Fill(dataset);

            foreach (DataRow row in dataset.Tables[0].Rows)
            {
                WpBusiness business = new WpBusiness(row);

                business.cities_approved = SelectBusinessTermUrlsByMetaString(conn, prefix, business.ID, "company_cities_id");
                business.cities_requested = SelectBusinessTermUrlsByMetaString(conn, prefix, business.ID, "company_ordered_cities_id");
                business.cities_internet_approved = SelectBusinessTermUrlsByMetaString(conn, prefix, business.ID, "company_internet_cities_id");
                business.cities_internet_requested = SelectBusinessTermUrlsByMetaString(conn, prefix, business.ID, "company_ordered_internet_cities_id");

                results.Add(business);
                Console.WriteLine(string.Format("Loaded WpBusiness ID:{0} Name:{1}", business.ID, business.public_company_name));
            }

            return results;
        }

        private static List<string> SelectBusinessTermUrlsByMetaString(MySqlConnection conn, string prefix, ulong businessID, string metaKey )
        {
            List<string> termUrls = new List<string>();

            string sql = "SELECT t.slug as termSlug " +
                "FROM wp_" + prefix + "usermeta termIdsStr " +
                "LEFT OUTER JOIN wp_" + prefix + "term_taxonomy tt ON FIND_IN_SET(tt.term_id, termIdsStr.meta_value) " +
                "LEFT OUTER JOIN wp_" + prefix + "terms t ON t.term_id = tt.term_id " +
                "WHERE termIdsStr.user_id = " + businessID + " " +
                "AND termIdsStr.meta_key = '"+ metaKey + "' " +
                "AND t.term_id IS NOT NULL";

            MySqlDataAdapter adapter = new MySqlDataAdapter(sql, conn);
            DataSet dataset = new DataSet("TableData");
            adapter.Fill(dataset);

            foreach (DataRow row in dataset.Tables[0].Rows)
                termUrls.Add(CMSManager.ClearURL(HttpUtility.UrlDecode(row["termSlug"].ToString())));

            return termUrls;
        }

    }
}
