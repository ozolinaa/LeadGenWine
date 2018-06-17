using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace LeadGen
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                name: "Sitemap",
                url: "sitemap_{siteMapName}.xml",
                defaults: new { controller = "Sitemap", action = "SitemapXml", siteMapName = "Index" },
                namespaces: new[] { "LeadGen.Controllers" }
            );

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "CMS", action = "Index", id = UrlParameter.Optional },
                constraints: new { controller = @"^Login|Token|Order|System" },
                namespaces: new[] { "LeadGen.Controllers" }
            );

            routes.MapRoute(
                name: "LeadPublic",
                url: "zakaz/{id}",
                defaults: new { controller = "Order", action = "Show", id = "id" },
                namespaces: new[] { "LeadGen.Controllers" }
            );

            routes.MapRoute(
                name: "CMS",
                url: "{*urlPath}",
                defaults: new { controller = "CMS", action = "Index" },
                namespaces: new[] { "LeadGen.Controllers" }
            );

        }
    }
}
