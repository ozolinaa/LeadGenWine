using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Lead
{
    public class FieldGroup
    {
        public int ID { get; set; }

        [Required]
        public string code { get; set; }
        public string title { get; set; }
        public List<FieldItem> fields { get; set; }

        public FieldGroup() { }

        public FieldGroup(DataRow row)
        {
            ID = (int)row["GroupID"];
            code = row["GroupCode"].ToString();
            title = row["GroupTitle"].ToString();
        }


        public static void InitializeFieldGroups(DataTable fieldGroupDataTable, List<FieldGroup> fieldGroups)
        {
            //List<FieldGroup> fieldGroups = new List<FieldGroup>();
            using (DataTable dt = fieldGroupDataTable.DefaultView.ToTable(true, "GroupID", "GroupCode", "GroupTitle"))
            {
                foreach (DataRow fieldGroupRow in dt.Rows)
                {
                    // BEGIN Initialize Field Groups
                    FieldGroup fieldGroup = fieldGroups.FirstOrDefault(x => x.ID == (int)fieldGroupRow["GroupID"]);
                    if (fieldGroup == null)
                    {
                        fieldGroup = new FieldGroup(fieldGroupRow);
                        fieldGroups.Add(fieldGroup);
                    }

                    if (fieldGroup.fields == null)
                        fieldGroup.fields = new List<FieldItem>();
                    // END Initialize Field Groups

                    // BEGIN Initialize Fiels For Each Field Group
                    foreach (DataRow fieldRow in fieldGroupDataTable.Select(String.Format("GroupID = {0}", fieldGroupRow["GroupID"])))
                    {
                        FieldItem fieldItem = fieldGroup.fields.FirstOrDefault(x => x.ID == (int)fieldRow["FieldID"]);
                        if (fieldItem == null)
                        {
                            fieldItem = new FieldItem();
                            fieldGroup.fields.Add(fieldItem);
                        }
                        fieldItem.ParseFieldValueFromDataRow(fieldRow);
                    }
                    // END Initialize Fiels For Each Field Group
                }
            }
        }


        public bool UpdateInDB(SqlConnection con)
        {
            bool result = false;
            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadFieldStructureGroupInsertOrUpdate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@GroupID", ID);
                cmd.Parameters.AddWithValue("@GroupCode", code);
                cmd.Parameters.AddWithValue("@GroupTitle", String.IsNullOrEmpty(title) ? (object)DBNull.Value : title);

                SqlParameter returnParameter = cmd.Parameters.Add("RetVal", SqlDbType.Bit);
                returnParameter.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(returnParameter.Value);
            }
            return result;
        }
    }
}
