using LeadGen.Code.CMS;
using LeadGen.Code.Taxonomy;
using LeadGen.Controllers;
using Microsoft.AspNetCore.Mvc;
using PagedList;
using PagedList.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


namespace LeadGen.Areas.Admin.Controllers
{
    public class TaxonomyController : AdminBaseController
    {
        // GET: Admin/Taxonomy
        public override ActionResult Index()
        {
            return View(taxonomyList);
        }

        //Show Add Form
        public PartialViewResult TaxonomyEdit(int? taxonomyID = null)
        {
            Taxonomy tax = null;

            if (taxonomyID == null)
                tax = new Taxonomy();
            else
                tax = Taxonomy.SelectFromDB(DBLGcon, TaxonomyID: taxonomyID).First();

            return PartialView("popups/_TaxonomyEdit", tax);
        }

        //Insert or Modify the Taxonomy
        [HttpPost]
        public ActionResult TaxonomyEdit(Taxonomy postedTaxonomy)
        {
            if (String.IsNullOrEmpty(postedTaxonomy.code) || String.IsNullOrEmpty(postedTaxonomy.name))
                ModelState.AddModelError(String.Empty, "All fields are required");

            if (ModelState.IsValid)
            {
                postedTaxonomy.code = CMSManager.ClearURL(postedTaxonomy.code);

                string errorMessage = null;

                if (postedTaxonomy.ID == 0)
                {
                    //Creating new Taxonomy
                    long? newTaxonomyID = null;
                    newTaxonomyID = postedTaxonomy.TryInsert(DBLGcon, ref errorMessage);

                    if (newTaxonomyID == null)
                        ModelState.AddModelError(String.Empty, "Make sure that taxonomy URL and Code are UNINQUE");
                }
                else
                {
                    //Updating postedTaxonomy taxonomy
                    if (postedTaxonomy.TryUpdate(DBLGcon, ref errorMessage) == false)
                        ModelState.AddModelError(String.Empty, "Make sure that taxonomy URL and Code are UNINQUE");
                }
            }


            if (ModelState.IsValid == false)
            {
                return PartialView("popups/_TaxonomyEdit", postedTaxonomy);
            }
            else
            {
                return Ok();
            }

        }


        //Show list of terms in Taxonomy
        public ActionResult Terms(int taxonomyID, string query = "", int page = 1)
        {
            Taxonomy tax = Taxonomy.SelectFromDB(DBLGcon, TaxonomyID: taxonomyID).FirstOrDefault();

            //Find Post Types where this taxonomy is used
            List<PostType> taxUsedInPostTypes = new List<PostType>();
            foreach (PostType postType in postTypeList)
                foreach (Taxonomy postTypeTax in postType.taxonomyList.Select(x=>x.taxonomy))
                    if (postTypeTax.ID == tax.ID)
                        taxUsedInPostTypes.Add(postType);

            tax.LoadTerms(DBLGcon);

            List<Term> resultTerms = null;
            if (query != "")
            {
                resultTerms = new List<Term>();
                resultTerms.AddRange(tax.termList.Where(x => x.termURL.ToLower().Contains(query.ToLower())));
                resultTerms.AddRange(tax.termList.Where(x => x.name.ToLower().Contains(query.ToLower())));
                resultTerms.OrderBy(x => x.name);
            }
            else
            {
                resultTerms = tax.termList;
            }

            IPagedList<Term> terms = resultTerms.AsQueryable().ToPagedList(page, 20);

            ViewBag.activeTaxonomyID = tax.ID; //For the layout menu
            ViewBag.taxUsedInPostTypes = taxUsedInPostTypes;
            ViewBag.taxonomy = tax;
            ViewBag.query = query;

            return View(terms);
        }

        //Show Add Form
        public PartialViewResult TermCreate(int taxonomyID)
        {
            Taxonomy tax = Taxonomy.SelectFromDB(DBLGcon, TaxonomyID: taxonomyID).First();
            tax.LoadTerms(DBLGcon);
            ViewBag.taxonomy = tax;

            return PartialView("popups/_TermCreate", new Term());
        }

        //Process Term Insert
        [HttpPost]
        public ActionResult TermCreate(int taxonomyID, Term postedTerm)
        {
            string errorMessage = null;
            long? newTermID = null;
            if (ModelState.IsValid)
            {
                newTermID = postedTerm.TryInsert(DBLGcon, taxonomyID, ref errorMessage);
                if (newTermID == null)
                    switch (errorMessage)
                    {
                        case "FAILED ParentID Taxonomy":
                            ModelState.AddModelError("parentID", "ParentID has wrong taxonomy");
                            break;
                        case "FAILED Name":
                            ModelState.AddModelError("name", "This Term Name already exist in this taxonomy");
                            break;
                        case "FAILED URL":
                            ModelState.AddModelError("termURL", "This Term URL already exist in this taxonomy");
                            break;
                        default:
                            ModelState.AddModelError(String.Empty, "Something is wrong");
                            break;
                    }
            }

            if (newTermID == null)
            {
                Taxonomy tax = Taxonomy.SelectFromDB(DBLGcon, TaxonomyID: taxonomyID).First();
                tax.LoadTerms(DBLGcon);
                ViewBag.taxonomy = tax;
                return PartialView("popups/_TermCreate", postedTerm);
            }
            else
            {
                return Ok();
            }
        }

