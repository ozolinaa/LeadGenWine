using LeadGen.Code.Business;
using LeadGen.Code.Helpers;
using System.Data;
using System.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Business.Inovice
{
    public class InvoiceManager
    {
        public List<Business> SelectBusinessessForNewInvoices(SqlConnection con, DateTime leadCompletedBefore)
        {
            List<Business> result = new List<Business>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[Business.Lead.Completed.SelectForNewInvoices]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@CompletedBeforeDate", leadCompletedBefore);
                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);

                foreach (DataRow businessIdRow in dt.DefaultView.ToTable(true, "BusinessID").Rows)
                {
                    Business business = Business.SelectFromDB(con, businessID: (long)businessIdRow["BusinessID"]).First();
                    business.leads = business.SelectLeadsFromDB(con, Lead.BusinessDetails.Status.NextInvoice, completedBeforeDate: leadCompletedBefore).ToList();
                    result.Add(business);
                }
            }

            return result;
        }





    }
}
