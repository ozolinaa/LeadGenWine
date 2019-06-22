using LeadGen.Code.Sys;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace LeadGen.Code.Helpers
{
    public static class ViewHelper
    {
        //https://ppolyzos.com/2016/09/09/asp-net-core-render-view-to-string/
        public static string RenderPartialToString(string filePath, object model, ControllerContext controllerContext)
        {
            throw new NotImplementedException();
            ////isMain  or flase for PartialView

            ////https://joonasw.net/view/aspnet-core-di-deep-dive
            ////https://stackoverflow.com/questions/47459857/mvc-core-2-0-check-path-exists-of-controller-and-view-exist-and-if-not-go-to-ow?rq=1



            //ICompositeViewEngine viewEngine = (ICompositeViewEngine)controllerContext.HttpContext.RequestServices.GetService(typeof(ICompositeViewEngine));
            //ViewEngineResult viewResult = viewEngine.FindView(ControllerContext, viewName, isMain);
            //return (viewResult.View != null);

            //ViewEngineResult result = ViewEngines.Engines.FindPartialView(controllerContext, filePath);

            //controllerContext.Controller.ViewData.Model = model;

            //if (result.View != null)
            //{
            //    StringBuilder sb = new StringBuilder();

            //    using (var sw = new StringWriter(sb))
            //    {
            //        using (var output = new HtmlTextWriter(sw))
            //        {
            //            var viewContext = new ViewContext(controllerContext, result.View, controllerContext.Controller.ViewData, controllerContext.Controller.TempData, output);
            //            result.View.Render(viewContext, output);
            //        }
            //    }

            //    return sb.ToString();
            //}

            //return string.Empty;
        }

        public static string RenderViewToString(string viewPath, object model, ViewDataDictionary additionalViewData = null)
        {
            IViewRenderService viewRenderService = SysHelper.GetService<IViewRenderService>();
            return viewRenderService.RenderToStringAsync(viewPath, model, additionalViewData).Result;
        }

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
