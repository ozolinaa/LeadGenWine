using LeadGen.Code;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;


namespace LeadGen.Web.Controllers
{
    public class LoginController : DatabaseController
    {
        public Login login { get; set; }
        public string loginSessionID { get; set; }

        private const string loginSessionCookieName = "LeadGenLoginSessionID";

        private const string loginActionName = "Index";
        private const string logoutActionName = "Logout";

        protected const string loginSuccessRedirectActionName = "afterLogin";

        protected List<string> publicActionNames = new List<string>();
        protected List<string> publicOnlyActionNames = new List<string>();

        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            base.OnActionExecuting(filterContext);

            //Try authorize login by leadGenLoginSessionCookie
            if (HttpContext.Request.Cookies.TryGetValue(loginSessionCookieName, out string loginSessionCookieValue))
            {
                login = Code.Session.GetLoginBySessionID(DBLGcon, loginSessionCookieValue);
                loginSessionID = loginSessionCookieValue;
            }

            string controllerName = filterContext.RouteData.Values["controller"].ToString().ToLower();
            string actionName = filterContext.RouteData.Values["action"].ToString().ToLower();
            string areaName = "";
            if (filterContext.RouteData.Values.ContainsKey("area"))
                areaName = filterContext.RouteData.Values["area"].ToString().ToLower();


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
                if (login.role == Login.UserRoles.business_admin && new string[] { "", "business" }.Contains(areaName) == false)
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
                SetLoginSessionCookie(DBLGcon, HttpContext, login.ID);
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
            string sessionId = Session.GenerateNewSessionID(con, loginID);
            context.Response.Cookies.Append(loginSessionCookieName, sessionId, new CookieOptions() { Expires = DateTime.UtcNow.AddDays(365) });
            return sessionId;
        }

        [ActionName("logout")]
        public virtual ActionResult LogoutRedirect()
        {
            //Delete cookie
            if (ControllerContext.HttpContext.Request.Cookies.TryGetValue(loginSessionCookieName, out string sessionId))
            {
                ControllerContext.HttpContext.Response.Cookies.Delete(loginSessionCookieName);
            }

            //Delete session from the DB
            if (login != null)
                login.Logout(DBLGcon, sessionId);

            return RedirectToAction(loginActionName, "Login", new { area = ""});
        }

        [HttpPost]
        public ActionResult SendPasswordRestoreEmail(Login postedLogin)
        {
            Login foundLogin = null;
            if (!ModelState["email"].Errors.Any())
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
                    if (!ModelState["newPassword.password"].Errors.Any() && !ModelState["newPassword.passwordConfirmation"].Errors.Any())
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
                        SetLoginSessionCookie(DBLGcon, HttpContext, loginID);
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
            if (!ModelState["password"].Errors.Any() && !ModelState["newPassword.password"].Errors.Any() && !ModelState["newPassword.passwordConfirmation"].Errors.Any())
            {
                if (postedLogin.newPassword.password == postedLogin.newPassword.passwordConfirmation)
                    if (Login.Authenticate(DBLGcon, login.email, postedLogin.password) != null)
                        ViewBag.status = Login.SetNewPassword(DBLGcon, login.ID, loginSessionID, postedLogin.newPassword.password);
                    else
                        ModelState.AddModelError("password", "Wrong Password");
                else
                    ModelState.AddModelError("newPassword.passwordConfirmation", "Confirmation password does not match new password");
            }

            return PartialView("EditorTemplates/LoginPassword", postedLogin);
        }

    }
}