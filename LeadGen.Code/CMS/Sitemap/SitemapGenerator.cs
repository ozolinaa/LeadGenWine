using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace LeadGen.Code.CMS.Sitemap
{

    /// <summary>
    /// How frequently the page is likely to change. This value provides general information to search engines and may not correlate exactly to how often they crawl the page.
    /// </summary>
    /// <remarks>
    /// The value "always" should be used to describe documents that change each time they are accessed. The value "never" should be used to describe archived URLs.
    /// </remarks>
    public enum SitemapChangeFrequency
    {
        Always = 1,
        Hourly,
        Daily,
        Weekly,
        Monthly,
        Yearly,
        Never
    }


    /// <summary>
    /// A class for creating XML Sitemaps (see http://www.sitemaps.org/protocol.html)
    /// </summary>
    public class SitemapGenerator : ISitemapGenerator
    {

        //The same dictionary is stored in DB SEO.Sitemap.ChangeFrequency Table please reflect any changes also in the DB
        //It is confortable to use static Property because no need to connect to DB every time so it can be used in lot
        public static Dictionary<int, SitemapChangeFrequency> changeFrequencyDictionary = new Dictionary<int, SitemapChangeFrequency> {
            {1, SitemapChangeFrequency.Always},
            {2, SitemapChangeFrequency.Hourly},
            {3, SitemapChangeFrequency.Daily},
            {4, SitemapChangeFrequency.Weekly},
            {5, SitemapChangeFrequency.Monthly},
            {6, SitemapChangeFrequency.Yearly},
            {7, SitemapChangeFrequency.Never}
        };

        public static decimal [] priorityArray = new decimal[] { 1.0m, 0.9m, 0.8m, 0.7m, 0.6m, 0.5m, 0.4m, 0.3m, 0.2m, 0.1m, 0.0m };

        private static readonly XNamespace xmlns = "http://www.sitemaps.org/schemas/sitemap/0.9";
        private static readonly XNamespace xsi = "http://www.w3.org/2001/XMLSchema-instance";

        public virtual XDocument GenerateSiteMap(IEnumerable<ISitemapItem> items)
        {
            //Ensure.Argument.NotNull(items, "items");

            var sitemap = new XDocument(
                new XDeclaration("1.0", "utf-8", "yes"),
                    new XProcessingInstruction("xml-stylesheet", "type='text/xsl' href='/css/XML-Sitemap-Style.xsl'"),
                    new XElement(xmlns + "urlset",
                      new XAttribute("xmlns", xmlns),
                      new XAttribute(XNamespace.Xmlns + "xsi", xsi),
                      new XAttribute(xsi + "schemaLocation", "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"),
                      from item in items
                      select CreateItemElement(item)
                      )
                 );

            return sitemap;
        }

        private XElement CreateItemElement(ISitemapItem item)
        {
            var itemElement = new XElement(xmlns + "url", new XElement(xmlns + "loc", item.Url.ToLowerInvariant()));

            // all other elements are optional

            itemElement.Add(new XElement(xmlns + "lastmod", item.LastModified.ToString("yyyy-MM-dd")));

            itemElement.Add(new XElement(xmlns + "changefreq", item.ChangeFrequency.ToString().ToLower()));

            itemElement.Add(new XElement(xmlns + "priority", item.Priority.ToString("F1", CultureInfo.InvariantCulture)));

            return itemElement;
        }
    }
}
