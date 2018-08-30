using LeadGen.Code.Lead.Notification;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Sys.Scheduled
{
    class QueueMailMessagesForLeadsAboutReviewRequest : ScheduledTask
    {
        protected override string RunInternal(SqlConnection con)
        {
            List<QueueMailMessage> qeuedMailMessages = NotificationManager.QueueMailMessagesForLeadsAboutReviewRequest(con);
            return string.Format("Messages Queued: {0}", qeuedMailMessages.Count);
        }
    }
}
