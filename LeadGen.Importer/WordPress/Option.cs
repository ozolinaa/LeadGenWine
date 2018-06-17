using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Importer.WordPress
{
    public class Option
    {
        public string option_name { get; set; }
        public string option_value { get; set; }

        public static Option SelectFromDB(MySqlConnection conn, string prefix, string option_name)
        {
            string sql = "SELECT * FROM wp_" + prefix + "options WHERE option_name = '"+ option_name + "'";

            MySqlDataAdapter adapter = new MySqlDataAdapter(sql, conn);
            DataSet dataset = new DataSet("TableData");
            adapter.Fill(dataset);

            if (dataset.Tables[0].Rows.Count == 1)
                return new Option(dataset.Tables[0].Rows[0]);

            return null;
        }

        public Option(DataRow row)
        {
            option_name = (string)row["option_name"];
            option_value = (string)row["option_value"];
        }
    }
}
