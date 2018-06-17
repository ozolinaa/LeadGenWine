using System.Web.Mvc;

namespace LeadGen.Code.Sys
{
    public class LeadGenBaseController : Controller
    {
        public enum AjaxResponseType
        {
            success,
            error,
            html
        };

        public string requestedHttpHostUrl { get { return string.Format("{0}://{1}", Request.Url.Scheme, Request.Url.Host); } }

        [NonAction]
        public RedirectToRouteResult RedirectToMainPage()
        {
            return RedirectToAction("Index", "CMS", new { area = "" });
        }

        [NonAction]
        protected bool ViewExists(string name)
        {
            ViewEngineResult result = ViewEngines.Engines.FindView(ControllerContext, name, null);
            return (result.View != null);
        }
    }
}
