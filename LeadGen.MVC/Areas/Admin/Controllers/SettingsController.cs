using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LeadGen.Areas.Admin.Controllers
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