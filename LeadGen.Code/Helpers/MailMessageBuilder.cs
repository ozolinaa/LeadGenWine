﻿using LeadGen.Code.CMS;
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

            NewLoginEmailVerificationToken token = new NewLoginEmailVerificationToken(login.ID);
            token.CreateInDB(con);

            ViewDataDictionary viewDataDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary()) { { "tokenKey", token.Key } };

            MailMessageLeadGen message = new MailMessageLeadGen(login.email);

            message.Subject = mailSubject;
            message.Body = ViewHelper.RenderViewToString(viewPath, login, viewDataDictionary);

            return message;
        }

        public static MailMessageLeadGen BuildCompanyLoginLinkVerifyMailMessage(Login login, SqlConnection con)
        {
            string mailSubject = $"You are invited to {login.business.name}";
            string viewPath = "~/Areas/Business/Views/Registration/E-mails/LoginLinkEmailVerify.cshtml";

            NewLoginEmailVerificationToken token = new NewLoginEmailVerificationToken(login.ID);
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

            string[] adminEmails = SysHelper.AppSettings.AdminEmails;
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

        public static List<MailMessageLeadGen> BuildLeadNotificationForCRMBusiness(SqlConnection con, Dictionary<PostBusiness, List<LeadItem>> businessPostsWithLeadsToNotifyAbout)
        {
            List<MailMessageLeadGen> messages = new List<MailMessageLeadGen>();

            string viewPath = "~/Areas/Business/Views/E-mails/_CRMBusinessLeadNotification.cshtml";

            foreach (KeyValuePair<PostBusiness, List<LeadItem>> businessPostLeads in businessPostsWithLeadsToNotifyAbout)
            {
                try
                {
                    PostBusiness businessPost = businessPostLeads.Key;
                    string businessLocation = businessPost.company_notification_location?.Name;
                    string businessEmail = businessPost.company_notification_email;

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
