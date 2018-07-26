using LeadGen.Code.Helpers;
using LeadGen.Code.Sys;
using LeadGen.Code.Lead;
using LeadGen.Code.Taxonomy;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Mail;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using X.PagedList;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace LeadGen.Code.Business
{
    public class Business
    {
        public long ID { get; set; }

        public long adminLoginID { get; set; }

        [Required]
        [Display(Name ="Company Name")]
        public string name { get; set; }

        [Required]
        [Display(Name = "Company Web Site")]
        public string webSite { get; set; }
        [Display(Name = "Company Address")]
        public string address { get; set; }

        public DateTime registrationDate { get; set; }

        public Term country { get; set; }

        public List<LeadPermittion> leadPermissions { get; set; }

        public List<LeadItem> leads { get; set; }

        public NotificationSettings notification { get; set; }
        public Contact contact { get; set; }
        public Billing billing { get; set; }

        public LeadManager leadManager { get; set; }
        
        public List<Lead.Review> reviews { get; set; }

        public List<BusinessLocation> locations { get; set; }

        public Dictionary<Lead.Review.Measure, short> rating {
            get {
                if (reviews == null)
                    return null;

                Dictionary<Lead.Review.Measure, List<short>> totalMeasures = new Dictionary<Lead.Review.Measure, List<short>>();
                foreach (Lead.Review review in reviews)
                {
                    foreach (KeyValuePair<Lead.Review.Measure, short> score in review.measureScores)
                    {
                        if (score.Value > 0)
                        {
                            if (totalMeasures.Keys.Contains(score.Key))
                                totalMeasures[score.Key].Add(score.Value);
                            else
                                totalMeasures.Add(score.Key, new List<short>() { score.Value });
                        }
                    }
                }

                return totalMeasures.ToDictionary(
                    x => x.Key, 
                    x => Convert.ToInt16(x.Value.Average(y => y)
                ));
            }
        }

        public Business()
        {
        }

        public Business(DataRow row)
        {
            DataColumnCollection Colums = row.Table.Columns;

            ID = (long)row["BusinessID"];
            name = row["BusinessName"].ToString();
            registrationDate = Convert.ToDateTime(row["BusinessRegistrationDate"]);

            if (Colums.Contains("WebSite"))
                webSite = row["WebSite"].ToString();
            if (Colums.Contains("BusinessAdminLoginID"))
                adminLoginID = (long)row["BusinessAdminLoginID"];
            if (Colums.Contains("Address"))
                address = row["Address"].ToString();
            
            if (Colums.Contains("TermID") && Colums.Contains("TermName") && Colums.Contains("TermParentID") && Colums.Contains("TermURL") && Colums.Contains("TaxonomyID"))
                country = new Term(row);

            if (Colums.Contains("NotificationFrequencyID"))
            {
                NotificationSettings.Frequency frequency = NotificationSettings.Frequency.DoNotNotify;
                if (NotificationSettings.FrequencyDictionary.TryGetValue((int)row["NotificationFrequencyID"], out frequency))
                    notification = new NotificationSettings() { frequency = frequency };
            }

            if (Colums.Contains("TermID") && Colums.Contains("TermName") && Colums.Contains("TermParentID") && Colums.Contains("TermURL") && Colums.Contains("TaxonomyID"))
                country = new Term(row);

            if (Colums.Contains("ContactName") && Colums.Contains("ContactPhone") && Colums.Contains("ContactSkype") && Colums.Contains("ContactEmail"))
                contact = new Contact(row);

            if (Colums.Contains("BillingName") && Colums.Contains("BillingCode1") && Colums.Contains("BillingCode2") && Colums.Contains("BillingAddress"))
                billing = new Billing(row);
        }


        public static Business Create(SqlConnection con, string name, string site, long countryID)
        {
            long businessID;

            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.Create]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@name", name);
                cmd.Parameters.AddWithValue("@webSite", site);
                cmd.Parameters.AddWithValue("@countryID", countryID); 

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@businessID";
                outputParameter.SqlDbType = SqlDbType.BigInt;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                if (long.TryParse(outputParameter.Value.ToString(), out businessID))
                    return new Business { ID = businessID, name = name };
            }

            return null;
        }

        public bool LinkLogin(SqlConnection con, Login newLogin)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.AddLogin]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@businessID", ID);
                cmd.Parameters.AddWithValue("@loginID", newLogin.ID);
                cmd.Parameters.AddWithValue("@roleID", (int)Login.UserRoles.business_admin);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@result";
                outputParameter.SqlDbType = SqlDbType.Bit;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                return Boolean.Parse(outputParameter.Value.ToString());
            }
        }

        public void NotifiedAboutLeadSet(SqlConnection con, long leadID, DateTime? notifiedDateTime = null)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.Lead.SetNotified]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", ID);
                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@NotifiedDateTime", notifiedDateTime ?? DateTime.UtcNow);

                cmd.ExecuteNonQuery();
            }
        }

        

        public bool SendRegistrationConfirmationEmail(SqlConnection con, Login login)
        {
            string mailSubject = "Пожалуйста подтвердите регистрацию";
            string viewPath = "~/Areas/Business/Views/Registration/E-mails/_registrationConfirmation.cshtml";

            Token token = new Token(con, Token.Action.LoginEmailConfirmation.ToString(), login.ID.ToString());

            QueueMailMessage message = new QueueMailMessage(login.email);
            message.Subject = mailSubject;
            ViewDataDictionary viewDataDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary()) { { "tokenKey", token.key } };

            message.Body = ViewHelper.RenderPartialToString(viewPath, login, viewDataDictionary);
            using (SmtpClientLeadGen smtp = new SmtpClientLeadGen())
            {
                message.Send(smtp);
            }
            

            return true;
        }


        public static List<Business> SelectPendingForAdmin(SqlConnection con, long? countryID, long? regionID)
        {
            return new List<Business>();
        }


        public static StaticPagedList<Business> SelectFromDB(SqlConnection con, string query = "", long? businessID = null, DateTime? registeredFrom = null, DateTime? registeredTo = null, int page = 1, int pageSize = Int32.MaxValue)
        {
            List<Business> businessList = new List<Business>();
            int totalCount = 0;
            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.Select]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@businessID", businessID ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@query", string.IsNullOrEmpty(query) ? (object)DBNull.Value : query);
                cmd.Parameters.AddWithValue("@registeredFrom", registeredFrom ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@registeredTo", registeredTo ?? (object)DBNull.Value);



                cmd.Parameters.AddWithValue("@Offset", pageSize * (page - 1));
                cmd.Parameters.AddWithValue("@Fetch", pageSize);

                SqlParameter totalCountParameter = new SqlParameter();
                totalCountParameter.ParameterName = "@TotalCount";
                totalCountParameter.SqlDbType = SqlDbType.Int;
                totalCountParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(totalCountParameter);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                totalCount = (int)totalCountParameter.Value;
                foreach (DataRow row in dt.Rows)
                {
                    businessList.Add(new Business(row));
                }
            }
            return new StaticPagedList<Business>(businessList, page, pageSize, totalCount);
        }

        public void Update(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.Update.Basic]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@businessID", ID);
                cmd.Parameters.AddWithValue("@name", name);
                cmd.Parameters.AddWithValue("@webSite", webSite);
                cmd.Parameters.AddWithValue("@address", address ?? "");

                cmd.ExecuteNonQuery();
            }
        }





        public bool UpdateRequestedPermissions(SqlConnection con, ICollection<long[]> RequestedTermIDs, List<LeadPermittion> originalPermissions)
        {
            bool result = true;
            foreach (long[] termIDs in RequestedTermIDs)
            {
                bool isNewPermission = true;
                foreach (LeadPermittion leadPermission in originalPermissions)
                    if (termIDs.Except(leadPermission.terms.Select(x => x.ID)).ToList().Count == 0)
                        isNewPermission = false;

                //Add new permission requests
                if (isNewPermission && result && termIDs.Length > 0)
                    result = new LeadPermittion() { terms = termIDs.Select(x=> new Term() {ID = x }).ToList() }.AddRequestToDB(con, ID);
            }
            foreach (LeadPermittion leadPermission in originalPermissions)
            {
                bool removePermission = true;
                foreach (long[] termIDs in RequestedTermIDs)
                    if (leadPermission.terms.Select(x=>x.ID).Except(termIDs).ToList().Count == 0)
                        removePermission = false;
                if (result && removePermission)
                    result = leadPermission.RemoveRequestFromDB(con, ID);
            }
            return result;
        }


        public void LoadLeadPermissions(SqlConnection con, bool onlyCurrentlyRequested = true)
        {
            leadPermissions = new List<LeadPermittion>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.Permission.Term.Select]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", ID);
                cmd.Parameters.AddWithValue("@RequestedOnly",  onlyCurrentlyRequested ? 1 : 0);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);

                foreach (DataRow permissionRow in dt.DefaultView.ToTable(true, "PermissionID", "RequestedDateTime", "ApprovedDateTime").Rows)
                {
                    DataRow[] termDataRows = dt.Select(String.Format("PermissionID = {0}", permissionRow["PermissionID"]));
                    leadPermissions.Add(new LeadPermittion(permissionRow, termDataRows));
                }
            }

        }

        public void LoadReviews(SqlConnection con, bool? published = true)
        {
            reviews = Lead.Review.SelectFromDB(con, businessID: ID, published: published).ToList();
        }

        public IPagedList<LeadItem> SelectLeadsFromDB(SqlConnection con, 
            BusinessDetails.Status status = BusinessDetails.Status.All, 
            long ? leadID = null, DateTime? dateFrom = null, 
            DateTime? dateTo = null, DateTime? completedBeforeDate = null, 
            string query = "",
            int page = 1,
            int pageSize = int.MaxValue,
            bool loadFieldValues = false
            )
        {

            if (String.IsNullOrEmpty(query) == false)
                query = query.Trim();

            List<LeadItem> leadItems = new List<LeadItem>();
            int totalCount = 0;
            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.Lead.Select]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", ID); 
                cmd.Parameters.AddWithValue("@LeadID", (object)leadID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Status", status.ToString());
                cmd.Parameters.AddWithValue("@DateFrom", (object)dateFrom ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@DateTo", (object)dateTo ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@CompletedBeforeDate", (object)completedBeforeDate ?? DBNull.Value);
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
                LeadItem.LoadFieldValuesForLeads(con, leadItems);

            return new StaticPagedList<LeadItem>(leadItems, page, pageSize, totalCount);
        }


        public void LoadLocations(SqlConnection con)
        {
            locations = BusinessLocation.SelectFromDbForBusinessID(con, ID);
        }

    }
}
