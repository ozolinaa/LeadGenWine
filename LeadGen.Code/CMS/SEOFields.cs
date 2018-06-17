using LeadGen.Code.CMS.Sitemap;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.CMS
{
    public class SEOFields
    {
        public string title { get; set; }
        public string metaDescription { get; set; }
        public string metaKeywords { get; set; }
        public SitemapChangeFrequency changeFrequency { get; set; }
        public decimal priority { get; set; }
        public string focuskw { get; set; }

        public SEOFields()
        {}

        public SEOFields(DataRow row)
        {
            title = row["SeoTitle"].ToString();
            metaKeywords = row["SeoMetaKeywords"].ToString();
            metaDescription = row["SeoMetaDescription"].ToString();
            changeFrequency = (SitemapChangeFrequency)(int)row["SeoChangeFrequencyID"];
            priority = (decimal)row["SeoPriority"];
        }

    }
}