        //Show Edit Form
        public ActionResult TermEdit(int taxonomyID, int termID)
        {
            Taxonomy tax = Taxonomy.SelectFromDB(DBLGcon, TaxonomyID: taxonomyID).First();
            tax.LoadTerms(DBLGcon);
            ViewBag.taxonomy = tax;
            Term termToUpdate = tax.termList.Where(x => x.ID == termID).First();
            return PartialView("popups/_TermEdit", termToUpdate);
        }

        //Process Term Update
        [HttpPost]
        public ActionResult TermEdit(int taxonomyID, Term postedTerm)
        {
            string errorMessage = null;
            if (ModelState.IsValid)
                if (postedTerm.TryUpdate(DBLGcon, ref errorMessage) == false)
                    switch (errorMessage)
                    {
                        case "FAILED ParentID Taxonomy":
                            ModelState.AddModelError("parentID", "Parent has wrong taxonomy");
                            break;
                        case "FAILED ParentID Offsprings":
                            ModelState.AddModelError("parentID", "Parent was found in Offsprings");
                            break;
                        case "FAILED Name":
                            ModelState.AddModelError("name", "This Term Name already exist in this taxonomy");
                            break;
                        case "FAILED URL":
                            ModelState.AddModelError("termURL", "This Term URL already exist in this taxonomy");
                            break;
                        default:
                            ModelState.AddModelError(String.Empty, "Something is wrong");
                            break;
                    }

            if (ModelState.IsValid == false)
            {
                Taxonomy tax = Taxonomy.SelectFromDB(DBLGcon, TaxonomyID: taxonomyID).FirstOrDefault();
                tax.LoadTerms(DBLGcon);
                ViewBag.taxonomy = tax;
                return PartialView("popups/_TermEdit", postedTerm);
            }
            else
            {
                return Ok();
            }
        }

        //Show Delete Form
        public ActionResult TermDelete(int taxonomyID, int termID)
        {
            Taxonomy tax = Taxonomy.SelectFromDB(DBLGcon, TaxonomyID: taxonomyID).First();
            tax.LoadTerms(DBLGcon);
            ViewBag.taxonomy = tax;
            Term termToDelete = tax.termList.Where(x => x.ID == termID).First();
            return PartialView("popups/_TermDelete", termToDelete);
        }

        //Process Term Delete
        [HttpPost]
        [ActionName("TermDelete")]
        public ActionResult ProcessTermDelete(int taxonomyID, int termID)
        {
            if (Term.TryDelete(DBLGcon, termID) == false)
                ModelState.AddModelError(String.Empty, "Term is used");

            if (ModelState.IsValid == false)
            {
                Taxonomy tax = Taxonomy.SelectFromDB(DBLGcon, TaxonomyID: taxonomyID).First();
                tax.LoadTerms(DBLGcon);
                ViewBag.taxonomy = tax;
                Term termToDelete = tax.termList.Where(x => x.ID == termID).First();
                return PartialView("popups/_TermDelete", termToDelete);
            }
            else
            {
                return Ok();
            }


        }

        public IEnumerable<Term> GetTaxonomyTerms(int taxonomyID, string termSearch)
        {
            Taxonomy tax = Taxonomy.SelectFromDB(DBLGcon, TaxonomyID: taxonomyID).First();
            tax.LoadTerms(DBLGcon);
            IEnumerable<Term> terms = tax.termList.Where(x=> x.name.ToLower().Contains(termSearch.ToLower()));
            return terms;
        }

        [HttpPost]
        public Term CreateTag(int taxonomyID, string tagName, string tagUrl = "")
        {
            Taxonomy tax = Taxonomy.SelectFromDB(DBLGcon, TaxonomyID: taxonomyID).First();
            tax.LoadTerms(DBLGcon);
            Term tag = tax.termList.FirstOrDefault(x => String.Equals(x.name, tagName, StringComparison.OrdinalIgnoreCase));
            if (tag == null)
            {
                tag = new Term() { isChecked = true, name = tagName, termURL = CMSManager.ClearURL(String.IsNullOrEmpty(tagUrl) ? tagName : tagUrl) };
                string errorMessage = "";
                long? newTermID = tag.TryInsert(DBLGcon, taxonomyID, ref errorMessage);
                if (newTermID == null)
                {
                    switch (errorMessage)
                    {
                        case "FAILED URL":
                            return CreateTag(taxonomyID, tag.name, tag.termURL + "_new");
                        default:
                            ModelState.AddModelError(String.Empty, "Something is wrong");
                            break;
                    }
                }
            }
            return tag;
        }

    }
}