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
                center = new Location() { Lat = -34.397, Lng = 150.644, Zoom = 8 };
            else if (locations.Count() == 1)
                center = locations[0];
            else
                center = new Location() { Lat = locations.Average(x => x.Lat), Lng = locations.Average(x => x.Lng), Zoom = 8 };
        }
    }
}
