using LeadGen.Code;
using LeadGen.Code.Business;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LeadGen.Areas.Business.Controllers
{
    public class SettingsController : BusinessParentController
    {

        protected override void Initialize(System.Web.Routing.RequestContext requestContext)
        {
            // Invoke base class Initialize method (login.business initialized there)
            base.Initialize(requestContext); 

            //Initialize Business Notification
            login.business.notification = new NotificationSettings(DBLGcon, login.business.ID, login.business.notification.frequency);

            login.business.LoadLocations(DBLGcon);
            login.business.LoadLeadPermissions(DBLGcon);
        }


        // GET: Business/Settings
        public override ActionResult Index()
        {
            return View(login);
        }

        [HttpPost]
        public ActionResult LoginBusinessMainUpdate(Login updateLogin)
        {
            ViewBag.status = false;
            if (ModelState.IsValidField("business.webSite") && ModelState.IsValidField("business.name"))
            {
                login.business.webSite = updateLogin.business.webSite;
                login.business.name = updateLogin.business.name;
                login.business.address = updateLogin.business.address;
                login.business.Update(DBLGcon);
                ViewBag.status = true;
            }

            return PartialView("EditorTemplates/LoginBusinessMain", updateLogin);
        }

        [HttpPost]
        public ActionResult LoginBusinessContactUpdate(Login updateLogin)
        {
            ViewBag.status = false;
            if (ModelState.IsValidField("business.contact.name") && ModelState.IsValidField("business.contact.email") && ModelState.IsValidField("business.contact.phone") && ModelState.IsValidField("business.contact.skype"))
            {
                updateLogin.business.contact.Update(DBLGcon, login.business.ID);
                ViewBag.status = true;
            }

            ViewData.TemplateInfo.HtmlFieldPrefix = "business.contact";
            return PartialView("EditorTemplates/Contact", updateLogin.business.contact);
        }

        [HttpPost]
        public ActionResult LoginBusinessBillingUpdate(Login updateLogin)
        {
            ViewBag.status = false;
            if (ModelState.IsValidField("business.billing.name") && ModelState.IsValidField("business.billing.code1") && ModelState.IsValidField("business.billing.code2") && ModelState.IsValidField("business.billing.address"))
            {
                updateLogin.business.billing.Update(DBLGcon, login.business.ID);
                ViewBag.status = true;
            }
            ViewData.TemplateInfo.HtmlFieldPrefix = "business.billing";
            return PartialView("EditorTemplates/Billing", updateLogin.business.billing);
        }

        [HttpPost]
        public ActionResult LoginBusinessPermissionsUpdate(Login updateLogin)
        {
            AjaxResponseType ajaxResponseType = AjaxResponseType.error;

            List<long[]> requestedTermIDs = new List<long[]>();

            foreach (LeadPermittion permission in updateLogin.business.leadPermissions)
                requestedTermIDs.Add(permission.terms.Select(x => x.ID).ToArray());

            if (login.business.UpdateRequestedPermissions(DBLGcon, requestedTermIDs, login.business.leadPermissions))
                ajaxResponseType = AjaxResponseType.success;

            return new JsonResult()
            {
                JsonRequestBehavior = JsonRequestBehavior.AllowGet,
                Data = new { status = ajaxResponseType.ToString() }
            };
        }

        #region BusinessLcations

        [HttpPost]
        public ActionResult BusinessLocationCreate(BusinessLocation location)
        {
            location.CreateInDB(DBLGcon, login.business.ID);
            login.business.LoadLocations(DBLGcon);
            return PartialView("_LocationsMapList", login.business.locations);
        }

        [HttpGet]
        public ActionResult BusinessLocationEdit(long locationID)
        {
            BusinessLocation location = login.business.locations.First(x => x.locationID == locationID);
            return PartialView("_LocationMapEditorModal", location);
        }

        [HttpPost]
        public ActionResult BusinessLocationEdit(BusinessLocation location)
        {
            location.UpdateInDB(DBLGcon, login.business.ID);
            login.business.LoadLocations(DBLGcon);
            return PartialView("_LocationsMapList", login.business.locations);
        }

        [HttpDelete]
        public ActionResult BusinessLocationDelete(long locationID)
        {
            BusinessLocation.DeleteFromDB(DBLGcon, locationID, login.business.ID);
            login.business.LoadLocations(DBLGcon);
            return PartialView("_LocationsMapList", login.business.locations);
        }

        #endregion

        [HttpPost]
        public ActionResult BusinessNotificationEmailAddressRemove(string removeEmail)
        {
            Code.Business.NotificationSettings.NotificationEmail RemoveNotificationEmail = login.business.notification.emailList.FirstOrDefault(x => x.address == removeEmail);

            if (RemoveNotificationEmail != null)
            {
                int RemoveNotificationEmailIndex = login.business.notification.emailList.IndexOf(RemoveNotificationEmail);
                ViewData.TemplateInfo.HtmlFieldPrefix = string.Format("business.notification.emailList[{0}]", RemoveNotificationEmailIndex);

                //PerformRemoving
                if (Code.Business.NotificationSettings.EmailRemove(DBLGcon, login.business.ID, removeEmail))
                    ViewBag.DeletedStatus = true;
            }
            return PartialView("EditorTemplates/NotificationEmail", RemoveNotificationEmail);
        }

        [HttpPost]
        public ActionResult LoginBusinessNotificationUpdate(Login updateLogin)
        {
            //Process Notification Frequency
            if (login.business.notification.frequency != updateLogin.business.notification.frequency)
                if (!NotificationSettings.FrequencyTryUpdate(DBLGcon, login.business.ID, updateLogin.business.notification.frequency))
                    ModelState.AddModelError("business.notification.frequency", "Notification Frequency Update Error");


            //Process new Notification Email Address 
            string newNotificationEmailAddress = updateLogin.business.notification.newNotificationEmail.address;
            if (!string.IsNullOrEmpty(newNotificationEmailAddress))
                if(ModelState.IsValidField("business.notification.newNotificationEmail.address"))
                    if (NotificationSettings.EmailAdd(DBLGcon, login.business.ID, newNotificationEmailAddress))
                    {
                        if (updateLogin.business.notification.emailList == null)
                            updateLogin.business.notification.emailList = new List<NotificationSettings.NotificationEmail>();
                        updateLogin.business.notification.emailList.Add(new NotificationSettings.NotificationEmail(newNotificationEmailAddress));
                    }
                    else
                        ModelState.AddModelError("business.notification.newNotificationEmail.address", "Email Insert Error");

            if (ModelState.IsValidField("business.notification.frequency") && ModelState.IsValidField("business.notification.newNotificationEmail.address"))
                ViewBag.status = true;

            ViewData.TemplateInfo.HtmlFieldPrefix = "business.notification";
            return PartialView("EditorTemplates/NotificationSettings", updateLogin.business.notification);
        }



    }
}