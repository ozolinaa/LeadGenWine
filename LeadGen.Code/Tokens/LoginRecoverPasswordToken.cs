using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Tokens
{
    public class LoginRecoverPasswordToken : Token
    {
        public LoginRecoverPasswordToken() { }
        public LoginRecoverPasswordToken(long loginID)
        {
            LoginID = loginID;
        }


        [JsonProperty("loginID")]
        public long LoginID { get; set; }
    }
}
