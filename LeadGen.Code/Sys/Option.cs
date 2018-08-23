using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace LeadGen.Code.Sys
{
    public class Option
    {
        public string key { get; set; }

        public string value { get; set; }

        public Option() {}

        public Option(DataRow row)
        {
            key = row["OptionKey"].ToString();
            value = row["OptionValue"].ToString();
        }

        public static Dictionary<string, Option> SelectFromDB(SqlConnection con, string optinonKey = "")
        {
            List<Option> optionList = new List<Option>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[SysOptionSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@OptionKey", string.IsNullOrEmpty(optinonKey) ? (object)DBNull.Value : optinonKey);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                    optionList.Add(new Option(row));
            }

            if (optionList.Any() == false && string.IsNullOrEmpty(optinonKey) == false)
                optionList.Add(new Option() { key = optinonKey, value = "" });

            return optionList.ToDictionary(x => x.key, x => x);
        }

        public void Update(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[SysOptionInsertOrUpdate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@OptionKey", key);
                cmd.Parameters.AddWithValue("@OptionValue", (object)value ?? "");

                cmd.ExecuteNonQuery();
            }
        }

        public enum SettingKey
        {
            AzureStorageConnectionString,
            AzureStorageHostName,

            EmailFromAddress,
            EmailFromName,
            EmailReplyToAddress,
            EmailSmtpHost,
            EmailSmtpPort,
            EmailSmtpUserName,
            EmailSmtpPassword,
            EmailSmtpEnableSsl,
            EmailSmtpSendIntervalMilliseconds,

            GoogleMapsAPIKey,

            LeadApprovalLocationEnabled,
            LeadApprovalPermissionEnabled,
            LeadSystemFeeDefaultPercent,
            LeadFieldMappingEmail,
            LeadFieldMappingDateDue,
            LeadFieldMappingLocationZip,
            LeadFieldMappingLocationRadius,

            SystemAccessToken
        };


    }
}
