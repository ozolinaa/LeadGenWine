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

        public IEnumerable<Organization> ParseOrganizations(Uri parseUrl)
        {
            string source = GetLikeBrowserAsync(httpClient, parseUrl).Result;

            var html = new HtmlDocument();
            html.LoadHtml(source);

            HtmlNode doc = html.DocumentNode;

            foreach (HtmlNode item in doc.QuerySelectorAll(".hz-pro-search-results .hz-pro-search-results__item"))
            {

                HtmlNode link = item.QuerySelector("a[itemprop='url']");
                string url = link.Attributes["href"].Value;
                var rrr =  ParseOrganization(new Uri(url));
                ;
            }

            return null;
        }

        private Organization ParseOrganization(Uri orgUri)
        {
            string source = GetLikeBrowserAsync(httpClient, orgUri).Result;

            HtmlDocument html = new HtmlDocument();
            html.LoadHtml(source);

            HtmlNode doc = html.DocumentNode;

            string name = doc.QuerySelector(".hz-profile-header__name")?.InnerText;
            string phone = doc.QuerySelector("[data-compid='Profile_Phone']")?.InnerText;
            string proxyWebSite = doc.QuerySelector("[data-compid='Profile_Website']")?.Attributes["href"].Value;
            string actualWebSite = null;
            string email = null;

            if (!string.IsNullOrEmpty(proxyWebSite))
            {
                HttpResponseMessage proxyWebSiteResponse = httpClient.GetAsync(proxyWebSite).Result;
                if (proxyWebSiteResponse.StatusCode == HttpStatusCode.Found)
                {
                    actualWebSite = proxyWebSiteResponse.Headers.Location.ToString();
                }
            }

            if (!string.IsNullOrEmpty(actualWebSite))
            {
                email = ParseEmail(new Uri(actualWebSite));
            }

            return new Organization() { Name = name, 
                PhonePublic = phone, 
                PhoneNotification = phone, 
                WebsiteOfficial = actualWebSite, 
                WebsiteOther = orgUri.ToString(), 
                EmailNotification = email, 
                EmailPublic = email
            };
        }

        private string ParseEmail(Uri orgUri)
        {
            byte[] bytes = httpClient.GetByteArrayAsync(orgUri).Result;
            string source = Encoding.GetEncoding("utf-8").GetString(bytes, 0, bytes.Length - 1);
            source = WebUtility.HtmlDecode(source);

            string[] hostParts = orgUri.Host.Split('.');
            string host = string.Join(".", hostParts.Reverse().Take(2).Reverse().ToArray());

            string emailSuffix = "@"+ host;
            int pos = source.IndexOf(emailSuffix);

            if (pos == -1)
            {
                return null;
            }

            int begin = pos;
            char[] beginChars = new char[] { ' ', ':', '<', '>', '"', '\'' };
            while (begin > 0)
            {
                if (beginChars.Contains(source[begin]))
                    break;
                begin--;
            };
            if (begin == 0)
                return null;
            string email = source.Substring(begin + 1, pos - begin + emailSuffix.Length - 1);
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


        private static async Task<string> GetLikeBrowserAsync(HttpClient httpClient, Uri url)
        {
            using (var request = new HttpRequestMessage(HttpMethod.Get, url))
            {
                request.Headers.TryAddWithoutValidation("Upgrade-Insecure-Requests", "1");
                request.Headers.TryAddWithoutValidation("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36");
                request.Headers.TryAddWithoutValidation("Sec-Fetch-User", "?1");
                request.Headers.TryAddWithoutValidation("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9");

                request.Headers.TryAddWithoutValidation("Cookie", "hZ8g4S9i=AjBvThZwAQAAYo-YgpUlkcdQPSrMocut4AgJr7QjZE10ljgRrQAAAXAWTm8wAe4H_RU=");

                request.Headers.TryAddWithoutValidation("Accept-Charset", "ISO-8859-1");
                //request.Headers.TryAddWithoutValidation("Accept-Encoding", "gzip, deflate");
                using (var response = await httpClient.SendAsync(request).ConfigureAwait(false))
                {
                    response.EnsureSuccessStatusCode();
                    using (var responseStream = await response.Content.ReadAsStreamAsync().ConfigureAwait(false))
                    //using (var decompressedStream = new GZipStream(responseStream, CompressionMode.Decompress))
                    using (var streamReader = new StreamReader(responseStream))
                    {
                        return await streamReader.ReadToEndAsync().ConfigureAwait(false);
                    }
                }
            }
        }


    }



}
