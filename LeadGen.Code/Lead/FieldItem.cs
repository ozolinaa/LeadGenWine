using LeadGen.Code.Taxonomy;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace LeadGen.Code.Lead
{
    public enum FieldType {
        Textbox = 1,
        Dropdown,
        Checkbox,
        Radio,
        Boolean,
        Datetime,
        Number,
        Textarea
    };

    public class FieldItem
    {
        public int? ID { get; set; }
        public FieldType fieldType { get; set; }

        [Required]
        public string name { get; set; }

        [Required]
        public string code { get; set; }

        [Required]
        public string label { get; set; }

        [Required]
        public int? groupID { get; set; }

        public bool isRequired { get; set; }
        public bool isActive { get; set; }
        public bool isContact { get; set; }

        public string description { get; set; }

        public int? taxonomyID { get; set; }
        public long? termParentID { get; set; }
        public int? termDepthMaxLevel { get; set; }

        public string placeholder { get; set; }
        public string regularExpression { get; set; }
        public long? minValue { get; set; }
        public long? maxValue { get; set; }

        public List<Term> fieldTerms { get; set; }
        public long? termIDSelected { get; set; }

        public string fieldText { get; set; }
        public DateTime? fieldDatetime { get; set; }
        public bool fieldBool { get; set; }
        public long? fieldNumber { get; set; }

        public string stringValue
        {
            get
            {
                switch (fieldType)
                {
                    case FieldType.Textbox:
                        return fieldText;
                    case FieldType.Dropdown:
                        return (fieldTerms.FirstOrDefault(x => x.ID == termIDSelected) ?? new Term()).name;
                    case FieldType.Checkbox:
                        return string.Join(", ", fieldTerms.Where(x => x.isChecked == true).ToList().Select(x=>x.name));
                    case FieldType.Radio:
                        return (fieldTerms.FirstOrDefault(x => x.ID == termIDSelected) ?? new Term()).name;
                    case FieldType.Boolean:
                        return fieldBool ? "Да" : "Нет";
                    case FieldType.Datetime:
                        if (fieldDatetime == null)
                            return string.Empty;
                        return fieldDatetime.Value.ToShortDateString();
                    case FieldType.Number:
                        return fieldNumber.ToString();
                    default:
                        return null;
                }
            }
        }

        public KeyValuePair<string,string>? validationError
        {
            get
            {
                string fieldPrefix = "Поле";
                string requiredSuffix = "обязательно к заполнению";

                switch (fieldType)
                {
                    case FieldType.Textbox:
                        if (isRequired && String.IsNullOrEmpty(fieldText))
                            return new KeyValuePair<string, string>("fieldText", string.Format("{2} \"{0}\" {1}", name, requiredSuffix, fieldPrefix).Trim());
                        break;
                    case FieldType.Dropdown:
                        if (isRequired && termIDSelected == null)
                            return new KeyValuePair<string, string>("termIDSelected", string.Format("{2} \"{0}\" {1}", name, requiredSuffix, fieldPrefix).Trim());
                        break;
                    case FieldType.Checkbox:
                        if (isRequired && fieldTerms.Where(x => x.isChecked == true).Count() == 0)
                            return new KeyValuePair<string, string>("fieldTerms", string.Format("{2} \"{0}\" {1}", name, requiredSuffix, fieldPrefix).Trim());
                        break;
                    case FieldType.Radio:
                        if (isRequired && termIDSelected == null)
                            return new KeyValuePair<string, string>("termIDSelected", string.Format("{2} \"{0}\" {1}", name, requiredSuffix, fieldPrefix).Trim());
                        break;
                    case FieldType.Boolean:
                        if (isRequired && fieldBool == false)
                            return new KeyValuePair<string, string>("fieldBool", string.Format("{2} \"{0}\" {1}", name, requiredSuffix, fieldPrefix).Trim());
                        break;
                    case FieldType.Datetime:
                        if (isRequired && fieldDatetime == null)
                            return new KeyValuePair<string, string>("fieldDatetime", string.Format("{2} \"{0}\" {1}", name, requiredSuffix, fieldPrefix).Trim());
                        break;
                    case FieldType.Number:
                        if (isRequired && fieldNumber == null)
                            return new KeyValuePair<string, string>("fieldNumber", string.Format("{2} \"{0}\" {1}", name, requiredSuffix, fieldPrefix).Trim());
                        else if (minValue != null && fieldNumber < minValue)
                            return new KeyValuePair<string, string>("fieldNumber", string.Format("{3} \"{0}\" {1} {2}", name, "must be >= ", minValue, fieldPrefix).Trim());
                        else if (maxValue != null && fieldNumber > maxValue)
                            return new KeyValuePair<string, string>("fieldNumber", string.Format("{3} \"{0}\" {1} {2}", name, "must be <= ", maxValue, fieldPrefix).Trim());
                        break;
                }
                return null;
            }
        }

        private static FieldType[] scalarFieldTypes = new FieldType[] { FieldType.Boolean, FieldType.Datetime, FieldType.Number, FieldType.Textbox };


        public bool UpdateInDB(SqlConnection con, ref string errorMessage)
        {
            ID = null;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[Lead.Field.Structure.InsertOrUpdate]";

                cmd.Parameters.AddWithValue("@FieldTypeID", (int)fieldType);
                cmd.Parameters.AddWithValue("@FieldCode", code); 
                cmd.Parameters.AddWithValue("@GroupID", (int)groupID);
                cmd.Parameters.AddWithValue("@FieldName", name);
                cmd.Parameters.AddWithValue("@LabelText", label);
                cmd.Parameters.AddWithValue("@IsRequired", isRequired);
                cmd.Parameters.AddWithValue("@IsContact", isContact);
                cmd.Parameters.AddWithValue("@IsActive", isActive);
                cmd.Parameters.AddWithValue("@Placeholder", String.IsNullOrEmpty(placeholder) ? "" : placeholder);
                cmd.Parameters.AddWithValue("@RegularExpression", String.IsNullOrEmpty(regularExpression)? "" : regularExpression);
                cmd.Parameters.AddWithValue("@MinValue", (object)minValue ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@MaxValue", (object)maxValue ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TaxonomyID", (object)taxonomyID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TermParentID", (object)termParentID ?? DBNull.Value);

                SqlParameter FieldIDParameter = new SqlParameter();
                FieldIDParameter.ParameterName = "@FieldID";
                FieldIDParameter.SqlDbType = SqlDbType.Int;
                FieldIDParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(FieldIDParameter);

                SqlParameter ErrorMessageParameter = new SqlParameter();
                ErrorMessageParameter.ParameterName = "@ErrorMessage";
                ErrorMessageParameter.SqlDbType = SqlDbType.NVarChar;
                ErrorMessageParameter.Size = 255;
                ErrorMessageParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(ErrorMessageParameter);

                cmd.ExecuteNonQuery();

                errorMessage = ErrorMessageParameter.Value.ToString();
                if (FieldIDParameter.Value != DBNull.Value)
                    ID = (int)FieldIDParameter.Value;
            }

            return ID != null;
        }

        public bool SaveLeadFieldValueInDB(SqlConnection con, long leadID)
        {
            List<bool> results = new List<bool>();

            if (scalarFieldTypes.Contains(fieldType))
                results.Add(SaveLeadScalarFieldValue(con, leadID));
            else
            {
                //Before saving new values need to clear any existing values
                ClearLeadTaxonomyFieldValues(con, leadID);
                if (fieldType == FieldType.Checkbox)
                    foreach (var term in fieldTerms.Where(x=>x.isChecked == true))
                        results.Add(SaveLeadTaxonomyFieldValue(con, leadID, term.ID));
                if ((fieldType == FieldType.Dropdown || fieldType == FieldType.Radio) && termIDSelected != null)
                    results.Add(SaveLeadTaxonomyFieldValue(con, leadID, termIDSelected.Value));
            }
            //return true if there is NO false results
            return results.Where(x=>x == false).Count() == 0;
        }

        private bool SaveLeadScalarFieldValue(SqlConnection con, long leadID)
        {
            bool result = false;
            using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.Field.Value.Scalar.InsertOrUpdate]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@FieldID", ID);
                cmd.Parameters.AddWithValue("@TextValue", fieldType == FieldType.Textbox ? fieldText : (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@BoolValue", fieldType == FieldType.Boolean ? fieldBool : (object)DBNull.Value); 
                cmd.Parameters.AddWithValue("@DatetimeValue", fieldType == FieldType.Datetime ? (object)fieldDatetime ?? DBNull.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@NumberValue", fieldType == FieldType.Number ? (object)fieldNumber ?? DBNull.Value : DBNull.Value);

                SqlParameter returnParameter = cmd.Parameters.Add("RetVal", SqlDbType.Bit);
                returnParameter.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(returnParameter.Value);
            }
            return result;
        }

        private void ClearLeadTaxonomyFieldValues(SqlConnection con, long leadID)
        {
            bool deleted = false;
            using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.Field.Value.Taxonomy.Delete]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@FieldID", ID);

                SqlParameter returnParameter = cmd.Parameters.Add("RetVal", SqlDbType.Bit);
                returnParameter.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();

                deleted = Convert.ToBoolean(returnParameter.Value);
            }
        }

        private bool SaveLeadTaxonomyFieldValue(SqlConnection con, long leadID, long termID)
        {
            bool result = false;
            using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.Field.Value.Taxonomy.Insert]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@FieldID", ID);
                cmd.Parameters.AddWithValue("@TermID", termID);
                
                SqlParameter returnParameter = cmd.Parameters.Add("RetVal", SqlDbType.Bit);
                returnParameter.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(returnParameter.Value);
            }
            return result;
        }

        public void ParseFieldStructureFromDataRow(DataRow row)
        {
            ParseBasicFieldDataFromDataRow(row);

            taxonomyID = (int?)(row["TaxonomyID"] == DBNull.Value ? null : row["TaxonomyID"]);
            termParentID = (long?)(row["TermParentID"] == DBNull.Value ? null : row["TermParentID"]);
            termDepthMaxLevel = (int?)(row["TermDepthMaxLevel"] == DBNull.Value ? null : row["TermDepthMaxLevel"]);

            placeholder = row["Placeholder"].ToString();
            regularExpression = row["RegularExpression"].ToString();
            minValue = (long?)(row["MinValue"] == DBNull.Value ? null : row["MinValue"]);
            maxValue = (long?)(row["MaxValue"] == DBNull.Value ? null : row["MaxValue"]);
            
        }

        public void ParseFieldValueFromDataRow(DataRow row)
        {
            ParseBasicFieldDataFromDataRow(row);

            switch (fieldType)
            {
                case FieldType.Textbox:
                    fieldText = row["TextValue"].ToString();
                    break;
                case FieldType.Boolean:
                    fieldBool = (row["BoolValue"] == DBNull.Value ? false : Convert.ToBoolean(row["BoolValue"]));
                    break;
                case FieldType.Datetime:
                    fieldDatetime = (DateTime?)(row["DatetimeValue"] == DBNull.Value ? null : row["DatetimeValue"]);
                    break;
                case FieldType.Number:
                    fieldNumber = (long?)(row["NumberValue"] == DBNull.Value ? null : row["NumberValue"]);
                    break;
                case FieldType.Checkbox:
                    SafeAddTermWithBasicData(row);
                    if(row["TermID"] != DBNull.Value)
                        fieldTerms.First(x => x.ID == (long)row["TermID"]).isChecked = true;
                    break;
                case FieldType.Dropdown:
                    SafeAddTermWithBasicData(row);
                    if (row["TermID"] != DBNull.Value)
                        termIDSelected = (long)row["TermID"];
                    break;
                case FieldType.Radio:
                    SafeAddTermWithBasicData(row);
                    if (row["TermID"] != DBNull.Value)
                        termIDSelected = (long)row["TermID"];
                    break;
                default:
                    break;
            }
        }

        private void ParseBasicFieldDataFromDataRow(DataRow row)
        {
            ID = (int)row["FieldID"];
            code = row["FieldCode"].ToString();
            fieldType = (FieldType)(int)row["FieldTypeID"];
            groupID = (int)row["GroupID"];
            name = row["FieldName"].ToString();
            label = row["LabelText"].ToString();
            isActive = Convert.ToBoolean(row["IsActive"]);
            isRequired = Convert.ToBoolean(row["IsRequired"]);
            isContact = Convert.ToBoolean(row["IsContact"]);
            description = row["Description"].ToString();
        }

        private void SafeAddTermWithBasicData(DataRow row)
        {
            if (fieldTerms == null)
                fieldTerms = new List<Term>();

            if (row["TermID"] != DBNull.Value && fieldTerms.FirstOrDefault(x => x.ID == (long)row["TermID"]) == null)
                fieldTerms.Add(new Term() {
                    ID = (long)row["TermID"],
                    name = (string)row["TermName"],
                    termURL = (string)row["TermURL"],
                    thumbnailURL = row["TermThumbnailURL"].ToString(),
                });
        }

        public void InitializeTermStructure(SqlConnection con)
        {
            if (taxonomyID == null)
                return;

            fieldTerms = new List<Term>();
            if (fieldType == FieldType.Dropdown)
            {
                //Load plain list of terms (with hierarhal order)
                List<Term> AllTaxonomyTerms = Term.SelectFromDB(con, TaxonomyID: taxonomyID, OnlyAllowedInLeads: true);
                List<Term> TopLevelTermListWithChildren = new List<Term>();
                foreach (Term TopLevelTerm in AllTaxonomyTerms.Where(x => x.parentID == termParentID))
                    TopLevelTermListWithChildren.Add(new   Term(TopLevelTerm, AllTaxonomyTerms, 1));

                foreach (var term in TopLevelTermListWithChildren)
                    fieldTerms.AddRange(term.GetAllChildTermsInPlainList().Where(x=> (termDepthMaxLevel == null) || (x.level <= termDepthMaxLevel)));
            }
            else
            {
                //terms will not have information about children or Level
                fieldTerms = Term.SelectFromDB(con, TaxonomyID: taxonomyID, TermParentID: termParentID, OnlyAllowedInLeads: true);
            }
   

        }


    }
}
