﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Net;
using System.Web;
using System.Web.Helpers;
using System.Device.Location;

namespace LeadGen.Code.Map
{
    public class GoogleMapsClientWrapper
    {
        public static Location GetLocation(string address)
        {
            string APIKey = ConfigurationManager.AppSettings["GoogleMapsAPIKey"];

            string url = string.Format("https://maps.googleapis.com/maps/api/geocode/json?address={0}&key={1}", HttpUtility.UrlEncode(address), APIKey);
            string json = String.Empty;
            using (WebClient wc = new WebClient())
            {
                json = wc.DownloadString(url);
            }


            dynamic data = Newtonsoft.Json.JsonConvert.DeserializeObject(json);

            Location location = null;
            try
            {
                var result = data.results[0];

                location = new Location();
                location.name = address;
                location.address = result.formatted_address;
                location.lat = result.geometry.location.lat;
                location.lng = result.geometry.location.lng;

                GeoCoordinate sCoord = new GeoCoordinate((double)result.geometry.bounds.southwest.lat, (double)result.geometry.bounds.southwest.lng);
                GeoCoordinate eCoord = new GeoCoordinate((double)result.geometry.bounds.northeast.lat, (double)result.geometry.bounds.northeast.lng);

                double boundsDiag = sCoord.GetDistanceTo(eCoord);
                double boundsSide = boundsDiag / Math.Sqrt(2);

                location.radiusInMeters = Convert.ToInt32(boundsSide / 2);

                return location;

            }
            catch (Exception e)
            {
                location = null;
            }

            return location;
        }

        public static Location GetLocationByUsZipCode(int zipCode)
        {
            return GetLocation(string.Format("zip {0}, USA", zipCode));
        }
    }
}
