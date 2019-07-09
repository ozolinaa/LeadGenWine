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
        private Post _businessPost;

        [JsonIgnore]
        public Post BusinessPost => _businessPost;

        public void LoadBusinessPost(SqlConnection con)
        {
            _businessPost = Post.SelectFromDB(con, postID: BusinessPostID).First();
            _businessPost.LoadFields(con);
        }

        public void UnsubscribeBusinessPost(SqlConnection con)
        {
            if (_businessPost == null)
            {
                LoadBusinessPost(con);
            }
            int businessPostFieldIDDoNotSendEmails = 8;
            PostField field = _businessPost.fields.First(x => x.ID == businessPostFieldIDDoNotSendEmails);
            field.fieldBool = true; //TRUE means DO NOT send
            field.SaveToDB(con, _businessPost.ID);
        }
    }
}
