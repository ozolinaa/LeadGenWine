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
using LeadGen.Code.Tokens;
using LeadGen.Code.Business;

namespace LeadGen.Debugger
{
    class Program
    {
        static void Main(string[] args)
        {
            using (SqlConnection con = new SqlConnection("Data Source=db.winecellars.pro;Initial Catalog=LeadGenDB_dev;Persist Security Info=True;User ID=LeadGenDB_dev;Password=Pass@word1!;"))
            {
                con.Open();

                Login login = Login.SelectOne(con, email: "anton.ozolin+bizaaa@gmail.com");
                login.business = Business.SelectFromDB(con, businessID: 1)[0];


                LoginManager lm = new LoginManager(con, login);

                lm.EmailAdd("anton.ozolin+linkedStuff1", false);

                List<BusinessLogin> logins = lm.SelectLogins();
                ;
            }
        }

        private static void RunParce()
        {
            using (WebOrgParser parser = new WebOrgParser())
            {
                var rrr = parser.ParseHouzzOrganizations(new Uri("https://www.houzz.com/professionals/wine-cellars/los-angeles"));
                ;
            }
        }

        private static void RunCRMImport()
        {
            Uri parseUrl = new Uri("https://www.houzz.com/professionals/searchDirectory?topicId=11841&query=Wine+Cellars&location=San+Diego%2C+CA&distance=50&sort=4");
            string termUrl = "san-diego";

            List<Organization> orgsToImport = null;
            using (WebOrgParser parser = new WebOrgParser())
            {
                orgsToImport = parser.ParseHouzzOrganizations(parseUrl);
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
