using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySql.Data;
using MySql.Data.MySqlClient;
using System.Configuration;

namespace LeadGen.Importer.WordPress
{
    public class WordPressClient : IDisposable
    {
        public MySqlConnection conn = null;

        public WordPressClient()
        {
            string connStr = ConfigurationManager.ConnectionStrings["WordPress"].ConnectionString;
            conn = new MySqlConnection(connStr);
            conn.Open();


            MySqlCommand cmd = new MySqlCommand("SET NAMES 'utf8'", conn);
            cmd.ExecuteNonQuery();
        }


        public List<WpTerm> LoadCityTaxonomy(string prefix = "")
        {
            dynamic taxSeo = get_wpseo_taxonomy_meta(conn, prefix);

            string[] fields = new string[] {
                "city_h1_text",
                "seo_under_h1",
                "city_page_content",
                "city_page_content_after",
                "case_genitive",
                "case_prepositional",
                "region_name",
                "region_name_case_genitive",
                "region_name_case_prepositional",
                "city_include_in_lists"
            };
            return WpTerm.StructureizeFlatList(WpTerm.SelectFromDB(conn, prefix, "pam_city", fields, taxSeo));
        }

        public List<WpTerm> LoadKladCityTaxonomy(string prefix = "")
        {
            dynamic taxSeo = get_wpseo_taxonomy_meta(conn, prefix);

            string[] fields = new string[] {
                "city_h1_text",
                "seo_under_h1",
                "city_page_content",
                "city_page_content_after",
                //"case_genitive",
                //"case_prepositional",
                //"region_name",
                //"region_name_case_genitive",
                //"region_name_case_prepositional"
            };
            return WpTerm.StructureizeFlatList(WpTerm.SelectFromDB(conn, prefix, "pam_city_klad", fields, taxSeo));
        }

        public List<WpTerm> LoadPamTagTaxonomy(string prefix = "")
        {
            dynamic taxSeo = get_wpseo_taxonomy_meta(conn, prefix);

            string[] fields = new string[] {
                "city_h1_text",
                "seo_under_h1"
            };

            return WpTerm.StructureizeFlatList(WpTerm.SelectFromDB(conn, prefix, "pam_mogila_tag", fields, taxSeo)); ;
        }

        public List<WpTerm> LoadPhotoShapeTaxonomy(string prefix = "")
        {
            return WpTerm.StructureizeFlatList(WpTerm.SelectFromDB(conn, prefix, "pam_foto_shape", null)); ;
        }
        public List<WpTerm> LoadPhotoMaterialTaxonomy(string prefix = "")
        {
            return WpTerm.StructureizeFlatList(WpTerm.SelectFromDB(conn, prefix, "pam_foto_material", null)); ;
        }
        public List<WpTerm> LoadPhotoPriceTaxonomy(string prefix = "")
        {
            return WpTerm.StructureizeFlatList(WpTerm.SelectFromDB(conn, prefix, "pam_foto_price", null)); ;
        }
        public List<WpTerm> LoadPhotoAdditionTaxonomy(string prefix = "")
        {
            return WpTerm.StructureizeFlatList(WpTerm.SelectFromDB(conn, prefix, "pam_foto_addition", null)); ;
        }

        public List<WpPost> LoadMasterPosts(string prefix = "")
        {
            List<WpPost> masters = WpPost.SelectFromDB(conn, prefix, "pam_master", "publish", new string[] { "crm_company_id" }, null);
            masters.AddRange(WpPost.SelectFromDB(conn, prefix, "pam_master", "draft", new string[] { "crm_company_id" }, null));

            return masters;
        }

        public Dictionary<string, WpPost> LoadAttachmentPosts(string prefix = "")
        {
            Dictionary<string, WpPost> attachments = new Dictionary<string, WpPost>();
            foreach (WpPost post in WpPost.SelectFromDB(conn, prefix, "attachment", "inherit", null, new string[] { "pam_foto_shape", "pam_foto_material", "pam_foto_addition", "pam_foto_price" }))
            {
                if (attachments.ContainsKey(post.guid) == false)
                {
                    attachments.Add(post.guid, post);
                }
            }
            return attachments;
        }
        
        public List<WpPost> LoadKladPosts(string prefix = "")
        {
            List<WpPost> kladPosts = WpPost.SelectFromDB(conn, prefix, "pam_klad", "publish", new string[] { "klad_phone", "klad_site", "klad_email", "klad_address", "klad_map" }, new string[] { "pam_city_klad" });
            return kladPosts;
        }

        public List<WpPost> LoadPamPosts(string prefix = "")
        {
            List<WpPost> pamPosts = WpPost.SelectFromDB(conn, prefix, "pam_mogila", "publish", new string[] { "klad_map" }, new string[] { "pam_mogila_tag" });
            return pamPosts;
        }

