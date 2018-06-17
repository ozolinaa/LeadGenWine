using LeadGen.Code;
using LeadGen.Code.Lead;
using LeadGen.Controllers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LeadGen.Areas.Admin.Controllers
{
    public class LeadStructureController : AdminBaseController
    {
        public List<FieldGroup> fieldGroups { get; set; }

        protected override void Initialize(System.Web.Routing.RequestContext requestContext)
        {
            // Invoke base class Initialize method
            base.Initialize(requestContext);

            // Initialize fieldItems from leadIted
            LeadItem leadItem = new LeadItem();
            leadItem.LoadFieldStructure(DBLGcon, false);
            fieldGroups = leadItem.fieldGroups;
        }

        // GET: Admin/Lead
        public override ActionResult Index()
        {
            return View(fieldGroups);
        }

        //Show Add Form
        public PartialViewResult GroupCreate()
        {
            return PartialView("popups/_GroupEditor", new FieldGroup() {ID = 0});
        }

        //Show Add Form
        public PartialViewResult FieldCreate(int groupID)
        {
            return PartialView("popups/_FieldEditor", new FieldItem() { isActive = true, groupID = groupID });
        }
        //Show Edit Form
        public PartialViewResult FieldEdit(int id)
        {
            List<FieldItem> fieldList = new List<FieldItem>();
            fieldGroups.ForEach(x=> fieldList.AddRange(x.fields));
            return PartialView("popups/_FieldEditor", fieldList.FirstOrDefault(x=>x.ID == id));
        }

        

        //Process FieldItem Create
        [HttpPost]
        public ActionResult FieldEdit(FieldItem fieldItem)
        {
            FieldType[] taxonomyFields = new FieldType[] { FieldType.Dropdown, FieldType.Checkbox, FieldType.Radio };
            FieldType[] placeholderFields = new FieldType[] { FieldType.Textbox, FieldType.Number, FieldType.Dropdown };

            if (fieldItem.fieldType != FieldType.Textbox && !String.IsNullOrEmpty(fieldItem.regularExpression))
                ModelState.AddModelError("regularExpression", "regularExpression must be empty");
            if (!placeholderFields.Contains(fieldItem.fieldType) && !String.IsNullOrEmpty(fieldItem.placeholder))
                ModelState.AddModelError("placeholder", "placeholder must be empty");
            if (fieldItem.fieldType != FieldType.Number && fieldItem.minValue != null)
                ModelState.AddModelError("minValue", "minValue must be empty");
            if (fieldItem.fieldType != FieldType.Number && fieldItem.maxValue != null)
                ModelState.AddModelError("maxValue", "maxValue must be empty");
            if (taxonomyFields.Contains(fieldItem.fieldType) && fieldItem.taxonomyID == null)
                ModelState.AddModelError("taxonomyID", "taxonomyID is required for Dropdown, Checkbox, Radio");
            if (!taxonomyFields.Contains(fieldItem.fieldType) && fieldItem.taxonomyID != null)
                ModelState.AddModelError("taxonomyID", "taxonomyID must be empty for Dropdown, Checkbox, Radio");
            if (!taxonomyFields.Contains(fieldItem.fieldType) && fieldItem.termParentID != null)
                ModelState.AddModelError("termParentID", "termParentID must be empty for Dropdown, Checkbox, Radio");
            //if (fieldGroups != null && fieldGroups.Find(x => (fieldItem.ID == null || x.ID != fieldItem.ID) && x.fields.Find(y => y.name == fieldItem.name) != null) != null)
            //    ModelState.AddModelError("name", fieldItem.name + " already exist in lead field structure");


            if (ModelState.IsValid)
            {
                string errorMessage = "";
                if (fieldItem.ID == null)
                    fieldItem.UpdateInDB(DBLGcon, ref errorMessage);
                //else
                //    fieldItem.TryInsert(DBLGcon, ref errorMessage);

                if (!String.IsNullOrEmpty(errorMessage))
                    ModelState.AddModelError(null, errorMessage);
            }

            if (ModelState.IsValid == false)
                return PartialView("popups/_FieldEditor", fieldItem);
            else
                return new JsonResult()
                {
                    JsonRequestBehavior = JsonRequestBehavior.AllowGet,
                    Data = new { status = "success" }
                };
        }


        //Process FieldItem Create
        [HttpPost]
        public ActionResult GroupEdit(FieldGroup groupItem)
        {
            //if (fieldGroups != null && fieldGroups.Find(x => (fieldItem.ID == null || x.ID != fieldItem.ID) && x.fields.Find(y => y.name == fieldItem.name) != null) != null)
            //    ModelState.AddModelError("name", fieldItem.name + " already exist in lead field structure");

            if (ModelState.IsValid)
            {
                string errorMessage = "";
                if (groupItem.UpdateInDB(DBLGcon) == false)
                    errorMessage = "Something is Wrong";

                if (!String.IsNullOrEmpty(errorMessage))
                    ModelState.AddModelError("", errorMessage);
            }

            if (ModelState.IsValid == false)
                return PartialView("popups/_GroupEditor", groupItem);
            else
                return new JsonResult()
                {
                    JsonRequestBehavior = JsonRequestBehavior.AllowGet,
                    Data = new { status = "success" }
                };
        }
        
    }
}