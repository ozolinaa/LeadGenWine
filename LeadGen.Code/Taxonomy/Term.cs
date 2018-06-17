using LeadGen.Code.CMS;
using LeadGen.Code.Helpers;
using LeadGen.Code.Sys;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace LeadGen.Code.Taxonomy
{
    public class Term : ICloneable
    {
        public long ID { get; set; }

        [Required]
        public string name { get; set; }
        public string nameDashed
        {
            get
            {
                if (level > 1)
                {
                    string Dashes = "";
                    for (int i = 1; i <= level-1; i++)
                        Dashes = Dashes + "-";

                    return Dashes + name;
                }
                else
                    return name;
            }
        }
        [Required]
        public string termURL { get; set; }
        public long? parentID { get; set; }
        public List<Term> childTerms { get; set; }
        public int? level { get; set; }
        public bool isChecked { get; set; }

        public string thumbnailURL { get; set; }

        public SEOFields SEO { get; set; }

        public Dictionary<string, Word> words { get; set; }

        //Need Parametress Constructor to make ModelBinder Work
        public Term()
        {
        }

        public Term(DataRow TermRow)
        {
            ID = (long)TermRow["TermID"];
            name = TermRow["TermName"].ToString();
            termURL = TermRow["TermURL"].ToString();
            parentID = (long?)(TermRow["TermParentID"] == DBNull.Value ? null : TermRow["TermParentID"]);
            thumbnailURL = TermRow["TermThumbnailURL"].ToString();

            if (TermRow.Table.Columns.Contains("SeoTitle"))
                SEO = new SEOFields(TermRow);
        }

        public Term(Term TermToInititalize, List<Term> AllTaxonomyTerms, int TermLevel)
        {
            ID = TermToInititalize.ID;
            name = TermToInititalize.name;
            termURL = TermToInititalize.termURL;
            parentID = TermToInititalize.parentID;
            SEO = TermToInititalize.SEO;
            level = TermLevel;

            //Initialize ChildTerms 
            childTerms = new List<Term>();
            foreach (Term ChildTerm in AllTaxonomyTerms.Where(x => x.parentID != null && x.parentID == ID))
            {
                childTerms.Add(new Term(ChildTerm, AllTaxonomyTerms, TermLevel + 1));
            }
        }

        public static List<Term> SelectFromDB(
            SqlConnection con, 
            long? TermID = null, 
            string TermURL = null, 
            string TermName = null, 
            int? TaxonomyID = null, 
            string TaxonomyName = null,
            string TaxonomyCode = null,
            long? TermParentID = 0,
            bool OnlyAllowedInLeads = false)
        {

            List<Term> TermList = new List<Term>();

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[Taxonomy.Term.Select]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TermID", (object)TermID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TermURL", (object)TermURL ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TermName", (object)TermName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TaxonomyID", (object)TaxonomyID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TaxonomyName", (object)TaxonomyName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TaxonomyCode", (object)TaxonomyCode ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TermParentID", (object)TermParentID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@OnlyAllowedInLeads", OnlyAllowedInLeads);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    //The New Term will NOT have information about Children or Level
                    TermList.Add(new Term(row));
                }
            }

            return TermList;
        }

        public List<Term> GetAllChildTermsInPlainList()
        {
            List<Term> result = new List<Term>();
            result.Add(this);
            if (childTerms != null)
                foreach (Term term in childTerms)
                    result.AddRange(term.GetAllChildTermsInPlainList());
            return result;
        }

        public bool TryUpdate(SqlConnection con, ref string errorMessage)
        {
            string DBresult = null;
            using (SqlCommand cmd = new SqlCommand())
            {

                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[Taxonomy.Term.Update]";

                cmd.Parameters.AddWithValue("@TermID", ID);
                cmd.Parameters.AddWithValue("@TermName", name);
                cmd.Parameters.AddWithValue("@TermURL", CMSManager.ClearURL(termURL));
                cmd.Parameters.AddWithValue("@TermParentID", (object)parentID ?? DBNull.Value);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@Result";
                outputParameter.SqlDbType = SqlDbType.NVarChar;
                outputParameter.Size = 255;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                DBresult = outputParameter.Value.ToString();
            }

            if (DBresult == "SUCCESS")
                return true;
            else
            {
                errorMessage = DBresult;
                return false;
            }
        }

        public long? TryInsert(SqlConnection con, int TaxonomyID, ref string errorMessage)
        {
            long termID;
            string DBresult = null;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[Taxonomy.Term.Insert]";

                cmd.Parameters.AddWithValue("@TaxonomyID", TaxonomyID);
                cmd.Parameters.AddWithValue("@TermName", name);
                cmd.Parameters.AddWithValue("@TermURL", CMSManager.ClearURL(termURL));
                cmd.Parameters.AddWithValue("@TermParentID", (object)parentID ?? DBNull.Value);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@Result";
                outputParameter.SqlDbType = SqlDbType.NVarChar;
                outputParameter.Size = 255;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                DBresult = outputParameter.Value.ToString();
            }

            if (Int64.TryParse(DBresult, out termID))
            {
                ID = termID;
                return termID;
            }

            errorMessage = DBresult;
            return null;
        }

        public static bool TryDelete(SqlConnection con, long termID)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[Taxonomy.Term.Delete]";

                cmd.Parameters.AddWithValue("@TermID", termID);

                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            return result;
        }

        public void SetSystemWord(SqlConnection con, long wordID, string wordCode)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[Taxonomy.Term.Word.Set]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TermID", ID);
                cmd.Parameters.AddWithValue("@WordID", wordID);
                cmd.Parameters.AddWithValue("@WordCode", wordCode);

                cmd.ExecuteNonQuery();
            }
        }

        public void LoadSystemWords(SqlConnection con, string wordCode = "")
        {
            words = new Dictionary<string, Word>();
            using (SqlCommand cmd = new SqlCommand("[dbo].[Taxonomy.Term.Word.Select]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TermID", ID);
                cmd.Parameters.AddWithValue("@WordCode", String.IsNullOrEmpty(wordCode) ? (object)DBNull.Value : wordCode);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    words.Add((string)row["TermWordCode"], new Word(row));
                }
            }
        }

        public Object Clone()
        {
            Term clonedTerm = new Term();

            clonedTerm.ID = ID;
            clonedTerm.name = name;
            clonedTerm.termURL = termURL;
            clonedTerm.parentID = parentID;
            clonedTerm.childTerms = childTerms;
            clonedTerm.level = level;
            clonedTerm.isChecked = isChecked;
            clonedTerm.SEO = SEO;
            clonedTerm.thumbnailURL = thumbnailURL;

            return clonedTerm;
        }
    }
}
