using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Lead
{
    public class AdminDetails
    {

        public enum Status
        {
            All,
            NotConfirmed,
            ReadyToPublish,
            Canceled,
            Published,
            NotInWork,
            InWork,
            Completed,
            Important
        }

        public DateTime? createdDateTime { get; set; }
        public DateTime? emailConfirmedDateTime { get; set; }
        public DateTime? userCanceledDateTime { get; set; }
        public DateTime? publishedDateTime { get; set; }
        public DateTime? adminCanceledPublishDateTime { get; set; }
        

        public List<BusinessDetails> businessesActivity { get; set; }

        public Status status
        {
            get
            {
                if (emailConfirmedDateTime == null)
                    return Status.NotConfirmed;
                else if (publishedDateTime != null)
                    return Status.Published;
                else if (emailConfirmedDateTime != null && publishedDateTime == null)
                    return Status.ReadyToPublish;
                else
                    return Status.All;
            }
        }

        public static Dictionary<Status, string> statusDictionary = new Dictionary<Status, string>() {
            { Status.All, "All" },
            { Status.NotConfirmed, "Not Confirmed" },
            { Status.ReadyToPublish, "Ready to Publish" },
            { Status.Canceled, "Canceled" },
            { Status.Published, "Published" },
            { Status.NotInWork, "Not In Work"},
            { Status.InWork, "In Work" },
            { Status.Completed, "Completed" },
            { Status.Important, "Important" }
        };

        public AdminDetails() {
            
        }
        public AdminDetails(DataRow row) : this()
        {
            createdDateTime = Convert.ToDateTime(row["CreatedDateTime"]);
            if (row["EmailConfirmedDateTime"] != DBNull.Value)
                emailConfirmedDateTime = Convert.ToDateTime(row["EmailConfirmedDateTime"]);
            if (row["UserCanceledDateTime"] != DBNull.Value)
                userCanceledDateTime = Convert.ToDateTime(row["UserCanceledDateTime"]);
            if (row["PublishedDateTime"] != DBNull.Value)
                publishedDateTime = Convert.ToDateTime(row["PublishedDateTime"]);
            if (row["AdminCanceledPublishDateTime"] != DBNull.Value)
                adminCanceledPublishDateTime = Convert.ToDateTime(row["AdminCanceledPublishDateTime"]);
        }

    }
}
