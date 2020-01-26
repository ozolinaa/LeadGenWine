using LeadGen.Code.CMS;
using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Clients.CRM
{
    public interface ICRMClient : IDisposable
    {
        IEnumerable<Organization> GetOrganizations();
        Organization GetOrganizationByID(string OrgID);
        void SetPostID(string OrgID, long? PostID);
        void SetBusinessID(string OrgID, long? BusinessID);
        void SetOptOutEmailLeadNotifications(string OrgID, bool optOut);

    }
}
