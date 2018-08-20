using LeadGen.Code.Sys;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;


namespace LeadGen.Web.Areas.Admin.Controllers
{
    public class AdvancedController : AdminBaseController
    {
        public AdvancedController()
        {
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