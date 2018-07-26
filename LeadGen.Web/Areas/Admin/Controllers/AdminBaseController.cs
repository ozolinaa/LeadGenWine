using LeadGen.Code.CMS;
using LeadGen.Code.Taxonomy;
using LeadGen.Web.Controllers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


namespace LeadGen.Web.Areas.Admin.Controllers
{
    [Area("Admin")]
    public class AdminBaseController : LoginController
    {
        public List<PostType> postTypeList;
        public List<Taxonomy> taxonomyList;

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);

            postTypeList = PostType.SelectFromDB(DBLGcon);
            postTypeList.ForEach(x => x.LoadTaxonomyList(DBLGcon));

            taxonomyList = Taxonomy.SelectFromDB(DBLGcon);

            ViewBag.postTypeList = postTypeList;
            ViewBag.taxonomyList = taxonomyList;
        }
    }
}