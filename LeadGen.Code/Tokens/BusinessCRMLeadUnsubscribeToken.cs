using Newtonsoft.Json;
using System;
using System.Collections.Generic;
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
    }
}
