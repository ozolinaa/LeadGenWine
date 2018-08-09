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
            if (requestHasValidAccessToken() == false)
                filterContext.HttpContext.Response.StatusCode = 403;
        }

        private bool requestHasValidAccessToken()
        {
            
            ControllerContext.RouteData.DataTokens.TryGetValue("accessToken", out object accessTokenObj);

            string accessToken = accessTokenObj as string;
            if (string.IsNullOrEmpty(accessToken))
                return false;

            string systemAccessToken = SysHelper.AppSettings.SystemAccessToken;
            if (string.IsNullOrEmpty(systemAccessToken) == false && systemAccessToken == accessToken)
                return true;

            return false;
        }

        [HttpPost]
        public ActionResult ProcessTasks(string tasks = "")
        {
            if (string.IsNullOrEmpty(tasks))
                return BadRequest("tasks parameter is empty");

            ScheduledTaskManager tm = new ScheduledTaskManager(DBLGconString);

            string[] taskNames = tasks.Split(',');

            //Try create tasks to validate taskNames
            foreach (string taskName in taskNames)
                try
                {
                    tm.GetScheduledTaskByName(taskName);
                }
                catch (Exception e)
                {
                    return BadRequest(e.Message);
                }

            foreach (string taskName in taskNames)
            {
                tm.GetScheduledTaskByName(taskName).Run();
            }
            return Ok();
        }

        [NonAction]
        public static void InitializeScheduledTasks(SqlConnection DBLGcon, string hostUrl, List<Type> types)
        {
            string systemAccessToken = SysHelper.AppSettings.SystemAccessToken;
            string taskListStr = System.Web.HttpUtility.UrlEncode(string.Join(",", types.Select(x => x.Name)));
            string requestUrl = string.Format("/system/ProcessTasks?accessToken={0}&tasks={1}", systemAccessToken, taskListStr);

            System.Threading.ThreadPool.QueueUserWorkItem(async o =>
            {
                using (var client = new HttpClient())
                {
                    client.BaseAddress = new Uri(hostUrl);
                    var content = new FormUrlEncodedContent(new[] { new KeyValuePair<string, string>("", "login") });
                    var res = await client.PostAsync(requestUrl, content);
                }
            });
        }

    }
}