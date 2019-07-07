using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Tokens
{
    public class LeadReviewCreateToken : Token
    {
        public LeadReviewCreateToken() { }
        public LeadReviewCreateToken(long leadID)
        {
            LeadID = leadID;
        }

        [JsonProperty("leadID")]
        public long LeadID { get; set; }
    }
}
