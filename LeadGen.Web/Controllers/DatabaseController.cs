using LeadGen.Code.Sys;
using LeadGen.Web.Controllers;
using Microsoft.AspNetCore.Mvc.Filters;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace LeadGen.Web.Controllers
{
    public class DatabaseController : LeadGenBaseController
    {
        protected SqlConnection DBLGcon;
        internal string DBLGconString {
            get {
                return Code.Helpers.SysHelper.AppSettings.SQLConnectionString;
            }
        }


        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);

            DBLGcon = new SqlConnection(DBLGconString);
            DBLGcon.Open();
        }


        public override void OnActionExecuted(ActionExecutedContext context)
        {
            if (DBLGcon != null) {
                DBLGcon.Dispose();
            }

            base.OnActionExecuted(context);
        }
    }
}