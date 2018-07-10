using LeadGen.Controllers;
using LeadGen.Code;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using LeadGen.Code.CMS;
using LeadGen.Code.Taxonomy;
using PagedList;
using System.Net;
using Microsoft.AspNetCore.Mvc;
using PagedList.Core;
using Microsoft.AspNetCore.Http;
using System.IO;

namespace LeadGen.Areas.Admin.Controllers
{
    public class CMSController : AdminBaseController
    {
        // GET: Admin/CMS
        public override ActionResult Index()
        {
            return View(postTypeList);
        }


        [HttpPost]
        public ActionResult PostCreate(int typeID)
        {
            long newPostID = Code.CMS.Post.CreateNew(DBLGcon, login.ID, typeID);
            return RedirectToAction("PostEdit", new { ID = newPostID });
        }

        // Show Edit Form
        public PartialViewResult ShowPostTypeEditForm(int postTypeID = 0)
        {
            PostType postType = postTypeList.FirstOrDefault(x => x.ID == postTypeID);

            if (postType == null)
            {
                SEOFields seo = new SEOFields() { changeFrequency = Code.CMS.Sitemap.SitemapChangeFrequency.Weekly, priority = 0.5m };
                postType = new PostType() { ID = postTypeID, postSEO = seo, SEO = seo };
            }
                
            return PartialView("popups/_PostTypeEditor", postType);
        }

        // Save Posted Post Type
        [HttpPost]
        public ActionResult PostTypeEdit(PostType postedPostType)
        {
            if (ModelState.IsValid)
            {
                bool status = false;
                string errorText = "Something is wrong";
                if (postedPostType.ID > 0)
                    status = postedPostType.Update(DBLGcon);
                else
                    status = postedPostType.Insert(DBLGcon, ref errorText);

                if (status == false)
                    ModelState.AddModelError("", errorText);
            }

            if (ModelState.IsValid == false)
                return PartialView("popups/_PostTypeEditor", postedPostType);
            else
                return Ok();
        }

        // Show list of posts
        public ActionResult PostList(int typeID, int statusID = 50, string query = "", int page = 1)
        {
            IPagedList<Post> posts = Post.SelectFromDB(DBLGcon, typeID: typeID, statusID: statusID, query: query, page: page, pageSize: 5, excludeStartPage: true);

            foreach (Post post in posts)
                post.LoadTaxonomies(DBLGcon);

            PostType postType = postTypeList.First(x => x.ID == typeID);
            postType.LoadStartPost(DBLGcon);

            //Set activePostType for the layout menu
            ViewBag.activePostTypeID = postType.ID;

            ViewBag.postType = postType;
            ViewBag.statusList = Post.Status.SelectFromDB(DBLGcon);
            ViewBag.statusID = statusID;
            ViewBag.query = query;


            return View(posts);
        }


        public IEnumerable<Post> SearchPostsJson(int typeID, int? statusID = null, string query = "", int page = 1)
        {
            IPagedList<Post> posts = Post.SelectFromDB(DBLGcon, typeID: typeID, statusID: statusID, query: query, page: page, pageSize: 20);
            return posts;
        }

        // Display Post for Edit
        public ActionResult PostEdit(int ID)
        {
            Post postItem = Post.SelectFromDB(DBLGcon, postID: ID, loadAttachmentList: true, loadFields: true).First();
            postItem.LoadTaxonomies(DBLGcon, loadTerms: true, termsCheckedOnly: false);

            //Set activePostType
            ViewBag.activePostTypeID = postItem.postType.ID;

            ViewBag.siteURL = requestedHttpHostUrl;
            ViewBag.statusList = Post.Status.SelectFromDB(DBLGcon);
            if (postItem.postParentID != null)
                ViewBag.postParentUrl = Post.SelectFromDB(DBLGcon, postID: postItem.postParentID).First().postURLHierarchical;

            return View(postItem);
        }

        private bool postEditModelUpdateFilter(Microsoft.AspNetCore.Mvc.ModelBinding.ModelMetadata modelMetadata) {
            modelMetadata = modelMetadata;
            return true;
        }

