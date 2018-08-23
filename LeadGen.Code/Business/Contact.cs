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
    public class Contact
    {
        [Display(Name = "Name")]
        public string name { get; set; }

        [Display(Name = "Phone")]
        public string phone { get; set; }

        [Display(Name = "Skype")]
        public string skype { get; set; }

        [EmailAddress]
        [Display(Name = "E-Mail")]
        public string email { get; set; }


        public Contact()
        {
        }
        public Contact(DataRow row)
        {
            name = row["ContactName"].ToString();
            phone = row["ContactPhone"].ToString();
            skype = row["ContactSkype"].ToString();
            email = row["ContactEmail"].ToString();
        }

        public void Update(SqlConnection con, long businessID)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessUpdateContact]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@businessID", businessID);
                cmd.Parameters.AddWithValue("@name", String.IsNullOrEmpty(name) ? (object)DBNull.Value : name);
                cmd.Parameters.AddWithValue("@email", String.IsNullOrEmpty(email) ? (object)DBNull.Value : email);
                cmd.Parameters.AddWithValue("@phone", String.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                cmd.Parameters.AddWithValue("@skype", String.IsNullOrEmpty(skype) ? (object)DBNull.Value : skype);

                cmd.ExecuteNonQuery();
            }
        }
    }
}
