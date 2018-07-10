using LeadGen.Code.Business.Inovice;
using Microsoft.AspNetCore.Mvc;
using PagedList;
using PagedList.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


namespace LeadGen.Areas.Business.Controllers
{
    public class InvoiceController : BusinessParentController
    {
        public override ActionResult Index()
        {
            return RedirectToAction("List");
        }

        public ActionResult List(bool isPaid = false, int? legalYear = null, int? legalNumber = null, int page = 1)
        {
            List<Invoice> invoices = Invoice.SelectFromDB(DBLGcon, businessID: login.business.ID, legalYear: legalYear, legalNumber: legalNumber).Where(x => x.publishedDateTime != null).ToList();

            if(isPaid)
                invoices = invoices.Where(x => x.paidDateTime != null).ToList();
            else
                invoices = invoices.Where(x => x.paidDateTime == null).ToList();

            IPagedList<Invoice> results = invoices.ToPagedList(page, 20);

            foreach (Invoice invoice in results)
            {
                invoice.loadIncludedLeads(DBLGcon);
            }

            ViewBag.isPaid = isPaid;
            ViewBag.legalYear = legalYear;
            ViewBag.legalNumber = legalNumber;
            return View(results);
        }


        public ActionResult Details(int legalNumber, int legalYear, bool showAct = false)
        {
            Invoice invoice = Invoice.SelectFromDB(DBLGcon, businessID: login.business.ID, legalYear: legalYear, legalNumber: legalNumber, loadInvoiceLines: true).FirstOrDefault();

            if (invoice == null)
                return RedirectToAction("List");

            ViewBag.showAct = showAct;
            return View(invoice);
        }


    }
}