using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Sys
{
    public class MailMessageLeadGen : MailMessage
    {
        #region Fields
        private Guid ID;
        private DateTime createdDateTime;
        private DateTime sendingScheduledDateTime;
        private DateTime? sendingStartedDateTime;
        private DateTime? sentDateTime;
        #endregion

        #region Constructors

        public MailMessageLeadGen() : base()
        {
            ID = Guid.NewGuid();
            createdDateTime = DateTime.UtcNow;
            From = new MailAddress(SysHelper.AppSettings.EmailSettings.FromAddress, SysHelper.AppSettings.EmailSettings.FromName);
            ReplyToList.Add(new MailAddress(SysHelper.AppSettings.EmailSettings.ReplyToAddress));
            IsBodyHtml = true;
        }

        public MailMessageLeadGen(string emailAddressString) : this()
        {
            To.Add(new MailAddress(emailAddressString.ToLower().Trim()));
        }

        public MailMessageLeadGen(DataRow row)
        {
            ID = (Guid)row["EmailID"];

            createdDateTime = Convert.ToDateTime(row["CreatedDateTime"]);
            sendingScheduledDateTime = Convert.ToDateTime(row["SendingScheduledDateTime"]);

            sentDateTime = null;
            if (row["SendingStartedDateTime"] != DBNull.Value)
                sentDateTime = Convert.ToDateTime(row["SendingStartedDateTime"]);

            sendingStartedDateTime = null;
            if (row["SentDateTime"] != DBNull.Value)
                sendingStartedDateTime = Convert.ToDateTime(row["SentDateTime"]);

            From = new MailAddress((string)row["FromAddress"], (string)row["FromName"]);
            To.Add(new MailAddress(row["ToAddress"].ToString().ToLower().Trim()));
            ReplyToList.Add((string)row["ReplyToAddress"]);

            Subject = (string)row["Subject"];
            Body = (string)row["Body"];

            IsBodyHtml = true;
        }

        #endregion

        #region Public Methods

        public void Send(SmtpClient smtp)
        {
            smtp.Send(this);
        }

        public void QueueToDB(SqlConnection connection, DateTime sendingScheduledDateTime)
        {
            this.sendingScheduledDateTime = sendingScheduledDateTime;

            using (SqlCommand cmd = new SqlCommand("[dbo].[EmailQueueInsert]", connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@EmailID", ID);
                cmd.Parameters.AddWithValue("@CreatedDateTime", createdDateTime);
                cmd.Parameters.AddWithValue("@SendingScheduledDateTime", this.sendingScheduledDateTime);
                cmd.Parameters.AddWithValue("@FromAddress", From.Address);
                cmd.Parameters.AddWithValue("@FromName", From.DisplayName);
                cmd.Parameters.AddWithValue("@ToAddress", To.First().Address);
                cmd.Parameters.AddWithValue("@ReplyToAddress", ReplyToList.Count == 0 ? (object)DBNull.Value : ReplyToList.First().Address);
                cmd.Parameters.AddWithValue("@Subject", Subject);
                cmd.Parameters.AddWithValue("@Body", Body);

                cmd.ExecuteNonQuery();
            }
        }

        public static int SendQueuedMessages(SqlConnection connection)
        {
            int sentMessagesCount = 0;
            using (SmtpClientLeadGen smtp = new SmtpClientLeadGen())
            {
                int sendIntervalMilliseconds = SysHelper.AppSettings.EmailSettings.SmtpSettings.SendIntervalMilliseconds;
                do
                {
                    MailMessageLeadGen message = GetNextMessageFromTheQueue(connection);
                    if (message == null)
                        break;

                    //Our current Amazon SES maximum send rate is 14 messages per second
                    //So need to wait about 100 miliseconds between sending the next email
                    if (sendIntervalMilliseconds > 0)
                        System.Threading.Thread.Sleep(sendIntervalMilliseconds);

                    message.SendQueuedMessage(connection, smtp);
                    sentMessagesCount++;
                }
                while (true);
            }
            return sentMessagesCount;
        }

        #endregion

        #region Private Methods

        private void UpdateSendingStartedDateTimeInDB(SqlConnection connection, DateTime sendingStartedDateTime)
        {
            this.sendingStartedDateTime = sendingStartedDateTime;

            using (SqlCommand cmd = new SqlCommand("[dbo].[EmailQueueSetStartedDateTime]", connection))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@EmailID", ID);
                cmd.Parameters.AddWithValue("@SendingStartedDateTime", this.sendingStartedDateTime);

                cmd.ExecuteNonQuery();
            }
        }

        private void UpdateSentDateTimeDateTimeInDB(SqlConnection connection, DateTime sentDateTime)
        {
            this.sentDateTime = sentDateTime;

            using (SqlCommand cmd = new SqlCommand("[dbo].[EmailQueueSetSentDateTime]", connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@EmailID", ID);
                cmd.Parameters.AddWithValue("@SentDateTime", this.sentDateTime);

                cmd.ExecuteNonQuery();
            }
        }

        private void SendQueuedMessage(SqlConnection connection, SmtpClient smtp)
        {
            if (sendingStartedDateTime != null || sentDateTime != null)
                return;

            UpdateSendingStartedDateTimeInDB(connection, DateTime.UtcNow);

            Send(smtp);

            UpdateSentDateTimeDateTimeInDB(connection, DateTime.UtcNow);
        }

        private static MailMessageLeadGen GetNextMessageFromTheQueue(SqlConnection connection)
        {
            MailMessageLeadGen message = null;

            using (SqlCommand cmd = new SqlCommand("[dbo].[EmailQueueSelectNextEmailToSend]", connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@CurrentDateTime", DateTime.UtcNow);

                using (DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd))
                    if (dt.Rows.Count > 0)
                        message = new MailMessageLeadGen(dt.Rows[0]);
            }

            if (message == null)
                return null;

            return message;
        }

        #endregion

    }
}
