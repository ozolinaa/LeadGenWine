using LeadGen.Code.CMS;
using LeadGen.Code.Taxonomy;
using LeadGen.Controllers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LeadGen.Areas.Admin.Controllers
{
    public class AdminBaseController : LoginController
    {
        public List<PostType> postTypeList;
        public List<Taxonomy> taxonomyList;

        protected override void Initialize(System.Web.Routing.RequestContext requestContext)
        {
            // Invoke base class Initialize method
            base.Initialize(requestContext);

            postTypeList = PostType.SelectFromDB(DBLGcon);
            postTypeList.ForEach(x => x.LoadTaxonomyList(DBLGcon));

            taxonomyList = Taxonomy.SelectFromDB(DBLGcon);

            ViewBag.postTypeList = postTypeList;
            ViewBag.taxonomyList = taxonomyList;
        }
    }
}