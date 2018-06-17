using LeadGen.Code.Business.Notification;
using LeadGen.Code.Lead;
using LeadGen.Code.Sys;
using LeadGen.Controllers;
using PagedList;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;

namespace LeadGen.Areas.Admin.Controllers
{
    public class LeadController : AdminBaseController
    {
        // GET: Admin/Orders
        public override ActionResult Index()
        {
            return RedirectToAction("List");
        }

        
        public ActionResult List(AdminDetails.Status status = AdminDetails.Status.ReadyToPublish, long? leadID = null, DateTime? publishedFrom = null, DateTime? publishedTo = null, string query = "", int page = 1)
        {
            ViewBag.status = status;

            IPagedList<LeadItem> leads = LeadItem.SelectFromDB(DBLGcon, status: status, leadID: leadID, dateFrom: publishedFrom, dateTo: publishedTo, query: query, page: page, pageSize: 20);

            LeadItem.LoadFieldValuesForLeads(DBLGcon, leads);
            foreach (LeadItem item in leads)
                item.LoadBusinessActvityForAdmin(DBLGcon);


            ViewBag.status = status;
            ViewBag.leadID = leadID;
            ViewBag.publishedFrom = publishedFrom;
            ViewBag.publishedTo = publishedTo;
            ViewBag.query = query;

            return View(leads);
        }

        [HttpPost]
        public PartialViewResult Manage(long leadID, string doAction)
        {
            bool result = false;

            LeadItem leadItem = LeadItem.SelectFromDB(DBLGcon, leadID: leadID).FirstOrDefault();
            if (leadItem != null)
            {
                if (doAction == "TryPublish")
                {
                    result = leadItem.TryPublish(DBLGcon, login.ID);
                    if (result)
                    {
                        NotificationManager.QueueMailMessagesForBusinessesRegisteredAboutNewLeads(DBLGcon, Code.Business.NotificationSettings.Frequency.Immediate);

                        //This code will perform HTTP call that will run these tasks in the separate thread
                        SystemController.InitializeScheduledTasks(DBLGcon, requestedHttpHostUrl, new List<Type>() {
                            typeof(Code.Sys.Scheduled.SendQueuedMail)
                        });
                    }

                }
                else if (doAction == "TryUnPublish")
                    result = leadItem.TryUnPublishByAdmin(DBLGcon, login.ID);
            }

            return PartialView("LeadActions/_" + leadItem.adminDetails.status.ToString(), leadItem);
        }

        public ActionResult Edit(long leadID)
        {
            LeadItem leadItem = LeadItem.SelectFromDB(DBLGcon, leadID: leadID).FirstOrDefault();
            if (leadItem == null)
                return RedirectToAction("List", "Lead", new { area = "Admin" });

            leadItem.LoadFieldStructure(DBLGcon);
            leadItem.LoadFieldValues(DBLGcon);
            

            return View(leadItem);
        }

        [HttpPost]
        public ActionResult Edit(LeadItem postedLeadItem)
        {
            LeadItem leadItem = new LeadItem() {ID = postedLeadItem.ID };
            leadItem.LoadFieldStructure(DBLGcon, false);
            leadItem.SafeReplaceLeadValuesWith(postedLeadItem);

            leadItem.Validate(ModelState);
            var validationErrors = ModelState.Values.Where(x => x.Errors.Count > 0).ToArray();

            if (ModelState.IsValid)
            {
                bool updateResult = leadItem.UpdateFieldGroupsInDB(DBLGcon);
                if (updateResult == false)
                    ModelState.AddModelError("", "Something is wrong");
            }

            ViewBag.NofificationStatus = ModelState.IsValid;

            return PartialView("EditorTemplates/LeadItem", leadItem);
        }

        [HttpPost]
        public ActionResult Duplicate(long leadID)
        {
            LeadItem duplicateLeadItem = LeadItem.SelectFromDB(DBLGcon, leadID: leadID).FirstOrDefault();

            if (duplicateLeadItem == null || duplicateLeadItem.adminDetails.emailConfirmedDateTime == null || duplicateLeadItem.adminDetails.publishedDateTime != null)
                return new HttpStatusCodeResult(500, "Lead email must be confirmed and the lead should not be published");

            duplicateLeadItem.LoadFieldStructure(DBLGcon);
            duplicateLeadItem.LoadFieldValues(DBLGcon);

            LeadItem leadItem = new LeadItem();
            leadItem.LoadFieldStructure(DBLGcon, false);
            leadItem.SafeReplaceLeadValuesWith(duplicateLeadItem);

            if (leadItem.Insert(DBLGcon) == false)
                return new HttpStatusCodeResult(500, "Can not create new Lead in the database");

            leadItem.UpdateFieldGroupsInDB(DBLGcon);
            LeadItem.EmailConfirm(DBLGcon, leadItem.ID);

            return Json(new { Url = new UrlHelper(Request.RequestContext).Action("Edit", "Lead", new { area = "Admin", leadID = leadItem.ID }) });
        }

    }
}