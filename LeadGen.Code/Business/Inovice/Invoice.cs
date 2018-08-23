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
    public class Invoice
    {
        public long ID { get; set; }
        public long businessID { get; set; }
        public int legalNumber { get; set; }
        public int? legalFacturaNumber { get; set; }
        public int legalYear { get; set; }
        public int legalMonth { get; set; }
        public decimal totalSum { get; set; }
        public string totalSumStr {
            get {
                return Slepov.Russian.СуммаПрописью.Валюта.Рубли.Пропись(totalSum);

                //string unitWhole = "рубль";
                //string sumWhole = Morpher.Factory.Russian.NumberSpelling.Spell((int)totalSum, ref unitWhole, Morpher.Russian.Case.Accusative) + " " + unitWhole;

                //string unitFraction = "копейка";
                //string sumFraction = Morpher.Factory.Russian.NumberSpelling.Spell((int)((decimal.Round(totalSum, 2)  - Math.Truncate(totalSum)) * 100), ref unitFraction, Morpher.Russian.Case.Accusative) + " " + unitFraction;

                //return sumWhole + " " + sumFraction;
            }
        }

        public List<InvoiceLine> lines { get; set; }

        public Billing legalBilling { get; set; }
        public Billing buisnessBilling { get; set; }

        public DateTime createdDateTime { get; set; }
        public DateTime payTillDateTime {
            get {
                //The last day of the current month
                return new DateTime(createdDateTime.Year, createdDateTime.Month, 1).AddMonths(1).AddDays(-1).ToUniversalTime();
            }
        }

        public DateTime? paidDateTime { get; set; }
        public DateTime? publishedDateTime { get; set; }

        public List<LeadItemCompleatedData> leadCompleatedData { get; set; }


        public Invoice() { }

        public Invoice(DataRow row)
        {
            ID = (long)row["InvoiceID"];
            businessID = (long)row["BusinessID"];
            legalMonth = (Int16)row["LegalMonth"];
            legalYear = (Int16)row["LegalYear"];
            legalNumber = (int)row["LegalNumber"];

            legalFacturaNumber = null;
            if (row["LegalFacturaNumber"] != DBNull.Value)
                legalFacturaNumber = (int?)row["LegalFacturaNumber"];

            totalSum = (decimal)row["TotalSum"];

            createdDateTime = Convert.ToDateTime(row["CreatedDateTime"]);
            paidDateTime = null;
            if (row["PaidDateTime"] != DBNull.Value)
                paidDateTime = Convert.ToDateTime(row["PaidDateTime"]);
            publishedDateTime = null;
            if (row["PublishedDateTime"] != DBNull.Value)
                publishedDateTime = Convert.ToDateTime(row["PublishedDateTime"]);

            legalBilling = new Billing() {
                countryID = (long)row["LegalCountryID"],
                address = (string)row["LegalAddress"],
                code1 = (string)row["LegalCode1"],
                code2 = (string)row["LegalCode2"],
                name = (string)row["LegalName"],
                bankAccount = (string)row["LegalBankAccount"],
                bankCode1 = (string)row["LegalBankCode1"],
                bankCode2 = (string)row["LegalBankCode2"],
                bankName = (string)row["LegalBankName"],
            };

            buisnessBilling = new Billing()
            {
                countryID = (long)row["BillingCountryID"],
                address = (string)row["BillingAddress"],
                code1 = (string)row["BillingCode1"],
                code2 = (string)row["BillingCode2"],
                name = (string)row["BillingName"]
            };
        }

        public static List<Inovice.Invoice> SelectFromDB(SqlConnection con, long? invoiceID = null, long? businessID = null, int? legalYear = null, int ? legalNumber = null, bool loadInvoiceLines = false)
        {
            List<Inovice.Invoice> result = new List<Inovice.Invoice>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessInvoiceSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@InoiceID", (object)invoiceID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@BusinessID", (object)businessID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@LegalYear", (object)legalYear ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@LegalNumber", (object)legalNumber ?? DBNull.Value);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    Inovice.Invoice invoice = new Invoice(row);
                    if (loadInvoiceLines)
                        invoice.lines = InvoiceLine.GetInvoiceLines(con, invoice.ID);
                    result.Add(invoice);
                }  
            }

            return result;
        }

        public static Invoice GenerateInvoiceForBusiness(SqlConnection con, long businessID, int leagalYear, int legalMonth, DateTime? invoceCreatedDateTime = null)
        {
            Invoice result = null;
            long generatedInvoiceID = 0;

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessInvoiceCreate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.AddWithValue("@LegalYear", leagalYear);
                cmd.Parameters.AddWithValue("@LegalMonth", legalMonth);
                cmd.Parameters.AddWithValue("@CreatedDateTime", invoceCreatedDateTime == null ? (object)DBNull.Value : invoceCreatedDateTime);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@InvoiceID";
                outputParameter.SqlDbType = SqlDbType.BigInt;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                if (long.TryParse(outputParameter.Value.ToString(), out generatedInvoiceID))
                    result = Invoice.SelectFromDB(con, invoiceID: generatedInvoiceID, loadInvoiceLines: true).First();
            }

            return result;
        }

        public void TryAddLineWithLeads(SqlConnection con, string invoiceLineDescription)
        {
            //Int16 newLine = 0;
            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessInvoiceLineLeadsCreate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@InvoiceID", ID);
                cmd.Parameters.AddWithValue("@InvoiceLineDescription", invoiceLineDescription);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@InvoiceLineID";
                outputParameter.SqlDbType = SqlDbType.SmallInt;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                //if (long.TryParse(outputParameter.Value.ToString(), out newLine))
            }
        }

        public Int16 LineAdd(SqlConnection con, string invoiceLineDescription = "", decimal unitPrice = 0, Int16 quantaty = 1, decimal tax = 0)
        {
            Int16 newLine = 0;
            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessInvoiceLineCreate]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@InvoiceID", ID);
                cmd.Parameters.AddWithValue("@InvoiceLineDescription", invoiceLineDescription);
                cmd.Parameters.AddWithValue("@UnitPrice", unitPrice);
                cmd.Parameters.AddWithValue("@Quantity", quantaty);
                cmd.Parameters.AddWithValue("@Tax", tax);


                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@InvoiceLineID";
                outputParameter.SqlDbType = SqlDbType.SmallInt;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                Int16.TryParse(outputParameter.Value.ToString(), out newLine);
            }
            return newLine;
        }

        public void LineRemove(SqlConnection con, Int16 lineID)
        {
            using (SqlCommand cmd = new SqlCommand("[BusinessInvoiceLineDelete]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@InvoiceID", ID);
                cmd.Parameters.AddWithValue("@InvoiceLineID", lineID);

                cmd.ExecuteNonQuery();
            }
        }

        public void Publish(SqlConnection con, DateTime publishedDateTime)
        {
            if (this.publishedDateTime == null)
            {
                this.publishedDateTime = publishedDateTime;

                using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessInvoicePublish]", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@InvoiceID", ID);
                    cmd.Parameters.AddWithValue("@PublishedDatetime", this.publishedDateTime);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void SetPaid(SqlConnection con, DateTime paidDateTime)
        {
            if (this.paidDateTime == null)
            {
                this.paidDateTime = paidDateTime;

                using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessInvoiceSetPaid]", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@InvoiceID", ID);
                    cmd.Parameters.AddWithValue("@PaidDateTime", this.paidDateTime);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void UpdateInDB(SqlConnection con)
        {
            BillingUpdateInDB(con);
            LinesUpdateInDB(con);
        }

        private void BillingUpdateInDB(SqlConnection con)
        {
            if(legalBilling != null && buisnessBilling != null)
                using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessInvoiceUpdateBilling]", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@InvoiceID", ID);
                    cmd.Parameters.AddWithValue("@LegalAddress", String.IsNullOrEmpty(legalBilling.address) ? "" : legalBilling.address);
                    cmd.Parameters.AddWithValue("@LegalName", String.IsNullOrEmpty(legalBilling.name) ? "" : legalBilling.name);
                    cmd.Parameters.AddWithValue("@LegalCode1", String.IsNullOrEmpty(legalBilling.code1) ? "" : legalBilling.code1);
                    cmd.Parameters.AddWithValue("@LegalCode2", String.IsNullOrEmpty(legalBilling.code2) ? "" : legalBilling.code2);

                    cmd.Parameters.AddWithValue("@LegalBankAccount", String.IsNullOrEmpty(legalBilling.bankAccount) ? "" : legalBilling.bankAccount);
                    cmd.Parameters.AddWithValue("@LegalBankName", String.IsNullOrEmpty(legalBilling.bankName) ? "" : legalBilling.bankName);
                    cmd.Parameters.AddWithValue("@LegalBankCode1", String.IsNullOrEmpty(legalBilling.bankCode1) ? "" : legalBilling.bankCode1);
                    cmd.Parameters.AddWithValue("@LegalBankCode2", String.IsNullOrEmpty(legalBilling.bankCode2) ? "" : legalBilling.bankCode2);

                    cmd.Parameters.AddWithValue("@BillingAddress", String.IsNullOrEmpty(buisnessBilling.address) ? "" : buisnessBilling.address);
                    cmd.Parameters.AddWithValue("@BillingName", String.IsNullOrEmpty(buisnessBilling.name) ? "" : buisnessBilling.name);
                    cmd.Parameters.AddWithValue("@BillingCode1", String.IsNullOrEmpty(buisnessBilling.code1) ? "" : buisnessBilling.code1);
                    cmd.Parameters.AddWithValue("@BillingCode2", String.IsNullOrEmpty(buisnessBilling.code2) ? "" : buisnessBilling.code2);


                    cmd.ExecuteNonQuery();
                }
        }

        private void LinesUpdateInDB(SqlConnection con)
        {
            if (lines == null)
                return;

            foreach (InvoiceLine line in lines)
                if(line.isLeadLine == false)
                    line.UpdateInDB(con, ID);
        }

        public static void DeleteFromDB(SqlConnection con, long invoiceID)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessInvoiceDelete]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@InvoiceID", invoiceID);

                cmd.ExecuteNonQuery();
            }
        }

        public void loadIncludedLeads(SqlConnection con)
        {
            leadCompleatedData = new List<LeadItemCompleatedData>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessInvoiceLeadsSelectCompleted]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@InoiceID", ID);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    leadCompleatedData.Add(new LeadItemCompleatedData(row));
                }
            }
        }


    }
}
