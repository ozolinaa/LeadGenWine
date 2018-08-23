using LeadGen.Code.CMS;
using LeadGen.Code.CMS.Sitemap;
using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Taxonomy
{
    public class Taxonomy
    {
        public int ID { get; set; }
        public string code { get; set; }
        public string name { get; set; }
        public bool isTag { get; set; }

        public List<Term> termList { get; set; }

        public bool isChecked { get; set; }

        //Need Parametress Constructor to make ModelBinder Work
        public Taxonomy()
        {
        }

        public Taxonomy(DataRow TaxonomyRow)
        {
            ID = (int)TaxonomyRow["TaxonomyID"];
            code = (string)TaxonomyRow["TaxonomyCode"];
            name = (string)TaxonomyRow["TaxonomyName"];
            isTag = Convert.ToBoolean(TaxonomyRow["IsTag"]);
        }


        public static List<Taxonomy> SelectFromDB(SqlConnection con, int? TaxonomyID = null, string TaxonomyCode = null, string TaxonomyName = null)
        {
            List<Taxonomy> TaxonomyList = new List<Taxonomy>();

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[TaxonomySelect]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TaxonomyID", (object)TaxonomyID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TaxonomyCode", (object)TaxonomyCode ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TaxonomyName", (object)TaxonomyName ?? DBNull.Value);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    TaxonomyList.Add(new Taxonomy(row));
                }
            }

            return TaxonomyList;
        }




        public void LoadTerms(SqlConnection con)
        {
            //Load complete TermList with Children and Levels

                //Load plain list of AllTaxonomyTerms
                List<Term> AllTaxonomyTerms = Term.SelectFromDB(con, TaxonomyID: ID);
                //In This list will be loaded Top Level terms with complete tree of offstrings
                List<Term> TopLevelTermListWithChildren = new List<Term>();
                foreach (Term TopLevelTerm in AllTaxonomyTerms.Where(x => x.parentID == null))
                {
                    //Term Children will be initialized automatically in Term constructor
                    TopLevelTermListWithChildren.Add(new Term(TopLevelTerm, AllTaxonomyTerms, 1));
                }
                //Fill plain TermList with all terms from every level of TopLevelTermListWithChildren
                termList = new List<Term>();
                FillTermList(TopLevelTermListWithChildren);
        }

        private void FillTermList(List<Term> LevelTermList)
        {
            if (LevelTermList != null && LevelTermList.Count > 0)
                foreach (Term TermItem in LevelTermList)
                {
                    termList.Add(TermItem); //AddTerm
                    FillTermList(TermItem.childTerms); //AddTermChildren
                }
        }

        //public bool UpdateForPostType(SqlConnection con, int PostTypeID)
        //{

        //    bool DBresult = false;

        //    using (SqlCommand cmd = new SqlCommand())
        //    {
        //        cmd.Connection = con;
        //        cmd.CommandText = "[dbo].[CMS.Post.Type.Taxonomy.Update]";
        //        cmd.CommandType = CommandType.StoredProcedure;

        //        cmd.Parameters.AddWithValue("@PostTypeID", PostTypeID);
        //        cmd.Parameters.AddWithValue("@TaxonomyID", ID);
        //        cmd.Parameters.AddWithValue("@seoTitle", String.IsNullOrEmpty(SEO.title) ? (object)DBNull.Value : SEO.title);
        //        cmd.Parameters.AddWithValue("@seoMetaDescription", String.IsNullOrEmpty(SEO.metaDescription) ? (object)DBNull.Value : SEO.metaDescription);
        //        cmd.Parameters.AddWithValue("@seoMetaKeywords", String.IsNullOrEmpty(SEO.metaKeywords) ? (object)DBNull.Value : SEO.metaKeywords);
        //        cmd.Parameters.AddWithValue("@seoChangeFrequencyID", SEO.changeFrequency);
        //        cmd.Parameters.AddWithValue("@seoPriority", SEO.priority);

        //        SqlParameter outputParameter = new SqlParameter();
        //        outputParameter.ParameterName = "@Result";
        //        outputParameter.SqlDbType = SqlDbType.Bit;
        //        outputParameter.Direction = ParameterDirection.Output;
        //        cmd.Parameters.Add(outputParameter);

        //        cmd.ExecuteNonQuery();

        //        Boolean.TryParse(outputParameter.Value.ToString(), out DBresult);
        //    }

        //    return DBresult;

        //}

        public long? TryInsert(SqlConnection con, ref string errorMessage)
        {
            long taxonomyID;
            string DBresult = null;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[TaxonomyInsert]";

                cmd.Parameters.AddWithValue("@TaxonomyCode", CMSManager.ClearURL(code));
                cmd.Parameters.AddWithValue("@TaxonomyName", name);
                cmd.Parameters.AddWithValue("@IsTag", isTag);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@Result";
                outputParameter.SqlDbType = SqlDbType.NVarChar;
                outputParameter.Size = 255;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                DBresult = outputParameter.Value.ToString();
            }

            if (Int64.TryParse(DBresult, out taxonomyID))
                return taxonomyID;

            errorMessage = DBresult;
            return null;
        }


        public bool TryUpdate(SqlConnection con, ref string errorMessage)
        {
            bool result = false;

            using (SqlCommand cmd = new SqlCommand())
            {

                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[TaxonomyUpdate]";

                cmd.Parameters.AddWithValue("@TaxonomyID", ID); 
                cmd.Parameters.AddWithValue("@TaxonomyCode", code);
                cmd.Parameters.AddWithValue("@TaxonomyName", name);
                cmd.Parameters.AddWithValue("@IsTag", isTag);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@Result";
                outputParameter.SqlDbType = SqlDbType.Bit;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(outputParameter.Value);
            }

            return result;
        }


    }
}
