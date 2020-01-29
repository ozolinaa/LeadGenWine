using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Clients.CRM
{
    public class Location
    {
        public string Name { get; set; }
        public string TermURL { get; set; }
        public double Lat { get; set; }
        public double Lng { get; set; }
        public int RadiusMeters { get; set; }
        public int Zoom { get; set; }
        public Location Parent { get; set; }
    }
}
