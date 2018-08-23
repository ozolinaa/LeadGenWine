
using LeadGen.Code.CMS.Sitemap;
using LeadGen.Code.Helpers;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Text.RegularExpressions;
using System.Web;


namespace LeadGen.Code.CMS
{
    public class CMSManager
    {
        public static string postContentPreviewSeparator = "<!--more-->";

        public static string ClearURL(string URL)
        {
            if (String.IsNullOrEmpty(URL))
                URL = "";
            NickBuhro.Translit.Transliteration.CyrillicToLatin(URL);
            string transliterated = NickBuhro.Translit.Transliteration.CyrillicToLatin(URL, NickBuhro.Translit.Language.Russian);
            Regex rgx = new Regex("[^a-zA-Z0-9 -_]");
            return rgx.Replace(transliterated, "").Replace(" ", "-").ToLower();
        }

        public static List<ImageSize> GetImageSizes(SqlConnection con)
        {
            List<ImageSize> results = new List<ImageSize>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[CMSAttachmentImageSizeSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                    results.Add(new ImageSize(row));
            }

            return results;
        }

        public enum PostTypesBuiltIn {
            Page = 1,
            Widget = 8
        };

        public enum TaxonomiesBuiltIn
        {
            City = 3
        };

        public static List<SitemapItem> SelecItemsForSiteMapIndexPage(SqlConnection con, string urlFormat, int pageSize)
        {
            List<SitemapItem> sitemapItems = new List<SitemapItem>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[CMSPostTypeSelect_SiteMapData]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PageSize", pageSize);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    string url = string.Format(urlFormat, (string)row["TypeCode"], row["PageNumber"].ToString());
                    DateTime lastModified = (DateTime)row["DateLastModified"];
                    SitemapChangeFrequency changeFrequency = SitemapChangeFrequency.Weekly;
                    double priority = 0.5;

                    sitemapItems.Add(new SitemapItem(url, lastModified, changeFrequency, priority));
                }
            }

            return sitemapItems;
        }
    }
}