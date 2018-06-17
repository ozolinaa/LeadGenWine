using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.CMS
{
    public class CMSterm
    {
        public static List<Taxonomy.Term> SelectFromDB(SqlConnection con, int? TaxonomyID = null, long? PostID = null, long? AttachmentID = null)
        {
            List<Taxonomy.Term> TermList = new List<Taxonomy.Term>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[CMS.Term.Select]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TaxonomyID", (object)TaxonomyID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@PostID", (object)PostID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@AttachmentID", (object)AttachmentID ?? DBNull.Value);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    //The New Term will NOT have information about Children or Level
                    TermList.Add(new Taxonomy.Term(row));
                }
            }

            return TermList;
        }
    }
}
