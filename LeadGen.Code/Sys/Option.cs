using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace LeadGen.Code.Sys
{
    public class Option
    {
        public string key { get; set; }

        [AllowHtml]
        public string value { get; set; }

        public Option() {}

        public Option(DataRow row)
        {
            key = row["OptionKey"].ToString();
            value = row["OptionValue"].ToString();
        }

        public static List<Option> SelectFromDB(SqlConnection con, string optinonKey = "")
        {
            List <Option> optionList = new List<Option>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[Sys.Option.Select]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@OptionKey", string.IsNullOrEmpty(optinonKey) ? (object)DBNull.Value : optinonKey);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                    optionList.Add(new Option(row));
            }

            if (optionList.Count() == 0)
                optionList.Add(new Option() { key = optinonKey, value = "" });

            return optionList;
        }

        public void Update(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[Sys.Option.InsertOrUpdate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@OptionKey", key);
                cmd.Parameters.AddWithValue("@OptionValue", (object)value ?? "");

                cmd.ExecuteNonQuery();
            }
        }

        public enum LeadSettingKey
        {
            LeadSettingApprovalLocationEnabled,
            LeadSettingApprovalPermissionEnabled,
            LeadSettingFieldMappingEmail,
            LeadSettingFieldMappingDateDue,
            LeadSettingFieldMappingLocationZip,
            LeadSettingFieldMappingLocationRadius
        };


    }
}
