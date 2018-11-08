﻿using LeadGen.Code;
using LeadGen.Code.Taxonomy;
using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Linq;
using System.Threading.Tasks;
using System.Web;

using LeadGen.Code.Business;
using Microsoft.AspNetCore.Mvc;

namespace LeadGen.Web.Areas.Business.Controllers
{
    [Area("Business")]
    public class RegistrationController : LeadGen.Web.Controllers.LoginController
    {
        public RegistrationController() {
            publicOnlyActionNames.Add("Registration");
        }
        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);
        }

        public ActionResult Registration()
        {
            Term country = Term.SelectFromDB(DBLGcon, TaxonomyCode: "city", TermURL: "usa").First();

            Login login = new Login
            {
                business = new Code.Business.Business() {
                    country = country,
                    locations = new List<BusinessLocation>() {
                        new BusinessLocation() { lat = 34.2898097, lng = -117.6294237, zoom = 7, radiusInMeters = 220*1000, address = "Southern California", name = "Southern California" }
                    }
                }
            };
            return View(login);
        }

        // POST: Business/Register
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Registration(Login postedLogin)
        {
            Login newLogin = null;
            string tempPassword = null;

            
            //Anton
            if (!ModelState["email"].Errors.Any() && !ModelState["business.webSite"].Errors.Any() && !ModelState["business.name"].Errors.Any())
            {
                tempPassword = SysHelper.GenerateRandomString();
                newLogin = Login.Create(DBLGcon, Login.UserRoles.business_admin, postedLogin.email, tempPassword);
            }
            else
            {
                //Handle input errors
                return View(postedLogin);
            }

            // If Login.Create method returns null, means the email was already used
            if (newLogin == null)
            {
                //Handle E-mail unique error
                ModelState.AddModelError("email", "This E-mail is already exist, please use another E-Mail");
                return View(postedLogin);
            }

            // If executing this code, means everything is ok (All errors already handled)

            newLogin.business = Code.Business.Business.Create(DBLGcon, postedLogin.business.name, postedLogin.business.webSite, postedLogin.business.country.ID);

            foreach (BusinessLocation location in postedLogin.business.locations)
            {
                location.CreateInDB(DBLGcon, newLogin.business.ID);
            }


            newLogin.business.LinkLogin(DBLGcon, newLogin); //Link login to business

            List<long[]> requestedTermIDs = new List<long[]>();
            newLogin.business.UpdateRequestedPermissions(DBLGcon, requestedTermIDs, new List<LeadPermittion>());

            newLogin.business.SendRegistrationConfirmationEmail(DBLGcon, newLogin);

            return View("confirmEmailRequest", newLogin);
        }
    }
}