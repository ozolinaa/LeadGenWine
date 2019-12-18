using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Settings
{
    public struct CMSSettings
    {
        public string HtmlHeadInjection { get; set; }
    }

    public struct EmailSettings
    {
        public string FromAddress { get; set; }
        public string FromName { get; set; }
        public string ReplyToAddress { get; set; }
        public SmtpSettings SmtpSettings { get; set; }
    }

    public struct SmtpSettings
    {
        public int SendIntervalMilliseconds { get; set; }
        public string Host { get; set; }
        public int Port { get; set; }
        public string UserName { get; set; }
        public string Password { get; set; }
        public bool EnableSsl { get; set; }
    }
}
