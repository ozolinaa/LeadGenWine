using LeadGen.Web.Controllers;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;


namespace LeadGen.Web.Areas.Admin.Controllers
{
    public class HomeController : AdminBaseController
    {
        // GET: Admin/Home
        public override ActionResult Index()
        {
            return View();
        }
    }
}