using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.AspNetCore.Routing;
using System;
using System.IO;

namespace LeadGen.Code.Sys
{
    public class LeadGenBaseController : Controller
    {
        public LeadGenBaseController()
        {
        }

        public enum AjaxResponseType
        {
            success,
            error,
            html
        };


        public string requestedHttpHostUrl { get { return string.Format("{0}://{1}", Request.Scheme, Request.Host); } }

        [NonAction]
        public RedirectToActionResult RedirectToMainPage()
        {
            return RedirectToAction("Index", "CMS", new { area = "" });
        }

        [NonAction]
        protected bool ViewExists(string viewName, bool isMain = true)
        {
            //isMain  or flase for PartialView

            //https://joonasw.net/view/aspnet-core-di-deep-dive
            //https://stackoverflow.com/questions/47459857/mvc-core-2-0-check-path-exists-of-controller-and-view-exist-and-if-not-go-to-ow?rq=1

            ICompositeViewEngine viewEngine = (ICompositeViewEngine)ControllerContext.HttpContext.RequestServices.GetService(typeof(ICompositeViewEngine));
            ViewEngineResult viewResult = viewEngine.FindView(ControllerContext, viewName, isMain);
            return (viewResult.View != null);
        }

    }
}
