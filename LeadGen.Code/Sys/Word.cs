using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Sys
{
    public class Word
    {
        public long? ID { get; set; }
        public string nominativeSingular { get; set; }
        public string genitiveSingular { get; set; }
        public string dativeSingular { get; set; }
        public string accusativeSingular { get; set; }
        public string instrumentalSingular { get; set; }
        public string prepositionalSingular { get; set; }
        public string nominativePlural { get; set; }
        public string genitivePlural { get; set; }
        public string dativePlural { get; set; }
        public string accusativePlural { get; set; }
        public string instrumentalPlural { get; set; }
        public string prepositionalPlural { get; set; }


        public Word()
        {
        }

        public Word(string word)
        {
            nominativeSingular = word;
        }

        public Word(DataRow row)
        {
            ID = (long)row["WordID"];
            nominativeSingular = row["NominativeSingular"].ToString();
            genitiveSingular = row["GenitiveSingular"].ToString();
            dativeSingular = row["DativeSingular"].ToString();
            accusativeSingular = row["AccusativeSingular"].ToString();
            instrumentalSingular = row["InstrumentalSingular"].ToString();
            prepositionalSingular = row["PrepositionalSingular"].ToString();
            nominativePlural = row["NominativePlural"].ToString();
            genitivePlural = row["GenitivePlural"].ToString();
            dativePlural = row["DativePlural"].ToString();
            accusativePlural = row["AccusativePlural"].ToString();
            instrumentalPlural = row["InstrumentalPlural"].ToString();
            prepositionalPlural = row["PrepositionalPlural"].ToString();
        }

        public void SaveInDB(SqlConnection con)
        {
            if (ID == null)
                InsertToDB(con);
            else
                UpdateInDB(con);
        }

        private void InsertToDB(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[SysWordCaseInsert]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@NominativeSingular", String.IsNullOrEmpty(nominativeSingular) ? (object)DBNull.Value : nominativeSingular);
                cmd.Parameters.AddWithValue("@GenitiveSingular", String.IsNullOrEmpty(genitiveSingular) ? (object)DBNull.Value : genitiveSingular);
                cmd.Parameters.AddWithValue("@DativeSingular", String.IsNullOrEmpty(dativeSingular) ? (object)DBNull.Value : dativeSingular);
                cmd.Parameters.AddWithValue("@AccusativeSingular", String.IsNullOrEmpty(accusativeSingular) ? (object)DBNull.Value : accusativeSingular);
                cmd.Parameters.AddWithValue("@InstrumentalSingular", String.IsNullOrEmpty(instrumentalSingular) ? (object)DBNull.Value : instrumentalSingular);
                cmd.Parameters.AddWithValue("@PrepositionalSingular", String.IsNullOrEmpty(prepositionalSingular) ? (object)DBNull.Value : prepositionalSingular);
                cmd.Parameters.AddWithValue("@NominativePlural", String.IsNullOrEmpty(nominativePlural) ? (object)DBNull.Value : nominativePlural);
                cmd.Parameters.AddWithValue("@GenitivePlural", String.IsNullOrEmpty(genitivePlural) ? (object)DBNull.Value : genitivePlural);
                cmd.Parameters.AddWithValue("@DativePlural", String.IsNullOrEmpty(dativePlural) ? (object)DBNull.Value : dativePlural);
                cmd.Parameters.AddWithValue("@AccusativePlural", String.IsNullOrEmpty(accusativePlural) ? (object)DBNull.Value : accusativePlural);
                cmd.Parameters.AddWithValue("@InstrumentalPlural", String.IsNullOrEmpty(instrumentalPlural) ? (object)DBNull.Value : instrumentalPlural);
                cmd.Parameters.AddWithValue("@PrepositionalPlural", String.IsNullOrEmpty(prepositionalPlural) ? (object)DBNull.Value : prepositionalPlural);

                SqlParameter wordIDParameter = new SqlParameter();
                wordIDParameter.ParameterName = "@WordID";
                wordIDParameter.SqlDbType = SqlDbType.BigInt;
                wordIDParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(wordIDParameter);

                cmd.ExecuteNonQuery();
                ID = (long)wordIDParameter.Value;
            }
        }

        private void UpdateInDB(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[SysWordCaseUpdate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@WordID", ID);
                cmd.Parameters.AddWithValue("@NominativeSingular", String.IsNullOrEmpty(nominativeSingular) ? (object)DBNull.Value : nominativeSingular);
                cmd.Parameters.AddWithValue("@GenitiveSingular", String.IsNullOrEmpty(genitiveSingular) ? (object)DBNull.Value : genitiveSingular);
                cmd.Parameters.AddWithValue("@DativeSingular", String.IsNullOrEmpty(dativeSingular) ? (object)DBNull.Value : dativeSingular);
                cmd.Parameters.AddWithValue("@AccusativeSingular", String.IsNullOrEmpty(accusativeSingular) ? (object)DBNull.Value : accusativeSingular);
                cmd.Parameters.AddWithValue("@InstrumentalSingular", String.IsNullOrEmpty(instrumentalSingular) ? (object)DBNull.Value : instrumentalSingular);
                cmd.Parameters.AddWithValue("@PrepositionalSingular", String.IsNullOrEmpty(prepositionalSingular) ? (object)DBNull.Value : prepositionalSingular);
                cmd.Parameters.AddWithValue("@NominativePlural", String.IsNullOrEmpty(nominativePlural) ? (object)DBNull.Value : nominativePlural);
                cmd.Parameters.AddWithValue("@GenitivePlural", String.IsNullOrEmpty(genitivePlural) ? (object)DBNull.Value : genitivePlural);
                cmd.Parameters.AddWithValue("@DativePlural", String.IsNullOrEmpty(dativePlural) ? (object)DBNull.Value : dativePlural);
                cmd.Parameters.AddWithValue("@AccusativePlural", String.IsNullOrEmpty(accusativePlural) ? (object)DBNull.Value : accusativePlural);
                cmd.Parameters.AddWithValue("@InstrumentalPlural", String.IsNullOrEmpty(instrumentalPlural) ? (object)DBNull.Value : instrumentalPlural);
                cmd.Parameters.AddWithValue("@PrepositionalPlural", String.IsNullOrEmpty(prepositionalPlural) ? (object)DBNull.Value : prepositionalPlural);

                cmd.ExecuteNonQuery();
            }
        }

        public static void LoadWordsForTerms(SqlConnection con, ref List<Taxonomy.Term> terms, string wordCode = null)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[TaxonomyTermWordSelectForMany]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add(DBHelper.GetNumericTableTypeParamter("@TermIDTable", "[dbo].[SysBigintTableType]", terms.Select(x => x.ID)));
                cmd.Parameters.AddWithValue("@WordCode", String.IsNullOrEmpty(wordCode) ? (object)DBNull.Value : wordCode);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);

                foreach (DataRow TermIDRow in dt.DefaultView.ToTable(true, "TermID").Rows)
                {
                    long termID = (long)TermIDRow["TermID"];
                    Taxonomy.Term term = terms.First(x => x.ID == termID);
                    term.words = new Dictionary<string, Word>();

                    foreach (DataRow wordRow in dt.Select(String.Format("TermID = {0} AND TermID IS NOT NULL", termID)))
                    {
                        term.words.Add((string)wordRow["TermWordCode"], new Word(wordRow));
                    }
                }
            }
        }
    }
}
