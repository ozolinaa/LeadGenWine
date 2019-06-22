using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using LeadGen.Code;
using LeadGen.Code.Helpers;
using LeadGen.Code.Lead;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.ViewFeatures;

namespace LeadGen.Web.Controllers
{
    public class TestController : Controller
    {
        [HttpGet]
        public ContentResult Index()
        {
            string viewPath = "~/Views/Order/E-mails/EmailVerify.cshtml";

            ViewDataDictionary viewDataDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary()) { { "tokenKey", 123 } };
            LeadItem leadItem = new LeadItem();

            string html = ViewHelper.RenderViewToString(viewPath, leadItem, viewDataDictionary);

            return new ContentResult
            {
                ContentType = "text/html",
                StatusCode = (int)HttpStatusCode.OK,
                Content = html
            };
        }
    }
}