using LeadGen.Code.Clients.CRM;
using LeadGen.Code.CMS;
using LeadGen.Code.Lead.Notification;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Sys.Scheduled
{
    public class SyncCRM : ScheduledTask
    {
        private CompanyPost getCompanyPostForOrganization(SqlConnection con, Organization org)
        {
            CompanyPost companyPost;
            if (org.LeadGenPostID != null)
            {
                companyPost = Post.SelectFromDB<CompanyPost>(con, postID: org.LeadGenPostID.Value).FirstOrDefault();
                if (companyPost == null || companyPost.postType.ID != PostType.BuiltIn.Company)
                    throw new Exception($"Error in sync CRM: CompanyPost with ID {org.LeadGenPostID.Value} not found");
            }
            else
            {
                companyPost = Post.SelectFromDB<CompanyPost>(con, fieldCode: "company_crmId", textValue: org.ID).FirstOrDefault();
                if (companyPost == null)
                {
                    long postId = Post.CreateNew(con, 1, PostType.BuiltIn.Company);
                    companyPost = Post.SelectFromDB<CompanyPost>(con, postID: postId).First();
                    companyPost.postStatus = new Post.Status() { ID = 30 }; // Pending
                }
            }

            companyPost.LoadFields(con);

            return companyPost;
        }
        protected override string RunInternal(SqlConnection con)
        {
            string mysqlString = Helpers.SysHelper.AppSettings.CRMSettings.DBConnectionString;
            ESPOClient client = new ESPOClient(mysqlString);

            int processedCount = 0;
            foreach (Organization org in client.GetOrganizations())
            {
                CompanyPost companyPost = getCompanyPostForOrganization(con, org);

                companyPost.title = org.Name;
                companyPost.company_crmId = org.ID;
                companyPost.company_businessId = org.LeadGenBusinessID;

                string errorMessage = null;
                companyPost.Update(con, ref errorMessage);
                if (!string.IsNullOrEmpty(errorMessage))
                    throw new Exception("Error updating company post during sync CRM");


                client.SetPostID(org.ID, companyPost.ID);
                client.SetBusinessID(org.ID, companyPost.company_businessId);
                client.SetOptOutEmailLeadNotifications(org.ID, companyPost.company_notification_do_not_send_leads);

                processedCount++;
            }

            return string.Format("Companies Synced With CRM: {0}", processedCount);
        }
    }
}
