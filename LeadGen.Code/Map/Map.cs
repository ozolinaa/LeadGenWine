using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Map
{
    public abstract class Map
    {
        public string APIKey { get; set; }
        public Location center { get; set; }
        public List<Location> locations { get; set; }

        public Map() {
            if (locations == null)
                locations = new List<Location>();
        }

        public void initCenter() {
            if (center != null)
                return;
            else if (locations.Count() == 0)
                center = new Location() { lat = -34.397, lng = 150.644, zoom = 8 };
            else if (locations.Count() == 1)
                center = locations[0];
            else
                center = new Location() { lat = locations.Average(x => x.lat), lng = locations.Average(x => x.lng), zoom = 8 };
        }
    }
}
