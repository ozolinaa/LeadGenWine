using LeadGen.Code.CMS;
using LeadGen.Code.Helpers;
using LeadGen.Code.Taxonomy;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace LeadGen.Code.CMS
{
    public class PostTypeTaxonomy
    {
        public int? forPostTypeID { get; set; }
        public Taxonomy.Taxonomy taxonomy { get; set; }
        public PostType postType { get; set; }


        public static List<PostTypeTaxonomy> SelectFromDB(SqlConnection con, int? ForPostTypeID = null, int? ForTaxonomyID = null, bool EnabledOnly = true)
        {
            List<PostTypeTaxonomy> PostTypeTaxonomies = new List<PostTypeTaxonomy>();

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[CMSPostTypeTaxonomySelect]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ForPostTypeID", (object)ForPostTypeID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ForTaxonomyID", (object)ForTaxonomyID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@EnabledOnly", (object)EnabledOnly ?? DBNull.Value);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                
                foreach (DataRow row in dt.Rows)
                {
                    PostTypeTaxonomies.Add(new PostTypeTaxonomy() {
                        forPostTypeID = ForPostTypeID,
                        postType = row["TypeID"] == DBNull.Value ? new PostType() { url = "" } : new PostType(row),
                        taxonomy = new Taxonomy.Taxonomy(row) { isChecked = Convert.ToBoolean(row["IsEnabled"]) }
                    });
                }
            }

            return PostTypeTaxonomies;
        }

        public bool Update(SqlConnection con)
        {
            bool result = false;

            if (postType == null || taxonomy == null || forPostTypeID == null || String.IsNullOrEmpty(postType.url))
                return result;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[CMSPostTypeTaxonomyAddOrUpdate]";

                cmd.Parameters.AddWithValue("@ForPostTypeID", forPostTypeID.Value);
                cmd.Parameters.AddWithValue("@ForTaxonomyID", taxonomy.ID);
                cmd.Parameters.AddWithValue("@SeoTitle", DBNull.Value);
                cmd.Parameters.AddWithValue("@SeoMetaDescription", DBNull.Value);
                cmd.Parameters.AddWithValue("@SeoMetaKeywords", DBNull.Value);
                cmd.Parameters.AddWithValue("@SeoChangeFrequencyID", 4);
                cmd.Parameters.AddWithValue("@SeoPriority", 0.5);
                cmd.Parameters.AddWithValue("@URL", CMSManager.ClearURL(postType.url));


                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@Result";
                outputParameter.SqlDbType = SqlDbType.Bit;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(outputParameter.Value);

            }

            if (result)
            {
                postType = PostType.SelectFromDB(con, TypeURL: CMSManager.ClearURL(postType.url)).First(); //LoadID for newly created postType
                postType.LoadStartPost(con);  //Make sure start post is created
            }

            return result;
        }

        public void Disable (SqlConnection con)
        {

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[CMSPostTypeTaxonomyDisable]";

                cmd.Parameters.AddWithValue("@ForPostTypeID", forPostTypeID.Value);
                cmd.Parameters.AddWithValue("@ForTaxonomyID", taxonomy.ID);

                cmd.ExecuteNonQuery();

            }

        }

    }
}