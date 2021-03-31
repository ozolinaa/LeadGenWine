using LeadGen.Code;
using LeadGen.Code.Tokens;
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

        private const string loginActionName = "index";
        private const string logoutActionName = "logout";

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
                publicActionNames.Add("sendpasswordrestoreemail");
                publicActionNames.Add("setnewpassword");
            }

            IActionResult redirectToLogin = RedirectToAction(loginActionName, "Login", new { area = "" });
            IActionResult redirectToAdminHome = RedirectToAction("index", "Home", new { area = "Admin" });
            IActionResult redirectToBusinessHome = RedirectToAction("index", "Leads", new { area = "Business" });

            //Redirect user if needed
            if (login == null)
            {
                if (!publicActionNames.Contains(actionName))
                {
                    // Redirect unauthorized to login
                    filterContext.Result = redirectToLogin;
                }
            }
            else
            {
                if (areaName == "admin" && login.business != null)
                {
                    //Redirect business away from admin to business home
                    filterContext.Result = redirectToBusinessHome;
                }
                else if (string.IsNullOrEmpty(areaName) && controllerName == "login" && string.Equals(actionName, loginActionName))
                {
                    //Redirect authorized user from login page to his area
                    filterContext.Result = login.business == null ? redirectToAdminHome : redirectToBusinessHome;
                }
                else if(publicOnlyActionNames.Contains(actionName))
                {
                    //Redirect authorized user to login page from registration page
                    filterContext.Result = redirectToLogin;
                }
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
            bool status = false;
            Token token = Token.LoadFromDB(DBLGcon, tokenKey);
            long? loginID = null;
            if (token != null)
            {
                if (token is NewLoginEmailVerificationToken)
                {
                    loginID = ((NewLoginEmailVerificationToken)token).LoginID;
                }
                else if (token is LoginRecoverPasswordToken)
                {
                    loginID = ((LoginRecoverPasswordToken)token).LoginID;
                }
            }

            if (loginID == null)
                return RedirectToAction("index", "Home"); //Error   

            if (!ModelState["newPassword.password"].Errors.Any() && !ModelState["newPassword.passwordConfirmation"].Errors.Any())
            {
                if (postedLogin.newPassword.password != postedLogin.newPassword.passwordConfirmation)
                    ModelState.AddModelError("newPassword.passwordConfirmation", "Confirmation password does not match new password");
                else
                    status = Login.SetNewPassword(DBLGcon, loginID.Value, "", postedLogin.newPassword);
            }

            if (status == false)
            {
                ViewData["token"] = token;
                return View("SetPassword", postedLogin);
            }

            //success
            token.DeleteFromDB(DBLGcon);
            SetLoginSessionCookie(DBLGcon, HttpContext, loginID.Value);
            return RedirectToAction(loginActionName, "Login", new { area = "" });
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
                        ViewBag.status = Login.SetNewPassword(DBLGcon, login.ID, loginSessionID, postedLogin.newPassword);
                    else
                        ModelState.AddModelError("password", "Wrong Password");
                else
                    ModelState.AddModelError("newPassword.passwordConfirmation", "Confirmation password does not match new password");
            }

            return PartialView("EditorTemplates/LoginPassword", postedLogin);
        }

    }
}