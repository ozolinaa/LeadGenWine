﻿using LeadGen.Code.Sys;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LeadGen.Areas.Admin.Controllers
{
    public class AdvancedController : AdminBaseController
    {
        public string clearCache()
        {
            HttpRuntime.UnloadAppDomain();
            return "Cache Cleared";
        }

        public ActionResult test()
        {

            //List<QueueMailMessage> reviewRequestMessages = Code.Lead.Notification.NotificationManager.QueueMailMessagesForLeadsAboutReviewRequest(ControllerContext, DBLGcon);
            //List<QueueMailMessage> newLeadsMessages = Code.Business.Notification.NotificationManager.QueueMailMessagesForBusinessesAboutNewLeads(ControllerContext, DBLGcon);

            //QueueMailMessage.SendQueuedMessages(DBLGcon);

            return View();
        }


    }
}