        // Save Updated Post
        [HttpPost]
        public ActionResult PostEdit(Post postedPostItem)
        {
            //Load Original Post
            Post postToUpdate = Post.SelectFromDB(DBLGcon, postID: postedPostItem.ID, loadAttachmentList: true, loadFields: true).FirstOrDefault();
            postToUpdate.LoadTaxonomies(DBLGcon, loadTerms: true, termsCheckedOnly: false);

            //Check if forTermID is not null, means the post is a "term" post
            if (postToUpdate.forTermID != null)
                return TermPostEdit(postedPostItem);

            //Set activePostType
            ViewBag.activePostTypeID = postToUpdate.postType.ID;

            //Need to clear the old Nullable Values because if NULL was recieved it will not be updated
            postToUpdate.thumbnailAttachmentID = null;

            //Update postToUpdate from the httpContext but exclude some properties that should not be changed
            Predicate<string> propertyFilter = propertyName => new string[] { "attachmentList", "forTermID", "taxonomies" }.Contains(propertyName);
            TryUpdateModelAsync(postToUpdate,"", postEditModelUpdateFilter).Wait();

            //Remove taxonomies validation errors as tags urls and other properties are not availeble
            ModelState.Keys.Where(x => x.StartsWith("taxonomies[")).ToList().ForEach(x => ModelState[x].Errors.Clear());

            //Check selected taxonomies
            if (postedPostItem.taxonomies != null)
            {
                long[] selectedTermIds = postedPostItem.taxonomies.Where(x => x.taxonomy.termList != null).SelectMany(x => x.taxonomy.termList).Where(x => x.isChecked).Select(x => x.ID).ToArray();
                postToUpdate.taxonomies.ForEach(x => x.taxonomy.termList.ForEach(y => y.isChecked = selectedTermIds.Contains(y.ID)));
            }

            if (ModelState.IsValid)
            {
                //Try UPDATE post
                string updateErrorMessage = null;
                bool wasUpdated = postToUpdate.Update(DBLGcon, ref updateErrorMessage);
                if (wasUpdated == false)
                    switch (updateErrorMessage) //Add Validation error if wasUpdated == false
                    {
                        case "FAILED PostParentID Type":
                            ModelState.AddModelError("postParentID", "Post Parent is in wrong post type or does not exist");
                            break;
                        case "FAILED PostParentID Offsprings":
                            ModelState.AddModelError("postParentID", "Post Parent was found in current post offsprings");
                            break;
                        case "FAILED URL":
                            ModelState.AddModelError("postURL", "This URL already exit in current post type level");
                            break;
                        default:
                            ModelState.AddModelError(String.Empty, "Something is wrong the post was not updated");
                            break;
                    }
            }

            if (ModelState.IsValid)
            {
                //Clear the cache for this post
                string cacheUrl = Url.Action("Index", "CMS", new { area = "", urlPath = postToUpdate.Url }).TrimEnd('/');

                //ANTON TODO
                //HttpResponse.RemoveOutputCacheItem(cacheUrl);
                //HttpResponse.RemoveOutputCacheItem(cacheUrl + "/");

                //Need to reload post data because DB logic may had changed some fields after the update
                Post postItem = Post.SelectFromDB(DBLGcon, postID: postToUpdate.ID, loadAttachmentList: true, loadFields: true).First();
                postItem.LoadTaxonomies(DBLGcon, loadTerms: true, termsCheckedOnly: false);

                ViewBag.siteURL = requestedHttpHostUrl;
                ViewBag.statusList = Post.Status.SelectFromDB(DBLGcon);
                ViewBag.NofificationStatus = true;

                return PartialView("EditorTemplates/Post", postItem);

            }
            else
            {
                postToUpdate.LoadTaxonomies(DBLGcon,true,false);

                ViewBag.siteURL = requestedHttpHostUrl;
                ViewBag.statusList = Post.Status.SelectFromDB(DBLGcon);
                if (postToUpdate.postParentID != null)
                    ViewBag.postParentUrl = Post.SelectFromDB(DBLGcon, postID: postToUpdate.postParentID).First().postURLHierarchical;
            
                ViewBag.NofificationStatus = false;
                return PartialView("EditorTemplates/Post", postToUpdate);
            }
        }

