using Fizzler.Systems.HtmlAgilityPack;
using HtmlAgilityPack;
using LeadGen.Code.Clients.CRM;
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Mail;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace LeadGen.Code.Clients
{
    public class WebOrgParser : IDisposable
    {
        HttpClient httpClient = null;
        public WebOrgParser()
        {
            httpClient = new HttpClient();
        }

        public void Dispose()
        {
            httpClient.Dispose();
        }

        public List<Organization> ParseOrganizations(Uri parseUrl)
        {
            //string ggg = "";
            //ParseEmail(GetLikeBrowserAsync(httpClient, new Uri("http://glrwinecellars.com")).Result, new Uri("http://glrwinecellars.com"), ref ggg);
            //string fakesource = File.ReadAllText(@"D:\text.txt");
            string source = GetLikeBrowserAsync(httpClient, parseUrl).Result;

            var html = new HtmlDocument();
            html.LoadHtml(source);

            HtmlNode doc = html.DocumentNode;

            List<Organization> result = new List<Organization>();
            foreach (HtmlNode item in doc.QuerySelectorAll(".hz-pro-search-results .hz-pro-search-results__item"))
            {

                HtmlNode link = item.QuerySelector("a[itemprop='url']");
                string url = link.Attributes["href"].Value;
                result.Add(ParseHouzzOrganization(new Uri(url)));
            }
            return result;
        }

        private Organization ParseHouzzOrganization(Uri orgUri)
        {
            string source = GetLikeBrowserAsync(httpClient, orgUri).Result;

            HtmlDocument html = new HtmlDocument();
            html.LoadHtml(source);

            HtmlNode doc = html.DocumentNode;

            string name = doc.QuerySelector(".hz-profile-header__name")?.InnerText;
            string phone = null;
            string proxyWebSite = doc.QuerySelector("[data-compid='Profile_Website']")?.Attributes["href"].Value;
            string actualWebSite = null;
            string email = null;

            if (!string.IsNullOrEmpty(proxyWebSite))
            {
                HttpResponseMessage proxyWebSiteResponse = httpClient.GetAsync(proxyWebSite).Result;
                if (proxyWebSiteResponse.StatusCode == HttpStatusCode.Found)
                {
                    actualWebSite = proxyWebSiteResponse.Headers.Location.ToString().Trim('/');
                }
            }

            if (!string.IsNullOrEmpty(actualWebSite))
            {
                Uri orgSite = new Uri(actualWebSite);
                string actualSiteContent = GetLikeBrowserAsync(httpClient, orgSite).Result;
                ParseEmail(actualSiteContent, orgSite, ref email);
                ParsePhone(actualSiteContent, ref phone);

                string contactUrl = null;
                if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(phone))
                {
                    contactUrl = GetContactUrl(actualSiteContent, actualWebSite);
                    if (!string.IsNullOrEmpty(contactUrl))
                    {
                        actualSiteContent = GetLikeBrowserAsync(httpClient, new Uri(contactUrl)).Result;
                        ParseEmail(actualSiteContent, orgSite, ref email);
                        ParsePhone(actualSiteContent, ref phone);
                    }
                }
                if (string.IsNullOrEmpty(contactUrl) && (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(phone)))
                {
                    actualSiteContent = GetLikeBrowserAsync(httpClient, new Uri(actualWebSite + "/contact")).Result;
                    ParseEmail(actualSiteContent, orgSite, ref email);
                    ParsePhone(actualSiteContent, ref phone);
                }
                if (string.IsNullOrEmpty(contactUrl) && (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(phone)))
                {
                    actualSiteContent = GetLikeBrowserAsync(httpClient, new Uri(actualWebSite + "/contacts")).Result;
                    ParseEmail(actualSiteContent, orgSite, ref email);
                    ParsePhone(actualSiteContent, ref phone);
                }
            }

            return new Organization() { Name = name, 
                PhonePublic = phone, 
                PhoneNotification = phone, 
                WebsitePublic = actualWebSite, 
                WebsiteOther = orgUri.ToString(), 
                EmailNotification = email, 
                EmailPublic = email
            };
        }

        private void ParseEmail(string siteContent, Uri uri, ref string emailRef)
        {
            if (!string.IsNullOrEmpty(emailRef))
                return;

            string[] hostParts = uri.Host.Split('.');
            string host = string.Join(".", hostParts.Reverse().Take(2).Reverse().ToArray());
            string emailSuffix = "@" + host;

            emailRef = GetEmail(siteContent, emailSuffix);

            if (string.IsNullOrEmpty(emailRef))
                emailRef = GetEmail(siteContent, "@gmail.com");
            if (string.IsNullOrEmpty(emailRef))
                emailRef = GetEmail(siteContent, "@yahoo.com");
        }

        private string GetEmail(string source, string emailSuffix) {
            if (string.IsNullOrEmpty(source))
                return null;
            HtmlDocument html = new HtmlDocument();
            html.LoadHtml(source);
            return GetEmailRecur(html.DocumentNode, emailSuffix);
        }

        private string GetEmailRecur(HtmlNode node, string emailSuffix)
        {
            if (node.OuterHtml.StartsWith("<style") || node.OuterHtml.StartsWith("<script"))
            {
                return null;
            }

            string email = FindEmail(node.GetDirectInnerText(), emailSuffix);
            if (!string.IsNullOrEmpty(email))
                return email;

            if (node.HasChildNodes)
            {
                foreach (HtmlNode n in node.ChildNodes)
                {
                    email = GetEmailRecur(n, emailSuffix);
                    if (!string.IsNullOrEmpty(email))
                        return email;
                }
            }

            return null;
        }


        private string FindEmail(string str, string emailSuffix)
        {
            int pos = str.IndexOf(emailSuffix);

            if (pos == -1)
            {
                return null;
            }

            int begin = pos;
            char[] beginChars = new char[] { ' ', ':', '<', '>', '"', '\'', '\n', '\r' };
            while (begin >= 0)
            {
                if (beginChars.Contains(str[begin]))
                    break;
                begin--;
            };
            string email = str.Substring(begin + 1, pos - begin + emailSuffix.Length - 1);
            try
            {
                MailAddress addr = new MailAddress(email);
                if(addr.Address.ToLower() == email.ToLower())
                    return addr.Address;
                return null;
            }
            catch
            {
                return null;
            }
        }


        private void ParsePhone(string siteContent, ref string phoneRef)
        {
            if (!string.IsNullOrEmpty(phoneRef))
                return;
            phoneRef = GetPhone(siteContent);
        }

        private string GetPhone(string source)
        {
            if (string.IsNullOrEmpty(source))
                return null;
            HtmlDocument html = new HtmlDocument();
            html.LoadHtml(source);
            return GetPhoneRecur(html.DocumentNode);
        }

        private string GetPhoneRecur(HtmlNode node)
        {
            if (node.OuterHtml.StartsWith("<style") || node.OuterHtml.StartsWith("<script"))
            {
                return null;
            }
            string phone = FindPhone(node.GetDirectInnerText());
            if (!string.IsNullOrEmpty(phone))
                return phone;

            if (node.HasChildNodes)
            {
                foreach (HtmlNode n in node.ChildNodes)
                {
                    phone = GetPhoneRecur(n);
                    if (!string.IsNullOrEmpty(phone))
                        return phone;
                }
            }

            return null;
        }

        string FindPhone(string str)
        {
            if (string.IsNullOrEmpty(str))
                return null;
            string number = string.Join("", Regex.Split(str, @"[^\d]"));

            if (number.Length == 11)
                number = number.TrimStart('1');

            if (number.Length == 10)
            {
                return number;
            }
                
            return null;
        }


        private string GetContactUrl(string source, string siteUrl)
        {
            if (string.IsNullOrEmpty(source))
                return null;
            HtmlDocument html = new HtmlDocument();
            html.LoadHtml(source);
            HtmlNode contactLink = GetContactLinkRecur(html.DocumentNode);
            if(contactLink == null)
            {
                return null;
            }
            string contactLinkHref = contactLink.Attributes["href"].Value;


            if (contactLinkHref.StartsWith("http"))
                return contactLinkHref;
            return siteUrl.TrimEnd('/') + "/" + contactLinkHref.TrimStart('/');
        }

        private HtmlNode GetContactLinkRecur(HtmlNode node)
        {
            if (isContactLink(node))
                return node;

            if (node.HasChildNodes)
            {
                foreach (HtmlNode n in node.ChildNodes)
                {
                    HtmlNode found = GetContactLinkRecur(n);
                    if (found != null)
                        return found;
                }
            }

            return null;
        }

        private bool isContactLink(HtmlNode node)
        {
            if (!node.OuterHtml.StartsWith("<a "))
                return false;
            if (node.InnerHtml.ToLower().Contains("contact"))
                return true;
            return false;
        }



        private static async Task<string> GetLikeBrowserAsync(HttpClient httpClient, Uri url)
        {
            string cookieName = "hZ8g4S9i";
            string cookieValue = "AgG6MS1wAQAAa6j9tgmwReyKelbWtAdEQKBZ_OqN_KlUlxHKQAAAAXAtMboBAQcrCJs=";
            Console.WriteLine(url.ToString());
            try
            {
                using (var request = new HttpRequestMessage(HttpMethod.Get, url))
                {
                    request.Headers.TryAddWithoutValidation("Upgrade-Insecure-Requests", "1");
                    request.Headers.TryAddWithoutValidation("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36");
                    request.Headers.TryAddWithoutValidation("Sec-Fetch-User", "?1");
                    request.Headers.TryAddWithoutValidation("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9");
                    request.Headers.TryAddWithoutValidation("Accept-Charset", "utf-8, iso-8859-1;q=0.5");

                    request.Headers.TryAddWithoutValidation("Cookie", cookieName + "=" + cookieValue);
                    using (var response = await httpClient.SendAsync(request).ConfigureAwait(false))
                    {
                        response.EnsureSuccessStatusCode();
                        byte[] byteArray = await response.Content.ReadAsByteArrayAsync();
                        var responseString = Encoding.UTF8.GetString(byteArray, 0, byteArray.Length);
                        return responseString;
                    }
                }
            }
            catch (Exception)
            {
                return null;
            }

        }

    }
}
