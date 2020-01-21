using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Clients.CRM
{
    public class Organization
    {
        public string ID { get; set; }
        public string Name { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string Website { get; set; }

        public bool isActive { get; set; }

        public bool OptOutEmailPromoNotifications { get; set; }
        public bool OptOutEmailLeadNotifications { get; set; }

        public long? LeadGenPostID { get; set; }
        public long? LeadGenBusinessID { get; set; }

        public IEnumerable<Location> Locations { get; set; }
    }
}
