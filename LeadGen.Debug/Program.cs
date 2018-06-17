using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LeadGen.Code;
using LeadGen.Code.CMS;
using System.Configuration;
using System.Net.Http;
using System.IO;
using System.Text.RegularExpressions;
using LeadGen.Code.Taxonomy;

namespace LeadGen.Debug
{
    class Program
    {

        static void Main(string[] args)
        {
            Debugger d = new Debugger();
            d.Run();

        }
    }

    public class Debugger
    {
        public SqlConnection con;

        public void Run()
        {
            using (con = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                con.Open();

                var ttt = Post.SelectFromDB(con, new List<string>() { "kladbisha/reutov/", "gorod/moskva", "znamenitostyam" });

            }
        }
    }
}
