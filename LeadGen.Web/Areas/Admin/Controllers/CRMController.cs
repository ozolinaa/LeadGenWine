using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LeadGen.Code.Clients;
using LeadGen.Code.Clients.CRM;
using LeadGen.Code.Taxonomy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace LeadGen.Web.Areas.Admin.Controllers
{
    public class CRMController : AdminBaseController
    {
        private string locationDictSelected = null;

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);
            Taxonomy cityTax = Taxonomy.SelectFromDB(DBLGcon,TaxonomyCode: "city").First();
            cityTax.LoadTerms(DBLGcon);
            ViewBag.locationDict = cityTax.termList.ToDictionary(x=>x.termURL, x=>x.nameDashed);
            
            try
            {
                locationDictSelected = context.HttpContext.Request.Form["locationUrl"].ToString();
                ViewBag.locationDictSelected = locationDictSelected;
            }
            catch (Exception)
            {
            }

        }

        [HttpGet]
        public IActionResult CreateOrganization()
        {
            return View();
        }

        [HttpPost]
        public IActionResult CreateOrganization(Organization org, bool parseUrl)
        {
            if (parseUrl)
                return ParseOrganization(org);
            using (ICRMClient client = CRMClient.GetClient())
            {
                Location location = client.GetLocations().ToList().Find(x => x.TermURL == locationDictSelected);
                List<Organization> orgsToImport = new List<Organization>() { org };
                orgsToImport.ForEach(x => x.Locations = new List<Location>() { location });
                CRMImportManager manager = new CRMImportManager(client);
                manager.ImportOrganizations(orgsToImport);
                ViewBag.importedID = org.ID;
            }
            return View(org);
        }

        [NonAction]
        private IActionResult ParseOrganization(Organization org)
        {
            if (!string.IsNullOrEmpty(org.WebsitePublic))
            {
                using (WebOrgParser parser = new WebOrgParser())
                {
                    Organization parsedOrg = parser.ParseOrganization(new Uri(org.WebsitePublic), org.Name);
                    org.Name = parsedOrg.Name;
                    org.WebsiteOther = parsedOrg.WebsiteOther;
                    org.WebsitePublic = parsedOrg.WebsitePublic;
                    org.EmailNotification = parsedOrg.EmailNotification;
                    org.EmailPublic = parsedOrg.EmailPublic;
                    org.PhonePublic = parsedOrg.PhonePublic;
                    org.PhoneNotification = parsedOrg.PhoneNotification;
                }
            }
            ModelState.Clear();
            return View("CreateOrganization", org);
        }
    }
}