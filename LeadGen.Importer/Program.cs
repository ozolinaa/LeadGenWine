using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Importer
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;


            //Meetpsychic mp = new Meetpsychic();
            //mp.Run(); 


            using (Importer importer = new Importer())
            {
                importer.ImportTaxonomyCity();
                importer.ImportTaxonomyPamTag();
                importer.ImportTaxonomyCMSTag();
                importer.ImportTaxonomyCMSCategory();

                //importer.ImportBusinesses(1);
                //Importer.DeleteExistingLeads(importer.con);
                //importer.ImportLeads(1);
                //importer.ImportInvoices(1);
                //importer.ImportReviews(1);

                //importer.SyncCrmCompaniesEPESICompanies();
                //importer.ImportPostsMasterData();

                //importer.ImportPages();
                //importer.ImportPostsArticle();
                //importer.ImportPostsKlad();
                //importer.ImportPostsPam();

            }


            Console.WriteLine("Finished!!! Press Enter to exit...");
            Console.ReadLine();
        }
    }
}
