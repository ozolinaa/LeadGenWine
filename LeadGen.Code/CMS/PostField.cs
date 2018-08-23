using LeadGen.Code.Helpers;
using LeadGen.Code.Map;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.CMS
{
    public class PostField
    {

        public enum FieldType
        {
            Text = 1,
            Datetime = 2,
            Bool = 3,
            Number = 4,
            Location = 5
        };

        public int ID { get; set; }
        public string code { get; set; }
        public string labelText { get; set; }

        public FieldType type { get; set; }

        public string fieldText { get; set; }
        public DateTime? fieldDatetime { get; set; }
        public bool fieldBool { get; set; }
        public long? fieldNumber { get; set; }
        public Location location { get; set; }

        public object fieldValue {
            get {
                switch (type)
                {
                    case FieldType.Text:
                        return fieldText;
                    case FieldType.Datetime:
                        return fieldDatetime;
                    case FieldType.Bool:
                        return fieldBool;
                    case FieldType.Number:
                        return fieldNumber;
                    case FieldType.Location:
                        return location;
                    default:
                        return null;
                }
            }
        }



        public PostField() { }

        public PostField(DataRow row)
        {
            ID = (int)row["FieldID"];
            code = row["FieldCode"].ToString();
            labelText = row["FieldLabelText"].ToString();

            type = (FieldType)(int)row["FieldTypeID"]; 
            //FieldType parsedType;
            //if (Enum.TryParse<FieldType>(row["FieldTypeName"].ToString(), out parsedType))
            //    type = parsedType;

            switch (type)
            {
                case FieldType.Text:
                    fieldText = row["TextValue"].ToString();
                    break;
                case FieldType.Datetime:
                    if (row["DatetimeValue"] == DBNull.Value)
                    {
                        fieldDatetime = null;
                    }
                    else
                    {
                        fieldDatetime = Convert.ToDateTime(row["DatetimeValue"]);
                    }
                    break;
                case FieldType.Bool:
                    fieldBool = false;
                    bool parsedBool = false;
                    if (bool.TryParse(row["BoolValue"].ToString(), out parsedBool))
                        fieldBool = parsedBool;
                    break;
                case FieldType.Number:
                    if (row["NumberValue"] == DBNull.Value)
                    {
                        fieldNumber = null;
                    }
                    else
                    {
                        fieldNumber = (long)row["NumberValue"];
                    }
                    break;
                case FieldType.Location:
                    if (row["TextValue"] == DBNull.Value)
                    {
                        location = null;
                    }
                    else
                    {
                        location = JsonConvert.DeserializeObject<Location>((string)row["TextValue"]);
                    }
                    break;
            }

        }





        public bool SaveToDB(SqlConnection con, long postID)
        {
            bool result = false;

            string TextValue = String.Empty;

            switch (type)
            {
                case FieldType.Text:
                    TextValue = fieldText;
                    break;
                case FieldType.Datetime:
                    break;
                case FieldType.Bool:
                    break;
                case FieldType.Number:
                    break;
                case FieldType.Location:
                    TextValue = JsonConvert.SerializeObject(location);
                    break;
                default:
                    break;
            }
            //if (type == FieldType.Location)


            using (SqlCommand cmd = new SqlCommand("[dbo].[CMSPostFieldValueInsertOrUpdate]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PostID", postID);
                cmd.Parameters.AddWithValue("@FieldID", ID);
                cmd.Parameters.AddWithValue("@TextValue", String.IsNullOrEmpty(TextValue) ? (object)DBNull.Value : TextValue );
                cmd.Parameters.AddWithValue("@DatetimeValue", type == FieldType.Datetime ? (object)fieldDatetime ?? DBNull.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@BoolValue", type == FieldType.Bool ? fieldBool : (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@NumberValue", type == FieldType.Number ? (object)fieldNumber ?? DBNull.Value : DBNull.Value);

                SqlParameter returnParameter = cmd.Parameters.Add("RetVal", SqlDbType.Bit);
                returnParameter.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(returnParameter.Value);
            }
            return result;
        }
    }
}
