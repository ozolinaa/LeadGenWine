using LeadGen.Code;
using LeadGen.Code.Helpers;
using LeadGen.Code.Lead;
using LeadGen.Code.Sys;
using LeadGen.Web.Controllers;
using LeadGen.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


namespace LeadGen.Web.Controllers
{
    public class TokenController : DatabaseController
    {
        // GET: Token
        public ActionResult Index(string key)
        {
            Token token = Token.Find(DBLGcon, key);

            Token.Action tokenAction;
            if (token == null || !Enum.TryParse(token.action, out tokenAction))
                return View("error");

            switch (tokenAction)
            {
                case Token.Action.LoginEmailConfirmation:
                    return LoginEmailConfirm(token);
                case Token.Action.LoginRecoverPassword:
                    return LoginRecoverPassword(token);
                case Token.Action.LeadEmailConfirmation:
                    return LeadEmailConfirm(token);
                case Token.Action.LeadRemoveByUser:
                    return LeadRemoveByUser(token);
                default:
                    return RedirectToAction("Index", "Home", new { area = "" });
            }


        }

        [NonAction]
        private ActionResult LoginEmailConfirm(Token token)
        {
            long loginID;
            Login confirmLogin = null;

            if (Int64.TryParse(token.value, out loginID))
                confirmLogin = Login.SelectOne(DBLGcon, loginID: loginID);

            if (confirmLogin != null)
            {
                Login.EmailConfirm(DBLGcon, confirmLogin.ID);
                string sessionID = LoginController.SetLoginSessionCookie(DBLGcon, HttpContext, confirmLogin.ID);
                token.Delete(DBLGcon);

                confirmLogin = LeadGen.Code.Session.GetLoginBySessionID(DBLGcon, sessionID);

                if (confirmLogin.business != null)
                {
                    Code.Business.NotificationSettings.EmailAdd(DBLGcon, confirmLogin.business.ID, confirmLogin.email);

                    SendMessageToAdmins("New Business Registered", string.Format("New business: #{0} {1}", confirmLogin.business.ID, confirmLogin.business.name));

                    return RedirectToAction("Index", "Account", new { area = "Business" });
                }
            } 
   
            //Error
            return RedirectToAction("Index", "Home", new { area = "" });
        }

        [NonAction]
        private ActionResult LoginRecoverPassword(Token token)
        {
            Login recoverLogin = null;
            long loginID;
            if (Int64.TryParse(token.value, out loginID))
                recoverLogin = Login.SelectOne(DBLGcon, loginID: loginID);

            ViewData["tokenKey"] = token.key;
            return View("../Login/RecoverPassword", recoverLogin);
        }

        [NonAction]
        private ActionResult LeadEmailConfirm(Token token)
        {
            long leadID;
            if (Int64.TryParse(token.value, out leadID))
                if (LeadItem.EmailConfirm(DBLGcon, leadID))
                {
                    token.Delete(DBLGcon);
                    LeadItem leadItem = LeadItem.SelectFromDB(DBLGcon, leadID: leadID, loadFieldValues: true).FirstOrDefault();

                    SendMessageToAdmins("New Lead Confirmed", string.Format("New Lead: #{0}", leadItem.ID));

                    return View("../Order/ConfirmEmailSuccess", leadItem);
                }
                    

            //Error
            return RedirectToAction("Index", "Home", new { area = "" });
        }

        [NonAction]
        private ActionResult LeadRemoveByUser(Token token)
        {
            string email = token.value.Trim();

            List<LeadItem> userLeads = LeadItem.SelectFromDB(DBLGcon, email).Where(x=>x.adminDetails.publishedDateTime != null).ToList();
            foreach (LeadItem lead in userLeads)
                lead.CancelByUser(DBLGcon, DateTime.UtcNow);

            token.Delete(DBLGcon);

            return View("../Order/Canceled", email);
        }


        private static void SendMessageToAdmins(string subject, string message) {

            IEnumerable<MailMessageLeadGen> mailMessages = MailMessageBuilder.BuildAdminNotificationMessages(subject, message);

            foreach (MailMessageLeadGen mailMessage in mailMessages)
            {
                SmtpClientLeadGen.SendSingleMessage(mailMessage);
            }
        }
    }
}