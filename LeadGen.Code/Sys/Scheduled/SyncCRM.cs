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
using LeadGen.Code.Taxonomy;

namespace LeadGen.Code.Sys.Scheduled
{
    public class SyncCRM : ScheduledTask
    {
        private PostCompany getCompanyPostForOrganization(SqlConnection con, Organization org)
        {
            PostCompany companyPost;
            if (org.LeadGenPostID != null)
            {
                companyPost = Post.SelectFromDB<PostCompany>(con, postID: org.LeadGenPostID.Value).FirstOrDefault();
                if (companyPost == null || companyPost.postType.ID != PostType.BuiltIn.CompanyTypeId)
                    throw new Exception($"Error in sync CRM: CompanyPost with ID {org.LeadGenPostID.Value} not found");
            }
            else
            {
                companyPost = Post.SelectFromDB<PostCompany>(con, fieldCode: "company_crmId", textValue: org.ID).FirstOrDefault();
                if (companyPost == null)
                {
                    long postId = Post.CreateNew(con, 1, PostType.BuiltIn.CompanyTypeId);
                    companyPost = Post.SelectFromDB<PostCompany>(con, postID: postId).First();
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

            foreach (Location crmLocation in client.GetLocations())
            {
                PostCompanyCity post = getCompanyCityPostForLocation(con, crmLocation);
                if (crmLocation.Lat == 0 && crmLocation.Lng == 0)
                    continue;
                if (post.company_city_location == null)
                    post.company_city_location = new Map.Location();
                Map.Location postLocation = post.company_city_location;
                _updatePostLocation(ref postLocation, crmLocation);
                string errorMessage = null;
                post.Update(con, ref errorMessage);
                if (!string.IsNullOrEmpty(errorMessage))
                    throw new Exception("Error updating PostCompanyCity post during sync CRM");
            }


            int processedCount = 0;
            foreach (Organization org in client.GetOrganizations())
            {
                PostCompany post = getCompanyPostForOrganization(con, org);

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

        private Term getTermForLocation(SqlConnection con, Location loc)
        {
            int cityTaxId = Taxonomy.Taxonomy.BuiltIn.CityTaxId;
            Term cityTerm = Term.SelectFromDB(con, TermURL: loc.TermURL, TaxonomyID: cityTaxId).FirstOrDefault();
            if (cityTerm == null)
            {
                Term parentTerm = loc.Parent == null ? null : getTermForLocation(con, loc.Parent);
                cityTerm = new Term() { termURL = loc.TermURL, name = loc.Name, parentID = parentTerm?.ID };
                string errorMsg = null;
                long? newTermId = cityTerm.TryInsert(con, cityTaxId, ref errorMsg);
                if (newTermId == null)
                    throw new Exception("Can not create new term for CRM location" + loc.TermURL);
                cityTerm = Term.SelectFromDB(con, TermID: newTermId).First();
            }
            return cityTerm;
        }
        private PostCompanyCity getCompanyCityPostForLocation(SqlConnection con, Location loc)
        {
            Term term = getTermForLocation(con, loc);
            //PostCompanyCity must exists in DB if term exists, should be created by SQL triggers
            PostCompanyCity post = Post.SelectFromDB<PostCompanyCity>(con, forTermID: term.ID, forTypeID: PostType.BuiltIn.CompanyTypeId).First();
            post.LoadFields(con);
            return post;
        }

        private void syncCompanyByOrganization(SqlConnection con, PostCompany post, Organization org)
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
            _syncCityTerms(con,post, org.Locations);

            string errorMessage = null;
            post.Update(con, ref errorMessage);
            if (!string.IsNullOrEmpty(errorMessage))
                throw new Exception("Error updating company post during sync CRM");
        }

        private void _syncLocation(PostCompany post, Organization org)
        {
            //remove company_notification_location
            post.company_notification_location = null;
            return;

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
            _updatePostLocation(ref postLocation, crmLocation);
        }

        private void _syncCityTerms(SqlConnection con, PostCompany post, List<Location> locations)
        {
            post.LoadTaxonomies(con, loadTerms: true, termsCheckedOnly: false);
            PostTypeTaxonomy cityPostTax = post.taxonomies.Find(x => x.taxonomy.ID == Taxonomy.Taxonomy.BuiltIn.CityTaxId);
            List<string> locationTermUrls = locations.Select(x => x.TermURL.ToLower()).ToList();
            cityPostTax.taxonomy.termList.ForEach(x => x.isChecked = locationTermUrls.Contains(x.termURL.ToLower()));
        }

        private void _updatePostLocation(ref Map.Location postLocation, Location crmLocation)
        {
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
