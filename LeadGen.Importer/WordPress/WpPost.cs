using LeadGen.Code.CMS;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace LeadGen.Importer.WordPress
{
    public class WpPost
    {
        public ulong ID { get; set; }
        public string post_url { get; set; }
        public string post_type { get; set; }
        public string post_title { get; set; }
        public string post_content { get; set; }

        public string guid { get; set; }
        public ulong post_author { get; set; }
        public string post_status { get; set; }
        public DateTime post_date { get; set; }

        public string thumbnail_url { get; set; }
        public Dictionary<string, WpPost> attachments { get; set; }

        public string seo_under_h1 { get; set; }

        public SEOFields seo { get; set; }

        public Dictionary<string, IEnumerable<string>> taxonomies { get; set; }
        public Dictionary<string, string> fields { get; set; }
        public Dictionary<string, string> metaData { get; set; }


        public static List<WpPost> SelectFromDB(MySqlConnection conn, string prefix, string type, string status, IEnumerable<string> fields, IEnumerable<string> taxonomies, string url = "")
        {
            List<WpPost> results = new List<WpPost>();

            string sql = "SELECT p.ID, p.post_name, p.post_type, p.post_title, p.post_content, " +
"p.guid, p.post_author, p.post_status, p.post_date, " +
"post_thumb.GUID as thumbnail_url, GROUP_CONCAT(distinct att.guid) as attachment_urls, ";

            if(taxonomies != null)
                foreach (string taxCode in taxonomies)
                    sql += string.Format("GROUP_CONCAT(distinct t_{0}.slug) as taxonomy_{0}, ", taxCode);

            if (fields != null)
                foreach (string field in fields)
                    sql += string.Format("field_{0}.meta_value as field_{0}, ", field);

            sql += "seo_underh1.meta_value as seo_under_h1, " +
                "seo_title.meta_value as seo_title, " +
                "seo_metadesc.meta_value as seo_metadesc, " +
                "seo_keywords.meta_value as seo_keywords, " +
                "seo_focuskw.meta_value as seo_focuskw " +
                "FROM wp_" + prefix + "posts p " +
                "LEFT OUTER JOIN wp_" + prefix + "postmeta seo_underh1 ON seo_underh1.post_id = p.ID AND seo_underh1.meta_key = 'seo_under_h1' " +
                "LEFT OUTER JOIN wp_" + prefix + "postmeta seo_title ON seo_title.post_id = p.ID AND seo_title.meta_key = '_yoast_wpseo_title' " +
                "LEFT OUTER JOIN wp_" + prefix + "postmeta seo_metadesc ON seo_metadesc.post_id = p.ID AND seo_metadesc.meta_key = '_yoast_wpseo_metadesc' " +
                "LEFT OUTER JOIN wp_" + prefix + "postmeta seo_keywords ON seo_keywords.post_id = p.ID AND seo_keywords.meta_key = '_yoast_wpseo_metakeywords' " +
                "LEFT OUTER JOIN wp_" + prefix + "postmeta seo_focuskw ON seo_focuskw.post_id = p.ID AND seo_focuskw.meta_key = '_yoast_wpseo_focuskw' " +
                "LEFT OUTER JOIN wp_" + prefix + "postmeta meta_thumb ON meta_thumb.post_id = p.ID AND meta_thumb.meta_key = '_thumbnail_id' " +
                "LEFT OUTER JOIN wp_" + prefix + "posts post_thumb ON post_thumb.ID = meta_thumb.meta_value " +
                "LEFT OUTER JOIN wp_" + prefix + "term_relationships tr ON tr.object_id = p.ID " +
                "LEFT OUTER JOIN wp_" + prefix + "posts att ON att.post_parent = p.ID AND att.post_type = 'attachment'";

            if (taxonomies != null)
                foreach (string taxCode in taxonomies)
                {
                    sql += string.Format("LEFT OUTER JOIN wp_" + prefix + "term_taxonomy tt_{0} ON tt_{0}.term_taxonomy_id = tr.term_taxonomy_id AND tt_{0}.taxonomy = '{0}' ", taxCode);
                    sql += string.Format("LEFT OUTER JOIN wp_" + prefix + "terms t_{0} ON t_{0}.term_id = tt_{0}.term_id ", taxCode);
                }

            if (fields != null)
                foreach (string field in fields)
                    sql += string.Format("LEFT OUTER JOIN wp_" + prefix + "postmeta field_{0} ON field_{0}.post_id = p.ID AND field_{0}.meta_key = '{0}' ", field);

            sql += "WHERE p.post_type = '" + type + "' AND p.post_status = '" + status + "' ";

            if (string.IsNullOrEmpty(url) == false)
                sql += "AND p.post_title = '" + url + "' ";

            sql += "GROUP BY p.ID";


            sql += " LIMIT 50";

            MySqlDataAdapter adapter = new MySqlDataAdapter(sql, conn);
            DataSet dataset = new DataSet("TableData");
            adapter.Fill(dataset);

            foreach (DataRow row in dataset.Tables[0].Rows)
            {
                results.Add(new WpPost(conn, row, taxonomies, fields));
            }

            return results;
        }

        public WpPost()
        {
        }

        public WpPost(MySqlConnection conn, DataRow row, IEnumerable<string> taxonomies, IEnumerable<string> fields)
        {
            ID = (ulong)row["ID"];
            post_url = HttpUtility.UrlDecode((string)row["post_name"]);
            post_type = (string)row["post_type"];
            post_title = (string)row["post_title"];
            post_content = formatPostContent((string)row["post_content"]);
            guid = (string)row["guid"];
            post_author = (ulong)row["post_author"];
            post_status = (string)row["post_status"];
            post_date = (DateTime)row["post_date"];
            thumbnail_url = row["thumbnail_url"].ToString();

            seo_under_h1 = row["seo_under_h1"].ToString();

            
            seo = new SEOFields() {
                title = row["seo_title"].ToString(),
                metaKeywords = row["seo_keywords"].ToString(),
                metaDescription = row["seo_metadesc"].ToString(),
                focuskw = row["seo_focuskw"].ToString(),
                priority = 0.5M,
                changeFrequency = Code.CMS.Sitemap.SitemapChangeFrequency.Monthly,
            };


            if (taxonomies != null)
            {
                this.taxonomies = new Dictionary<string, IEnumerable<string>>();

                foreach (string taxCode in taxonomies)
                {
                    if (string.IsNullOrEmpty(row["taxonomy_" + taxCode].ToString()))
                    {
                        this.taxonomies.Add(taxCode, new string[] { });
                    }
                    else
                    {
                        this.taxonomies.Add(taxCode, row["taxonomy_" + taxCode].ToString().Split(',').Select(x => CMSManager.ClearURL(HttpUtility.UrlDecode(x))));
                    }
                }
            }

            if (fields != null)
            {
                this.fields = new Dictionary<string, string>();
                foreach (string field in fields)
                    this.fields.Add(field, row["field_" + field].ToString());
            }

            attachments = new Dictionary<string, WpPost>();
            if (string.IsNullOrEmpty(row["attachment_urls"].ToString()) == false)
            {
                foreach (string attachment_url in row["attachment_urls"].ToString().Split(','))
                {
                    attachments.Add(attachment_url, null);
                }
            }

        }


        public void LoadMetaData(MySqlConnection conn, string prefix)
        {
            metaData = new Dictionary<string, string>();

            string sql = "SELECT meta_key, meta_value FROM wp_"+ prefix + "postmeta WHERE post_id = " + ID;

            MySqlDataAdapter adapter = new MySqlDataAdapter(sql, conn);
            DataSet dataset = new DataSet("TableData");
            adapter.Fill(dataset);

            foreach (DataRow row in dataset.Tables[0].Rows)
            {
                try {fields.Add(row["meta_key"].ToString(), row["meta_value"].ToString());}
                catch (Exception) { }
            }
        }

        private static string formatPostContent(string wpRawContentString)
        {
            string content = ReplaceNewLinesWithParagraphs(wpRawContentString);
            content = RemoveSquareTags(content);
            return content;
        }

        private static string ReplaceNewLinesWithParagraphs(string rawText)
        {
            if (string.IsNullOrEmpty(rawText))
                return rawText;

            string content = "";

            string goodBreak = string.Format("{0}{0}{1}{0}{0}", System.Environment.NewLine, CMSManager.postContentPreviewSeparator);

            if (rawText.Contains(goodBreak) == false)
                rawText = rawText.Replace(CMSManager.postContentPreviewSeparator, goodBreak);

            string[] paragraphs = rawText.Split(new string[] { string.Format("{0}{0}", System.Environment.NewLine) }, StringSplitOptions.None);
            foreach (string paragraph in paragraphs)
                if (String.IsNullOrEmpty(paragraph) == false)
                    content = content+"<p>" + paragraph + "</p>";

            return content;
        }

        private static string RemoveSquareTags(string content)
        {
            //http://stackoverflow.com/questions/740642/c-sharp-regex-split-everything-inside-square-brackets
            //https://www.dotnetperls.com/regex-replace
            return System.Text.RegularExpressions.Regex.Replace(content, @"\[(.*?)\]", delegate (System.Text.RegularExpressions.Match match)
            {
                string matchedString = match.ToString();
                if (matchedString.StartsWith("[audio "))
                    return matchedString;
                else
                    return "";
            });
        }

        public override string ToString()
        {
            return string.Format("ID:'{0}', author:'{1}', type:'{2}', status:'{3}', date:'{4}', title:'{5}', content (length):'{6}'", ID, post_author, post_type, post_status, post_date.ToString(), post_title, post_content.Count());
        }
    }
}
