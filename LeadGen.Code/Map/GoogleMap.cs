using System;
using System.Configuration;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Map
{
    public class GoogleMap : Map
    {
        public GoogleMap() : base()
        {
            APIKey = Helpers.SysHelper.AppSettings.GoogleMapsAPIKey;

        }
    }
}
