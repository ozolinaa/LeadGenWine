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
            else if (token is BusinessCRMLeadUnsubscribeToken)
                return BusinessCRMLeadUnsubscribeAskConfirmation(token as BusinessCRMLeadUnsubscribeToken);

            return RedirectToAction("Index", "Home", new { area = "" });
        }

        [NonAction]
        private ActionResult LoginEmailConfirm(BusinessRegistrationEmaiConfirmationToken token)
        {
            Login login = Login.SelectOne(DBLGcon, loginID: token.LoginID);

            if (login != null)
            {
                Login.EmailConfirm(DBLGcon, login.ID);
                string sessionID = LoginController.SetLoginSessionCookie(DBLGcon, HttpContext, login.ID);
                if (String.IsNullOrEmpty(sessionID)) {
                    // sessionId will be empty if the password was not set  
                    // return view to set password
                    ViewData["token"] = token;
                    return View("../Login/SetPassword", login);
                }

                token.DeleteFromDB(DBLGcon);
                login = LeadGen.Code.Session.GetLoginBySessionID(DBLGcon, sessionID);

                if (login.business != null)
                {
                    Code.Business.NotificationSettings.EmailAdd(DBLGcon, login.business.ID, login.email);

                    SendMessageToAdmins("New Business Registered", string.Format("New business: #{0} {1}", login.business.ID, login.business.name));

                    return RedirectToAction("Index", "Account", new { area = "Business" });
                }
            }

            //Error
            return RedirectToAction("Index", "Home", new { area = "" });
        }

        [NonAction]
        private ActionResult LoginRecoverPassword(LoginRecoverPasswordToken token)
        {
            Login login = Login.SelectOne(DBLGcon, loginID: token.LoginID);

            ViewData["token"] = token;
            return View("../Login/SetPassword", login);
        }

        [NonAction]
        private ActionResult LeadEmailConfirm(LeadEmailConfirmationToken token)
        {
            if (LeadItem.EmailConfirm(DBLGcon, token.LeadID))
            {
                token.DeleteFromDB(DBLGcon);
                LeadItem leadItem = LeadItem.SelectFromDB(DBLGcon, leadID: token.LeadID, loadFieldValues: true).FirstOrDefault();

                SendMessageToAdmins("New Lead Confirmed", string.Format("New Lead: #{0}", leadItem.ID));

                return View("Order/ConfirmEmailSuccess", leadItem);
            }

            //Error
            return RedirectToAction("Index", "Home", new { area = "" });
        }

        [NonAction]
        private ActionResult LeadRemoveByUser(LeadRemoveByUserToken token)
        {
            List<LeadItem> userLeads = LeadItem.SelectFromDB(DBLGcon, token.UserEmailAddress).Where(x => x.adminDetails.publishedDateTime != null).ToList();
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

        #region BusinessCRMLeadUnsubscribe

        private ActionResult BusinessCRMLeadUnsubscribeAskConfirmation(BusinessCRMLeadUnsubscribeToken token)
        {
            token.LoadBusinessPost(DBLGcon);
            return View("BusinessCRMLeadUnsubscribe/AskConfirmation", token);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult BusinessCRMLeadUnsubscribeSubmitConfirmation(BusinessCRMLeadUnsubscribeToken token)
        {
            token = (BusinessCRMLeadUnsubscribeToken)Token.LoadFromDB(DBLGcon, token.Key);
            token.LoadBusinessPost(DBLGcon);
            token.BusinessPost.UnsubscribeFromNewLeads(DBLGcon);

            SendMessageToAdmins("CRM Business unsubscribed", string.Format("CRM business post: #{0}", token.BusinessPost.ID));

            return View("BusinessCRMLeadUnsubscribe/ShowSuccess", token);
        }

        #endregion



    }
}