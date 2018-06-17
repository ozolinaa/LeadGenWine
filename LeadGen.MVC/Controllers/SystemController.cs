﻿using LeadGen.Code.Sys;
using LeadGen.Code.Sys.Scheduled;
using LeadGen.MVC.Controllers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace LeadGen.Controllers
{
    public class SystemController : DatabaseController
    {

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            if (requestHasValidAccessToken() == false)
                filterContext.Result = new HttpStatusCodeResult(HttpStatusCode.Unauthorized);
        }

        private bool requestHasValidAccessToken()
        {
            string accessToken = ControllerContext.RequestContext.HttpContext.Request.Params["accessToken"] as string;

            if (string.IsNullOrEmpty(accessToken))
                return false;

            string systemAccessToken = GetSystemAccessToken(DBLGcon);
            if (string.IsNullOrEmpty(systemAccessToken) == false && systemAccessToken == accessToken)
                return true;

            return false;
        }

        private static string GetSystemAccessToken(SqlConnection DBLGcon) {
            string token = string.Empty;
            Option taskAdminTokenOption = Option.SelectFromDB(DBLGcon, "systemAccessToken").FirstOrDefault();
            if (taskAdminTokenOption != null)
                token = taskAdminTokenOption.value;
            return token;
        }

        [HttpPost]
        public ActionResult ProcessTasks(string tasks = "")
        {
            if (string.IsNullOrEmpty(tasks))
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest, "tasks parameter is empty");

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
                    return new HttpStatusCodeResult(HttpStatusCode.BadRequest, e.Message);
                }

            foreach (string taskName in taskNames)
            {
                tm.GetScheduledTaskByName(taskName).Run();
            }
            return new HttpStatusCodeResult(HttpStatusCode.OK);
        }

        [NonAction]
        public static void InitializeScheduledTasks(SqlConnection DBLGcon, string hostUrl, List<Type> types)
        {
            string systemAccessToken = GetSystemAccessToken(DBLGcon);
            string taskListStr = HttpUtility.UrlEncode(string.Join(",", types.Select(x => x.Name)));
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