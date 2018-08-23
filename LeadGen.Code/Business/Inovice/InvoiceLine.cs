using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Business.Inovice
{
    public class InvoiceLine
    {
        public Int16 ID { get; set; }
        public string description { get; set; }
        public decimal unitPrice { get; set; }
        public Int16 quantity { get; set; }
        public decimal tax { get; set; }
        public decimal linePrice {
            get { return unitPrice * quantity; }
        }
        public decimal lineTotalPrice {
            get { return linePrice + linePrice * tax / 100; }
        }

        public bool isLeadLine { get; set; }
        public List<LeadItemCompleatedData> leadCompleatedData { get; set; }



        public InvoiceLine() { }

        public InvoiceLine(DataRow row) {
            ID = (Int16)row["LineID"];
            description = (string)row["Description"];
            unitPrice = (decimal)row["UnitPrice"];
            quantity = (Int16)row["Quantity"];
            tax = (decimal)row["Tax"];
            isLeadLine = Convert.ToBoolean(row["isLeadLine"]);
        }

        public static List<InvoiceLine> GetInvoiceLines(SqlConnection con, long invoiceID)
        {
            List<InvoiceLine> result = new List<InvoiceLine>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessInvoiceLineSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@InoiceID", invoiceID);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                    result.Add(new InvoiceLine(row));
            }

            return result;
        }

        public void UpdateInDB(SqlConnection con, long invoiceID)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessInvoiceLineUpdate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@InvoiceID", invoiceID);
                cmd.Parameters.AddWithValue("@LineID", ID);
                cmd.Parameters.AddWithValue("@InvoiceLineDescription", String.IsNullOrEmpty(description) ? "" : description);
                cmd.Parameters.AddWithValue("@UnitPrice", unitPrice);
                cmd.Parameters.AddWithValue("@Quantity", quantity);
                cmd.Parameters.AddWithValue("@Tax", tax);

                cmd.ExecuteNonQuery();
            }
        }
    }
}
