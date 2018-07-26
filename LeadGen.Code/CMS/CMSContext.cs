﻿using Microsoft.AspNetCore.Mvc;
using X.PagedList;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using static LeadGen.Code.CMS.CMSManager;

namespace LeadGen.Code.CMS
{
    public class CMSContext
    {
        public int pageNumber = 1;

        public enum PageType
        {
            NotFond,
            StartPage,
            Post,
            TermPost,
            PostType,
            TermPostType,
            Exclusion
        }

        private string[] urlPathSegments { get; set; }

        public string urlPath { get; set; }
        public PageType pageType { get; set; }
        public PostType postType { get; set; }
        public PostTypeTaxonomy postTypeTaxonomy { get; set; }
        public Post post { get; set; }
        public List<Post> postParents { get; set; }
        public IPagedList<Post> postList { get; set; }
        public Dictionary<long, Business.Business> postBusinesses { get; set; }

        private long[] countryIds = new long[] { 1, 2, 3 };

        public bool isRegionCityAllowedInLeads { get; set; }
        public Taxonomy.Term country { get; set; }
        public Taxonomy.Term regionCity { get; set; }
        public Taxonomy.Term smallCity { get; set; }
        public List<Taxonomy.Term> cities { get; set; }


        public IEnumerable<Post> widgets;
        public IEnumerable<Post> widgetsLayoutSidebarRight
        {
            get {
                return widgets.Where(x => x.taxonomies.Find(y => y.taxonomy.code == "layout_location").taxonomy.termList.Where(z => z.termURL == "right-sidebar").Any());
            }
        }


        public Taxonomy.Term term { get; set; }

        private ControllerContext controllerContext = null;

        private static string[] exclusionUrls = null;

        public CMSContext(SqlConnection con, ControllerContext controllerContext, string enteredUrlPath)
        {
            urlPath = enteredUrlPath;
            urlPathSegments = urlPath.Split('/');
            processPageNumber();
            this.controllerContext = controllerContext;

            pageType = PageType.NotFond;

            if (pageType == PageType.NotFond)
                tryLoadContextForStartPage(con);

            if (pageType == PageType.NotFond)
                tryLoadContextForExclusionPath(con);

            if (pageType == PageType.NotFond && urlPathSegments.Length == 1)
                tryLoadContextForPostType(con);

            if (pageType == PageType.NotFond)
                tryLoadContextForPost(con);

            InitializeAdditionalData(con);
            LoadWidgets(con);
        }

        private void processPageNumber()
        {
            //Set pageNumber .../page/NUMBER
            if (urlPathSegments.Length > 2 && urlPathSegments[urlPathSegments.Length - 2] == "page") //If the second from the end segment is "page"
                if (Int32.TryParse(urlPathSegments[urlPathSegments.Length - 1], out pageNumber)) //page NUMBER should be the last urlPathSegment
                {
                    urlPathSegments = urlPathSegments.Take(urlPathSegments.Length - 2).ToArray(); //Remove last 2 urlPathSegments
                    urlPath = string.Join("/", urlPathSegments);
                }
        }

        private bool tryLoadContextForExclusionPath(SqlConnection con)
        {
            if (exclusionUrls == null || exclusionUrls.Contains(urlPathSegments[0]) == false)
                return false;

            //Code for exclusion urls here

            return false;
        }

        private void LoadWidgets(SqlConnection con)
        {
            widgets = Post.SelectFromDB(con, typeID: (int)PostTypesBuiltIn.Widget, loadTaxonomySelectedList: true, statusID: 50);
            var layoutWidgets = widgets.Where(x => x.taxonomies.Find(y => y.taxonomy.code == "layout_location").taxonomy.termList.Any());
            foreach (var layoutWidget in layoutWidgets)
                layoutWidget.processContentTags(con, controllerContext);
        }

