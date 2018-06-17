using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Helpers
{
    public static class DecimalExtensions
    {
        public static string ToString(this decimal some, bool compactFormat)
        {
            return some.ToString(new System.Globalization.CultureInfo("en-US"));
        }
    }
}
