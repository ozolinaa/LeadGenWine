using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Importer.YelpHelper
{
    public class ClientWrapper
    {
        public static List<Yelp.Api.Models.BusinessResponse> GetBusinesses(string term, string location, int maxTotalResults = Int32.MaxValue)
        {
            Yelp.Api.Models.SearchRequest request = new Yelp.Api.Models.SearchRequest();
            request.Term = term;
            request.Location = location;

            return SerachBusinesses(request, maxTotalResults).Result;
        }

        public static List<Yelp.Api.Models.BusinessResponse> GetBusinesses(string term, double latitude, double longitude, int radiusMeters = 40000, int maxTotalResults = Int32.MaxValue)
        {
            Yelp.Api.Models.SearchRequest request = new Yelp.Api.Models.SearchRequest();
            request.Term = term;
            request.Latitude = latitude;
            request.Longitude = longitude;
            request.Radius = radiusMeters;

            return SerachBusinesses(request, maxTotalResults).Result;
        }


        private static async Task<List<Yelp.Api.Models.BusinessResponse>> SerachBusinesses(Yelp.Api.Models.SearchRequest request, int maxTotalResults = Int32.MaxValue)
        {
            List<Yelp.Api.Models.BusinessResponse> yelpBusinesses = new List<Yelp.Api.Models.BusinessResponse>();

            string Yelp_APP_ID = ConfigurationManager.AppSettings["Yelp_APP_ID"];
            string Yelp_APP_SECRET = ConfigurationManager.AppSettings["Yelp_APP_SECRET"];
            Yelp.Api.Client client = new Yelp.Api.Client(Yelp_APP_ID, Yelp_APP_SECRET);

            request.ResultsOffset = 0;

            int yelpTotal = Int32.MaxValue;
            int yelpMaxResults = 40;

            Yelp.Api.Models.SearchResponse yelpResponse = null;

            while (yelpTotal > yelpBusinesses.Count())
            {
                request.MaxResults = Math.Min(yelpTotal - request.ResultsOffset, yelpMaxResults);
                
                //Do not exceed maxTotalResults
                if (request.MaxResults + request.ResultsOffset > maxTotalResults)
                    request.MaxResults = maxTotalResults - request.ResultsOffset;

                if (request.MaxResults == 0 || (yelpResponse != null && yelpResponse.Businesses.Count() < request.MaxResults))
                    break;

                try
                {
                    yelpResponse = await client.SearchBusinessesAllAsync(request);
                }
                catch (Exception e)
                {
                    throw e;
                }

                if (yelpResponse == null || yelpResponse.Businesses == null || yelpResponse.Businesses.Count() == 0)
                    break;

                yelpBusinesses.AddRange(yelpResponse.Businesses);

                yelpTotal = yelpResponse.Total;
                request.ResultsOffset = yelpBusinesses.Count();
            }

            return yelpBusinesses;
        }

    }
}
