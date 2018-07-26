using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Abstractions;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.Razor;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Routing;

namespace LeadGen.Code.Helpers
{
    //https://ppolyzos.com/2016/09/09/asp-net-core-render-view-to-string/
    public interface IViewRenderService
    {
        Task<string> RenderToStringAsync(string viewName, object model, ViewDataDictionary additionalViewData = null);
    }

    public class ViewRenderService : IViewRenderService
    {
        private readonly IRazorViewEngine _razorViewEngine;
        private readonly ITempDataProvider _tempDataProvider;
        private readonly IServiceProvider _serviceProvider;
        private readonly IHttpContextAccessor _httpContextAccessor;


        public ViewRenderService(IRazorViewEngine razorViewEngine,
            ITempDataProvider tempDataProvider,
            IServiceProvider serviceProvider,
            IHttpContextAccessor httpContextAccessor)
        {
            _razorViewEngine = razorViewEngine;
            _tempDataProvider = tempDataProvider;
            _serviceProvider = serviceProvider;
            _httpContextAccessor = httpContextAccessor;
        }

        //https://stackoverflow.com/questions/44443659/render-view-to-string-argumentoutofrangeexception?rq=1
        public async Task<string> RenderToStringAsync(string viewName, object model, ViewDataDictionary additionalViewData = null)
        {
            HttpContext httpContext = _httpContextAccessor.HttpContext;
            RouteData routeData = httpContext.GetRouteData();
            ActionDescriptor actionDescriptor = new ActionDescriptor();
            ActionContext actionContext = new ActionContext(httpContext, routeData, actionDescriptor);

            using (StringWriter sw = new StringWriter())
            {
                var viewResult = _razorViewEngine.GetView(viewName, viewName, false);

                if (viewResult.View == null)
                {
                    throw new ArgumentNullException($"{viewName} does not match any available view");
                }

                var viewDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary())
                {
                    Model = model
                };

                if (additionalViewData != null)
                    foreach (var item in additionalViewData)
                        viewDictionary.Add(item.Key, item.Value);

                var viewContext = new ViewContext(
                    actionContext,
                    viewResult.View,
                    viewDictionary,
                    new TempDataDictionary(actionContext.HttpContext, _tempDataProvider),
                    sw,
                    new HtmlHelperOptions()
                );

                await viewResult.View.RenderAsync(viewContext);
                return sw.ToString();
            }
        }


        //public static string RenderPartialToString2(string filePath, object model, ViewDataDictionary additionalViewData = null)
        //{
        //    StringWriter st = new StringWriter();
        //    HttpContextWrapper context = new HttpContextWrapper(HttpContext.Current);
        //    RouteData routeData = new RouteData();
        //    ControllerContext controllerContext = new ControllerContext(new RequestContext(context, routeData), new LeadGenBaseController());

        //    RazorView razor = new RazorView(controllerContext, filePath, null, false, null);

        //    ViewDataDictionary viewDataDictionary = new ViewDataDictionary(model);
        //    if (additionalViewData != null)
        //        foreach (var item in additionalViewData)
        //            viewDataDictionary.Add(item.Key, item.Value);

        //    razor.Render(new ViewContext(controllerContext, razor, viewDataDictionary, new TempDataDictionary(), st), st);
        //    return st.ToString();
        //}

    }
}
