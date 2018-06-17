using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Map
{
    public class Location
    {
        public double lat { get; set; }
        public double lng { get; set; }
        public int radiusInMeters { get; set; }
        public int zoom { get; set; }
        public string name { get; set; }
        public string address { get; set; }
    }
}
