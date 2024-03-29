﻿using LeadGen.Code;
using LeadGen.Code.CMS;
using LeadGen.Code.Helpers;
using LeadGen.Code.Lead;
using LeadGen.Code.Sys;
using LeadGen.Code.Tokens;
using LeadGen.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Threading.Tasks;

namespace LeadGen.Web.Controllers
{
    public class OrderController : DatabaseController
    {

        public LeadItem leadItem { get; set; }

        public ActionResult Index()
        {
            leadItem = new LeadItem();
            leadItem.LoadFieldStructure(DBLGcon, true);

            return View("Create", leadItem);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Index(LeadItem postedLeadItem)
        {
            leadItem = new LeadItem();
            leadItem.LoadFieldStructure(DBLGcon, true);
            leadItem.SafeReplaceLeadValuesWith(postedLeadItem);
            leadItem = leadItem;

            leadItem.Validate(ModelState);
            var validationErrors = ModelState.Values.Where(x => x.Errors.Count > 0).ToArray();

            if (ModelState.IsValid)
                return PartialView("DisplayTemplates/LeadItem", leadItem);

            return PartialView("EditorTemplates/LeadItem", leadItem);
                
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Confirm(LeadItem postedLeadItem, bool GoBackToOrder = false, bool AgreeWithSystemTerms = false)
        {
            leadItem = new LeadItem();
            leadItem.LoadFieldStructure(DBLGcon, true);
            leadItem.SafeReplaceLeadValuesWith(postedLeadItem);

            //Validate and send back to order editor template if model is not valid
            leadItem.Validate(ModelState);

            if (GoBackToOrder || !ModelState.IsValid)
            {
                return PartialView("EditorTemplates/LeadItem", leadItem);
            }

            //If Not AgreeWithSystemTerms, add validation error and show the same page with validation error
            if (!AgreeWithSystemTerms)
            {
                ModelState.AddModelError("AgreeWithSystemTerms", "You must agree with system terms and conditions");
                return PartialView("DisplayTemplates/LeadItem", leadItem);
            }

            // If we are here, means everything is valid and user agreed
            leadItem.Insert(DBLGcon);
            MailMessageLeadGen message = MailMessageBuilder.BuildLeadEmailVerifyMailMessage(leadItem, DBLGcon);
            SmtpClientLeadGen.SendSingleMessage(message);

            return PartialView("ConfirmEmail", leadItem);
        }

        public ActionResult Show(long id)
        {
            leadItem = LeadItem.SelectFromDB(DBLGcon, leadID: id, loadFieldValues: true).FirstOrDefault();
            return View(leadItem);
        }

        public ActionResult Review(long id, string token)
        {
            LeadReviewCreateToken foundToken = Token.LoadFromDB(DBLGcon, token) as LeadReviewCreateToken;
            if (foundToken == null || foundToken.LeadID != id)
                return RedirectToMainPage();

            ViewBag.token = foundToken.Key;

            leadItem = LeadItem.SelectFromDB(DBLGcon, leadID: id, loadFieldValues: true).FirstOrDefault();
            Review review = new Review(leadItem.ID);
            review.LoadMeasures(DBLGcon);
            review.LoadBusinessOptions(DBLGcon, setDefaultBusinessID: true);
            return View(review);
        }

        [HttpPost]
        public ActionResult Review(long id, string token, Review review)
        {
            LeadReviewCreateToken foundToken = Token.LoadFromDB(DBLGcon, token) as LeadReviewCreateToken;
            if (foundToken == null || foundToken.LeadID != id)
                return RedirectToMainPage();

            ViewBag.token = foundToken.Key;

            ModelState.Clear();

            review.adjustProvidedStarValues();

            if (review.businessOptions == null)
                review.businessOptions = new List<Code.Business.Business>();

            //If otherBusiness
            if (review.otherBusiness == true && string.IsNullOrEmpty(review.otherBusinessName))
                ModelState.AddModelError("otherBusinessName", "Название мастерской обязательно");

            //If completed
            if (review.businessID != null || review.otherBusiness == true)
                if (string.IsNullOrEmpty(review.authorName))
                    ModelState.AddModelError("authorName", "Введите имя");

            //If Validation errors, return the view
            if (ModelState.IsValid == false)
                return View(review);

            review.reviewDateTime = DateTime.UtcNow;

            review.reviewText = SysHelper.ReplaceNewLinesWithParagraph(review.reviewText);
            review.SaveInDB(DBLGcon);
            foundToken.DeleteFromDB(DBLGcon);

            //If review.notCompleted then genereate another review request for the next month
            if (review.notCompleted ?? false == true)
                review.scheduleReviewRequestAfterDays(DBLGcon, 30);

            return View("Review-Saved",review);
        }


        public ActionResult Cancel(string email, string error)
        {
            if (string.IsNullOrEmpty(error) == false)
                ModelState.AddModelError("email", error);
            return View(email??"");
        }

        [HttpPost]
        [ActionName("Cancel")]
        public ActionResult CancelSubmitted(string email)
        {
            string error = "";

            MailMessageLeadGen message = null;
            try
            {
                message = new MailMessageLeadGen(email);
            }
            catch (Exception)
            {
                error = "invalidEmail";
            }
            email = email.ToLower().Trim();


            if (string.IsNullOrEmpty(error) == false)
            {
                return RedirectToAction("Cancel", new { email = email, error = error });
            }

            LeadRemoveByUserToken token = new LeadRemoveByUserToken(email);
            token.CreateInDB(DBLGcon);
            ViewDataDictionary viewDataDictionary = new ViewDataDictionary(null) { { "tokenKey", token.Key } };

            message.Subject = "Подтверждение на удаление заявки";
            message.Body = ViewHelper.RenderViewToString("~/Views/Order/E-mails/_CancelOrders.cshtml", email, viewDataDictionary);

            SmtpClientLeadGen.SendSingleMessage(message);

            return View("CancelSubmitted", email);
        }

    }
}