using LeadGen.Code.Helpers;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static LeadGen.Code.Helpers.DBHelper;

namespace LeadGen.Importer.EPESI
{
    public class Company
    {

        public long ID { get; set; }
        public string name
        {
            get
            {
                string result = string.Empty;
                fields.TryGetValue("company_name", out result);
                return result;
            }
            set
            {
                if (fields == null)
                    fields = new Dictionary<string, string>();
                if (fields.ContainsKey("company_name") == false)
                    fields.Add("company_name", value);
                else
                    fields["company_name"] = value;
            }
        }
        public string shortName
        {
            get
            {
                string result = string.Empty;
                fields.TryGetValue("short_name", out result);
                return result;
            }
            set
            {
                if (fields == null)
                    fields = new Dictionary<string, string>();
                if (fields.ContainsKey("short_name") == false)
                    fields.Add("short_name", value);
                else
                    fields["short_name"] = value;
            }
        }

        public Dictionary<string, string> fields { get; set; }

        public Dictionary<string, List<Group>> groups { get; set; }

        public Company(DataRow row)
        {
            fields = new Dictionary<string, string>();
            groups = new Dictionary<string, List<Group>>();

            foreach (DataColumn column in row.Table.Columns)
            {
                switch (column.ColumnName)
                {
                    case "id":
                        ID = Convert.ToInt64(row[column.ColumnName]);
                        break;
                    default:
                        if (column.ColumnName.StartsWith("f_"))
                            fields.Add(column.ColumnName.Substring(2, column.ColumnName.Length - 2), row[column.ColumnName].ToString());
                        break;
                }
            }
        }

        public void InitializeGroupsFromFields(string groupKey, Dictionary<string, string> availebleGroups)
        {
            List<Group> epesiGroupsToPopulate = new List<Group>();
            groups.Add(groupKey, epesiGroupsToPopulate);

            foreach (string groupCompoundKey in fields[groupKey].Split(new string[] { "__" }, StringSplitOptions.RemoveEmptyEntries))
                epesiGroupsToPopulate.Add(new Group(groupCompoundKey, availebleGroups));
        }

        public void InitializeFieldsFromGroups(string groupKey)
        {
            string groupValueStr = "";
            if(groups != null && groups.ContainsKey(groupKey))
                groupValueStr = string.Join("__", groups[groupKey]);

            fields[groupKey] = string.IsNullOrEmpty(groupValueStr) ? "" : string.Format("__{0}__", groupValueStr);
        }


        public override string ToString()
        {
            return string.Format("ID:'{0}', name:'{1}'", ID, name);
        }


        public static List<Company> SelectFromDB(MySqlConnection conn, List<SQLfilter> SQLFilters = null, bool isActiveOnly = true )
        {
            List<Company> results = new List<Company>();

            if (SQLFilters == null)
                SQLFilters = new List<SQLfilter>();


            if (isActiveOnly)
                SQLFilters.Add( new SQLfilter() {
                    fieldName = "active",
                    parameterName = "isActive",
                    parameterOperator = "=",
                    parameterValue = 1
                });

            IEnumerable<string> whereFilters = SQLFilters.Select(
                x => string.Format("{0} {1} @{2}", x.fieldName, x.parameterOperator, x.parameterName)
                );
            string where = SQLFilters.Any() ? "WHERE " + string.Join(" AND ", whereFilters) : "";

            string selectSql = string.Format("SELECT * FROM company_data_1 {0}", where);

            MySqlCommand selectCmd = new MySqlCommand(selectSql, conn);
            selectCmd.CommandType = CommandType.Text;

            foreach (SQLfilter filter in SQLFilters)
                selectCmd.Parameters.AddWithValue("@"+ filter.parameterName, filter.parameterValue);

            DataTable dt = new DataTable();
            using (MySqlDataReader rdr = selectCmd.ExecuteReader())
                dt.Load(rdr);

            foreach (DataRow row in dt.Rows)
                results.Add(new Company(row));

            return results;
        }



        public void UpdateInDB(MySqlConnection conn)
        {
            string fieldNamesUpdateSQL = string.Join(", ", fields.Keys.Select(x => string.Format("f_{0} = @_{0}", x)));

            string strQuery = string.Format("UPDATE company_data_1 SET {0} WHERE id = @CompanyID", fieldNamesUpdateSQL);
            MySqlCommand cmd = new MySqlCommand(strQuery, conn);
            cmd.CommandType = CommandType.Text;
            cmd.Parameters.AddWithValue("@CompanyID", ID);
            foreach (KeyValuePair<string,string> fieldItem in fields)
            {
                cmd.Parameters.AddWithValue("@_"+ fieldItem.Key, String.IsNullOrEmpty(fieldItem.Value) ? (object)DBNull.Value : fieldItem.Value );
            }

            cmd.ExecuteNonQuery();
        }


        public static Company CreateInDB(MySqlConnection conn, string name, string countyCode = "US", string permissionCode = "0")
        {
            string insertSql = "INSERT INTO company_data_1 (created_by, created_on, indexed, active, f_company_name, f_permission, f_country) " +
                "VALUES (1, @created_on, 1, 1, @f_company_name, @f_permission, @f_country)";

            MySqlCommand insertCmd = new MySqlCommand(insertSql, conn);
            insertCmd.CommandType = CommandType.Text;
            insertCmd.Parameters.AddWithValue("@created_on", DateTime.UtcNow);
            insertCmd.Parameters.AddWithValue("@f_company_name", name);
            insertCmd.Parameters.AddWithValue("@f_permission", permissionCode);
            insertCmd.Parameters.AddWithValue("@f_country", countyCode);
            insertCmd.ExecuteNonQuery();
            long Id = insertCmd.LastInsertedId;

            string selectSql = "SELECT * FROM company_data_1 WHERE id = " + Id;

            MySqlDataAdapter adapter = new MySqlDataAdapter(selectSql, conn);
            DataSet dataset = new DataSet("TableData");
            adapter.Fill(dataset);


            return new Company(dataset.Tables[0].Rows[0]);
        }

        public void SetFieldsFromYelpBusiness(Yelp.Api.Models.BusinessResponse yelpBusiness)
        {
            fields["city"] = yelpBusiness.Location.City;
            fields["zone"] = yelpBusiness.Location.State;
            fields["country"] = yelpBusiness.Location.Country;

            fields["yelpid"] = yelpBusiness.Id;
            fields["yelpurl"] = yelpBusiness.Url;
            fields["yelpreviewscount"] = yelpBusiness.ReviewCount.ToString();
            fields["yelprating"] = yelpBusiness.Rating.ToString();
            fields["yelpphone"] = yelpBusiness.Phone.ToString();


            fields["latitude"] = yelpBusiness.Coordinates.Latitude.ToString();
            fields["longitude"] = yelpBusiness.Coordinates.Longitude.ToString();
        }
    }
}
