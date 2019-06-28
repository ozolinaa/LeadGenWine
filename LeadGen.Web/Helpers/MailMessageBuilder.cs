using LeadGen.Code;
using LeadGen.Code.Helpers;
using LeadGen.Code.Lead;
using LeadGen.Code.Sys;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace LeadGen.Web.Helpers
{
    public static class MailMessageBuilder
    {
        public static MailMessageLeadGen BuildLeadEmailVerifyMailMessage(LeadItem lead, SqlConnection con)
        {
            string mailSubject = "E-mail address verification";
            string viewPath = "~/Views/Order/E-mails/EmailVerify.cshtml";

            Token token = new Token(con, Token.Action.LeadEmailConfirmation.ToString(), lead.ID.ToString());
            ViewDataDictionary viewDataDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary()) { { "tokenKey", token.key } };

            MailMessageLeadGen message = new MailMessageLeadGen(lead.email);

            message.Subject = mailSubject;
            message.Body = ViewHelper.RenderViewToString(viewPath, lead, viewDataDictionary);

            return message;
        }

        public static MailMessageLeadGen BuildCompanyRegistrationVerifyMailMessage(Login login, SqlConnection con)
        {
            string mailSubject = "Confirm business E-mail address";
            string viewPath = "~/Areas/Business/Views/Registration/E-mails/RegistrationEmailVerify.cshtml";

            Token token = new Token(con, Token.Action.LoginEmailConfirmation.ToString(), login.ID.ToString());
            ViewDataDictionary viewDataDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary()) { { "tokenKey", token.key } };

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
    }
}
