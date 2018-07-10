﻿using LeadGen.Code.Helpers;
using LeadGen.Code.Sys;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;


namespace LeadGen.Code.Lead.Notification
{
    public class NotificationManager
    {
        public static List<QueueMailMessage> QueueMailMessagesForLeadsAboutReviewRequest(SqlConnection connection)
        {
            DateTime now = DateTime.UtcNow;
            List<LeadItem> leads = ReviewRequestSelectLeads(connection, 30);
            LeadItem.LoadFieldValuesForLeads(connection, leads);
            List<QueueMailMessage> messages = ReviewRequestGenerateEmailMessages(connection, leads);
            leads.ForEach(x => x.SetReviewRequestSent(connection));
            messages.ForEach(x => x.QueueToDB(connection, now));
            return messages;
        }

        private static List<LeadItem> ReviewRequestSelectLeads(SqlConnection connection, int completedDaysBefore)
        {
            List<LeadItem> leadItems = new List<LeadItem>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.SelectForReview]", connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@CompletedDaysBefore", completedDaysBefore);

                using (DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd))
                    foreach (DataRow row in dt.Rows)
                        leadItems.Add(new LeadItem(row));
            }

            LeadItem.LoadFieldValuesForLeads(connection, leadItems);

            return leadItems;
        }

        public static List<QueueMailMessage> ReviewRequestGenerateEmailMessages(SqlConnection con, List<LeadItem> leads)
        {
            List<QueueMailMessage> messages = new List<QueueMailMessage>();

            string mailSubject = "Отзыв о заявке";
            string viewPath = "~/Views/Order/E-mails/_ReviewRequest.cshtml";

            foreach (LeadItem item in leads)
            {
                Token token = new Token(con, Token.Action.LeadReviewCreate.ToString(), item.ID.ToString());
                ViewDataDictionary viewDataDictionary = new ViewDataDictionary(null) { { "tokenKey", token.key } };

                QueueMailMessage message = new QueueMailMessage(item.email);
                message.Subject = mailSubject;
                message.Body = ViewHelper.RenderPartialToString(viewPath, item, viewDataDictionary);
                messages.Add(message);
            }

            return messages;
        }

    }
}
