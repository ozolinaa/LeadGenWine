using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Debugger.Docker
{
    public class ImageTagResponse
    {
        public List<ImageTag> results { get; set; }
    }

    public class ImageTag
    {
        public string name { get; set; }
        public DateTime last_updated { get; set; }
    }
}
