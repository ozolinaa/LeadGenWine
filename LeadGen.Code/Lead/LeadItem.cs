using LeadGen.Code.CMS.Sitemap;
using LeadGen.Code.Helpers;
using LeadGen.Code.Taxonomy;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using X.PagedList;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;


namespace LeadGen.Code.Lead
{
    public class LeadItem
    {
        public long ID { get; set; }

        [EmailAddress(ErrorMessage = "Invalid E-Mail")]
        [Required(ErrorMessage = "E-Mail is required")]
        public string email { get; set; }

        public AdminDetails adminDetails { get; set; }
        public BusinessDetails businessDetails { get; set; }
        public List<FieldGroup> fieldGroups { get; set; }

        public FieldItem getFieldByCode(string code)
        {
            FieldItem field = null;
            if (string.IsNullOrEmpty(code) == false)
            {
                foreach (var group in fieldGroups)
                {
                    if (group.fields != null)
                        field = group.fields.FirstOrDefault(x => x.code.Equals(code, StringComparison.OrdinalIgnoreCase));
                    if (field != null)
                        break;
                }
            }
            return field;
        }

        public LeadItem() { }

        public LeadItem(DataRow row)
        {
            ID = (long)row["LeadID"];
            email = row["Email"].ToString();

            adminDetails = new AdminDetails(row);

            if (row.Table.Columns.Contains("BusinessID"))
                businessDetails = new Lead.BusinessDetails(row);
        }

        public static IPagedList<LeadItem> SelectFromDB(SqlConnection con, 
            AdminDetails.Status status = AdminDetails.Status.All, 
            long? leadID = null, 
            DateTime? dateFrom = null, 
            DateTime? dateTo = null, 
            string query = "", 
            bool loadFieldValues = false,
            int page = 1,
            int pageSize = Int32.MaxValue)
        {
            List<LeadItem> leadItems = new List<LeadItem>();

            if (String.IsNullOrEmpty(query) == false)
                query = query.Trim();

            int totalCount = 0;
            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", (object)leadID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Status", status.ToString());
                cmd.Parameters.AddWithValue("@DateFrom", (object)dateFrom ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@DateTo", (object)dateTo ?? DBNull.Value);

                cmd.Parameters.AddWithValue("@Query", String.IsNullOrEmpty(query) ? DBNull.Value : (object)query);

                cmd.Parameters.AddWithValue("@Offset", pageSize * (page - 1));
                cmd.Parameters.AddWithValue("@Fetch", pageSize);

                SqlParameter totalCountParameter = new SqlParameter();
                totalCountParameter.ParameterName = "@TotalCount";
                totalCountParameter.SqlDbType = SqlDbType.Int;
                totalCountParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(totalCountParameter);

                using (DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd))
                {
                    totalCount = (int)totalCountParameter.Value;
                    foreach (DataRow row in dt.Rows)
                        leadItems.Add(new LeadItem(row));
                }

            }

            if (loadFieldValues)
                LoadFieldValuesForLeads(con, leadItems);

