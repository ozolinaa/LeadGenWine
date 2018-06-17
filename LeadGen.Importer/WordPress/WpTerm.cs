using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace LeadGen.Importer.WordPress
{
    public class WpTerm
    {
        //t.term_id, tt.parent, t.name, t.slug, tt.description, o_city_page_content_after.option_value as o_city_page_content_after,
        public ulong term_id { get; set; }
        public ulong? parent { get; set; }
        public string name { get; set; }
        public string slug { get; set; }
        public string taxonomy { get; set; }
        public string description { get; set; }
        public Dictionary<string, string> fields { get; set; }
        public Code.CMS.SEOFields SEO { get; set; }
        public List<WpTerm> childTerms { get; set; }

        public static List<WpTerm> SelectFromDB(MySqlConnection conn, string prefix, string taxonomy, IEnumerable<string> loadFields = null, dynamic taxSeo = null)
        {
            Console.WriteLine("Loading Wordpress Taxonomy \""+ taxonomy + "\"...");

            List<WpTerm> results = new List<WpTerm>();

            string sql = "SELECT  t.term_id, tt.taxonomy, tt.parent, t.name, t.slug, ";

            if (loadFields != null)
                foreach (string fieldCode in loadFields)
                    sql += string.Format("field_{0}.option_value as field_{0}, ", fieldCode);

            sql += "tt.description " +
                "FROM wp_" + prefix + "term_taxonomy tt " +
                "INNER JOIN wp_" + prefix + "terms t ON t.term_id = tt.term_id ";

            if (loadFields != null)
                foreach (string fieldCode in loadFields)
                    sql += string.Format("LEFT OUTER JOIN wp_" + prefix + "options field_{0} ON field_{0}.option_name = CONCAT('{1}_', t.term_id, '_{0}') ", fieldCode, taxonomy);

            sql += "WHERE tt.taxonomy = '" + taxonomy + "'" +
                "ORDER BY tt.parent, t.term_id";


            MySqlDataAdapter adapter = new MySqlDataAdapter(sql, conn);
            DataSet dataset = new DataSet("TableData");
            adapter.Fill(dataset);

            foreach (DataRow row in dataset.Tables[0].Rows)
            {
                results.Add(new WpTerm(row, loadFields, taxSeo) {taxonomy = taxonomy });
            }

            return results;
        }


        public WpTerm(DataRow row, IEnumerable<string> loadFields, dynamic taxSeo = null)
        {
            term_id = (ulong)row["term_id"];
            parent = row["parent"] == DBNull.Value ? null : (ulong?)row["parent"];
            name = (string)row["name"];
            slug = HttpUtility.UrlDecode((string)row["slug"]);
            description = (string)row["description"];

            if (loadFields != null)
            {
                fields = new Dictionary<string, string>();
                foreach (string fieldCode in loadFields)
                {
                    fields.Add(fieldCode, row["field_" + fieldCode].ToString());
                }
            }

            if (taxSeo != null)
            {
                try
                {
                    var termSeo = taxSeo[row["taxonomy"]][Convert.ToInt32(term_id.ToString())];
                    SEO = new Code.CMS.SEOFields()
                    {
                        title = termSeo["wpseo_title"],
                        metaKeywords = termSeo["wpseo_metakey"],
                        metaDescription = termSeo["wpseo_desc"],
                        priority = 0.5m,
                        changeFrequency = Code.CMS.Sitemap.SitemapChangeFrequency.Monthly
                    };
                }
                catch (Exception e)
                {
                }
            }

        }

        public WpTerm(WpTerm term, List<WpTerm> flatList)
        {
            term_id = term.term_id;
            parent = term.parent;
            name = term.name;
            slug = term.slug;
            description = term.description;
            taxonomy = term.taxonomy;

            SEO = term.SEO;
            fields = term.fields;

            //Initialize ChildTerms 
            childTerms = new List<WpTerm>();
            foreach (WpTerm childTerm in flatList.Where(x => x.parent != null && x.parent == term_id))
            {
                childTerms.Add(new WpTerm(childTerm, flatList));
            }
        }

        public static List<WpTerm> StructureizeFlatList(List<WpTerm> flatList)
        {
            Console.WriteLine("Structureizing Wordpress Taxonomy...");

            return flatList.Where(x => x.parent == 0).Select(x => new WpTerm(x, flatList)).ToList();
        }


        public override string ToString()
        {
            return String.Format("Term ID:{0}, Name:{1}", term_id, name);
        }
    }
}
