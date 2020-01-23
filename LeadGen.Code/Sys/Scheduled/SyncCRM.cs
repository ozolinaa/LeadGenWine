using LeadGen.Code.Clients.CRM;
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
        protected override string RunInternal(SqlConnection con)
        {
            string mysqlString = Helpers.SysHelper.AppSettings.CRMSettings.DBConnectionString;
            ESPOClient client = new ESPOClient(mysqlString);
            List<Organization> orgs = client.GetOrganizations();
            Organization org = orgs.FirstOrDefault(x => x.Name == "XtonyX Rambler TEST");
            client.SetBusinessID(org.ID, null);
            client.SetPostID(org.ID, null);
            client.OptOutEmailLeadNotifications(org.ID, false);

            return string.Format("Companies Synced With CRM: {0}", 3);
        }
    }
}
