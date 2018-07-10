using LeadGen.Code;
using LeadGen.Code.Lead;
using LeadGen.Code.Sys;
using LeadGen.Controllers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


namespace LeadGen.Areas.Admin.Controllers
{
    public class LeadSettingsController : AdminBaseController
    {
        public List<FieldGroup> fieldGroups { get; set; }
        public List<Option> leadSettingOptions { get; set; }


        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);

            // Initialize fieldItems from leadIted
            LeadItem leadItem = new LeadItem();
            leadItem.LoadFieldStructure(DBLGcon, false);
            fieldGroups = leadItem.fieldGroups;


            initializeLeadSettingOptions();
        }

        private void initializeLeadSettingOptions() {
            leadSettingOptions = Option.SelectFromDB(DBLGcon);
            bool settingsOpitonsUpdated = false;
            foreach (Option.LeadSettingKey lsKey in Enum.GetValues(typeof(Option.LeadSettingKey)))
            {
                if (leadSettingOptions.FirstOrDefault(x => x.key == lsKey.ToString()) == null)
                {
                    Option option = new Option() { key = lsKey.ToString() };
                    option.Update(DBLGcon);
                    settingsOpitonsUpdated = true;
                }
            }
            if(settingsOpitonsUpdated)
                leadSettingOptions = Option.SelectFromDB(DBLGcon);

            List<string> leadSettingKeys = new List<string>();
            foreach (Option.LeadSettingKey lsKey in Enum.GetValues(typeof(Option.LeadSettingKey)))
            {
                leadSettingKeys.Add(lsKey.ToString());
            }
            leadSettingOptions = leadSettingOptions.Where(x => leadSettingKeys.Contains(x.key)).ToList();
        }

        // GET: Admin/Lead
        public override ActionResult Index()
        {
            return View(leadSettingOptions);
        }

        public ActionResult Edit(Option.LeadSettingKey id)
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
            return RedirectToAction("Index");
        }


    }
}