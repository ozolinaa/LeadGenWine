using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Business
{
    public class InvoiceManager
    {
        public List<Business> SelectBusinessessForNewInvoices(SqlConnection con, DateTime leadCompletedBefore)
        {
            List<Business> result = new List<Business>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLeadCompletedSelectForNewInvoices]", con))
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
