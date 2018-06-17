using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LeadGen.Areas.Business.Controllers
{
    public class BusinessParentController : LeadGen.Controllers.LoginController
    {
        protected override void Initialize(System.Web.Routing.RequestContext requestContext)
        {
            base.Initialize(requestContext); // Invoke base class Initialize method (login initialized there)

            login.business = Code.Business.Business.SelectFromDB(DBLGcon, businessID: login.business.ID).FirstOrDefault();
        }
    }
}