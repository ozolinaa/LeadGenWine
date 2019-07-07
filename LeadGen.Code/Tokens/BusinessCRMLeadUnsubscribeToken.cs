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

        public Post UnsubscribeBusinessPost(SqlConnection con)
        {
            int businessPostFieldIDDoNotSendEmails = 8;

            Post businessPost = Post.SelectFromDB(con, postID: BusinessPostID).First();
            businessPost.LoadFields(con);
            PostField field = businessPost.fields.First(x => x.ID == businessPostFieldIDDoNotSendEmails);
            field.fieldBool = true; //TRUE means DO NOT send
            field.SaveToDB(con, businessPost.ID);

            return businessPost;
        }
    }
}
