using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Business.Inovice
{
    public class LeadItemCompleatedData
    {
        public long loginID { get; set; }
        public long businessID { get; set; }
        public long leadID { get; set; }
        public DateTime completedDateTime { get; set; }
        public decimal orderSum { get; set; }
        public decimal leadFee { get; set; }
        public decimal systemFeePercent { get; set; }
        public long invoiceID { get; set; }
        public int invoiceLineID { get; set; }

        public LeadItemCompleatedData(DataRow row)
        {
            loginID = (long)row["LoginID"];
            businessID = (long)row["BusinessID"];
            leadID = (long)row["LeadID"];
            completedDateTime = Convert.ToDateTime(row["CompletedDateTime"]);
            orderSum = Convert.ToDecimal(row["OrderSum"]);
            systemFeePercent = Convert.ToDecimal(row["SystemFeePercent"]);
            leadFee = Convert.ToDecimal(row["LeadFee"]);
            invoiceID = (long)row["InvoiceID"];
            invoiceLineID = (short)row["InvoiceLineID"];
        }
    }
}
