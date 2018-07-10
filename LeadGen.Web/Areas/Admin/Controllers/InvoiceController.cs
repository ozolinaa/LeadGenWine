using System;
using System.Collections.Generic;
using System.Linq;
using LeadGen.Code.Business.Inovice;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace LeadGen.Areas.Admin.Controllers
{
    public class InvoiceController : AdminBaseController
    {
        DateTime invoicingForLegalDate;
        DateTime leadsCompletedBeforeDateTime {
            get {
                return invoicingForLegalDate.AddMonths(1);
            }
        }
        InvoiceManager invoiceManager;

        


        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);

            invoicingForLegalDate = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1).AddMonths(-1);
            invoiceManager = new InvoiceManager();
        }

        // GET: Admin/Invoice
        public override ActionResult Index()
        {
            return RedirectToAction("List");
        }

        public ActionResult List(bool? isPublished = null, bool? isPaid = null, long? invoiceID = null, long? businessID = null, int? legalYear = null, int? legalNumber = null)
        {
            List<Invoice> invoices = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, businessID: businessID, legalYear: legalYear, legalNumber: legalNumber);

            switch (isPublished)
            {
                case true:
                    invoices = invoices.Where(x => x.publishedDateTime != null).ToList();
                    break;
                case false:
                    invoices = invoices.Where(x => x.publishedDateTime == null).ToList();
                    break;
            }

            switch (isPaid)
            {
                case true:
                    invoices = invoices.Where(x => x.paidDateTime != null).ToList();
                    break;
                case false:
                    invoices = invoices.Where(x => x.paidDateTime == null).ToList();
                    break;
            }


            return View(invoices);
        }

        public ActionResult BusinessLeadsCompletedBeforeCurrentMonth()
        {
            List<Code.Business.Business> businessList = invoiceManager.SelectBusinessessForNewInvoices(DBLGcon, leadsCompletedBeforeDateTime);

            return View(businessList);
        }

        [HttpPost]
        public ActionResult GenerateForBusiness(long businessID)
        {
            Code.Business.Business business = Code.Business.Business.SelectFromDB(DBLGcon, businessID: businessID).First();

            ////Check if the business has orders to pay
            //business.leads = business.SelectLeadsFromDB(DBLGcon, Code.Lead.BusinessDetails.Status.NextInvoice, completedBeforeDate: leadsCompletedBeforeDateTime).ToList();
            //if (business.leads.Count == 0 || business.leads.Sum(x => x.businessDetails.orderSum) == 0)
            //    return RedirectToAction("BusinessLeadsCompletedBeforeCurrentMonth");

            Invoice newInvoice = Invoice.GenerateInvoiceForBusiness(DBLGcon, business.ID, invoicingForLegalDate.Year, invoicingForLegalDate.Month);
            string monthName = invoicingForLegalDate.ToString("MMMM");
            newInvoice.TryAddLineWithLeads(DBLGcon, string.Format("Оплата услуг за {0} {1}г. по договору публичной оферты", monthName, invoicingForLegalDate.Year));

            return RedirectToAction("Edit", new { invoiceID = newInvoice.ID });
        }

        public ActionResult Show(long invoiceID)
        {
            Invoice invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines:true).FirstOrDefault();
            return View(invoice);
        }

        public ActionResult Edit(long invoiceID)
        {
            Invoice invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines: true).FirstOrDefault();
            if (invoice.publishedDateTime != null)
                return RedirectToAction("Show", new { invoiceID = invoice.ID });

            return View(invoice);
        }

        [HttpPost]
        public ActionResult LineAdd(long invoiceID)
        {
            Invoice invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines: true).FirstOrDefault();
            if (invoice.publishedDateTime != null)
                return RedirectToAction("Show", new { invoiceID = invoice.ID });

            invoice.LineAdd(DBLGcon);
            //ReloadInvoice
            invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines: true).FirstOrDefault();
            return PartialView("_InvoiceLinesEditor", invoice);
        }

        [HttpPost]
        public ActionResult LineRemove(long invoiceID, Int16 lineID)
        {
            Invoice invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines: true).FirstOrDefault();
            if (invoice.publishedDateTime != null)
                return RedirectToAction("Show", new { invoiceID = invoice.ID });

            invoice.LineRemove(DBLGcon, lineID);
            //ReloadInvoice
            invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines: true).FirstOrDefault();
            return PartialView("_InvoiceLinesEditor", invoice);
        }

        [HttpPost]
        [ActionName("Edit")]
        public ActionResult Edit_Post(long invoiceID)
        {
            Invoice invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines: true).FirstOrDefault();
            if (invoice.publishedDateTime != null)
                return RedirectToAction("Show", new { invoiceID = invoice.ID });

            string[] excludeProperties = new string [] {
                "ID","businessID","legalNumber","legalYear","legalMonth","totalSum","createdDateTime","paidDateTime","publishedDateTime"
            };

            throw new NotImplementedException();
            //TryUpdateModel(invoice, null,null, excludeProperties);

            invoice.UpdateInDB(DBLGcon);

            //ReloadInvoice
            invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines: true).FirstOrDefault();

            return PartialView("EditorTemplates/Invoice", invoice);
        }

        [HttpPost]
        public PartialViewResult Publish(long invoiceID)
        {
            Invoice invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines: true).FirstOrDefault();

            invoice.Publish(DBLGcon, DateTime.UtcNow);
            //ReloadInvoice
            invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines: true).FirstOrDefault();

            return PartialView("DisplayTemplates/Invoice", invoice);
        }

        [HttpPost]
        public ActionResult SetPaid(long invoiceID)
        {
            Invoice invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines: true).FirstOrDefault();
            if (invoice.publishedDateTime == null)
                return RedirectToAction("Show", new { invoiceID = invoice.ID });

            invoice.SetPaid(DBLGcon, DateTime.UtcNow);
            //ReloadInvoice
            invoice = Invoice.SelectFromDB(DBLGcon, invoiceID: invoiceID, loadInvoiceLines: true).FirstOrDefault();

            return PartialView("DisplayTemplates/Invoice", invoice);
        }

        [HttpPost]
        public ActionResult Delete(long invoiceID)
        {
            Invoice.DeleteFromDB(DBLGcon, invoiceID);
            return RedirectToAction("List");
        }


    }
}