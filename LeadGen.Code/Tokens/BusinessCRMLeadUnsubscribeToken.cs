using LeadGen.Code.CMS;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace LeadGen.Code.Tokens
{
    public class BusinessCRMLeadUnsubscribeToken : Token
    {
        public BusinessCRMLeadUnsubscribeToken() { }
        public BusinessCRMLeadUnsubscribeToken(long businessPostID)
        {
            BusinessPostID = businessPostID;
        }

        [JsonProperty("businessPostID")]
        public long BusinessPostID { get; set; }

        [JsonIgnore]
        private PostBusiness _businessPost;

        [JsonIgnore]
        public PostBusiness BusinessPost => _businessPost;

        public void LoadBusinessPost(SqlConnection con)
        {
            _businessPost = Post.SelectFromDB<PostBusiness>(con, postID: BusinessPostID).First();
        }
    }
}
