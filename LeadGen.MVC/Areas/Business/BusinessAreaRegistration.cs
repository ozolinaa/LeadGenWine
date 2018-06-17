using System.Web.Mvc;

namespace LeadGen.Areas.Business
{
    public class BusinessAreaRegistration : AreaRegistration 
    {
        public override string AreaName 
        {
            get 
            {
                return "Business";
            }
        }

        public override void RegisterArea(AreaRegistrationContext context) 
        {
            context.MapRoute(
                "Business_registration",
                "Business/Registration/{country}",
                new { controller = "Registration", action = "Registration", country = UrlParameter.Optional },
                new[] { "LeadGen.Areas.Business.Controllers" }
            );

            context.MapRoute(
                "Business_default",
                "Business/{controller}/{action}/{id}",
                new { controller = "Home", action = "Index", id = UrlParameter.Optional },
                new[] { "LeadGen.Areas.Business.Controllers" }
            );
        }
    }
}