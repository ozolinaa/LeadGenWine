using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Sys.Scheduled
{
    public class SendQueuedMail: ScheduledTask
    {
        public SendQueuedMail(string DBLGconString) : base(DBLGconString)
        {
        }

        protected override string RunInternal(SqlConnection con)
        {
            int messagesSentNumber = QueueMailMessage.SendQueuedMessages(con);
            return string.Format("Messages Sent: {0}", messagesSentNumber);
        }
    }
}
