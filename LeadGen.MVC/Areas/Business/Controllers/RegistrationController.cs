using LeadGen.Code;
using LeadGen.Code.Taxonomy;
using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using LeadGen.Code.Business;

namespace LeadGen.Areas.Business.Controllers
{
    public class RegistrationController : LeadGen.Controllers.LoginController
    {
        protected override void Initialize(System.Web.Routing.RequestContext requestContext)
        {
            base.Initialize(requestContext); // Invoke base class Initialize method
            publicOnlyActionNames.Add("Registration");
        }

        public ActionResult Registration()
        {
            Login login = new Login();
            login.business = new Code.Business.Business();                
            return View(login);
        }

        // POST: Business/Register
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Registration(Login postedLogin)
        {
            Login newLogin = null;
            string tempPassword = null;

            if (ModelState.IsValidField("email") && ModelState.IsValidField("business.webSite") && ModelState.IsValidField("business.name"))
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
            newLogin.business.LinkLogin(DBLGcon, newLogin); //Link login to business

            List<long[]> requestedTermIDs = new List<long[]>();
            newLogin.business.UpdateRequestedPermissions(DBLGcon, requestedTermIDs, new List<LeadPermittion>());

            newLogin.business.SendRegistrationConfirmationEmail(DBLGcon, newLogin);

            return View("confirmEmailRequest", newLogin);
        }
    }
}