        // Display Term Post for Edit
        public ActionResult TermPostEdit(int forTypeID, long forTermID)
        {
            Post post = Post.SelectFromDB(DBLGcon, forTypeID: forTypeID, forTermID: forTermID, loadFields: true).First();
            post.LoadTaxonomies(DBLGcon, loadTerms: true, termsCheckedOnly: false);


            //Set activePostType
            ViewBag.activePostTypeID = forTypeID;

            ViewBag.siteURL = requestedHttpHostUrl;
            return View(post);
        }

        // Display Term Type StartPage for Edit
        public ActionResult PostTypeTaxStartPostEdit(int typeID)
        {
            Post post = Post.SelectFromDB(DBLGcon, typeID: typeID, postURL:"", loadFields: true).First();
            post.LoadTaxonomies(DBLGcon, loadTerms: true, termsCheckedOnly: false);

            ViewBag.siteURL = requestedHttpHostUrl;
            return View("TermPostEdit", post);
        }


        // Save Updated Term Post
        [HttpPost]
        public ActionResult TermPostEdit(Post postedPostItem)
        {
            //Load Original Post
            Post postToUpdate = Post.SelectFromDB(DBLGcon, postID: postedPostItem.ID, loadFields: true).First();
            postToUpdate.LoadTaxonomies(DBLGcon, loadTerms: true, termsCheckedOnly: false);

            //Set activePostType
            ViewBag.activePostTypeID = postToUpdate.postType.forPostTypeID;

            //Need to clear the old Nullable Values because if NULL was recieved it will not be updated
            postToUpdate.thumbnailAttachmentID = null;

            //Update postToUpdate from the httpContext but exclude the AttachmentList property
            //ANTON TODO
            throw new NotImplementedException();
            //TryUpdateModel(postToUpdate, null, null, new string[] { "attachmentList", "postParentID", "postURL", "forTermID" });

            if (ModelState.IsValid)
            {
                string updateErrorMessage = null;
                bool wasUpdated = postToUpdate.Update(DBLGcon, ref updateErrorMessage);
                if (wasUpdated == false)
                    ModelState.AddModelError(String.Empty, "Something is wrong");
            }

            if (ModelState.IsValid)
            {
                //Need to reload post data because DB logic may had changed some fields after update
                if(string.IsNullOrEmpty(postToUpdate.postURL))
                    //redirect to the post type start page
                    return RedirectToAction("PostTypeTaxStartPostEdit", new { typeID = postToUpdate.postType.ID });
                else
                    //redirect to the term post edit
                    return RedirectToAction("TermPostEdit", new { forTypeID = postToUpdate.postType.forPostTypeID, forTermID = postToUpdate.forTermID });
            }
            else
            {
                ViewBag.siteURL = requestedHttpHostUrl;
                ViewBag.statusList = Post.Status.SelectFromDB(DBLGcon);

                return View(postToUpdate);
            }
        }

        // Show Post Type Selected Taxonomy
        public PartialViewResult ShowPostTypeTaxonomyEditor(int postTypeID)
        {
            PostType postType = postTypeList.Find(x => x.ID == postTypeID);
            postType.taxonomyList = PostTypeTaxonomy.SelectFromDB(DBLGcon, ForPostTypeID: postTypeID, EnabledOnly: false);
            return PartialView("popups/_PostTypeTaxonomyEditor", postType.taxonomyList);
        }

        // Update Posted Post Type Selected Taxonomy
        [HttpPost]
        public ActionResult PostTypeTaxonomyEdit(List<PostTypeTaxonomy> postTypeTaxonomies)
        {
            for (int i = 0; i < postTypeTaxonomies.Count; i++)
            {
                if (postTypeTaxonomies[i].taxonomy.isChecked)
                {
                    if (postTypeTaxonomies[i].Update(DBLGcon) == false)
                        ModelState.AddModelError(string.Format("postTypeTaxonomies[{0}].postType.url", i), "Can not use this url");
                }
                else
                    postTypeTaxonomies[i].Disable(DBLGcon);
            }



            if (ModelState.IsValid == false)
            {
                return PartialView("popups/_PostTypeTaxonomyEditor", postTypeTaxonomies);
            }
            else
                return Ok();
        }

