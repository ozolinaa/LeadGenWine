using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.CMS
{
    public class PostTitle
    {
        public PostTitle(Post post)
        {
            Title = post.title;
        }
        public string Title { get; set; }
        public string Content { get; set; }
        public bool ShowSiteName = false;
        public bool ShowBorder { get; set; }
    }
}
