using LeadGen.Code.CMS;
using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Clients.CRM
{
    public interface ICRMClient : IDisposable
    {
        string InsertOrganization(Organization organization);
        IEnumerable<Location> GetLocations();
        IEnumerable<Organization> GetOrganizations();
        Organization GetOrganizationByID(string orgID);
        void SetPostID(string orgID, long? postID);
        void SetBusinessID(string orgID, long? businessID);
        void SetOptOutEmailLeadNotifications(string orgID, bool optOut);
        void LinkOrgIdWithLocationId(string orgId, string LocationId);
    }
}
