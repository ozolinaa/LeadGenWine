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
    }
}
