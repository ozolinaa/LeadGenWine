using LeadGen.Code.Business;
using LeadGen.Code.Lead;
using LeadGen.Web.Controllers;
using Microsoft.AspNetCore.Mvc;
using X.PagedList;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


namespace LeadGen.Web.Areas.Admin.Controllers
{
    public class BusinessController : AdminBaseController
    {
        // GET: Admin/Business
        public override ActionResult Index()
        {
            return RedirectToAction("List");
        }

        public ActionResult List(long? businessID, DateTime? registeredFrom, DateTime? registeredTo, string query, int page = 1)
        {
            StaticPagedList<Code.Business.Business> businessList = Code.Business.Business.SelectFromDB(DBLGcon, businessID: businessID, query: query, registeredFrom: registeredFrom, registeredTo: registeredTo, page: page, pageSize:20);

            ViewBag.query = query;
            return View(businessList);
        }

        public ActionResult Details(long ID)
        {
            Code.Business.Business business = Code.Business.Business.SelectFromDB(DBLGcon, businessID: ID).FirstOrDefault();
            business.notification.LoadEmailList(DBLGcon, business.ID);
            Code.CMS.Post businessPost = Code.CMS.Post.SelectFromDB<Code.CMS.Post>(DBLGcon, "master_businessID", numberValue: business.ID).FirstOrDefault();

            ViewBag.businessPost = businessPost;
            return View(business);
        }

        public ActionResult Leads(long ID, BusinessDetails.Status status = BusinessDetails.Status.NewForBusiness, long? leadID = null, DateTime? publishedFrom = null, DateTime? publishedTo = null, string query = "", int page = 1)
        {
            Code.Business.Business business = Code.Business.Business.SelectFromDB(DBLGcon, businessID: ID).FirstOrDefault();

            IPagedList<LeadItem> leads = business.SelectLeadsFromDB(DBLGcon,
                status: status,
                leadID: leadID,
                dateFrom: publishedFrom,
                dateTo: publishedTo,
                query: query,
                page: page,
                pageSize: 10,
                loadFieldValues: true);

            ViewBag.business = business;
            ViewBag.status = status;
            ViewBag.leadID = leadID;
            ViewBag.publishedFrom = publishedFrom;
            ViewBag.publishedTo = publishedTo;
            ViewBag.query = query;

            return View(leads);
        }

        public ActionResult Locations(long ID)
        {
            Code.Business.Business business = Code.Business.Business.SelectFromDB(DBLGcon, businessID: ID).FirstOrDefault();
            business.LoadLocations(DBLGcon);
            return View(business);
        }

        [HttpPost]
        public ActionResult BusinessLocationApproval(long businessID, long locationID, bool approve) {
            Code.Business.Business business = Code.Business.Business.SelectFromDB(DBLGcon, businessID: businessID).First();
            business.LoadLocations(DBLGcon);
            BusinessLocation location = business.locations.First(x => x.Location.ID == locationID);
            location.ApprovalSetByAdmin(DBLGcon, login.ID, approve);

            //Just In Case, reload location data from DB (instead of setting approval in code)
            business.LoadLocations(DBLGcon);
            location = business.locations.First(x => x.Location.ID == locationID);

            return PartialView("_LocationDetails", location);
        }


        public ActionResult Permissions(long ID)
        {
            Code.Business.Business business = Code.Business.Business.SelectFromDB(DBLGcon, businessID: ID).FirstOrDefault();
            business.LoadLeadPermissions(DBLGcon, onlyCurrentlyRequested: false);
            return View(business);
        }

        [HttpPost]
        public ActionResult PermissionManage(long permittionID, long businessID, string doAction)
        {
            Code.Business.Business business = Code.Business.Business.SelectFromDB(DBLGcon, businessID: businessID).First();
            business.LoadLeadPermissions(DBLGcon, onlyCurrentlyRequested: false);
            LeadPermittion permittion = business.leadPermissions.First(x => x.ID == permittionID);

            if (doAction == "approve")
                permittion.Approve(DBLGcon, login.ID);
            else if (doAction == "approve-cancel")
                permittion.ApproveCancel(DBLGcon, login.ID);

            ViewData["businessID"] = businessID;
            return PartialView("EditorTemplates/LeadPermittion", permittion);
        }


        [HttpPost]
        public ActionResult Impersonate(long businessID)
        {
            Code.Business.Business business = Code.Business.Business.SelectFromDB(DBLGcon, businessID: businessID).First();
            string sessionID = LoginController.SetLoginSessionCookie(DBLGcon, HttpContext, business.adminLoginID);
            return RedirectToAction("Index", "Leads", new { area = "Business" });
        }

    }
}