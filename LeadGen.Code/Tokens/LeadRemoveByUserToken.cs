using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Tokens
{
    public class LeadRemoveByUserToken : Token
    {
        public LeadRemoveByUserToken() { }
        public LeadRemoveByUserToken(string userEmailAddress)
        {
            UserEmailAddress = userEmailAddress;
        }

        [JsonProperty("userEmailAddress")]
        public string UserEmailAddress { get; set; }
    }
}
