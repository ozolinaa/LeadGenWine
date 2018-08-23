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
    public class PostTypeAttachmentTaxonomy
    {
        public Taxonomy.Taxonomy taxonomy { get; set; }
        public int postTypeID { get; set; }

        public static List<PostTypeAttachmentTaxonomy> SelectFromDB(SqlConnection con, int postTypeID, bool enabledOnly = true)
        {
            List<PostTypeAttachmentTaxonomy> postTypeAttachmentTaxonomies = new List<PostTypeAttachmentTaxonomy>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[CMSPostTypeAttachmentTaxonomySelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PostTypeID", (object)postTypeID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@EnabledOnly", (object)enabledOnly ?? DBNull.Value);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                
                foreach (DataRow row in dt.Rows)
                {
                    postTypeAttachmentTaxonomies.Add(new PostTypeAttachmentTaxonomy() {
                        postTypeID = (int)row["PostTypeID"],
                        taxonomy = new Taxonomy.Taxonomy(row) { isChecked = Convert.ToBoolean(row["IsEnabled"]) }
                    });
                }
            }

            return postTypeAttachmentTaxonomies;
        }

        public void Update(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[CMSPostTypeAttachmentTaxonomyAddOrUpdate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PostTypeID", postTypeID);
                cmd.Parameters.AddWithValue("@AttachmentTaxonomyID", taxonomy.ID);

                cmd.ExecuteNonQuery();
            }
        }

        public void Disable(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[CMSPostTypeAttachmentTaxonomyDisable]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PostTypeID", postTypeID);
                cmd.Parameters.AddWithValue("@AttachmentTaxonomyID", taxonomy.ID);

                cmd.ExecuteNonQuery();
            }
        }

    }
}