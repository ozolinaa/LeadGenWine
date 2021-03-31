using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Tokens
{
    public class NewLoginEmailVerificationToken : Token
    {
        public NewLoginEmailVerificationToken() { }
        public NewLoginEmailVerificationToken(long loginID)
        {
            LoginID = loginID;
        }

        [JsonProperty("loginID")]
        public long LoginID { get; set; }
    }
}
