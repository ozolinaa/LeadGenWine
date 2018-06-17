using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using LeadGen.Code.Lead;
using PagedList;

namespace LeadGen.Areas.Admin.Controllers
{
    public class ReviewController : AdminBaseController
    {
        // GET: Admin/Review
        public override ActionResult Index()
        {
            return RedirectToAction("List");
        }

        public ActionResult Edit(long ID)
        {
            Review reviewItem = Review.SelectFromDB(DBLGcon, leadID: ID, published: null).First();
            reviewItem.LoadBusinessOptions(DBLGcon);
            reviewItem.LoadMeasures(DBLGcon);
            return View(reviewItem);
        }

        [HttpPost]
        public ActionResult Edit(Review review)
        {
            //Remove business validation errors
            ModelState.Clear();

            review.adjustProvidedStarValues();

            //If otherBusiness
            if (review.otherBusiness == true)
                if (string.IsNullOrEmpty(review.otherBusinessName))
                    ModelState.AddModelError("otherBusinessName", "Название мастерской обязательно");

            //If completed
            if (review.businessID != null || review.otherBusiness == true)
                if (string.IsNullOrEmpty(review.authorName))
                    ModelState.AddModelError("authorName", "Введите имя");

            review.LoadBusinessOptions(DBLGcon);

            //If Validation errors, return the view
            if (ModelState.IsValid == false)
                return View(review);
                
            review.SaveInDB(DBLGcon);
            return View(review);
        }

        public ActionResult List(Review.Status status = Review.Status.New, long? leadID = null, long? businessID = null, DateTime? createdFrom = null, DateTime? createdTo = null, int? page = 1)
        {
            IPagedList<Review> reviews = Review.SelectFromDB(DBLGcon, leadID: leadID, dateFrom: createdFrom, dateTo: createdTo, businessID: businessID, published: status == Review.Status.Published, page: page ?? 1, pageSize: 20);
            foreach (Review item in reviews)
            {
                item.LoadMeasures(DBLGcon);
                item.LoadBusinessOptions(DBLGcon);
            }

            ViewBag.status = status;
            ViewBag.leadID = leadID;
            ViewBag.createdFrom = createdFrom;
            ViewBag.createdTo = createdTo;
            ViewBag.businesses = Code.Business.Business.SelectFromDB(DBLGcon).ToList();

            return View(reviews);
        }


        [HttpPost]
        public PartialViewResult Manage(long leadID, string doAction)
        {
            bool result = false;

            Review reviewItem = Review.SelectFromDB(DBLGcon, leadID: leadID, published:null).FirstOrDefault();
            if (reviewItem != null)
            {
                if (doAction == "Publish")
                    result = reviewItem.Publish(DBLGcon, login.ID);
                else if (doAction == "UnPublish")
                    result = reviewItem.UnPublish(DBLGcon, login.ID);
            }

            return PartialView("_LeadAction", reviewItem);
        }
    }
}