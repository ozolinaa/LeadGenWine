using LeadGen.Code;
using LeadGen.MVC.Controllers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LeadGen.Controllers
{
    public class LoginController : DatabaseController
    {
        public Login login { get; set; }
        public string loginSessionID { get; set; }

        private static string loginSessionCookieName = "LeadGenLoginSessionID";

        private static string loginActionName = "Index";
        private static string logoutActionName = "Logout";

        protected string loginSuccessRedirectActionName = "afterLogin";

        protected List<string> publicActionNames;
        protected List<string> publicOnlyActionNames;

        protected override void Initialize(System.Web.Routing.RequestContext requestContext)
        {
            base.Initialize(requestContext); // Invoke base class Initialize method (DBLGcon initialized there)

            publicActionNames = new List<string>();
            publicOnlyActionNames = new List<string>();

            //Try authorize login by leadGenLoginSessionCookie
            HttpCookie leadGenLoginSessionCookie = HttpContext.Request.Cookies[loginSessionCookieName];
            if (leadGenLoginSessionCookie != null && !String.IsNullOrEmpty(leadGenLoginSessionCookie.Value))
            {
                login = Code.Session.GetLoginBySessionID(DBLGcon, leadGenLoginSessionCookie.Value);
                loginSessionID = leadGenLoginSessionCookie.Value;
            }
                           
        }

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            string controllerName = filterContext.RouteData.Values["controller"].ToString().ToLower();
            string actionName = filterContext.RouteData.Values["action"].ToString().ToLower();
            string areaName = "";
            if (filterContext.RouteData.DataTokens.ContainsKey("area"))
                areaName = filterContext.RouteData.DataTokens["area"].ToString().ToLower();


            publicActionNames.AddRange(publicOnlyActionNames);

            if (controllerName == "login")
            {
                publicActionNames.Add(loginActionName);
                publicActionNames.Add(logoutActionName);
                publicActionNames.Add("SendPasswordRestoreEmail");
                publicActionNames.Add("SetNewPassword");

            }

            //Redirect user if needed
            if (login == null && !publicActionNames.Contains(actionName, StringComparer.OrdinalIgnoreCase))
                filterContext.Result = RedirectToAction(logoutActionName, "Login", new { area = "" });
            else if (login != null && publicOnlyActionNames.Contains(actionName, StringComparer.OrdinalIgnoreCase))
                filterContext.Result = RedirectToAction(loginActionName, "Login", new { area = "" });
            else if (login != null && controllerName == "login" && string.Equals(actionName, loginActionName, StringComparison.CurrentCultureIgnoreCase))
            {
                //Redirect authorized user from login page to his area
                if (login.role == Login.UserRoles.system_admin)
                    filterContext.Result = RedirectToAction("index", "Home", new { area = "Admin" });
                else if (login.role == Login.UserRoles.business_admin)
                    filterContext.Result = RedirectToAction("index", "Account", new { area = "Business" });
                else
                    filterContext.Result = RedirectToAction(loginSuccessRedirectActionName);
            }
            else if (login != null)
            {
                if (login.role == Login.UserRoles.business_admin && new string[] { "", "business"}.Contains(areaName) == false)
                    filterContext.Result = RedirectToAction("index", "Account", new { area = "Business" });
            }
                
        }

        public virtual ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [ActionName("Index")]
        public virtual ActionResult Authorize(Login postedLogin)
        {

            if (!String.IsNullOrEmpty(postedLogin.email) && !String.IsNullOrEmpty(postedLogin.password))
                login = Login.Authenticate(DBLGcon, postedLogin.email, postedLogin.password);

            if (login != null && login.emailConfirmationDate != null)
            {
                SetLoginSessionCookie(DBLGcon, System.Web.HttpContext.Current, login.ID);
                return RedirectToAction(loginActionName); //performing redirect to allow OnActionExecuting method to work
            }
            else if (login != null && login.emailConfirmationDate == null)
                ModelState.AddModelError("emailConfirmationDate", "Пожалуйста, подтвердите регистрацию через E-Mail");
            else
                ModelState.AddModelError(string.Empty, "Неправильный логин или пароль");


            return View(postedLogin);
        }

        [NonAction]
        public static string SetLoginSessionCookie(SqlConnection con, HttpContext context, long loginID)
        {
            HttpCookie leadGenLoginSessionCookie = context.Request.Cookies[loginSessionCookieName] ?? new HttpCookie(loginSessionCookieName);
            leadGenLoginSessionCookie.Expires = DateTime.UtcNow.AddDays(365);
            leadGenLoginSessionCookie.Value = LeadGen.Code.Session.GenerateNewSessionID(con, loginID);
            //LeadGenLoginSessionCookie.Domain = "." + Request.Url.Host;
            context.Response.Cookies.Add(leadGenLoginSessionCookie);
            return leadGenLoginSessionCookie.Value;
        }

        [ActionName("logout")]
        public virtual ActionResult LogoutRedirect()
        {

            //Delete cookie
            HttpCookie leadGenLoginSessionCookie = Request.Cookies[loginSessionCookieName] ?? new HttpCookie(loginSessionCookieName);
            leadGenLoginSessionCookie.Expires = DateTime.UtcNow.AddDays(-1);
            Response.Cookies.Add(leadGenLoginSessionCookie);

            //Delete session from the DB
            if (login != null)
                login.Logout(DBLGcon, leadGenLoginSessionCookie.Value);

            return RedirectToAction(loginActionName, "Login", new { area = ""});
        }

        [HttpPost]
        public ActionResult SendPasswordRestoreEmail(Login postedLogin)
        {
            Login foundLogin = null;
            if (ModelState.IsValidField("email"))
                foundLogin = Login.SelectOne(DBLGcon, email: postedLogin.email);

            if (foundLogin != null)
            {
                ViewBag.status = true;
                foundLogin.PasswordRecoverySendEmail(DBLGcon);
            }
            else
                ModelState.AddModelError("email", "Email not found");

            return PartialView("FormForgotPassword", postedLogin);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SetNewPassword(Login postedLogin, string tokenKey)
        {
            long loginID;
            Token.Action tokenAction;
            bool status = false;

            Token token = Token.Find(DBLGcon, tokenKey);
            if (Enum.TryParse(token.action, out tokenAction))
                if (tokenAction == Token.Action.LoginRecoverPassword && Int64.TryParse(token.value, out loginID))
                {
                    if (ModelState.IsValidField("newPassword.password") && ModelState.IsValidField("newPassword.passwordConfirmation"))
                    {
                        if (postedLogin.newPassword.password != postedLogin.newPassword.passwordConfirmation)
                            ModelState.AddModelError("newPassword.passwordConfirmation", "Confirmation password does not match new password");
                        else
                            status = Login.SetNewPassword(DBLGcon, loginID, "", postedLogin.newPassword.password);
                    }

                    if (status == false)
                    {
                        ViewData["tokenKey"] = tokenKey;
                        return PartialView("RecoverPassword", postedLogin);
                    }
                    else
                    {
                        //success
                        SetLoginSessionCookie(DBLGcon, System.Web.HttpContext.Current, loginID);
                        return RedirectToAction(loginActionName, "Login", new { area = "" });
                    }
                }

            return RedirectToAction("index", "Home"); //Error   
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult PasswordUpdate(Login postedLogin)
        {
            ViewBag.status = false;
            if (ModelState.IsValidField("password") && ModelState.IsValidField("newPassword.password") && ModelState.IsValidField("newPassword.passwordConfirmation"))
            {
                if (postedLogin.newPassword.password == postedLogin.newPassword.passwordConfirmation)
                    if (Login.Authenticate(DBLGcon, login.email, postedLogin.password) != null)
                        ViewBag.status = Login.SetNewPassword(DBLGcon, login.ID, loginSessionID, postedLogin.newPassword.password);
                    else
                        ModelState.AddModelError("password", "Wrong Password");
                else
                    ModelState.AddModelError("newPassword.passwordConfirmation", "Confirmation password does not match new password");
            }

            return PartialView("~/Views/Shared/EditorTemplates/LoginPassword.cshtml", postedLogin);
        }

    }
}