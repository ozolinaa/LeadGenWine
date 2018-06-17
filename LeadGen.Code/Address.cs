using LeadGen.Code.Taxonomy;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code
{
    public class Address
    {
        public Term Country { get; set; }
        public string otherCountryName { get; set; }

        public Term Region { get; set; }
        public string otherRegionName { get; set; }

        public Term City { get; set; }
        public string otherCityName { get; set; }

        public string streetAddressLine1 { get; set; }
        public string streetAddressLine2 { get; set; }

        public string postalIndex { get; set; }
    }
}
