using LeadGen.Code.Clients.CRM;
using LeadGen.Code.CMS;
using LeadGen.Code.Lead.Notification;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
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
                    companyPost.postURL = org.Name;
                    companyPost.postStatus = new Post.Status() { ID = 30 }; // Pending
                }
            }

            companyPost.LoadFields(con);

            return companyPost;
        }

        private ICRMClient getCRMClient()
        {
            string mysqlString = Helpers.SysHelper.AppSettings.CRMSettings.DBConnectionString;
            return new ESPOClient(mysqlString);
        }

        protected override string RunInternal(SqlConnection con)
        {
            ICRMClient client = getCRMClient();

            int processedCount = 0;
            foreach (Organization org in client.GetOrganizations())
            {
                CompanyPost post = getCompanyPostForOrganization(con, org);

                syncCompanyByOrganization(con, post, org);

                if (org.LeadGenPostID != post.ID)
                    client.SetPostID(org.ID, post.ID);
                if (org.LeadGenBusinessID != post.company_businessId)
                    client.SetBusinessID(org.ID, post.company_businessId);
                if (org.OptOutEmailLeadNotifications != post.company_notification_do_not_send_leads)
                    client.SetOptOutEmailLeadNotifications(org.ID, post.company_notification_do_not_send_leads);

                processedCount++;
            }

            return string.Format("Companies Synced With CRM: {0}", processedCount);
        }

        private void syncCompanyByOrganization(SqlConnection con, CompanyPost post, Organization org)
        {
            post.title = org.Name;
            post.company_notification_email = org.EmailNotification;
            post.company_public_email = org.EmailPublic;
            post.company_web_site_official = org.WebsiteOfficial;
            post.company_web_site_other = org.WebsiteOther;

            Int64.TryParse(Regex.Match(org.PhoneNotification, @"\d+").Value, out long parcedPhoneNotification);
            post.company_notification_phone = parcedPhoneNotification > 0 ? parcedPhoneNotification as long? : null;
            Int64.TryParse(Regex.Match(org.PhonePublic, @"\d+").Value, out long parcedPhonePublic);
            post.company_public_phone = parcedPhonePublic > 0 ? parcedPhonePublic as long? : null;

            post.company_crmId = org.ID;
            post.company_businessId = org.LeadGenBusinessID ?? post.company_businessId;

            _syncLocation(post, org);

            string errorMessage = null;
            post.Update(con, ref errorMessage);
            if (!string.IsNullOrEmpty(errorMessage))
                throw new Exception("Error updating company post during sync CRM");
        }

        private void _syncLocation(CompanyPost post, Organization org)
        {

            Location crmLocation = getOrgLocation(org);
            if (crmLocation == null)
            {
                post.company_notification_location = null;
                return;
            }

            if (post.company_notification_location == null)
            {
                post.company_notification_location = new Map.Location();
            }

            Map.Location postLocation = post.company_notification_location;

            postLocation.Lat = crmLocation.Lat;
            postLocation.Lng = crmLocation.Lng;
            postLocation.RadiusMeters = crmLocation.RadiusMeters;
            postLocation.Name = crmLocation.Name;
            postLocation.Zoom = crmLocation.Zoom;
            postLocation.Region = null;
            postLocation.StreetAddress = null;
            postLocation.Country = null;
            postLocation.City = null;
            postLocation.AccuracyMeters = 0;
        }

        private Location getOrgLocation(Organization org)
        {
            if (org.Locations == null || org.Locations.Count() == 0)
                return null;
            return org.Locations.Aggregate((curMax, x) => (curMax == null || (x.RadiusMeters) > curMax.RadiusMeters ? x : curMax));
        }
    }
}
