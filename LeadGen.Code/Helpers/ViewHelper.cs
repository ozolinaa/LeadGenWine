using LeadGen.Code.Sys;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Razor;
using System.Web.Routing;
using System.Web.UI;

namespace LeadGen.Code.Helpers
{
    public static class ViewHelper
    {

        public static string RenderPartialToString(string filePath, object model, ControllerContext controllerContext)
        {
            ViewEngineResult result = ViewEngines.Engines.FindPartialView(controllerContext, filePath);

            controllerContext.Controller.ViewData.Model = model;

            if (result.View != null)
            {
                StringBuilder sb = new StringBuilder();

                using (var sw = new StringWriter(sb))
                {
                    using (var output = new HtmlTextWriter(sw))
                    {
                        var viewContext = new ViewContext(controllerContext, result.View, controllerContext.Controller.ViewData, controllerContext.Controller.TempData, output);
                        result.View.Render(viewContext, output);
                    }
                }

                return sb.ToString();
            }

            return string.Empty;
        }

        public static string RenderPartialToString(string filePath, object model, ViewDataDictionary additionalViewData = null)
        {
            StringWriter st = new StringWriter();
            HttpContextWrapper context = new HttpContextWrapper(HttpContext.Current);
            RouteData routeData = new RouteData();
            ControllerContext controllerContext = new ControllerContext(new RequestContext(context, routeData), new LeadGenBaseController());

            RazorView razor = new RazorView(controllerContext, filePath, null, false, null);

            ViewDataDictionary viewDataDictionary = new ViewDataDictionary(model);
            if (additionalViewData != null)
                foreach (var item in additionalViewData)
                    viewDataDictionary.Add(item.Key, item.Value);

            razor.Render(new ViewContext(controllerContext, razor, viewDataDictionary, new TempDataDictionary(), st), st);
            return st.ToString();
        }

        //public static string MapPath(string filePath)
        //{
        //    return HttpContext.Current != null ? HttpContext.Current.Server.MapPath(filePath) : string.Format("{0}{1}", AppDomain.CurrentDomain.BaseDirectory, filePath.Replace("~", string.Empty).TrimStart('/'));
        //}

        public static string GetDigitStringFromNumber(decimal? number, bool alwaysShowFraction = false)
        {
            if (number == null)
                return "";
            return GetDigitStringFromNumber(number.Value, alwaysShowFraction: alwaysShowFraction);
        }

        public static string GetDigitStringFromNumber(decimal number, bool alwaysShowFraction = false)
        {
            int integral = (int)decimal.Truncate(number);
            int fraction = (int)((number - decimal.Truncate(number)) * 100);

            if (alwaysShowFraction || fraction > 0)
                return integral + "." + fraction;
            else
                return integral.ToString();
        }

    }
}
