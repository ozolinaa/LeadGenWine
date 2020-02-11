using LeadGen.Code;
using LeadGen.Code.Clients.CRM;
using LeadGen.Code.Clients;
using LeadGen.Code.Helpers;
using LeadGen.Debugger.Docker;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace LeadGen.Debugger
{
    class Program
    {
        static void Main(string[] args)
        {
            //RunParce();
            RunCRMImport();
            Console.ReadLine();
        }

        private static void RunParce()
        {
            using (WebOrgParser parser = new WebOrgParser())
            {
                var rrr = parser.ParseOrganizations(new Uri("https://www.houzz.com/professionals/wine-cellars/los-angeles"));
                ;
            }
        }

        private static void RunCRMImport()
        {
            Uri parseUrl = new Uri("https://www.houzz.com/professionals/wine-cellars/c/Santa-Barbara--CA/p/7");
            string termUrl = "santa-barbara";

            List<Organization> orgsToImport = null;
            using (WebOrgParser parser = new WebOrgParser())
            {
                orgsToImport = parser.ParseOrganizations(parseUrl);
            }

            using (ESPOClient client = new ESPOClient(@"server=crm.winecellars.pro;user=espocrm;database=espocrm;port=3306;password=h!!?F:_-O^Jp+TB4B*HYt3;"))
            {
                Location location = client.GetLocations().ToList().Find(x => x.TermURL == termUrl);
                orgsToImport.ForEach(x => x.Locations = new List<Location>() { location });
                CRMImportManager manager = new CRMImportManager(client);
                List<Organization> importedOrgs = manager.ImportOrganizations(orgsToImport);
            }
            Console.WriteLine("DONE");
        }
    }
}
