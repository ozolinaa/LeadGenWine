using LeadGen.Code.Sys;
using LeadGen.Code.Sys.Scheduled;
using LeadGen.Web.Controllers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc;
using LeadGen.Code.Helpers;

namespace LeadGen.Web.Controllers
{
    public class SystemController : DatabaseController
    {

        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            base.OnActionExecuting(filterContext);
            if (RequestHasValidAccessToken() == false)
            {
                throw new Exception("Forbidden");
            }
        }

        private bool RequestHasValidAccessToken()
        {
            ControllerContext.RouteData.DataTokens.TryGetValue("accessToken", out object accessTokenObj);
            string accessToken = accessTokenObj as string;
            if (string.IsNullOrEmpty(accessToken))
                return false;

            string validAccessToken = SysHelper.AppSettings.SystemAccessToken;
            if (validAccessToken == accessToken)
                return true;

            return false;
        }

        [HttpPost]
        public ActionResult ProcessTasks(string tasks = "")
        {
            if (string.IsNullOrEmpty(tasks))
                return BadRequest("tasks parameter is empty");

            string[] taskNames = tasks.Split(',');

            //Try create tasks to validate taskNames
            foreach (string taskName in taskNames)
                try
                {
                    ScheduledTaskManager.GetScheduledTaskByName(taskName);
                }
                catch (Exception e)
                {
                    return BadRequest(e.Message);
                }

            foreach (string taskName in taskNames)
            {
                ScheduledTaskManager.GetScheduledTaskByName(taskName).Run();
            }
            return Ok();
        }
    }
}