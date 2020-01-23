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
            if (!Request.Query.ContainsKey("accessToken"))
                return false;

            string accessToken = Request.Query["accessToken"];
            string validAccessToken = SysHelper.AppSettings.SystemAccessToken;
            if (validAccessToken == accessToken)
                return true;

            return false;
        }

        // /system/ProcessTasks?accessToken=XXXXXX&tasks=QueueMailMessagesForBusinessesAboutNewLeadsDaily,SendQueuedMail
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

            string response = "";
            foreach (string taskName in taskNames)
            {
                response += ScheduledTaskManager.GetScheduledTaskByName(taskName).Run() + Environment.NewLine;
            }
            return Ok(response);
        }
    }
}