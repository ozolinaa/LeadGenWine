//using LeadGen.Code.Taxonomy;
//using MySql.Data.MySqlClient;
//using System;
//using System.Collections.Generic;
//using System.Data;
//using System.Linq;
//using System.Text;
//using System.Threading.Tasks;
//using System.Web;

//namespace LeadGen.Importer.EPESI
//{
//    public class LeadGenCompany : Company
//    {
//        public List<Group> ruRegions { get; set; }
//        public List<Group> byRegions { get; set; }
//        public List<Group> uaRegions { get; set; }
//        public List<Group> groups { get; set; }
//        public List<Group> types { get; set; }

//        public LeadGenCompany(DataRow row) : base(row)
//        {
//            ruRegions = new List<Group>();
//            byRegions = new List<Group>();
//            uaRegions = new List<Group>();
//            groups = new List<Group>();
//            types = new List<Group>();
//        }


//        public void ProcessEPESIGroups(List<Group> epesiGroupsToPopulate, Dictionary<string, string> availebleGroups, string companyField)
//        {
//            foreach (string groupCompoundKey in fields[companyField].Split(new string[] { "__" }, StringSplitOptions.RemoveEmptyEntries))
//                epesiGroupsToPopulate.Add(new Group(groupCompoundKey, availebleGroups));
//        }

//        public static new List<LeadGenCompany> SelectAllFromDB(MySqlConnection conn)
//        {
//            List<LeadGenCompany> results = new List<LeadGenCompany>();

//            foreach (DataRow row in SelectAllActiveCompanyRows(conn))
//            {
//                results.Add(new LeadGenCompany(row));
//            }

//            return results;
//        }




//        public static void setTermsChecked(Group group, List<Term> terms, long? parentTermID = null)
//        {
//            Term term = terms.FirstOrDefault(x => x.parentID == parentTermID && x.name.Equals(group.name, StringComparison.OrdinalIgnoreCase));
//            if (term != null)
//            {
//                term.isChecked = true;
//                if (group.child != null)
//                    setTermsChecked(group.child, terms, term.ID);
//            }
//        }
//    }
//}
