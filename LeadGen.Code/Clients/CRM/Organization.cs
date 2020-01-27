using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Clients.CRM
{
    public class Organization
    {
        public string ID { get; set; }
        public string Name { get; set; }
        public string PhoneNotification { get; set; }
        public string EmailNotification { get; set; }

        public string PhonePublic { get; set; }
        public string EmailPublic { get; set; }

        public string WebsiteOfficial { get; set; }
        public string WebsiteOther { get; set; }

        public bool isActive { get; set; }

        public bool OptOutEmailPromoNotifications { get; set; }
        public bool OptOutEmailLeadNotifications { get; set; }

        public long? LeadGenPostID { get; set; }
        public long? LeadGenBusinessID { get; set; }

        public List<Location> Locations { get; set; }
    }
}
