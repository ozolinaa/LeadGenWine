using System;
using System.Collections.Generic;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Helpers
{
    public class SmtpClientLeadGen : SmtpClient
    {
        public SmtpClientLeadGen() : base() {
            this.Host = SysHelper.AppSettings.EmailSettings.SmtpSettings.Host;
            this.Port = SysHelper.AppSettings.EmailSettings.SmtpSettings.Port;
            this.Credentials = new System.Net.NetworkCredential(SysHelper.AppSettings.EmailSettings.SmtpSettings.UserName, SysHelper.AppSettings.EmailSettings.SmtpSettings.Password);
            this.EnableSsl = SysHelper.AppSettings.EmailSettings.SmtpSettings.EnableSsl;
        }

        public static void SendSingleMessage(MailMessage mailMessage) {
            Task.Factory.StartNew(() => {
                using (SmtpClientLeadGen smtpClient = new SmtpClientLeadGen())
                {
                    smtpClient.Send(mailMessage);
                }
            });
        }
    }
}
