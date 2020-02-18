using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Text.RegularExpressions;

namespace LeadGen.Code.Clients.CRM
{
    public class CRMImportManager
    {
        private ICRMClient crmClient = null;
        private List<Organization> existingOrgs = null;
        private Dictionary<string, Organization> emailDict = null;
        private Dictionary<string, Organization> phoneDict = null;
        private Dictionary<string, Organization> siteDict = null;


        public CRMImportManager(ICRMClient crmClient)
        {
            this.crmClient = crmClient;
            LoadExistingOrgsAndInitDicts();
        }

        private void LoadExistingOrgsAndInitDicts()
        {
            emailDict = new Dictionary<string, Organization>();
            phoneDict = new Dictionary<string, Organization>();
            siteDict = new Dictionary<string, Organization>();
            existingOrgs = crmClient.GetOrganizations().ToList();
            foreach (Organization org in existingOrgs)
                addToDict(org);
        }

        private void addToDict(Organization org)
        {
            addPhoneToPhoneDict(org.PhoneNotification, org, phoneDict);
            addPhoneToPhoneDict(org.PhonePublic, org, phoneDict);
            addEmailToEmailDict(org.EmailNotification, org, emailDict);
            addEmailToEmailDict(org.EmailPublic, org, emailDict);
            addSiteToSitelDict(org.WebsiteOther, org, siteDict);
            addSiteToSitelDict(org.WebsitePublic, org, siteDict);
        }

        private void addPhoneToPhoneDict(string phoneValue, Organization org, Dictionary<string, Organization> dict)
        {
            phoneValue = ExtractNumbers(phoneValue);
            if (string.IsNullOrEmpty(phoneValue))
                return;
            try
            {
                dict.Add(phoneValue, org);
            }
            catch (Exception) { }
        }

        private void addEmailToEmailDict(string email, Organization org, Dictionary<string, Organization> dict)
        {
            email = ExtractEmail(email);
            if (string.IsNullOrEmpty(email))
                return;
            try
            {
                dict.Add(email, org);
            }
            catch (Exception) { }
        }

        private void addSiteToSitelDict(string url, Organization org, Dictionary<string, Organization> dict)
        {
            url = ExtractUrl(url);
            if (string.IsNullOrEmpty(url))
                return;
            try
            {
                dict.Add(url, org);
            }
            catch (Exception) { }
        }

        private string ExtractNumbers(string str)
        {
            if (string.IsNullOrEmpty(str))
                return null;
            string result = string.Join("", Regex.Split(str, @"[^\d]"));
            return string.IsNullOrEmpty(result) ? null : result;
        }

        private string ExtractEmail(string email)
        {
            try
            {
                MailAddress addr = new MailAddress(email);
                if (addr.Address.ToLower() == email.ToLower())
                    return addr.Address.ToLower();
                return null;
            }
            catch
            {
                return null;
            }
        }

        private string ExtractUrl(string url)
        {
            if (string.IsNullOrEmpty(url))
                return null;
            try
            {
                url = url.Trim('/').ToLower();
                Uri uri = new Uri(url);
                if (uri.ToString().Trim('/').ToLower() == url)
                    return url;
                return null;
            }
            catch
            {
                return null;
            }
        }


        public List<Organization> ImportOrganizations(List<Organization> orgs)
        {
            List<Organization> results = new List<Organization>();
            foreach (Organization org in orgs)
            {
                Organization existingOrg = getExistingOrgFromDict(org);
                if (existingOrg != null)
                {
                    ProcessExistingOrganization(org, existingOrg);
                    continue;
                }


                org.ID = crmClient.InsertOrganization(org);
                addToDict(org);
                results.Add(org);
            }
            return results;
        }

        private void ProcessExistingOrganization(Organization importing, Organization existing)
        {
            string[] existingLocations = existing.Locations.Select(x => x.ID).ToArray();
            IEnumerable<Location> newLocations = importing.Locations.FindAll(x => existingLocations.Contains(x.ID) == false);
            foreach (Location newLocation in newLocations)
            {
                crmClient.LinkOrgIdWithLocationId(existing.ID, newLocation.ID);
                existing.Locations.Add(newLocation);
            }
            importing.ID = existing.ID;
            importing.LeadGenBusinessID = existing.LeadGenBusinessID;
            importing.LeadGenPostID = existing.LeadGenPostID;
        }

        private Organization getExistingOrgFromDict(Organization org)
        {
            if (!string.IsNullOrEmpty(org.EmailNotification) && emailDict.ContainsKey(ExtractEmail(org.EmailNotification)))
                return emailDict[ExtractEmail(org.EmailNotification)];
            if (!string.IsNullOrEmpty(org.EmailPublic) && emailDict.ContainsKey(ExtractEmail(org.EmailPublic)))
                return emailDict[ExtractEmail(org.EmailPublic)];
            if (!string.IsNullOrEmpty(org.PhoneNotification) && phoneDict.ContainsKey(ExtractNumbers(org.PhoneNotification)))
                return phoneDict[ExtractNumbers(org.PhoneNotification)];
            if (!string.IsNullOrEmpty(org.PhonePublic) && phoneDict.ContainsKey(ExtractNumbers(org.PhonePublic)))
                return phoneDict[ExtractNumbers(org.PhonePublic)];
            if (!string.IsNullOrEmpty(org.WebsitePublic) && siteDict.ContainsKey(ExtractUrl(org.WebsitePublic)))
                return siteDict[ExtractUrl(org.WebsitePublic)];
            if (!string.IsNullOrEmpty(org.WebsiteOther) && siteDict.ContainsKey(ExtractUrl(org.WebsiteOther)))
                return siteDict[ExtractUrl(org.WebsiteOther)];
            return null;
        }




    }
}