        public List<WpPost> LoadPages(string prefix = "")
        {
            List<WpPost> pagePosts = WpPost.SelectFromDB(conn, prefix, "page", "publish", new string[] { "seo_under_h1" }, new string[] { });
            return pagePosts;
        }

        public List<WpTerm> LoadCMSTagTaxonomy(string prefix = "")
        {
            dynamic taxSeo = get_wpseo_taxonomy_meta(conn, prefix);

            string[] fields = new string[] {"seo_under_h1"};

            return WpTerm.StructureizeFlatList(WpTerm.SelectFromDB(conn, prefix, "post_tag", fields, taxSeo)); ;
        }

        public List<WpTerm> LoadCMSCategoryTaxonomy(string prefix = "")
        {
            dynamic taxSeo = get_wpseo_taxonomy_meta(conn, prefix);

            string[] fields = new string[] { "seo_under_h1" };

            return WpTerm.StructureizeFlatList(WpTerm.SelectFromDB(conn, prefix, "category", fields, taxSeo)); ;
        }

        public List<WpPost> LoadArticlePosts(string prefix = "")
        {
            List<WpPost> pamArticles = WpPost.SelectFromDB(conn, prefix, "pam_article", "publish", new string[] { }, new string[] { "category", "post_tag" });
            return pamArticles;
        }

        public List<WpBusiness> LoadBusinesses(string prefix = "")
        {
            List<WpBusiness> businesses = WpBusiness.SelectFromDB(conn, prefix);
            return businesses;
        }

        public List<WpPost> LoadLeadPosts(string status, string prefix = "")
        {
            string[] fields = new string[] {
                "order_email"
            };

            string[] taxonomies = new string[] {
                "pam_shape",
                "pam_material",
                "pam_addition",
                "pam_price",
                "pam_city"
            };

            List<WpPost> leadPosts = WpPost.SelectFromDB(conn, prefix, "pam_order", status, fields, taxonomies);

            return leadPosts.Where(x=>x.fields["order_email"] != "sample@email.tst").ToList();
        }

        public List<WpPost> LoadWpInvoicesPosts(string prefix = "")
        {
            string[] fields = new string[] {
                "invoice_sum",
                "invoice_paid_date",
                "invoice_orders_included",
                "invoice_for_user_id",
                "invoice_for_period",
                "invoice_factura_number",
                "invoice_buh_number",
                "invoice_act_number",
                "inv_service_item",
                "inv_prod_rs",
                "inv_prod_name",
                "inv_prod_kpp",
                "inv_prod_kors",
                "inv_prod_inn",
                "inv_prod_bik",
                "inv_prod_bank_name",
                "inv_prod_address",
                "inv_pok_name",
                "inv_pok_kpp",
                "inv_pok_inn",
                "inv_pok_address",
                "fee_descriptions",
                "fee_summ"
            };

            List<WpPost> invoicePosts = WpPost.SelectFromDB(conn, prefix, "pam_invoice", "publish", fields, new string[] { });
            return invoicePosts;
        }

        public List<WpPost> LoadLeadReviews(string status, string prefix = "")
        {
            string[] fields = new string[] {
                "review_from_order",
                "review_for_reg_master",
                "review_for_not_reg_master",
                "review_order_not_complete",
                "review_fio",
                "rating_price",
                "rating_quality",
                "rating_speed",
                "rating_comfort",
                "price_pam",
                "price_install"
            };

            List<WpPost> leadReviews = WpPost.SelectFromDB(conn, prefix, "pam_review", status, fields, new string[] { });

            return leadReviews;
        }







        private dynamic get_wpseo_taxonomy_meta(MySqlConnection conn, string prefix = "")
        {
            Option wpseo = Option.SelectFromDB(conn, prefix, "wpseo_taxonomy_meta");
            PHPSerializer php = new PHPSerializer();
            return php.Deserialize(wpseo.option_value);
        }


        public static Code.Map.Location parseWpMap(string wpMapPHPSerialized)
        {
            PHPSerializer php = new PHPSerializer();
            dynamic wpMap = php.Deserialize(wpMapPHPSerialized);

            try
            {
                Code.Map.Location location = new Code.Map.Location()
                {
                    lat = Convert.ToDouble(wpMap["lat"]),
                    lng = Convert.ToDouble(wpMap["lng"]),
                    address = wpMap["address"],
                    zoom = 13
                };
                return location;
            }
            catch (Exception e)
            {
                return null;
            }

        }



        public void Dispose()
        {
            if (conn != null)
            {
                conn.Close();
                conn.Dispose();
            }
        }
    }
}
