using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc.Rendering;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

namespace LeadGen.Web.Helpers
{
    public static class ViewHelpers
    {
        public static string ToHtmlString(this IHtmlContent tag)
        {
            using (var writer = new StringWriter())
            {
                tag.WriteTo(writer, System.Text.Encodings.Web.HtmlEncoder.Default);
                return writer.ToString();
            }
        }

        public static bool IsDebug(this IHtmlHelper htmlHelper)
        {
#if DEBUG
            return true;
#else
            return false;
#endif
        }


        private static DateTime _appRunningSince = DateTime.Now;
        public static long AssemblyBuildTimeStamp(this IHtmlHelper htmlHelper)
        {
            return _appRunningSince.ToUniversalTime().Ticks;
        }
    }
}
