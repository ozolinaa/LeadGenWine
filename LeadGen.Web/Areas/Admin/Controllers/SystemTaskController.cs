using LeadGen.Code;
using LeadGen.Code.Helpers;
using LeadGen.Code.Lead;
using LeadGen.Code.Sys;
using LeadGen.Code.Sys.Scheduled;
using LeadGen.Web.Controllers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using X.PagedList;

namespace LeadGen.Web.Areas.Admin.Controllers
{
    public class SystemTaskController : AdminBaseController
    {
        // GET: Admin/SystemActions
        public override ActionResult Index()
        {
            int page = 1;
            if (Request.Query.ContainsKey("page"))
            {
                Int32.TryParse(Request.Query["page"], out int parsedPage);
                page = parsedPage > 0 ? parsedPage : 1;
            }

            IPagedList<DataRow> taskLog = ScheduledTaskManager.SystemScheduledTaskLogSelect(DBLGcon, page, 25);
            return View(taskLog);
        }
    }
}