using LeadGen.Code.CMS.Sitemap;
using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace LeadGen.Code.CMS
{
    public class PostType
    {

        public int ID { get; set; }
        public string code { get; set; }
        public string url { get; set; }
        public string name { get; set; }
        public bool hasContentIntro { get; set; }
        public bool hasContentEnding { get; set; }
        public bool isBrowsable { get; set; }
        public List<PostTypeTaxonomy> taxonomyList { get; set; }
        public SEOFields SEO { get; set; }
        public SEOFields postSEO { get; set; }

        public Post startPost { get; set; }

        public int? forTaxonomyID { get; set; }
        public int? forPostTypeID { get; set; }

        public PostType() { }

        public PostType(DataRow row)
        {
            ID = (int)row["TypeID"];
            code = row["TypeCode"].ToString();
            url = row["TypeURL"].ToString();
            name = row["TypeName"].ToString();
            isBrowsable = Convert.ToBoolean(row["IsBrowsable"]);
            hasContentIntro = Convert.ToBoolean(row["HasContentIntro"]);
            hasContentEnding = Convert.ToBoolean(row["HasContentEnding"]);
            SEO = new SEOFields(row);
            postSEO = new SEOFields
            {
                title = row["postSeoTitle"].ToString(),
                metaDescription = row["postSeoMetaDescription"].ToString(),
                metaKeywords = row["postSeoMetaKeywords"].ToString(),
                priority = (decimal)row["postSeoPriority"],
                changeFrequency = (SitemapChangeFrequency)(int)row["postSeoChangeFrequencyID"]
            };

            forTaxonomyID = (int?)(row["ForTaxonomyID"] == DBNull.Value ? null : row["ForTaxonomyID"]);
            forPostTypeID = (int?)(row["ForPostTypeID"] == DBNull.Value ? null : row["ForPostTypeID"]);
        }



        public static List<PostType> SelectFromDB(SqlConnection con, int? TypeID = null, string TypeCode = null, string TypeURL = null, string TypeName = null)
        {
            List<PostType> postTypeList = new List<PostType>();

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[CMS.Post.Type.Select]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TypeID", (object)TypeID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TypeCode", (object)TypeCode ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TypeURL", (object)TypeURL ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TypeName", (object)TypeName ?? DBNull.Value);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    postTypeList.Add(new PostType(row));
                }
            }

            return postTypeList;
        }

        public bool Update(SqlConnection con)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[CMS.Post.Type.Update]";

                if (SEO == null)
                    SEO = new SEOFields();
                if (postSEO == null)
                    postSEO = new SEOFields();

                cmd.Parameters.AddWithValue("@PostTypeID", ID);
                cmd.Parameters.AddWithValue("@typeCode", CMSManager.ClearURL(code));
                cmd.Parameters.AddWithValue("@typeName", string.IsNullOrEmpty(name) ? "" : name);
                cmd.Parameters.AddWithValue("@typeURL", CMSManager.ClearURL(url));
                cmd.Parameters.AddWithValue("@isBrowsable", isBrowsable);
                cmd.Parameters.AddWithValue("@seoTitle", string.IsNullOrEmpty(SEO.title) ? (object)DBNull.Value : SEO.title);
                cmd.Parameters.AddWithValue("@seoMetaDescription", string.IsNullOrEmpty(SEO.metaDescription) ? (object)DBNull.Value : SEO.metaDescription);
                cmd.Parameters.AddWithValue("@seoMetaKeywords", string.IsNullOrEmpty(SEO.metaKeywords) ? (object)DBNull.Value : SEO.metaKeywords);
                cmd.Parameters.AddWithValue("@seoChangeFrequencyID", SEO.changeFrequency);
                cmd.Parameters.AddWithValue("@seoPriority", SEO.priority);
                cmd.Parameters.AddWithValue("@postSeoTitle", string.IsNullOrEmpty(postSEO.title) ? (object)DBNull.Value : postSEO.title);
                cmd.Parameters.AddWithValue("@postSeoMetaDescription", string.IsNullOrEmpty(postSEO.metaDescription) ? (object)DBNull.Value : postSEO.metaDescription);
                cmd.Parameters.AddWithValue("@postSeoMetaKeywords", string.IsNullOrEmpty(postSEO.metaKeywords) ? (object)DBNull.Value : postSEO.metaKeywords);
                cmd.Parameters.AddWithValue("@postSeoChangeFrequencyID", postSEO.changeFrequency);
                cmd.Parameters.AddWithValue("@postSeoPriority", postSEO.priority);
                cmd.Parameters.AddWithValue("@HasContentIntro", hasContentIntro);
                cmd.Parameters.AddWithValue("@HasContentEnding", hasContentEnding);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@Result";
                outputParameter.SqlDbType = SqlDbType.Bit;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();
                result = Boolean.Parse(outputParameter.Value.ToString());
            }

            return result;
        }

        public bool Insert (SqlConnection con, ref string errorText)
        {
            int insertedID = 0;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[CMS.Post.Type.Insert]";

                if (SEO == null)
                    SEO = new SEOFields();
                if (postSEO == null)
                    postSEO = new SEOFields();

                cmd.Parameters.AddWithValue("@typeCode", CMSManager.ClearURL(code));
                cmd.Parameters.AddWithValue("@typeName", string.IsNullOrEmpty(name) ? "" : name);
                cmd.Parameters.AddWithValue("@typeURL", CMSManager.ClearURL(url));
                cmd.Parameters.AddWithValue("@isBrowsable", isBrowsable);
                cmd.Parameters.AddWithValue("@seoTitle", string.IsNullOrEmpty(SEO.title) ? (object)DBNull.Value : SEO.title);
                cmd.Parameters.AddWithValue("@seoMetaDescription", string.IsNullOrEmpty(SEO.metaDescription) ? (object)DBNull.Value : SEO.metaDescription);
                cmd.Parameters.AddWithValue("@seoMetaKeywords", string.IsNullOrEmpty(SEO.metaKeywords) ? (object)DBNull.Value : SEO.metaKeywords);
                cmd.Parameters.AddWithValue("@seoChangeFrequencyID", SEO.changeFrequency);
                cmd.Parameters.AddWithValue("@seoPriority", SEO.priority);
                cmd.Parameters.AddWithValue("@postSeoTitle", string.IsNullOrEmpty(postSEO.title) ? (object)DBNull.Value : postSEO.title);
                cmd.Parameters.AddWithValue("@postSeoMetaDescription", string.IsNullOrEmpty(postSEO.metaDescription) ? (object)DBNull.Value : postSEO.metaDescription);
                cmd.Parameters.AddWithValue("@postSeoMetaKeywords", string.IsNullOrEmpty(postSEO.metaKeywords) ? (object)DBNull.Value : postSEO.metaKeywords);
                cmd.Parameters.AddWithValue("@postSeoChangeFrequencyID", postSEO.changeFrequency);
                cmd.Parameters.AddWithValue("@postSeoPriority", postSEO.priority);
                cmd.Parameters.AddWithValue("@HasContentIntro", hasContentIntro);
                cmd.Parameters.AddWithValue("@HasContentEnding", hasContentEnding);

                SqlParameter idParameter = new SqlParameter();
                idParameter.ParameterName = "@typeID";
                idParameter.SqlDbType = SqlDbType.Int;
                idParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(idParameter);

                SqlParameter errorParameter = new SqlParameter();
                errorParameter.ParameterName = "@errorText";
                errorParameter.SqlDbType = SqlDbType.NVarChar;
                errorParameter.Size = 100;
                errorParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(errorParameter);

                cmd.ExecuteNonQuery();
                if (Int32.TryParse(idParameter.Value.ToString(), out insertedID))
                    ID = insertedID;
                else
                    errorText = errorParameter.Value.ToString();
            }
            //return true if insertedID != 0
            return insertedID != 0;
        }

        public void LoadTaxonomyList(SqlConnection con)
        {
            taxonomyList = PostTypeTaxonomy.SelectFromDB(con, ForPostTypeID: ID);
        }

        public void LoadStartPost(SqlConnection con, 
            bool loadTaxonomySelectedList = false,
            bool loadAttachmentList = false,
            bool loadFields = false)
        {
            startPost = Post.SelectFromDB(con, typeID: ID, postURL: "").FirstOrDefault();

            if (startPost == null)
                CreateStartPost(con);

            if (loadAttachmentList)
                startPost.LoadAttachments(con);
            if (loadFields)
                startPost.LoadFields(con);
            if (loadTaxonomySelectedList)
                startPost.LoadTaxonomies(con, loadTerms: true, termsCheckedOnly: true);
        }

        private void CreateStartPost(SqlConnection con) {
            startPost = Post.SelectFromDB(con, postID: Post.CreateNew(con, 1, ID)).First();
            startPost.postStatus.ID = 50;//Set Published
            startPost.postURL = "";
            string errorMessage = "";
            startPost.Update(con, ref errorMessage);
        }


    }
}
