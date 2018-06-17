using LeadGen.Code.Helpers;
using LeadGen.Code.Taxonomy;
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
    public class NotificationSettings
    {
        public enum Frequency { Immediate, Hourly, Daily, DoNotNotify }
        public static Dictionary<int, Frequency> FrequencyDictionary = new Dictionary<int, Frequency> {
            { 1, Frequency.Immediate },
            { 2, Frequency.Hourly },
            { 3, Frequency.Daily },
            { 4, Frequency.DoNotNotify }
        };
        public static Dictionary<Frequency, string> FrequencyNameDictionary = new Dictionary<Frequency, string> {
            { Frequency.Immediate, "Immediate"},
            { Frequency.Daily, "Daily"},
            { Frequency.DoNotNotify, "Do Not Notify"}
        };
        public class NotificationEmail
        {
            [EmailAddress]
            public string address { get; set; }

            public NotificationEmail() { }
            public NotificationEmail(string address)
            {
                this.address = address;
            }
        }
        [Display(Name = "New Lead Notification Mode")]
        public Frequency frequency { get; set; }
        public List<NotificationEmail> emailList { get; set; }
        public NotificationEmail newNotificationEmail { get; set; }

        public NotificationSettings()
        { }

        public NotificationSettings(SqlConnection con, long businessID, Frequency frequency)
        {
            this.frequency = frequency;
            LoadEmailList(con, businessID);
        }

        public void LoadEmailList(SqlConnection con, long businessID)
        {
            emailList = new List<NotificationEmail>();
            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.Notification.Email.Select]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@businessID", businessID);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    if (!String.IsNullOrEmpty(row["Email"].ToString()))
                        emailList.Add(new NotificationEmail(row["Email"].ToString()));
                }
            }
        }

        public static bool EmailAdd(SqlConnection con, long businessID, string email )
        {
            bool result = false;
            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.Notification.Email.Insert]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@businessID", businessID);
                cmd.Parameters.AddWithValue("@email", email);

                SqlParameter returnParameter = cmd.Parameters.Add("RetVal", SqlDbType.Bit);
                returnParameter.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(returnParameter.Value);
            }
            return result;
        }

        public static bool EmailRemove(SqlConnection con, long businessID, string email)
        {
            bool result = false;
            if (String.IsNullOrEmpty(email))
                return result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.Notification.Email.Delete]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@businessID", businessID);
                cmd.Parameters.AddWithValue("@email", email);

                SqlParameter returnParameter = cmd.Parameters.Add("RetVal", SqlDbType.Bit);
                returnParameter.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(returnParameter.Value);
            }
            return result;
        }

        public static bool FrequencyTryUpdate(SqlConnection con, long businessID, Frequency newFrequency)
        {
            bool result = false;
            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.Notification.Frequency.Update]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@businessID", businessID);
                cmd.Parameters.AddWithValue("@frequencyID", FrequencyDictionary.FirstOrDefault(x => x.Value == newFrequency).Key);

                SqlParameter returnParameter = cmd.Parameters.Add("RetVal", SqlDbType.Bit);
                returnParameter.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(returnParameter.Value);
            }
            return result;
        }
    }


}
