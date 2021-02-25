using LeadGen.Code;
using LeadGen.Code.CMS;
using LeadGen.Code.Lead;
using Microsoft.AspNetCore.Mvc;

using X.PagedList;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;


namespace LeadGen.Web.Areas.Business.Controllers
{
    public class AccountController : BusinessBaseController
    {

        public override ActionResult Index()
        {
            return RedirectToAction("Leads");
        }

        public ActionResult Leads(BusinessDetails.Status status = BusinessDetails.Status.All, long? leadID = null, DateTime? publishedFrom = null, DateTime? publishedTo = null, string query = "", int page = 1, bool searchInit = false)
        {
            if (publishedFrom == null)
            {
                publishedFrom = DateTime.Now.AddYears(-1);
            }

            IPagedList<LeadItem> leads = login.business.SelectLeadsFromDB(DBLGcon,
                status: status,
                leadID: leadID,
                dateFrom: publishedFrom,
                dateTo: publishedTo,
                query: query,
                page: page,
                pageSize: 10,
                loadFieldValues: true);

            ViewBag.status = status;
            ViewBag.leadID = leadID;
            ViewBag.publishedFrom = publishedFrom;
            ViewBag.publishedTo = publishedTo;
            ViewBag.query = query;

            return View(leads);
        }

        [HttpPost]
        public PartialViewResult ManageOrder(long leadID, string doAction)
        {
            bool result = false;

            LeadItem leadItem = login.business.SelectLeadsFromDB(DBLGcon, leadID: leadID, loadFieldValues: true).FirstOrDefault();
            if (leadItem != null)
            {
                login.business.leadManager = new Code.Business.LeadManager(DBLGcon, login.business.ID, login.ID, leadID);

                switch (doAction)
                {
                    case "GetContacts":
                        result = login.business.leadManager.GetContacts(ref leadItem);
                        break;
                    case "SetCompleted":
                        leadItem.businessDetails = new BusinessDetails()
                        {
                            systemFeePercent = login.business.leadManager.systemFeePercent
                        };
                        return PartialView("LeadActionParts/_SubmitOrderSum", leadItem);
                    case "SetImportant":
                        result = login.business.leadManager.SetImportant(ref leadItem);
                        break;
                    case "SetNotImportant":
                        result = login.business.leadManager.SetNotImportant(ref leadItem);
                        break;
                    case "SetInterested":
                        result = login.business.leadManager.SetInterested(ref leadItem);
                        break;
                    case "SetNotInterested":
                        result = login.business.leadManager.SetNotInterested(ref leadItem);
                        break;
                    default:
                        break;
                }

            }

            return PartialView("DisplayTemplates/LeadItem", leadItem);
        }


        [HttpPost]
        public PartialViewResult SubmitOrderSum(LeadItem lead)
        {
            bool result = false;

            LeadItem leadItem = login.business.SelectLeadsFromDB(DBLGcon, leadID: lead.ID, loadFieldValues: true).FirstOrDefault();
            if (leadItem != null && leadItem.businessDetails != null && lead.businessDetails.orderSum > 0)
            {
                login.business.leadManager = new Code.Business.LeadManager(DBLGcon, login.business.ID, login.ID, leadItem.ID);
                result = login.business.leadManager.SetCompleted(ref leadItem, lead.businessDetails.orderSum);
            }

            return PartialView("DisplayTemplates/LeadItem", leadItem);
        }
    }
}