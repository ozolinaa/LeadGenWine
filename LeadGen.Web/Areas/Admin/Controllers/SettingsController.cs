using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


namespace LeadGen.Web.Areas.Admin.Controllers
{
    public class SettingsController : AdminBaseController
    {
        // GET: Admin/Settings
        public override ActionResult Index()
        {
            return View(login);
        }

    }
}