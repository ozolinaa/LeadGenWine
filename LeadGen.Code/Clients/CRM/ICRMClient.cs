using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Clients.CRM
{
    public interface ICRMClient : IDisposable
    {
        List<Organization> GetOrganizations();
        Organization GetOrganizationByID(string OrgID);
        void SetPostAndBusinessID(string OrgID, long? PostID);
        void SetBusinessID(string OrgID, long? BusinessID);
        void OptOutEmailLeadNotifications(string OrgID, bool optOut);

    }
}
