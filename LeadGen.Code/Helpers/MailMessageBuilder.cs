using LeadGen.Code.CMS;
using LeadGen.Code.Helpers;
using LeadGen.Code.Lead;
using LeadGen.Code.Sys;
using LeadGen.Code.Tokens;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace LeadGen.Code.Helpers
{
    public static class MailMessageBuilder
    {
        public static MailMessageLeadGen BuildLeadEmailVerifyMailMessage(LeadItem lead, SqlConnection con)
        {
            string mailSubject = "E-mail address verification";
            string viewPath = "~/Views/Order/E-mails/EmailVerify.cshtml";


            LeadEmailConfirmationToken token = new LeadEmailConfirmationToken(lead.ID);
            token.CreateInDB(con);

            ViewDataDictionary viewDataDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary()) { { "tokenKey", token.Key } };

            MailMessageLeadGen message = new MailMessageLeadGen(lead.email);

            message.Subject = mailSubject;
            message.Body = ViewHelper.RenderViewToString(viewPath, lead, viewDataDictionary);

            return message;
        }

        public static MailMessageLeadGen BuildCompanyRegistrationVerifyMailMessage(Login login, SqlConnection con)
        {
            string mailSubject = "Confirm business E-mail address";
            string viewPath = "~/Areas/Business/Views/Registration/E-mails/RegistrationEmailVerify.cshtml";

            BusinessRegistrationEmaiConfirmationToken token = new BusinessRegistrationEmaiConfirmationToken(login.ID);
            token.CreateInDB(con);

            ViewDataDictionary viewDataDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary()) { { "tokenKey", token.Key } };

            MailMessageLeadGen message = new MailMessageLeadGen(login.email);

            message.Subject = mailSubject;
            message.Body = ViewHelper.RenderViewToString(viewPath, login, viewDataDictionary);

            return message;
        }

        public static IEnumerable<MailMessageLeadGen> BuildAdminNotificationMessages(string notificationSubject, string notificationMessage)
        {
            List<MailMessageLeadGen> result = new List<MailMessageLeadGen>();

            string[] adminEmails = new string[] { "anton.ozolin@gmail.com" };
            string mailSubject = "Admin Notification: " + notificationSubject;
            string viewPath = "~/Areas/Admin/Views/E-mails/Notification.cshtml";

            string body = ViewHelper.RenderViewToString(viewPath, notificationMessage);

            foreach (string adminEmail in adminEmails)
            {
                MailMessageLeadGen message = new MailMessageLeadGen(adminEmail);

                message.Subject = mailSubject;
                message.Body = body;

                result.Add(message);
            }

            return result;
        }

        public static List<MailMessageLeadGen> BuildLeadNotificationForCRMBusiness(SqlConnection con, Dictionary<Post, List<LeadItem>> businessPostsWithLeadsToNotifyAbout)
        {
            List<MailMessageLeadGen> messages = new List<MailMessageLeadGen>();

            string viewPath = "~/Areas/Business/Views/E-mails/_CRMBusinessLeadNotification.cshtml";

            foreach (KeyValuePair<Post, List<LeadItem>> businessPostLeads in businessPostsWithLeadsToNotifyAbout)
            {
                try
                {
                    Post businessPost = businessPostLeads.Key;
                    string businessLocation = businessPost.getFieldByCode("company_notification_location").location.Name;
                    string businessEmail = businessPost.getFieldByCode("company_notification_email").fieldText;

                    string mailSubject = string.Format("Wine cellar order for {0}, please review", businessPost.title);
                    if (!string.IsNullOrEmpty(businessLocation))
                        mailSubject = string.Format("Wine cellar order in {0}, {1} please review", businessLocation, businessPost.title);

                    BusinessCRMLeadUnsubscribeToken token = new BusinessCRMLeadUnsubscribeToken(businessPost.ID);
                    token.CreateInDB(con);

                    ViewDataDictionary viewDataDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary()) { { "unsubscribeTokenKey", token.Key } };

                    MailMessageLeadGen message = new MailMessageLeadGen(businessEmail);
                    message.Subject = mailSubject;
                    message.Body = ViewHelper.RenderViewToString(viewPath, businessPostLeads, viewDataDictionary);
                    messages.Add(message);
                }
                catch (Exception e)
                {
                    //May be master_email does not have a valid email
                    //Or View rendering
                    Log.Insert(e.ToString());
                    throw e;
                }
            }

            return messages;
        }
    }
}
