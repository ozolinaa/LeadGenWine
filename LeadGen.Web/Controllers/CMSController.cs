using LeadGen.Code.CMS;
using LeadGen.Code.Map;
using LeadGen.Code.Sys;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using static LeadGen.Code.CMS.CMSManager;

namespace LeadGen.Web.Controllers
{
    public class CMSController : DatabaseController
    {
        public CMSContext cmsContext { get; set; }

        //https://docs.microsoft.com/en-us/aspnet/core/performance/caching/memory?view=aspnetcore-2.1
        private CacheProvider _cache;
        public CMSController(IMemoryCache memoryCache)
        {
            _cache = new CacheProvider(memoryCache);
        }


        //Cache The Page at the server for 24 hours
        public IActionResult Index(string urlPath = "", bool preview = false)
        {
            if (urlPath == null)
                urlPath = "";
            else
                urlPath = urlPath.Trim('/');

            IActionResult result = null;
            if (false) {
                if (!preview && _cache.TryGetValue(urlPath, out result))
                    return result;
            }

            cmsContext = new CMSContext(DBLGcon, ControllerContext, urlPath, !preview);
            ViewBag.cmsContext = cmsContext;
            switch (cmsContext.pageType)
            {
                case CMSContext.PageType.StartPage:
                    result = StartPage();
                    break;
                case CMSContext.PageType.Post:
                    result = SinglePost();
                    break;
                case CMSContext.PageType.Exclusion:
                    result = Exclusion();
                    break;
                case CMSContext.PageType.TermPost:
                    result = TermPostList();
                    break;
                case CMSContext.PageType.PostType:
                    result = TypePostList();
                    break;
                case CMSContext.PageType.TermPostType:
                    result = TermTypePostList();
                    break;
                default:
                    result = NotFound();
                    break;
            }

            // Save data in cache (Keep in cache for this time, reset time if accessed)
            if(!preview)
                _cache.Set(urlPath, result);

            return result;
        }

        [NonAction]
        public ActionResult StartPage()
        {
            if(cmsContext.post.postType.ID == (int)PostTypesBuiltIn.Page)
                return View("Exclusion/pageStartPage", cmsContext);
            return View("Exclusion/postTypeStartPage", cmsContext);
        }

        [NonAction]
        public ActionResult SinglePost()
        {
            Post post = cmsContext.post;

            if (ViewExists("Single/" + post.postType.url))
                return View("Single/" + post.postType.url, post);

            if (post.postType.ID == (int)CMSManager.PostTypesBuiltIn.Page && ViewExists("Single/" + post.postURL))
                return View("Single/" + post.postURL, post);

            return View("Single/Default", post);
        }

        [NonAction]
        public ActionResult Exclusion()
        {
            if (ViewExists("Exclusion/" + cmsContext.post.postURL))
                return View("Exclusion/" + cmsContext.post.postURL, cmsContext);
            return View("Single/Default", cmsContext.post);
        }

        [NonAction]
        public ActionResult TermPostList()
        {
            if (ViewExists("TermPostList/" + cmsContext.post.postType.url))
                return View("TermPostList/" + cmsContext.post.postType.url, cmsContext.postList);
            return View("TermPostList/Default", cmsContext.postList);
        }

        [NonAction]
        public ActionResult TypePostList()
        {
            if (ViewExists("TypePostList/" + cmsContext.post.postType.url))
                return View("TypePostList/" + cmsContext.post.postType.url, cmsContext.postList);
            return View("TypePostList/Default", cmsContext.postList);
        }

        [NonAction]
        public ActionResult TermTypePostList()
        {
            if (ViewExists("TermTypePostList/" + cmsContext.post.postType.url))
                return View("TermTypePostList/" + cmsContext.post.postType.url, cmsContext.postList);
            return View("TermTypePostList/Default", cmsContext.postList);
        }

    }
}