        private bool tryLoadContextForStartPage(SqlConnection con)
        {
            if ((urlPathSegments.Length == 1 && string.IsNullOrEmpty(urlPathSegments[0])))
            {
                pageType = PageType.StartPage;

                postType = PostType.SelectFromDB(con, TypeID: (int)PostTypesBuiltIn.Page).FirstOrDefault();
                postType.LoadStartPost(con, loadTaxonomySelectedList: true, loadFields: true, loadAttachmentList: true);
                post = postType.startPost;
                post.processContentTags(con, controllerContext);

                return true;
            }

            return false;
        }

        private bool tryLoadContextForPostType(SqlConnection con)
        {
            postType = PostType.SelectFromDB(con, TypeURL: urlPathSegments[0]).FirstOrDefault();
            if (postType == null)
                return false;

            if (postType.forTaxonomyID == null)
                pageType = PageType.PostType;
            else
            {
                pageType = PageType.TermPostType;
                postTypeTaxonomy = PostTypeTaxonomy.SelectFromDB(con, ForPostTypeID: postType.forPostTypeID, ForTaxonomyID: postType.forTaxonomyID, EnabledOnly: true).First();
            }

            postType.LoadStartPost(con, loadTaxonomySelectedList: true, loadFields: true, loadAttachmentList: true);
            post = postType.startPost;
            post.processContentTags(con, controllerContext);
            postList = Post.SelectFromDB(con, typeID: postType.ID, statusID: 50, page: pageNumber, pageSize: 10, loadAttachmentList: true, loadFields: true, loadTaxonomySelectedList: true, excludeStartPage: true);

            return true;
        }

        private bool tryLoadContextForPost(SqlConnection con)
        {
            postType = PostType.SelectFromDB(con, TypeURL: urlPathSegments[0]).FirstOrDefault();

            if (postType != null)
            {
                postParents = getPostsHierarchical(con, postType.ID, urlPathSegments.Skip(1));
            }
            else
            {
                //There may be a post type with TypeURL: "" (page type)
                postType = PostType.SelectFromDB(con, TypeURL: "").FirstOrDefault();
                if (postType != null)
                    postParents = getPostsHierarchical(con, postType.ID, urlPathSegments);
            }

            if (postParents == null || postParents.Count == 0)
                return false;

            pageType = PageType.Post;
            post = postParents.Last();

            post.LoadAttachments(con);
            post.LoadFields(con);
            post.LoadTaxonomies(con, loadTerms: true, termsCheckedOnly: true);
            post.processContentTags(con, controllerContext);


            if (post.forTermID != null)
            {
                pageType = PageType.TermPost;
                postList = Post.SelectFromDB(con, typeID: post.postType.forPostTypeID, termID: post.forTermID, statusID:50, loadAttachmentList: true, loadFields:true, loadTaxonomySelectedList:true, excludeStartPage:true).AsQueryable().ToPagedList(pageNumber, 10);
                postTypeTaxonomy = PostTypeTaxonomy.SelectFromDB(con, ForPostTypeID: post.postType.forPostTypeID, ForTaxonomyID: postType.forTaxonomyID, EnabledOnly: true).First();

                term = Taxonomy.Term.SelectFromDB(con, TermID: post.forTermID).First();
            }

            return true;
        }

        private List<Post> getPostsHierarchical(SqlConnection con, int postTypeID, IEnumerable<string> postURLPath)
        {
            List<Post> hierarchicalPosts = new List<Post>();

            Post post = null;
            long? postParentID = null;
            // In first iteration PostParentID is NULL then Select only top level posts
            foreach (string postURL in postURLPath)
            {
                post = Post.SelectFromDB(con, typeID: postTypeID, postURL: postURL, postParentID: postParentID, statusID:50).FirstOrDefault();
                if (post == null)
                    return null;

                hierarchicalPosts.Add(post);
                postParentID = post.ID; //In next iteration use current PostID as PostParentID
            }

            return hierarchicalPosts;
        }

