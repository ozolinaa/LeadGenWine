using LeadGen.Code;
using LeadGen.Code.Helpers;
using LeadGen.Code.Lead;
using LeadGen.Code.Sys;
using LeadGen.Web.Controllers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


namespace LeadGen.Web.Areas.Admin.Controllers
{
    public class SystemSettingsController : AdminBaseController
    {
        public List<FieldGroup> fieldGroups { get; set; }
        public IEnumerable<Option> leadSettingOptions { get; set; }


        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);

            // Initialize fieldItems from leadIted
            LeadItem leadItem = new LeadItem();
            leadItem.LoadFieldStructure(DBLGcon, false);
            fieldGroups = leadItem.fieldGroups;
            leadSettingOptions = Option.SelectFromDB(DBLGcon).Values;
        }

        // GET: Admin/Lead
        public override ActionResult Index()
        {
            return View(leadSettingOptions);
        }

        public ActionResult Edit(Option.SettingKey id)
        {
            Option option = leadSettingOptions.First(x => x.key == id.ToString());
            return View(option);
        }

        [HttpPost]
        public ActionResult Edit(Option option)
        {
            if (option == null && leadSettingOptions.Select(x => x.key).Contains(option.key) == false)
                return RedirectToAction("Index");

            option.Update(DBLGcon);
            SysHelper.AppSettings.ReloadAppSettingsFromDB(DBLGcon);

            return RedirectToAction("Index");
        }


    }
}