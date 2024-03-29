﻿using LeadGen.Code.Business.Notification;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static LeadGen.Code.Business.NotificationSettings;

namespace LeadGen.Code.Sys.Scheduled
{
    public class QueueMailMessagesForBusinessesAboutNewLeadsHourly : ScheduledTask
    {
        protected override string RunInternal(SqlConnection con)
        {
            List<MailMessageLeadGen> qeuedMailMessages = NotificationManager.QueueMailMessagesForBusinessesRegisteredAboutNewLeads(con, Frequency.Hourly);
            return string.Format("Messages Queued: {0}", qeuedMailMessages.Count);
        }
    }
}