        private void InitializeAdditionalData(SqlConnection con)
        {
            //initializeContextCityTerms
            if (pageType == PageType.TermPost && postType.forTaxonomyID == 3)
                initializeContextCityTerms(con, term);
            else if (pageType == PageType.Post && post != null && post.taxonomies != null)
            {
                var cityTax = post.taxonomies.FirstOrDefault(x => x.taxonomy.code == "city");
                if (cityTax != null)
                    initializeContextCityTerms(con, cityTax.taxonomy);
            }

            initializePostsBusiness(con);
        }

        private void initializeContextCityTerms(SqlConnection con, Taxonomy.Taxonomy cityTax)
        {
            if (cityTax != null && cityTax.termList != null && cityTax.termList.Count > 0)
            {
                regionCity = cityTax.termList.FirstOrDefault(x => x.parentID != null && countryIds.Contains(x.parentID.Value));
                if (regionCity == null)
                {
                    smallCity = cityTax.termList.First();
                    foreach (long cityParentID in cityTax.termList.Where(x => x.parentID != null).Select(x => x.parentID.Value).Distinct())
                    {
                        Taxonomy.Term cityTerm = Taxonomy.Term.SelectFromDB(con, TermID: cityParentID).First();
                        if (cityTerm.parentID != null && countryIds.Contains(cityTerm.parentID.Value))
                        {
                            regionCity = cityTerm;
                            break;
                        }
                    }
                }
            }

            if (regionCity != null)
                regionCity.LoadSystemWords(con);
            if (smallCity != null)
                smallCity.LoadSystemWords(con);

        }

        private void initializeContextCityTerms(SqlConnection con, Taxonomy.Term city)
        {
            if (city == null)
                return;

            if (countryIds.Contains(city.ID))
            {
                country = city;
            }
            else if (city.parentID != null)
            {
                if (countryIds.Contains(city.parentID.Value))
                {
                    regionCity = city;
                }
                else
                {
                    smallCity = city;
                    if (smallCity.parentID != null)
                        regionCity = Taxonomy.Term.SelectFromDB(con, TermID: smallCity.parentID).First();
                }
            }




            if (country != null)
            {
                List<Taxonomy.Term> _cities = Taxonomy.Term.SelectFromDB(con, TermParentID: country.ID);
                Sys.Word.LoadWordsForTerms(con, ref _cities);
                cities = _cities;
            }
            if (regionCity != null)
            {
                regionCity.LoadSystemWords(con);
                isRegionCityAllowedInLeads = Lead.LeadConfiguration.FieldMetaTermIsAllowed(con, regionCity.ID);
                cities = Taxonomy.Term.SelectFromDB(con, TermParentID: regionCity.ID);
            }
            if (smallCity != null)
            {
                smallCity.LoadSystemWords(con);
            }

        }

        private void initializePostsBusiness(SqlConnection con)
        {
            //Populate posts list
            List<Post> posts = new List<Post>();
            string[] masterRelatedPostTypeUrls = new string[] { "masterskaya"};


            //if the post has postBuisnessTypeUrl
            if (pageType == PageType.Post && string.IsNullOrEmpty(post.postURL) == false && masterRelatedPostTypeUrls.Contains(post.postType.url))
                posts.Add(post);
            //if the post in postList postBuisnessTypeUrl
            if (postList != null)
                foreach (Post item in postList)
                    if (masterRelatedPostTypeUrls.Contains(item.postType.url))
                        posts.Add(item);

            //Populate postBusinesses dictionary
            postBusinesses = new Dictionary<long, Business.Business>();
            string postBuisnessIdKey = "LeadGenBusinessID";
            foreach (Post item in posts)
            {
                long? businessID = item.fields.FirstOrDefault(x => x.code == postBuisnessIdKey)?.fieldNumber;
                if (businessID == null)
                    continue;

                Business.Business business = Business.Business.SelectFromDB(con, businessID: businessID.Value).FirstOrDefault();
                if (business == null)
                    continue;

                business.LoadReviews(con, published: true);

                if(postBusinesses.ContainsKey(item.ID) == false)
                    postBusinesses.Add(item.ID, business);
            }

        }

    }
}