        // Show list of Tax Terms for Post Type ID
        public ActionResult PostTypeTaxTermList(int postTypeID, int taxonomyID, int page = 1)
        {
            PostTypeTaxonomy postTypeTax = PostTypeTaxonomy.SelectFromDB(DBLGcon, postTypeID, taxonomyID).First();
            postTypeTax.taxonomy.LoadTerms(DBLGcon);

            ViewBag.postTypeTax = postTypeTax;

            return View(postTypeTax.taxonomy.termList.ToPagedList(page, 20));
        }


        // Show Post Type Attachment Taxonomies
        public PartialViewResult ShowPostTypeAttachmentTaxonomyEditor(int postTypeID)
        {
            PostType postType = postTypeList.Find(x => x.ID == postTypeID);
            List<PostTypeAttachmentTaxonomy> ttt = PostTypeAttachmentTaxonomy.SelectFromDB(DBLGcon, postType.ID, enabledOnly: false);


            return PartialView("popups/_PostTypeAttachmentTaxonomyEditor", ttt);
        }

        // Update Posted Post Type Selected Taxonomy
        [HttpPost]
        public ActionResult PostTypeAttachmentTaxonomyEdit(List<PostTypeAttachmentTaxonomy> postTypeAttachmentTaxonomies)
        {
            for (int i = 0; i < postTypeAttachmentTaxonomies.Count; i++)
            {
                if (postTypeAttachmentTaxonomies[i].taxonomy.isChecked)
                    postTypeAttachmentTaxonomies[i].Update(DBLGcon);
                else
                    postTypeAttachmentTaxonomies[i].Disable(DBLGcon);
            }

            return Ok();
        }


        [HttpPost]
        public ActionResult AttachmentsUpload(long? PostID, List<IFormFile> files)
        {
            foreach (IFormFile file in files)
            {
                MemoryStream fileStream = new MemoryStream();
                file.CopyTo(fileStream);
                Attachment attachment = Attachment.ProcessNew(DBLGcon, login.ID, file.FileName, fileStream);
                if (PostID != null)
                    attachment.LinkToPost(DBLGcon, PostID.Value);
            }

            if (PostID != null)
            {
                Post post = Post.SelectFromDB(DBLGcon, postID: PostID, loadAttachmentList: true).FirstOrDefault();
                return PartialView("_PostAttahments", post);
            }
            else
            {
                return Ok();
            }

        }

        [HttpPost]
        public ActionResult AttachmentUnlink(long subjectID, long attachmentID)
        {
            Attachment attachment = new Attachment(DBLGcon, attachmentID);
            if (attachment != null)
            {
                int attachmentUsedInPostCount = attachment.UnlinkFromPost(DBLGcon, subjectID);
                if (attachmentUsedInPostCount == 0)
                    attachment.TryDelete(DBLGcon);

                return Ok();
            }
            else
            {
                return Ok();
            }
        }


        // Show Post Type Attachment Taxonomies
        public PartialViewResult ShowPostAttachmentEditor(int postID, long attachmnetID)
        {
            Post post = Post.SelectFromDB(DBLGcon, postID: postID, loadAttachmentList: true).First();
            Attachment attachment = post.attachmentList.First(x => x.attachmentID == attachmnetID);
            attachment.LoadTaxonomies(DBLGcon, post.postType.ID, loadTerms: true, termsCheckedOnly: false);

            return PartialView("popups/_PostAttachmentEditor", attachment);
        }

        [HttpPost]
        public ActionResult PostAttachmentEdit(Attachment postedAttachment)
        {
            postedAttachment.UpdateInDB(DBLGcon);

            return Ok();
        }


        public ActionResult Cache()
        {
            return View();
        }

        [HttpPost]
        public ActionResult clearCacheUrl(string url)
        {
            if (string.IsNullOrEmpty(url))
                return BadRequest("url is required");

            url = url.Replace(requestedHttpHostUrl, "");
            url = url.TrimEnd('/');

            //Anton TODO
            //HttpResponse.RemoveOutputCacheItem(url);
            //HttpResponse.RemoveOutputCacheItem(url + "/");

            return Ok(string.Format("Cache for URL {0} is cleared", url));
        }


        [HttpPost]
        public ActionResult clearCacheAll()
        {
            //Anton TODO
            //HttpRuntime.UnloadAppDomain();
            return Ok("All Cache is cleared");
        }

    }
}