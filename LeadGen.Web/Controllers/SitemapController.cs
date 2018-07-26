using LeadGen.Code;
using LeadGen.Code.Lead;
using LeadGen.Web.Controllers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using LeadGen.Code.CMS;
using LeadGen.Code.CMS.Sitemap;
using System.Xml.Linq;
using System.Xml;

using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using X.PagedList;

namespace LeadGen.Web.Controllers
{
    public class SitemapController : DatabaseController
    {
        private int pageSize = 1000;

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);
        }

        public ActionResult SitemapXml(string siteMapName)
        {
            siteMapName = siteMapName.ToLower();
            if (siteMapName == "index")
                return Index();

            string typeCodeString = "";
            int page = 1;

            string[] nameParts = siteMapName.Split('_');
            if (nameParts.Length == 1)
                typeCodeString = nameParts[0];
            else
            {
                typeCodeString = nameParts[0];
                Int32.TryParse(nameParts[1], out page);
                if (page < 1) page = 1;
            }

            if(typeCodeString == "zakaz")
                return LeadItemsXML(page);

            PostType postType = PostType.SelectFromDB(DBLGcon, TypeCode: typeCodeString).FirstOrDefault();
            if (postType == null || postType.isBrowsable == false)
                return NotFound();


            return PostTypePostsXML(postType, page);
        }

        private XmlActionResult Index()
        {
            List<SitemapItem> siteMapItems = CMSManager.SelecItemsForSiteMapIndexPage(DBLGcon, requestedHttpHostUrl + "/sitemap_{0}_{1}.xml", pageSize);
            siteMapItems.AddRange(LeadItem.SelectItemsForSiteMapIndexPage(DBLGcon, requestedHttpHostUrl + "/sitemap_zakaz_{0}.xml", pageSize));

            SitemapGenerator sg = new SitemapGenerator();
            XDocument xml = sg.GenerateSiteMap(siteMapItems);
            return new XmlActionResult(xml);
        }

        private XmlActionResult PostTypePostsXML(PostType postType, int page)
        {
            SitemapGenerator sg = new SitemapGenerator();

            IPagedList<Post> postItems = Post.SelectFromDB(DBLGcon, statusID: 50, typeID: postType.ID, page:page, pageSize:pageSize );

            foreach (Post post in postItems)
                post.httpHost = requestedHttpHostUrl;

            return new XmlActionResult(sg.GenerateSiteMap(postItems));
        }

        private XmlActionResult LeadItemsXML(int page)
        {
            IPagedList<LeadItem> leadItems = LeadItem.SelectFromDB(DBLGcon, status: AdminDetails.Status.Published, page: page, pageSize: pageSize);

            List<SitemapItem> sitemapItems = new List<SitemapItem>();
            foreach (LeadItem leadItem in leadItems)
            {
                string url = Url.RouteUrl("LeadPublic", new { area = "", id = leadItem.ID }, Request.Scheme);
                DateTime lastModified = (DateTime)leadItem.adminDetails.publishedDateTime;
                SitemapChangeFrequency changeFrequency = SitemapChangeFrequency.Weekly;
                double priority = 0.5;

                sitemapItems.Add(new SitemapItem(url, lastModified, changeFrequency, priority));
            }

            SitemapGenerator sg = new SitemapGenerator();
            return new XmlActionResult(sg.GenerateSiteMap(sitemapItems));
        }

        private sealed class XmlActionResult : ActionResult
        {
            private readonly XDocument _document;

            public Formatting Formatting { get; set; }
            public string MimeType { get; set; }

            public XmlActionResult(XDocument document)
            {
                if (document == null)
                    throw new ArgumentNullException("document");

                _document = document;

                // Default values
                MimeType = "text/xml";
                Formatting = Formatting.None;
            }

            
            public override void ExecuteResult(ActionContext context)
            {
                throw new NotImplementedException();
                //context.HttpContext.Response.Clear();
                //context.HttpContext.Response.ContentType = MimeType;
                //using (var writer = new XmlTextWriter(context.HttpContext.Response.OutputStream, System.Text.Encoding.UTF8) { Formatting = Formatting })
                //    _document.WriteTo(writer);
            }
        }
    }
}