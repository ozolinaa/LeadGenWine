using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LeadGen.Code;
using LeadGen.Code.Helpers;
using LeadGen.Code.Settings;
using LeadGen.Web.Helpers;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Primitives;

namespace LeadGen.Web
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddMemoryCache();

            services.AddMvc();

            //https://joonasw.net/view/aspnet-core-di-deep-dive 
            CoreSettings coreSettings = Configuration.GetSection("LeadGenCoreSettings").Get<CoreSettings>();
            AppSettings appSettings = new AppSettings(coreSettings);
            services.AddSingleton<IAppSettings>(appSettings);

            //https://stackoverflow.com/questions/41517359/pagedlist-core-mvc-pagedlistpager-html-extension-in-net-core-is-not-there
            services.AddSingleton<IActionContextAccessor, ActionContextAccessor>();

            //https://ppolyzos.com/2016/09/09/asp-net-core-render-view-to-string/
            services.AddScoped<IViewRenderService, ViewRenderService>();

            //https://stackoverflow.com/questions/38571032/how-to-get-httpcontext-current-in-asp-net-core
            services.TryAddSingleton<IHttpContextAccessor, HttpContextAccessor>();

            SysHelper.InitServiceProvider(services.BuildServiceProvider());


        }



        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseBrowserLink();
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Home/Error");
            }

            app.UseStaticFiles();

            //Rewrite url path and scheme passed from load balancer 
            app.Use((context, next) =>
            {
                if (context.Request.Headers.TryGetValue("X-Forwarded-PathBase", out StringValues pathBase))
                {
                    context.Request.PathBase = new PathString(pathBase);
                }

                if (context.Request.Headers.TryGetValue("X-Forwarded-Proto", out StringValues proto))
                {
                    if (!string.IsNullOrEmpty(proto))
                    {
                        //context.Request.Protocol = proto;
                        context.Request.Scheme = proto;
                    }
                }
                return next();
            });

            app.UseMvc(routes =>
            {
                //routes.MapRoute(
                //    name: "default",
                //    template: "{controller=Home}/{action=Index}/{id?}");

                routes.MapRoute(
                    name: "Default",
                    template: "{controller=CMS}/{action=Index}/{id?}",
                    defaults:null,
                    constraints: new { controller = @"^Login|Token|Order|System|Test" }
                );

                //https://docs.microsoft.com/en-us/aspnet/core/mvc/controllers/areas?view=aspnetcore-2.1
                routes.MapRoute(
                    name: "areaRoute",
                    template: "{area:exists}/{controller=Home}/{action=Index}/{id?}");

                routes.MapRoute(
                    name: "LeadPublic",
                    template: "order/{id}",
                    defaults: new { controller = "Order", action = "Show", id = "id" }
                );

                routes.MapRoute(
                    name: "Sitemap",
                    template: "sitemap_{siteMapName}.xml",
                    defaults: new { controller = "Sitemap", action = "SitemapXml", siteMapName= "siteMapName" }
                );

                routes.MapRoute(
                    name: "CMS",
                    template: "{*urlPath}",
                    defaults: new { controller = "CMS", action = "Index" }
                );
            });




            
        }
    }
}
