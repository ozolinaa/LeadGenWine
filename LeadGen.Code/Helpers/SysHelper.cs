using LeadGen.Code.Settings;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Helpers
{
    public class SysHelper
    {
        public static string GenerateRandomString(int length = 8)
        {
            var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            var random = new Random();
            var result = new string(
                Enumerable.Repeat(chars, length)
                          .Select(s => s[random.Next(s.Length)])
                          .ToArray());

            return result;
        }

        public static string ReplaceNewLinesWithParagraph(string value)
        {
            //http://stackoverflow.com/questions/2015563/replace-newlines-with-p-paragraph-and-with-br-tags
            if (string.IsNullOrEmpty(value))
                return value;
            return "<p>" + value
                    .Replace(Environment.NewLine + Environment.NewLine, "</p><p>")
                    .Replace(Environment.NewLine, "<br />")
                    .Replace("</p><p>", "</p>" + Environment.NewLine + "<p>") + "</p>";
        }

        public static string GetFileContentType(string fileName)
        {
            new FileExtensionContentTypeProvider().TryGetContentType(fileName, out string contentType);
            return contentType ?? "application/octet-stream";
        }

        public static bool ConvertToBoolean(string value) {
            if (string.IsNullOrEmpty(value))
                return false;
            return Convert.ToBoolean(value);
        }

        public static decimal CovertToDecimal(string value)
        {
            if (string.IsNullOrEmpty(value))
                return 0;
            return Convert.ToDecimal(value);
        }

        private static IServiceProvider _provider;
        public static void InitServiceProvider(IServiceProvider provider)
        {
            _provider = provider;
        }
        public static IServiceProvider GetServiceProvider { get { return _provider; } }

        public static IAppSettings AppSettings
        {
            get
            {
                return GetServiceProvider.GetRequiredService<IAppSettings>();
            }
        }

        public static IViewRenderService ViewRenderService
        {
            get
            {
                return GetServiceProvider.GetRequiredService<IViewRenderService>();
            }
        }
    }
}
