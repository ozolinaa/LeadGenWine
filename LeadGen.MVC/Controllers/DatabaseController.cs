using LeadGen.Code.Sys;
using LeadGen.Controllers;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LeadGen.MVC.Controllers
{
    public class DatabaseController : LeadGenBaseController
    {
        protected SqlConnection DBLGcon;
        internal string DBLGconString { get { return getDbConnectionString(); } }

        private static string getDbConnectionString() {
            return ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
        }

        protected override void Initialize(System.Web.Routing.RequestContext requestContext)
        {
            base.Initialize(requestContext); // Invoke base class Initialize method

            DBLGcon = new SqlConnection(DBLGconString);
            DBLGcon.Open();
        }

        protected override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            DBLGcon.Close();
            DBLGcon.Dispose();

            // End of custom OnActionExecuted method
            base.OnActionExecuted(filterContext); // Invoke base class OnActionExecuted method
        }



    }
}