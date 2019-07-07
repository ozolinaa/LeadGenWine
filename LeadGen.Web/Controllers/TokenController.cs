using LeadGen.Code;
using LeadGen.Code.CMS;
using LeadGen.Code.Helpers;
using LeadGen.Code.Lead;
using LeadGen.Code.Sys;
using LeadGen.Code.Tokens;
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
            Token token = Token.LoadFromDB(DBLGcon, key);
            if (token == null)
                return View("error");

            if (token is BusinessRegistrationEmaiConfirmationToken)
                return LoginEmailConfirm(token as BusinessRegistrationEmaiConfirmationToken);
            else if (token is LoginRecoverPasswordToken)
                return LoginRecoverPassword(token as LoginRecoverPasswordToken);
            else if (token is LeadEmailConfirmationToken)
                return LeadEmailConfirm(token as LeadEmailConfirmationToken);
            else if (token is LeadRemoveByUserToken)
                return LeadRemoveByUser(token as LeadRemoveByUserToken);
            else if (token is Token)
                return BusinessCRMLeadUnsubscribe(token as BusinessCRMLeadUnsubscribeToken);

            return RedirectToAction("Index", "Home", new { area = "" });
        }

        [NonAction]
        private ActionResult LoginEmailConfirm(BusinessRegistrationEmaiConfirmationToken token)
        {
            Login confirmLogin = Login.SelectOne(DBLGcon, loginID: token.LoginID);

            if (confirmLogin != null)
            {
                Login.EmailConfirm(DBLGcon, confirmLogin.ID);
                string sessionID = LoginController.SetLoginSessionCookie(DBLGcon, HttpContext, confirmLogin.ID);
                token.DeleteFromDB(DBLGcon);

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
        private ActionResult LoginRecoverPassword(LoginRecoverPasswordToken token)
        {
            Login recoverLogin = Login.SelectOne(DBLGcon, loginID: token.LoginID);

            ViewData["tokenKey"] = token.Key;
            return View("../Login/RecoverPassword", recoverLogin);
        }

        [NonAction]
        private ActionResult LeadEmailConfirm(LeadEmailConfirmationToken token)
        {
            if (LeadItem.EmailConfirm(DBLGcon, token.LeadID))
            {
                token.DeleteFromDB(DBLGcon);
                LeadItem leadItem = LeadItem.SelectFromDB(DBLGcon, leadID: token.LeadID, loadFieldValues: true).FirstOrDefault();

                SendMessageToAdmins("New Lead Confirmed", string.Format("New Lead: #{0}", leadItem.ID));

                return View("../Order/ConfirmEmailSuccess", leadItem);
            }

            //Error
            return RedirectToAction("Index", "Home", new { area = "" });
        }

        [NonAction]
        private ActionResult LeadRemoveByUser(LeadRemoveByUserToken token)
        {
            List<LeadItem> userLeads = LeadItem.SelectFromDB(DBLGcon, token.UserEmailAddress).Where(x=>x.adminDetails.publishedDateTime != null).ToList();
            foreach (LeadItem lead in userLeads)
                lead.CancelByUser(DBLGcon, DateTime.UtcNow);

            token.DeleteFromDB(DBLGcon);

            return View("../Order/Canceled", token.UserEmailAddress);
        }


        private static void SendMessageToAdmins(string subject, string message) {

            IEnumerable<MailMessageLeadGen> mailMessages = MailMessageBuilder.BuildAdminNotificationMessages(subject, message);

            foreach (MailMessageLeadGen mailMessage in mailMessages)
            {
                SmtpClientLeadGen.SendSingleMessage(mailMessage);
            }
        }

        private ActionResult BusinessCRMLeadUnsubscribe(BusinessCRMLeadUnsubscribeToken token)
        {
            Post businessPost = token.UnsubscribeBusinessPost(DBLGcon);
            token.DeleteFromDB(DBLGcon);

            SendMessageToAdmins("CRM Business unsubscribed", string.Format("CRM business post: #{0}", businessPost.ID));

            return View("BusinessCRMLeadUnsubscribeSuccess", businessPost);
        }
        
    }
}