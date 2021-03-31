using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Business
{
    public class BusinessLogin
    {
        public long LoginID { get; set; }

        [EmailAddress]
        [Display(Name = "E-Mail")]
        public string Email { get; set; }

        public Login.UserRole Role { get; set; }

        public DateTime LinkDate { get; set; }

        public DateTime? EmailConfirmationDate { get; set; }


        public BusinessLogin()
        {
        }
        public BusinessLogin(DataRow row)
        {
            LoginID = Int64.Parse(row["LoginID"].ToString());
            Email = row["Email"].ToString();
            Role = (Login.UserRole)(int)row["RoleID"];
            LinkDate = (DateTime)row["LinkDate"];
            EmailConfirmationDate = String.IsNullOrEmpty(row["EmailConfirmationDate"].ToString()) ? (DateTime?) null : (DateTime)row["EmailConfirmationDate"];
        }
    }
}
