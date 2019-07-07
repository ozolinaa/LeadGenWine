using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Tokens
{
    public class LeadEmailConfirmationToken : Token
    {
        public LeadEmailConfirmationToken() { }
        public LeadEmailConfirmationToken(long leadID)
        {
            LeadID = leadID;
        }

        [JsonProperty("leadID")]
        public long LeadID { get; set; }
    }
}
