using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Linq;
using System.Web;
using Microsoft.AspNetCore.Mvc;

namespace LeadGen.Web.Areas.Business.Controllers
{
    [Area("Business")]
    public class BusinessParentController : LeadGen.Web.Controllers.LoginController
    {
        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);

            login.business = Code.Business.Business.SelectFromDB(DBLGcon, businessID: login.business.ID).FirstOrDefault();
        }
    }
}