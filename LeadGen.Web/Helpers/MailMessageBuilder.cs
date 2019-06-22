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
    public class MailMessageBuilder
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
    }
}
