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
        private List<Post> companyPosts = null;
        private List<Organization> crmOrgs = null;

        protected override string RunInternal(SqlConnection con)
        {
            //string mysqlString = Helpers.SysHelper.AppSettings.CRMSettings.DBConnectionString;
            //ESPOClient client = new ESPOClient(mysqlString);
            //crmOrgs = client.GetOrganizations();

            string orgId = "5e216391071e53d68";
            string orgName = "XTONYX";

            CompanyPost companyPost = Post.SelectFromDB<CompanyPost>(con, fieldCode: "company_crmId", textValue: orgId).FirstOrDefault();
            if (companyPost == null)
            {
                long postId = 10011; // Post.CreateNew(con, 1, PostType.BuiltIn.Company);
                companyPost = Post.SelectFromDB<CompanyPost>(con, postID: postId).First();
                companyPost.postStatus = new Post.Status() { ID = 30 }; // Pending
            }
            companyPost.LoadFields(con);
            companyPost.company_crmId = orgId;
            companyPost.title = orgName;

            string errorMessage = null;
            companyPost.Update(con, ref errorMessage);
            if (!string.IsNullOrEmpty(errorMessage))
                throw new Exception("Error updating company post during sync CRM");

            //companyPosts = Post.SelectFromDB<Post>(con, fieldCode: "ff", po).ToList();

            //foreach (Organization org in client.GetOrganizations())
            //{
            //    total++;

            //    if (org.LeadGenPostID == null)
            //    {
            //        if(CMS.Post.SelectFromDB<Post>(con,)
            //    }
            //        CMS.Post.CreateNew(con, 1, CMS.PostType.BuiltIn.Company)

            //}

            //Organization org = orgs.FirstOrDefault(x => x.Name == "XtonyX Rambler TEST");
            //client.SetBusinessID(org.ID, null);
            //client.SetPostID(org.ID, null);
            //client.OptOutEmailLeadNotifications(org.ID, false);

            return string.Format("Companies Synced With CRM: {0}", 3);
        }
    }
}
