using LeadGen.Code.Taxonomy;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static LeadGen.Code.Helpers.DBHelper;

namespace LeadGen.Importer.EPESI
{
    public class Client : IDisposable
    {
        public MySqlConnection conn = null;

        private Dictionary<string, int> _fieldKeyGroupIdMapping = null;
        public Dictionary<string, Dictionary<string, string>> groupsAvaileble = null;

        public Client(string connectionString, Dictionary<string, int> fieldKeyGroupIdMapping)
        {
            _fieldKeyGroupIdMapping = fieldKeyGroupIdMapping;
            conn = new MySqlConnection(connectionString);
            conn.Open();


            MySqlCommand cmd = new MySqlCommand("SET NAMES 'utf8'", conn);
            cmd.ExecuteNonQuery();

            LoadGroupsAvaileble();
        }



        public Company CompanyCreate(string name, string countyCode = "US", string permissionCode = "0")
        {
            Company newCompany = Company.CreateInDB(conn, name, countyCode, permissionCode);

            foreach (KeyValuePair<string, Dictionary<string, string>> group in groupsAvaileble)
            {
                newCompany.InitializeGroupsFromFields(group.Key, group.Value);
            }

            return newCompany;
        }

        public List<Company> CompanySelect(List<SQLfilter> sqlFilters = null, bool isActiveOnly = true)
        {
            
            List<Company> companies = Company.SelectFromDB(conn, sqlFilters, isActiveOnly);

            foreach (Company company in companies)
            {
                foreach (KeyValuePair<string, Dictionary<string,string>> group in groupsAvaileble)
                {
                    company.InitializeGroupsFromFields(group.Key, group.Value);
                }
            }

            return companies;
        }

        public void CompanyUpdate(Company company)
        {
            CompaniesUpdate(new Company[] { company });
        }

        public void CompaniesUpdate(IEnumerable<Company> companies)
        {
            foreach (Company company in companies)
            {
                foreach (KeyValuePair<string, Dictionary<string, string>> groupAvaileble in groupsAvaileble)
                {
                    company.InitializeFieldsFromGroups(groupAvaileble.Key);
                }
                company.UpdateInDB(conn);
            }
        }

        private Dictionary<string, string> GetCommonDataByParentNode(int parentNodeID)
        {
            Dictionary<string, string> commonData = new Dictionary<string, string>();

            string sql = "SELECT c1.akey, c1.value " +
                "FROM utils_commondata_tree as c1 " +
                "WHERE c1.parent_id = "+ parentNodeID + " " +
                "UNION ALL " +
                "SELECT c2.akey, c2.value " +
                "FROM utils_commondata_tree as c1 " +
                "LEFT OUTER JOIN utils_commondata_tree as c2 ON c2.parent_id = c1.id " +
                "WHERE c1.parent_id = "+ parentNodeID + " AND c2.id != " + parentNodeID;

            MySqlDataAdapter adapter = new MySqlDataAdapter(sql, conn);
            DataSet dataset = new DataSet("TableData");
            adapter.Fill(dataset);

            foreach (DataRow row in dataset.Tables[0].Rows)
            {
                commonData.Add(row["akey"].ToString(), row["value"].ToString());
            }
            
            //Add this to Russia
            if (parentNodeID == 667)
                if (commonData.Keys.Contains("ru_re_altayskiykray_novoaltaysk") == false)
                    commonData.Add("ru_re_altayskiykray_novoaltaysk", "Новоалтайск");

            return commonData;
        }

        private void LoadGroupsAvaileble()
        {
            groupsAvaileble = new Dictionary<string, Dictionary<string, string>>();
            foreach (KeyValuePair<string, int> mappingItem in _fieldKeyGroupIdMapping)
            {
                groupsAvaileble.Add(mappingItem.Key, GetCommonDataByParentNode(mappingItem.Value));
            }
        }

        public void Dispose()
        {
            if (conn != null)
            {
                conn.Close();
                conn.Dispose();
            }
        }
    }
}