            return new StaticPagedList<LeadItem>(leadItems, page, pageSize, totalCount);
        }

        public static List<LeadItem> SelectFromDB(SqlConnection con, string email)
        {
            List<LeadItem> leadItems = new List<LeadItem>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadSelectByEmail]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Email", email);

                using (DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd))
                    foreach (DataRow row in dt.Rows)
                        leadItems.Add(new LeadItem(row));
            }

            return leadItems;
        }

        public void LoadFieldStructure(SqlConnection con, bool ActiveOnly = true)
        {
            if (fieldGroups == null)
                fieldGroups = new List<FieldGroup>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadFieldStructureSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ActiveStatus", ActiveOnly == true ? (object)ActiveOnly : DBNull.Value);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);

                foreach (DataRow fieldGroupRow in dt.DefaultView.ToTable(true, "GroupID", "GroupCode", "GroupTitle").Rows)
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
                    foreach (DataRow fieldRow in dt.Select(String.Format("GroupID = {0} AND FieldID IS NOT NULL", fieldGroupRow["GroupID"])))
                    {
                        FieldItem fieldItem = fieldGroup.fields.FirstOrDefault(x => x.ID == (int)fieldRow["FieldID"]);
                        if (fieldItem == null)
                        {
                            fieldItem = new FieldItem();
                            fieldGroup.fields.Add(fieldItem);
                        }
                        fieldItem.ParseFieldStructureFromDataRow(fieldRow);
                    }
                    // END Initialize Fiels For Each Field Group

                    //Load terms for fields that have taxonomyID
                    //terms will not have information about children or Level

                    //Initialize term structure for each lead
                    fieldGroup.fields.ForEach(x => x.InitializeTermStructure(con));
                }


            }

        }

        public void LoadFieldValues(SqlConnection con)
        {
            if (fieldGroups == null)
                fieldGroups = new List<FieldGroup>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadFieldValueSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add(DBHelper.GetNumericTableTypeParamter("@LeadIDTable", "[dbo].[SysBigintTableType]", new long[] { ID }));

                using (DataTable fieldGroupDataTable = DBHelper.ExecuteCommandToDataTable(cmd))
                {
                     FieldGroup.InitializeFieldGroups(fieldGroupDataTable, fieldGroups);
                } 
            }
        }

        public static void LoadFieldValuesForLeads(SqlConnection con, IEnumerable<LeadItem> leadItems)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadFieldValueSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add(DBHelper.GetNumericTableTypeParamter("@LeadIDTable", "[dbo].[SysBigintTableType]", leadItems.Select(x => x.ID)));

                using (DataTable mixedLeadFieldGroupDataTable = DBHelper.ExecuteCommandToDataTable(cmd))
                {
                    foreach (LeadItem leadItem in leadItems)
                    {
                        using (DataTable leadFieldGroupDataTable = mixedLeadFieldGroupDataTable.Clone())
                        {
                            foreach (DataRow row in mixedLeadFieldGroupDataTable.Select(String.Format("LeadID = {0}", leadItem.ID)))
                            {
                                leadFieldGroupDataTable.ImportRow(row);
                            }
                            if (leadItem.fieldGroups == null)
                            {
                                leadItem.fieldGroups = new List<FieldGroup>();
                            }
                            FieldGroup.InitializeFieldGroups(leadFieldGroupDataTable, leadItem.fieldGroups);
                        }
                    }
                }

            }
        }


        public void SafeReplaceLeadValuesWith(LeadItem leadItemData)
        {
            email = leadItemData.email;
            adminDetails = leadItemData.adminDetails;
            businessDetails = leadItemData.businessDetails;

            if (leadItemData.fieldGroups != null && leadItemData.fieldGroups.Count > 0)
                foreach (FieldGroup importFieldGroup in leadItemData.fieldGroups)
                    if (importFieldGroup.fields != null && importFieldGroup.fields.Count > 0)
                        foreach (FieldItem importField in importFieldGroup.fields)
                        {
                            FieldGroup fieldGroupToReplace = fieldGroups.FirstOrDefault(x => x.ID == importFieldGroup.ID);
                            if (fieldGroupToReplace != null)
                            {
                                FieldItem fieldToReplace = fieldGroupToReplace.fields.FirstOrDefault(x => x.ID == importField.ID);
                                if (fieldToReplace != null)
                                    switch (fieldToReplace.fieldType)
                                    {
                                        case FieldType.Textbox:
                                            fieldToReplace.fieldText = importField.fieldText;
                                            break;
                                        case FieldType.Textarea:
                                            fieldToReplace.fieldText = importField.fieldText;
                                            break;
                                        case FieldType.Dropdown:
                                            if (importField.termIDSelected != null)
                                                fieldToReplace.termIDSelected = fieldToReplace.fieldTerms.First(x => x.ID == importField.termIDSelected).ID;
                                            break;
                                        case FieldType.Checkbox:
                                            for (int i = 0; i < fieldToReplace.fieldTerms.Count; i++)
                                            {
                                                Term importTerm = fieldToReplace.fieldTerms.FirstOrDefault(x => x.ID == importField.fieldTerms[i].ID);
                                                if (importTerm != null)
                                                    fieldToReplace.fieldTerms[i].isChecked = importField.fieldTerms[i].isChecked;
                                            }
                                            break;
                                        case FieldType.Radio:
                                            if (importField.termIDSelected != null)
                                                fieldToReplace.termIDSelected = fieldToReplace.fieldTerms.First(x => x.ID == importField.termIDSelected).ID;
                                            break;
                                        case FieldType.Boolean:
                                            fieldToReplace.fieldBool = importField.fieldBool;
                                            break;
                                        case FieldType.Datetime:
                                            fieldToReplace.fieldDatetime = importField.fieldDatetime;
                                            break;
                                        case FieldType.Number:
                                            fieldToReplace.fieldNumber = importField.fieldNumber;
                                            break;
                                        default:
                                            break;
                                    }
                            }
                        }
        }

        public void Insert(SqlConnection con)
        {
            //Inser Lead Record
            ID = 0;
            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadInsert]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Email", email);
                SqlParameter LeadIDParameter = cmd.Parameters.Add("LeadID", SqlDbType.BigInt);
                LeadIDParameter.Direction = ParameterDirection.Output;
                cmd.ExecuteNonQuery();
                ID = (long)LeadIDParameter.Value;
            }

            if (ID == 0)
                throw new Exception("LeadItem Record ID was not generated");

            //Save Lead Fields
            UpdateFieldGroupsInDB(con);
        }

        public void UpdateFieldGroupsInDB(SqlConnection con)
        {
            //Update Fields in All Groups
            List<bool> fieldSaveResults = new List<bool>();
            if (fieldGroups != null)
                foreach (var fieldGroup in fieldGroups)
                    foreach (var fieldItem in fieldGroup.fields)
                        fieldSaveResults.Add(fieldItem.SaveLeadFieldValueInDB(con, ID));

            //Retrun false is there were any false statuses
            if (fieldSaveResults.Where(x => x == false).Any())
                throw new Exception("Some fieldSaveResults are not soccessfull");

            //Get ZIPcode and LocationRadiusMappings
            if (!string.IsNullOrEmpty(SysHelper.AppSettings.LeadSettings.FieldMappingLocationZip))
            {
                UpdateLocationInDB(con, SysHelper.AppSettings.LeadSettings.FieldMappingLocationZip, SysHelper.AppSettings.LeadSettings.FieldMappingLocationRadius);
            }
        }

        public static bool EmailConfirm(SqlConnection con, long leadID)
        {
            bool result = false;
            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadEmailConfirm]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", leadID);

                SqlParameter returnParameter = cmd.Parameters.Add("RetVal", SqlDbType.Bit);
                returnParameter.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(returnParameter.Value);
            }
            return result;
        }


        public bool TryPublish(SqlConnection con, long loginID, DateTime? publishDateTime = null)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadTryPublish]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", ID);
                cmd.Parameters.AddWithValue("@LoginID", loginID);
                cmd.Parameters.AddWithValue("@PublishDateTime", publishDateTime ?? DateTime.UtcNow);


                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            if (result == true && adminDetails != null)
                adminDetails.publishedDateTime = DateTime.UtcNow;

            return result;
        }

        public bool TryUnPublishByAdmin(SqlConnection con, long loginID, DateTime? canceledPublishDateTime = null)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadTryUnPublish]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", ID);
                cmd.Parameters.AddWithValue("@LoginID", loginID);
                cmd.Parameters.AddWithValue("@AdminCanceledPublishDateTime", canceledPublishDateTime ?? DateTime.UtcNow);

                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            if (result == true && adminDetails != null)
                adminDetails.publishedDateTime = null;

            return result;
        }

        public bool TryUnPublishByUser(SqlConnection con, DateTime? canceledPublishDateTime = null)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadTryUnPublishByUser]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", ID);
                cmd.Parameters.AddWithValue("@UserCanceledPublishDateTime", canceledPublishDateTime ?? DateTime.UtcNow);

                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            if (result == true)
                adminDetails.publishedDateTime = null;

            return result;
        }

        public bool SetReviewRequestSent(SqlConnection con)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadSetReviewRequestSent]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", ID);

                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            return result;
        }

        public void LoadBusinessActvityForAdmin(SqlConnection con)
        {
            if (adminDetails == null)
                adminDetails = new AdminDetails();

            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadSelectBusinessDetails]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", ID);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                DataColumn IsApprovedCol = new DataColumn("IsApproved", typeof(bool));
                IsApprovedCol.DefaultValue = true;
                dt.Columns.Add(IsApprovedCol);

                adminDetails.businessesActivity = new List<BusinessDetails>();  
                foreach (DataRow row in dt.Rows)
                    adminDetails.businessesActivity.Add(new BusinessDetails(row));
            }

        }

        public bool CancelByUser(SqlConnection con, DateTime? canceledDateTime)
        {
            bool result = false;
            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadCancelByUser]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", ID);
                cmd.Parameters.AddWithValue("@CanceledDateTime", canceledDateTime ?? (object)DBNull.Value);

                SqlParameter returnParameter = cmd.Parameters.Add("RetVal", SqlDbType.Bit);
                returnParameter.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(returnParameter.Value);
            }
            return result;
        }

        public void Validate(ModelStateDictionary ModelState)
        {
            for (int fieldGroupIndex = 0; fieldGroupIndex < fieldGroups.Count(); fieldGroupIndex++)
                for (int fieldIndex = 0; fieldIndex < fieldGroups[fieldGroupIndex].fields.Count(); fieldIndex++)
                {
                    KeyValuePair<string, string>? fieldValidationError = fieldGroups[fieldGroupIndex].fields[fieldIndex].validationError;
                    if (fieldValidationError != null)
                        ModelState.AddModelError(string.Format("fieldGroups[{0}].fields[{1}].{2}", fieldGroupIndex, fieldIndex, fieldValidationError.Value.Key), fieldValidationError.Value.Value);
                }
        }


        public static List<SitemapItem> SelectItemsForSiteMapIndexPage(SqlConnection con, string urlFormat, int pageSize)
        {
            List<SitemapItem> sitemapItems = new List<SitemapItem>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadSelect_SiteMapData]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PageSize", pageSize);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    string url = string.Format(urlFormat, row["PageNumber"].ToString());
                    DateTime lastModified = (DateTime)row["PublishedDateTime"];
                    SitemapChangeFrequency changeFrequency = SitemapChangeFrequency.Weekly;
                    double priority = 0.5;

                    sitemapItems.Add(new SitemapItem(url, lastModified, changeFrequency, priority));
                }
            }

            return sitemapItems;
        }

        private void UpdateLocationInDB(SqlConnection con, string zipMapping, string radiusMapping)
        {
            FieldItem zipField = getFieldByCode(zipMapping);
            Map.Location zipLocation = Map.GoogleMapsClientWrapper.GetLocationByUsZipCode(Int32.Parse(zipField.stringValue));

            int radiusInMeters = 0;
            FieldItem radiusField = getFieldByCode(radiusMapping);
            if (radiusField != null)
                radiusInMeters = Convert.ToInt32(Int32.Parse(radiusField.stringValue) * 1.609344 * 1000);


            zipLocation.CreateInDB(con);


            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadLocationInsertOrUpdate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", ID);
                cmd.Parameters.AddWithValue("@LocationId", zipLocation.ID);
                cmd.ExecuteNonQuery();
            }
        }
    }
}
