using LeadGen.Code.Map;
using LeadGen.Importer.EPESI;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static LeadGen.Code.Helpers.DBHelper;

namespace LeadGen.Importer
{
    public class Meetpsychic
    {
        public void Run()
        {
            //Location location2 = GoogleMapsClientWrapper.GetLocationByUsZipCode(92602);

            List<Yelp.Api.Models.BusinessResponse> yelpBusinesses = new List<Yelp.Api.Models.BusinessResponse>();

            Dictionary<string, int> locations = new Dictionary<string, int>() {
                //{"Tustin, California, USA", Int32.MaxValue },
                //{"Santa Ana, California, USA", Int32.MaxValue },
                //{"Irvine, California, USA", Int32.MaxValue },
                {"Fullerton, California, USA", 202 },
                //{"Laguna Beach, California, USA", Int32.MaxValue },
                //{"Anaheim, California, USA", Int32.MaxValue },
            }; 

            foreach (KeyValuePair<string,int> location in locations)
            {
                yelpBusinesses.AddRange(YelpHelper.ClientWrapper.GetBusinesses("psychic", location.Key, location.Value));
            }

            

            string epesiConnectionString = ConfigurationManager.ConnectionStrings["Psychic_EPESI"].ConnectionString;


            Dictionary<string, int> fieldKeyGroupIdMapping = new Dictionary<string, int>() {
                { "group", 645 },
                { "skill", 670 }
            };

            using (Client epesiClient = new Client(epesiConnectionString, fieldKeyGroupIdMapping))
            {
                foreach (var yelpBusiness in yelpBusinesses)
                {
                    Company company = getEpesiCpmanyByForYelpBusinessID(epesiClient, yelpBusiness);

                    company.SetFieldsFromYelpBusiness(yelpBusiness);

                    epesiClient.CompanyUpdate(company);
                }
            }

        }

        private Company getEpesiCpmanyByForYelpBusinessID(Client epesiClient, Yelp.Api.Models.BusinessResponse yelpBusiness)
        {
            List<SQLfilter> sqlFilters = new List<SQLfilter>() {
                        new SQLfilter() {
                            fieldName = "f_YelpID", parameterName = "YelpID", parameterOperator = "=", parameterValue = yelpBusiness.Id
                        }
                    };

            Company company = epesiClient.CompanySelect(sqlFilters).FirstOrDefault();
            if (company == null)
                company = epesiClient.CompanyCreate(yelpBusiness.Name);

            return company;
        }
    }
}
