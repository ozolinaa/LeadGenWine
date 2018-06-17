using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Lead
{
    public class BusinessDetails
    {
        public enum Status
        {
            NewForBusiness,
            WaitingApproval,
            Completed,
            ContactReceived,
            NotInterested,
            Important,
            NextInvoice,
            All
        }



        public long businessID { get; set; }

        public bool isPermittedForBusiness { get; set; }

        public DateTime? businessNotInterestedDateTime { get; set; }
        public DateTime? businessContactReceivedDateTime { get; set; }
        public DateTime? businessCompletedDateTime { get; set; }
        public DateTime? businessImportantDateTime { get; set; }

        public decimal orderSum { get; set; }
        public decimal systemFeePercent { get; set; }
        public decimal leadFee { get; set; }

        public Status status
        {
            get
            {
                if (isPermittedForBusiness == false)
                    return Status.WaitingApproval;
                else if (businessNotInterestedDateTime != null)
                    return Status.NotInterested;
                else if (businessImportantDateTime != null)
                    return Status.Important;
                else if (businessCompletedDateTime != null)
                    return Status.Completed;
                else if (businessContactReceivedDateTime != null)
                    return Status.ContactReceived;
                else
                    return Status.NewForBusiness;
            }
        }
        public static Dictionary<Status, string> statusDictionary = new Dictionary<Status, string>() {
            { Status.All, "Все" },
            { Status.Completed, "Состоявшиеся" },
            { Status.NewForBusiness, "Новые" },
            { Status.WaitingApproval, "Ожидают подтверждения" },
            { Status.ContactReceived, "В работе" },
            { Status.NotInterested, "Неинтересные" },
            { Status.Important, "Важные" }
        };

        public BusinessDetails() {
            systemFeePercent = Convert.ToDecimal(ConfigurationManager.AppSettings["DefaultSystemFeePercent"]);
        }
        public BusinessDetails(DataRow row) : this()
        {
            businessID = (long)row["BusinessID"];
            isPermittedForBusiness = Convert.ToBoolean(row["IsApproved"]);

            if (row["NotInterestedDateTime"] != DBNull.Value)
                businessNotInterestedDateTime = Convert.ToDateTime(row["NotInterestedDateTime"]);
            if (row["GetContactsDateTime"] != DBNull.Value)
                businessContactReceivedDateTime = Convert.ToDateTime(row["GetContactsDateTime"]);
            if (row["CompletedDateTime"] != DBNull.Value)
                businessCompletedDateTime = Convert.ToDateTime(row["CompletedDateTime"]);
            if (row["ImportantDateTime"] != DBNull.Value)
                businessImportantDateTime = Convert.ToDateTime(row["ImportantDateTime"]);
            if (row["OrderSum"] != DBNull.Value)
                orderSum = Convert.ToDecimal(row["OrderSum"]);
            if (row["SystemFeePercent"] != DBNull.Value)
                systemFeePercent = Convert.ToDecimal(row["SystemFeePercent"]);
            if (row["LeadFee"] != DBNull.Value)
                leadFee = Convert.ToDecimal(row["LeadFee"]);
        }
    }
}
