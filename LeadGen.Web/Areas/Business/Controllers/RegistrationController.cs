using LeadGen.Code;
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
using LeadGen.Web.Helpers;
using LeadGen.Code.Sys;

namespace LeadGen.Web.Areas.Business.Controllers
{
    [Area("Business")]
    public class RegistrationController : LeadGen.Web.Controllers.LoginController
    {
        public RegistrationController() {
            publicOnlyActionNames.Add("Registration");
            publicOnlyActionNames.Add("Index");
        }
        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);
        }

        public override ActionResult Index()
        {
            Term country = Term.SelectFromDB(DBLGcon, TaxonomyCode: "city", TermURL: "usa").First();

            Login login = new Login
            {
                business = new Code.Business.Business()
                {
                    country = country,
                    locations = new List<BusinessLocation>() {
                        new BusinessLocation() {
                            Location = new Code.Map.Location() {
                                Lat = 34.2898097,
                                Lng = -117.6294237,
                                Zoom = 7,
                                RadiusMeters = 220*1000,
                                StreetAddress = "Southern California",
                                Name = "Southern California" }
                        }
                    }
                }
            };
            return View(login);
        }

        // POST: Business/Register
        // Method name is "Authorize" because need to override method with same signature in the base class
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ActionName("Index")]
        public override ActionResult Authorize(Login postedLogin)
        {
            Login newLogin = null;
            string password = null;
            bool generateTempPassword = false;

            bool AgreeWithSystemTerms = HttpContext.Request.Form["AgreeWithSystemTerms"][0].ToLower() == "true";

            //If Not AgreeWithSystemTerms, add validation error and show the same page with validation error
            if (!AgreeWithSystemTerms)
            {
                ModelState.AddModelError("AgreeWithSystemTerms", "You must agree with system terms and conditions");
            }

            // TODO - this validation looks bad, but works
            if (!ModelState.ContainsKey("AgreeWithSystemTerms") && !ModelState["email"].Errors.Any() && !ModelState["business.webSite"].Errors.Any() && !ModelState["business.name"].Errors.Any())
            {
                if (generateTempPassword) 
                {
                    password = SysHelper.GenerateRandomString();
                }
                newLogin = Login.Create(DBLGcon, Login.UserRoles.business_admin, postedLogin.email, password);
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

            MailMessageLeadGen message = MailMessageBuilder.BuildCompanyRegistrationVerifyMailMessage(newLogin, DBLGcon);

            SmtpClientLeadGen.SendSingleMessage(message);

            return View("confirmEmailRequest", newLogin);
        }
    }
}