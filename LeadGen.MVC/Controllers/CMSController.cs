using LeadGen.Code.CMS;
using LeadGen.Code.Map;
using LeadGen.MVC.Controllers;
using PagedList;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LeadGen.Controllers
{
    public class CMSController : DatabaseController
    {
        public CMSContext cmsContext { get; set; }

        //Cache The Page at the server for 24 hours
        //[OutputCache(Duration = 60*60*24, Location = System.Web.UI.OutputCacheLocation.Server, VaryByParam = "*")]
        public ActionResult Index(string urlPath = "", bool preview = false)
        {
            cmsContext = new CMSContext(DBLGcon, ControllerContext, urlPath.TrimEnd('/'));
            ViewBag.cmsContext = cmsContext;
            switch (cmsContext.pageType)
            {
                case CMSContext.PageType.StartPage:
                    return StartPage();
                case CMSContext.PageType.Post:
                    return SinglePost(preview);
                case CMSContext.PageType.Exclusion:
                    return Exclusion(preview);
                case CMSContext.PageType.TermPost:
                    return TermPostList();
                case CMSContext.PageType.PostType:
                    return TypePostList();
                case CMSContext.PageType.TermPostType:
                    return TermTypePostList();
                default:
                    return HttpNotFound();
            }
        }

        [NonAction]
        public ActionResult StartPage()
        {
            return View("Exclusion/startPage", cmsContext);
        }

        [NonAction]
        public ActionResult SinglePost(bool preview = false)
        {
            Post post = cmsContext.post;
            //Check if post was fount and if post.postStatus.ID is 50 (or preview is true)
            if (post == null || (cmsContext.post.postStatus.ID != 50 && preview != true))
                return HttpNotFound();

            if (ViewExists("Single/" + post.postType.url))
                return View("Single/" + post.postType.url, post);

            if (post.postType.ID == (int)CMSManager.PostTypesBuiltIn.Page && ViewExists("Single/" + post.postURL))
                return View("Single/" + post.postURL, post);

            return View("Single/Default", post);
        }

        [NonAction]
        public ActionResult Exclusion(bool preview = false)
        {
            if (cmsContext.post != null && (cmsContext.post.postStatus.ID == 50 || preview == true))
            {
                if (ViewExists("Exclusion/" + cmsContext.post.postURL))
                    return View("Exclusion/" + cmsContext.post.postURL, cmsContext);
                return View("Single/Default", cmsContext.post);
            }

            else
                return HttpNotFound();
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