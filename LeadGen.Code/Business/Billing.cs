using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Business
{
    public class Billing
    {
        public long countryID { get; set; }
        [Display(Name = "Company Legal Name")]
        public string name { get; set; }

        public string code1 { get; set; }

        public string code2 { get; set; }

        [Display(Name = "Billing Address")]
        public string address { get; set; }

        public string bankName { get; set; }

        public string bankCode1 { get; set; }

        public string bankCode2 { get; set; }

        public string bankAccount { get; set; }

        public Billing()
        {
        }
        public Billing(DataRow row)
        {
            name = row["BillingName"].ToString();
            code1 = row["BillingCode1"].ToString();
            code2 = row["BillingCode2"].ToString();
            address = row["BillingAddress"].ToString();
        }

        public void Update(SqlConnection con, long businessID)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessUpdateBilling]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@businessID", businessID);
                cmd.Parameters.AddWithValue("@name", String.IsNullOrEmpty(name) ? (object)DBNull.Value : name);
                cmd.Parameters.AddWithValue("@code1", String.IsNullOrEmpty(code1) ? (object)DBNull.Value : code1);
                cmd.Parameters.AddWithValue("@code2", String.IsNullOrEmpty(code2) ? (object)DBNull.Value : code2);
                cmd.Parameters.AddWithValue("@address", String.IsNullOrEmpty(address) ? (object)DBNull.Value : address);

                cmd.ExecuteNonQuery();
            }
        }

        public override string ToString()
        {
            List<KeyValuePair<string, string>> parts = new List<KeyValuePair<string, string>>();
            parts.Add(new KeyValuePair<string, string>("name", name));
            parts.Add(new KeyValuePair<string, string>("code1", code1));
            parts.Add(new KeyValuePair<string, string>("code2", code2));
            parts.Add(new KeyValuePair<string, string>("address", address));

            //concatinate parts where value is not emplty and add key in front if key is not empty
            return string.Join(", ", parts.Where(x => string.IsNullOrEmpty(x.Value.ToString()) == false).Select(x => (x.Key == "" ? "" : x.Key + " ") + x.Value));
        }
    }
}
