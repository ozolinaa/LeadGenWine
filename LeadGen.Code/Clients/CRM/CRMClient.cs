using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Clients.CRM
{
    public class CRMClient
    {
        public static ICRMClient GetClient()
        {
            string mysqlString = Helpers.SysHelper.AppSettings.CRMSettings.DBConnectionString;
            return new ESPOClient(mysqlString);
        }
    }
}
