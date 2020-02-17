using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using LeadGen.Code.Helpers;
using System.ComponentModel.DataAnnotations;

using LeadGen.Code.CMS.Sitemap;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Mvc;
using X.PagedList;
using LeadGen.Code.Map;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace LeadGen.Code.CMS
{
    public class Post : ISitemapItem
    {
        public class Status
        {
            [Display(Name = "Post Status")]
            public int ID { get; set; }
            public string name { get; set; }

            public static List<Status> SelectFromDB(SqlConnection con)
            {
                List<Status> PostStatusList = new List<Status>();

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = con;
                    cmd.CommandText = "[dbo].[CMSPostStatusSelect]";
                    cmd.CommandType = CommandType.StoredProcedure;

                    DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                    foreach (DataRow row in dt.Rows)
                    {
                        PostStatusList.Add(new Status()
                        {
                            ID = (int)row["StatusID"],
                            name = row["StatusName"].ToString()
                        });
                    }
                }

                return PostStatusList;
            }
        }

        #region Properties

        public long ID { get; set; }
        public PostType postType { get; set; }

        [MaxLength(100)]
        public string postURL { get; set; }
        public string postURLParentPath { get; set; }

        public string postURLHierarchical
        {
            get
            {
                return postURLParentPath + postURL;
            }
        }

        public long? postParentID { get; set; }

        [Required()]
        public Status postStatus { get; set; }

        [Required()]
        public long authorID { get; set; }

        public DateTime dateCreated { get; set; }

        public DateTime dateModified { get; set; }

        [Display(Name = "Date Published")]
        public DateTime? datePublished { get; set; }

        [Required()]
        public string title { get; set; }

        public string contentIntro { get; set; }

        [DisplayFormat(ConvertEmptyStringToNull = false)]
        public string content { get; set; }
        public string contentPreview { get; set; }
        public string contentMain { get; set; }
        public string contentEnding { get; set; }
        public string customCSS { get; set; }

        public SEOFields SEO { get; set; }

        public long? thumbnailAttachmentID { get; set; }
        public string thumbnailUrl
        {
            get
            {
                if (thumbnailAttachmentID != null && attachmentList != null)
                {
                    var thumbnailAttachment = attachmentList.FirstOrDefault(x => x.attachmentID == thumbnailAttachmentID);
                    if (thumbnailAttachment != null)
                        return thumbnailAttachment.GetImageURLBySizeCode("Thumbnail").ToString();
                }
                return null;
            }
        }

        public int order { get; set; }

        public long? forTermID { get; set; }
        public int? forTaxonomyID { get; set; }

        public List<Attachment> attachmentList { get; set; }
        public List<PostTypeTaxonomy> taxonomies { get; set; }
        public List<PostField> fields { get; set; }
        public PostField getFieldByCode(string code)
        {
            return fields.FirstOrDefault(x => x.code == code);
        }
        #endregion


        #region ISitemapItem implementation
        public string Url
        {
            get
            {
                string relative = ((postType.url ?? "") + "/" + postURLParentPath + postURL).Replace("//", "/").Trim('/');
                return string.Format("{0}/{1}/", SysHelper.AppSettings.SiteUrl, relative);
            }
        }

        public DateTime LastModified
        {
            get
            {
                return dateModified;
            }
        }

        public SitemapChangeFrequency ChangeFrequency
        {
            get
            {
                return SEO.changeFrequency;
            }
        }

        public double Priority
        {
            get
            {
                return (double)SEO.priority;
            }
        }
        #endregion



        public Post()
        {
            postType = new PostType();
            postStatus = new Status();
            SEO = new SEOFields();
        }

        public Post(DataRow row)
        {
            InitializeFromDBRow(row);
        }

        private void InitializeFromDBRow(DataRow row)
        {
            ID = (long)row["PostID"];
            postParentID = DBNull.Value.Equals(row["PostParentID"]) ? null : (long?)row["PostParentID"];
            postType = new PostType
            {
                ID = (int)row["TypeID"],
                name = row["TypeName"].ToString(),
                url = DBNull.Value.Equals(row["TypeURL"]) ? null : row["TypeURL"].ToString(),
                hasContentIntro = Convert.ToBoolean(row["HasContentIntro"]),
                hasContentEnding = Convert.ToBoolean(row["HasContentEnding"]),
                forTaxonomyID = (int?)(row["ForTaxonomyID"] == DBNull.Value ? null : row["ForTaxonomyID"]),
                forPostTypeID = (int?)(row["ForPostTypeID"] == DBNull.Value ? null : row["ForPostTypeID"])
            };
            postStatus = new Post.Status
            {
                ID = (int)row["StatusID"],
                name = row["StatusName"].ToString()
            };
            authorID = (long)row["AuthorID"];
            dateCreated = (DateTime)row["DateCreated"];
            dateModified = (DateTime)row["DateLastModified"];
            datePublished = DBNull.Value.Equals(row["DatePublished"]) ? null : (DateTime?)row["DatePublished"];
            title = row["Title"].ToString();
            contentIntro = DBNull.Value.Equals(row["ContentIntro"]) ? null : row["ContentIntro"].ToString();
            contentPreview = DBNull.Value.Equals(row["ContentPreview"]) ? null : row["ContentPreview"].ToString();
            contentMain = row["ContentMain"].ToString();
            contentEnding = DBNull.Value.Equals(row["ContentEnding"]) ? null : row["ContentEnding"].ToString();
            customCSS = DBNull.Value.Equals(row["CustomCSS"]) ? null : row["CustomCSS"].ToString();
            content = DBNull.Value.Equals(row["ContentPreview"]) ? row["ContentMain"].ToString() : row["ContentPreview"] + CMSManager.postContentPreviewSeparator + row["ContentMain"];
            postURLParentPath = row["ParentPathURL"].ToString();
            postURL = DBNull.Value.Equals(row["PostURL"]) ? null : row["PostURL"].ToString();
            SEO = new SEOFields(row);
            thumbnailAttachmentID = DBNull.Value.Equals(row["ThumbnailAttachmentID"]) ? null : (long?)row["ThumbnailAttachmentID"];
            forTermID = DBNull.Value.Equals(row["PostForTermID"]) ? null : (long?)row["PostForTermID"];
            forTaxonomyID = DBNull.Value.Equals(row["PostForTaxonomyID"]) ? null : (int?)row["PostForTaxonomyID"];
            order = (int)row["Order"];
        }

        public static long CreateNew(SqlConnection con, long AuthorID, int PostTypeID)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[CMSPostCreateEmpty]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@AuthorID", AuthorID);
                cmd.Parameters.AddWithValue("@PostTypeID", PostTypeID);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@PostID";
                outputParameter.SqlDbType = SqlDbType.BigInt;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                return Int64.Parse(outputParameter.Value.ToString());
            }
        }

        public bool Update(SqlConnection con, ref string errorMessage)
        {
            //Process ContentMain and ContentPreview FROM Content
            if (!string.IsNullOrEmpty(content))
            {
                string[] contentParts;
                //Often PostContentPreviewSeparator is entered at the new line, so need to check if separator is wrapped in <p> tag
                string NewLineSeparator = string.Format("{1}{0}{2}", CMSManager.postContentPreviewSeparator, "<p>", "</p>");
                if (content.Contains(NewLineSeparator))
                    contentParts = content.Split(new string[] { NewLineSeparator }, StringSplitOptions.None);
                else
                    contentParts = content.Split(new string[] { CMSManager.postContentPreviewSeparator }, StringSplitOptions.None);

                if (contentParts.Length > 1)
                {
                    contentPreview = string.IsNullOrEmpty(contentParts[0].Trim()) ? null : contentParts[0].Trim();
                    if (string.IsNullOrEmpty(contentPreview))
                    {
                        contentMain = content.Replace(CMSManager.postContentPreviewSeparator, "").Trim();
                    }
                    else
                    {
                        contentMain = contentParts[1].Trim();
                    }
                }
                else
                {
                    contentPreview = null;
                    contentMain = content.Trim();
                }
            }
            else
            {
                contentPreview = null;
                contentMain = null;
            }

            string DBresult = null;
            using (SqlCommand cmd = new SqlCommand())
            {

                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[CMSPostUpdate]";

                cmd.Parameters.AddWithValue("@PostID", ID);
                cmd.Parameters.AddWithValue("@PostParentID", (object)postParentID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@AuthorID", authorID);
                cmd.Parameters.AddWithValue("@StatusID", postStatus.ID);
                cmd.Parameters.AddWithValue("@Title", title);
                cmd.Parameters.AddWithValue("@ContentIntro", (object)contentIntro ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ContentPreview", (object)contentPreview ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ContentMain", (contentMain == null) ? "" : contentMain);
                cmd.Parameters.AddWithValue("@ContentEnding", (object)contentEnding ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@CustomCSS", (object)customCSS ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@PostURL", CMSManager.ClearURL(postURL));
                cmd.Parameters.AddWithValue("@seoTitle", String.IsNullOrEmpty(SEO.title) ? (object)DBNull.Value : SEO.title);
                cmd.Parameters.AddWithValue("@seoMetaDescription", String.IsNullOrEmpty(SEO.metaDescription) ? (object)DBNull.Value : SEO.metaDescription);
                cmd.Parameters.AddWithValue("@seoMetaKeywords", String.IsNullOrEmpty(SEO.metaKeywords) ? (object)DBNull.Value : SEO.metaKeywords);
                cmd.Parameters.AddWithValue("@seoChangeFrequencyID", SEO.changeFrequency);
                cmd.Parameters.AddWithValue("@seoPriority", SEO.priority);
                cmd.Parameters.AddWithValue("@DatePublished", (object)datePublished ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ThumbnailAttachmentID", (object)thumbnailAttachmentID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Order", order);


                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@Result";
                outputParameter.SqlDbType = SqlDbType.NVarChar;
                outputParameter.Size = 255;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                DBresult = outputParameter.Value.ToString();
            }

            if (DBresult == "SUCCESS")
            {
                //Refresh Selected Terms based TaxonomyManageList
                UpdateTermsFromTaxonomyList(con);

                //Save Post Custom Fields
                if (fields != null && fields.Count > 0)
                    fields.ForEach(x => x.SaveToDB(con, ID));

                return true;
            }

            else
            {
                errorMessage = DBresult;
                return false;
            }

        }



        private bool IsUniqueURL(SqlConnection con)
        {
            bool result = false;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[CMSPostIsUniqueURL]";

                cmd.Parameters.AddWithValue("@PostURL", postURL);
                cmd.Parameters.AddWithValue("@PostTypeID", postType.ID);
                cmd.Parameters.AddWithValue("@PostParentID", (object)postParentID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ExcludePostID", ID);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@Result";
                outputParameter.SqlDbType = SqlDbType.Bit;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();
                result = (bool)outputParameter.Value;
            }

            return result;
        }


        public void LoadTaxonomies(SqlConnection con, bool loadTerms = false, bool termsCheckedOnly = true)
        {
            taxonomies = PostTypeTaxonomy.SelectFromDB(con, ForPostTypeID: postType.ID).ToList();

            if (loadTerms = true && termsCheckedOnly == true)
            {
                taxonomies.ForEach(x => x.taxonomy.termList = CMSterm.SelectFromDB(con, TaxonomyID: x.taxonomy.ID, PostID: ID));
                taxonomies.ForEach(x => x.taxonomy.termList.ForEach(y => y.isChecked = true));
            }
            else if (loadTerms = true && termsCheckedOnly == false)
            {
                taxonomies.ForEach(x => x.taxonomy.LoadTerms(con));
                List<Taxonomy.Term> selectedTerms = CMSterm.SelectFromDB(con, PostID: ID);

                foreach (PostTypeTaxonomy ptt in taxonomies)
                    foreach (Taxonomy.Term term in ptt.taxonomy.termList)
                        if (selectedTerms.Exists(x => x.ID == term.ID))
                            term.isChecked = true;
            }
        }


        private void UpdateTermsFromTaxonomyList(SqlConnection con)
        {
            if (taxonomies == null)
                return;

            using (SqlCommand cmd = new SqlCommand("[dbo].[CMSPostTermRemoveAll]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PostID", ID);

                cmd.ExecuteNonQuery();
            }

            foreach (Taxonomy.Term tax in taxonomies.Where(x => x.taxonomy.termList != null).SelectMany(x => x.taxonomy.termList).Where(x => x.isChecked == true))
            {
                using (SqlCommand cmd = new SqlCommand("[dbo].[CMSPostTermAdd]", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@PostID", ID);
                    cmd.Parameters.AddWithValue("@TermID", tax.ID);

                    cmd.ExecuteNonQuery();
                }
            }
        }




        public static IPagedList<T> SelectFromDB<T>(SqlConnection con,
            long? postID = null, 
            string postURL = null, 
            long? postParentID = 0, 
            int? typeID = null, 
            int? taxonomyID = null,  
            long? termID = null,
            int? forTypeID = null,
            long? forTermID = null,
            int? statusID = null,
            bool excludeStartPage = false,
            string query = null,
            int page = 1,
            int pageSize = Int32.MaxValue,
            bool loadTaxonomySelectedList = false, 
            bool loadAttachmentList = false,
            bool loadFields = false
            ) where T : Post, new()
        {

            if (query != null && String.IsNullOrEmpty(query.Trim()))
                query = null;

            List<T> postList = new List<T>();
            int totalCount = 0;
            using (SqlCommand cmd = new SqlCommand("[dbo].[CMSPostSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PostID", (object)postID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@PostURL", (object)postURL ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@PostParentID", (object)postParentID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TypeID", (object)typeID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TaxonomyID", (object)taxonomyID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TermID", (object)termID ?? DBNull.Value); 
                cmd.Parameters.AddWithValue("@ForTypeID", (object)forTypeID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ForTermID", (object)forTermID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ExcludeStartPage", excludeStartPage);
                cmd.Parameters.AddWithValue("@StatusID", (object)statusID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Query", query ?? (object)DBNull.Value);


                cmd.Parameters.AddWithValue("@Offset", pageSize * (page-1));
                cmd.Parameters.AddWithValue("@Fetch", pageSize);

                SqlParameter totalCountParameter = new SqlParameter();
                totalCountParameter.ParameterName = "@TotalCount";
                totalCountParameter.SqlDbType = SqlDbType.Int;
                totalCountParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(totalCountParameter);

                using (DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd))
                {
                    totalCount = (int)totalCountParameter.Value;
                    foreach (DataRow row in dt.Rows)
                    {
                        T loadedPost = (T)Activator.CreateInstance(typeof(T), row);

                        if (loadTaxonomySelectedList == true)
                            loadedPost.LoadTaxonomies(con, loadTerms: true, termsCheckedOnly: true);
                        if (loadAttachmentList == true)
                            loadedPost.LoadAttachments(con);
                        if (loadFields == true)
                            loadedPost.LoadFields(con);

                        postList.Add(loadedPost);
                    }
                }

            }

            return new StaticPagedList<T>(postList, page, pageSize, totalCount);
        }


        public static IPagedList<T> SelectFromDB<T>(SqlConnection con,
            string fieldCode,
            string textValue = null,
            DateTime? datetimeValue = null,
            bool? boolValue = null,
            long? numberValue = null,
            int page = 1,
            int pageSize = Int32.MaxValue,
            bool loadTaxonomySelectedList = false,
            bool loadAttachmentList = false,
            bool loadFields = false
            ) where T : Post
        {

            List<T> PostList = new List<T>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[CMSPostSelectByScalarField]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@FieldCode", fieldCode);
                cmd.Parameters.AddWithValue("@TextValue", String.IsNullOrEmpty(textValue) ? (object)DBNull.Value : textValue);
                cmd.Parameters.AddWithValue("@DatetimeValue", (object)datetimeValue ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@BoolValue", (object)boolValue ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@NumberValue", (object)numberValue ?? DBNull.Value);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    T loadedPost = (T)Activator.CreateInstance(typeof(T), row);

                    if (loadTaxonomySelectedList == true)
                        loadedPost.LoadTaxonomies(con, loadTerms: true, termsCheckedOnly: true);
                    if (loadAttachmentList == true)
                        loadedPost.LoadAttachments(con);
                    if (loadFields == true)
                        loadedPost.LoadFields(con);

                    PostList.Add(loadedPost);
                }
            }

            return PostList.AsQueryable().ToPagedList(page, pageSize);

        }


        public static IPagedList<T> SelectFromDB<T>(SqlConnection con,
            List<string> postUrls,
            int page = 1,
            int pageSize = Int32.MaxValue,
            bool loadTaxonomySelectedList = false,
            bool loadAttachmentList = false,
            bool loadFields = false
            ) where T : Post
        {
            List<T> PostList = new List<T>();

            postUrls.ForEach(x => x.Trim('/'));
            using (SqlCommand cmd = new SqlCommand("[dbo].[CMSPostSelectByUrls]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PostURLs", string.Join(",", postUrls));

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    T loadedPost = (T)Activator.CreateInstance(typeof(T), row);

                    if (loadTaxonomySelectedList == true)
                        loadedPost.LoadTaxonomies(con, loadTerms: true, termsCheckedOnly: true);
                    if (loadAttachmentList == true)
                        loadedPost.LoadAttachments(con);
                    if (loadFields == true)
                        loadedPost.LoadFields(con);

                    PostList.Add(loadedPost);
                }
            }

            return PostList.AsQueryable().ToPagedList(page, pageSize);
        }


        public void LoadAttachments(SqlConnection con)
        {
            attachmentList = new List<Attachment>();

            using (SqlCommand cmd = new SqlCommand("[dbo].[CMSPostGetAttachments]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PostID", ID);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);

                foreach (DataRow attachmentRow in dt.DefaultView.ToTable(true, "AttachmentID", "AuthorID", "DateCreated", "AttachmentTypeID", "AttachmentTypeName", "MIME", "URL", "Name", "Description").Rows)
                {
                    using (DataTable attachmentData = dt.Clone())
                    {
                        foreach (DataRow row in dt.Select(String.Format("AttachmentID = {0}", attachmentRow["AttachmentID"])))
                        {
                            attachmentData.ImportRow(row);
                        }
                        attachmentList.Add(new Attachment(attachmentRow, attachmentData));
                    }
                }
            }
        }

        public void LoadFields(SqlConnection con)
        {
            fields = new List<PostField>();

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[CMSPostFieldValueSelect]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PostID", ID);


                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    PostField field = new PostField(row);
                    if (field.location != null)
                    {
                        field.location = Location.LoadFromDB(field.location.ID, con);
                    }
                    fields.Add(field);
                }
            }
        }

        public void processContentTags(SqlConnection con)
        {
            if(string.IsNullOrEmpty(contentIntro) == false)
                contentIntro = processContentStringTags(con, contentIntro);
            if (string.IsNullOrEmpty(contentPreview) == false)
                contentPreview = processContentStringTags(con, contentPreview);
            if (string.IsNullOrEmpty(contentMain) == false)
                contentMain = processContentStringTags(con, contentMain);
            if (string.IsNullOrEmpty(contentEnding) == false)
                contentEnding = processContentStringTags(con, contentEnding);
        }

        private string processContentStringTags(SqlConnection con, string contentString)
        {
            string processedContent = processContentStringTagPosts(con, contentString);
            processedContent = processContentStringTagAudio(con, processedContent);

            return removeContentStringTags(con, processedContent);
        }

        private string processContentStringTagPosts(SqlConnection con, string contentString)
        {
            foreach (Match m in Regex.Matches(contentString, @"\[posts (.*?)\]")) //[posts type=xxx taxonomy=yyy term=zzz postUrls=iii,jjj,kkk]
            {
                string typeUrl = "";
                string taxonomyCode = "";
                string termUrls = "";
                string postUrls = "";
                string view = "";

                string[] parameters = m.Groups[1].ToString().ToLower().Trim().Split(' ');
                foreach (string parameterStr in parameters)
                {
                    string[] parameter = parameterStr.Trim().Split('=');
                    if (parameter.Length == 2)
                    {
                        switch (parameter[0])
                        {
                            case "typeurl":
                                typeUrl = parameter[1].Trim().Trim('"');
                                break;
                            case "taxonomycode":
                                taxonomyCode = parameter[1].Trim().Trim('"');
                                break;
                            case "termurls":
                                termUrls = parameter[1].Trim().Trim('"');
                                break;
                            case "posturls":
                                postUrls = parameter[1].Trim().Trim('"');
                                break;
                            case "view":
                                view = parameter[1].Trim().Trim('"');
                                break;
                        }
                    }
                }

                List<Post> posts = new List<Post>();

                if (typeUrl != "" && taxonomyCode != "" && termUrls != "")
                {
                    try
                    {
                        PostType postType = PostType.SelectFromDB(con, TypeURL: typeUrl).First();
                        foreach (string termUrl in termUrls.Split(','))
                        {
                            Taxonomy.Term term = Taxonomy.Term.SelectFromDB(con, TaxonomyCode: taxonomyCode, TermURL: termUrl.Trim()).FirstOrDefault();
                            if (term != null)
                            {
                                List<Post> termPosts = Post.SelectFromDB<Post>(con, typeID: postType.ID, termID: term.ID, statusID: 50).ToList();
                                posts.AddRange(termPosts.Where(p => !posts.Any(p2 => p2.ID == p.ID)));
                            }
                        }
                        posts.OrderByDescending(x => x.order).ThenByDescending(x => x.datePublished).ThenByDescending(x => x.dateCreated);

                    }
                    catch (Exception)
                    {
                    }

                }

                if (String.IsNullOrEmpty(postUrls) == false)
                {
                    try
                    {
                        List<string> postUrlList = postUrls.Split(',').ToList();
                        postUrlList.ForEach(x => x.Trim());
                        posts.AddRange(Post.SelectFromDB<Post>(con, postUrlList));
                    }
                    catch (Exception)
                    {
                    }
                }

                try
                {
                    if (posts.Any())
                    {
                        //Recursively call processContentTags for any of loaded posts
                        posts.ForEach(x => x.processContentTags(con));
                        posts.ForEach(x => x.LoadAttachments(con));

                        view = string.IsNullOrEmpty(view) ? "PostMiniList" : view;
                        string viewPath = $"~/Views/CMS/{view}.cshtml";
                        string renderedHtml = ViewHelper.RenderViewToString(viewPath, posts);
                        string matchedStr = m.Groups[0].ToString();
                        string matchedStrWithP = $"<p>{matchedStr}</p>";
                        if (contentString.Contains(matchedStrWithP)) {
                            matchedStr = matchedStrWithP;
                        }
                        contentString = contentString.Replace(matchedStr, renderedHtml);
                    }
                }
                catch (Exception e)
                {
                    ;
                }

            }

            return contentString;
        }

        private string processContentStringTagAudio(SqlConnection con, string contentString)
        {
            foreach (Match m in Regex.Matches(contentString, @"\[audio (.*?)\]")) //[audio mp3=xxx]
            {
                string mp3 = "";

                string[] parameters = m.Groups[1].ToString().ToLower().Trim().Split(' ');
                foreach (string parameterStr in parameters)
                {
                    string[] parameter = parameterStr.Trim().Split('=');
                    if (parameter.Length == 2)
                    {
                        switch (parameter[0])
                        {
                            case "mp3":
                                mp3 = parameter[1].Trim().Trim('"');
                                break;
                        }
                    }
                }

                string renderedHtml = "";
                if (string.IsNullOrEmpty(mp3) == false)
                {
                    renderedHtml = ViewHelper.RenderViewToString("AudioPlayer", mp3);

                    contentString = contentString.Replace(m.Groups[0].ToString(), renderedHtml);
                }

            }

            return contentString;
        }

        private string removeContentStringTags(SqlConnection con,string contentString)
        {
            //remove any [] tags
            foreach (Match m in Regex.Matches(contentString, @"\[(.*?)\]")) //[xxx]
                contentString = contentString.Replace(m.Groups[0].ToString(), "");

            return contentString;
        }



    }
}