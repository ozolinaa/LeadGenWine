using LeadGen.Code.Business.Notification;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static LeadGen.Code.Business.NotificationSettings;

namespace LeadGen.Code.Sys.Scheduled
{
    public class QueueMailMessagesForBusinessesAboutNewLeadsDaily : ScheduledTask
    {
        protected override string RunInternal(SqlConnection con)
        {
            List<MailMessageLeadGen> qeuedMailMessages = NotificationManager.QueueMailMessagesForBusinessesRegisteredAboutNewLeads(con, Frequency.Daily);
            qeuedMailMessages.AddRange(NotificationManager.QueueMailMessagesForCompanyPostsAboutNewLeads(con));
            return string.Format("Messages Queued: {0}", qeuedMailMessages.Count);
        }
    }
}
