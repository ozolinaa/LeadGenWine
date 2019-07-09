using LeadGen.Code.CMS;
using LeadGen.Code.Helpers;
using LeadGen.Code.Lead;
using LeadGen.Code.Sys;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;

using static LeadGen.Code.Business.NotificationSettings;

namespace LeadGen.Code.Business.Notification
{
    public class NotificationManager
    {
        public static List<MailMessageLeadGen> QueueMailMessagesForBusinessesRegisteredAboutNewLeads(SqlConnection connection, Frequency frequency)
        {
            List<MailMessageLeadGen> queuedMessages = new List<MailMessageLeadGen>();

            DateTime now = DateTime.UtcNow;
            DateTime notificationDateTime = now;
            //Set notificationDateTime to the beginning of the current hour
            notificationDateTime = notificationDateTime.AddMinutes((-now.Minute));
            notificationDateTime = notificationDateTime.AddSeconds((-notificationDateTime.Second));
            notificationDateTime = notificationDateTime.AddMilliseconds((-notificationDateTime.Millisecond));


            //Registered Businesses Process and Queue Messages
            Dictionary<Business, List<LeadItem>> businessesWithLeadsToNotifyAbout = GetBusinessesWithLeadsToNotifyAbout(connection, frequency, now.AddDays(-7));
            List<MailMessageLeadGen> businessMessages = GenerateEmailBusinessNotificationMessages(businessesWithLeadsToNotifyAbout);

            foreach (Business business in businessesWithLeadsToNotifyAbout.Keys)
                foreach (LeadItem lead in businessesWithLeadsToNotifyAbout[business])
                    business.NotifiedAboutLeadSet(connection, lead.ID, notificationDateTime);

            businessMessages.ForEach(x => x.QueueToDB(connection, notificationDateTime));
            queuedMessages.AddRange(businessMessages);

            return queuedMessages;
        }

        public static List<MailMessageLeadGen> QueueMailMessagesForCompanyPostsAboutNewLeads(SqlConnection connection)
        {
            DateTime now = DateTime.UtcNow;

            //CRM Businesses (Posts) Process and Queue Messages
            Dictionary<Post, List<LeadItem>> crmBusinessesWithLeadsToNotifyAbout = GetCompanyPostsWithLeadsToNotifyAbout(connection, now.AddDays(-7));
            IEnumerable<MailMessageLeadGen> postMessages = MailMessageBuilder.BuildLeadNotificationForCRMBusiness(connection, crmBusinessesWithLeadsToNotifyAbout);
            return postMessages.ToList();

            foreach (Post businessPost in crmBusinessesWithLeadsToNotifyAbout.Keys)
                foreach (LeadItem lead in crmBusinessesWithLeadsToNotifyAbout[businessPost])
                    PostNotifiedAboutLeadSet(connection, businessPost.ID, lead.ID, now);

            foreach (MailMessageLeadGen postMessage in postMessages)
            {
                postMessage.QueueToDB(connection, now);
            }

            return postMessages.ToList();
        }


        private static Dictionary<Business, List<LeadItem>> GetBusinessesWithLeadsToNotifyAbout(SqlConnection connection, Frequency frequency, DateTime publishedAfter)
        {
            Dictionary<Business, List<LeadItem>> businessesWithLeads = new Dictionary<Business, List<LeadItem>>();

            DataView leadNotificationData = GetLeadBusinessNotificationDataView(connection, frequency, publishedAfter);
            List<LeadItem> leadsToSend = LoadLeadsFromTheNotificationView(connection, leadNotificationData);
            List<Business> businessesSendTo = LoadBusinessesFromTheNotificationView(connection, leadNotificationData);

            foreach (Business business in businessesSendTo)
            {
                //Dictionary<long, bool> businessLeadPertmittions = new Dictionary<long, bool>();
                List<LeadItem> businessLeads = new List<LeadItem>();
                DataRow[] businessLeadRows = leadNotificationData.ToTable().Select(string.Format("BusinessID = {0}", business.ID));
                foreach (DataRow businessLeadRow in businessLeadRows)
                {
                    LeadItem lead = leadsToSend.Where(x => x.ID == (long)businessLeadRow["LeadID"]).Select(x => new LeadItem() {
                        ID = x.ID,
                        email = x.email,
                        fieldGroups = x.fieldGroups,
                        adminDetails = x.adminDetails,
                        businessDetails = new BusinessDetails() {
                            businessID = business.ID,
                            isPermittedForBusiness = Convert.ToBoolean(businessLeadRow["IsApproved"])
                        }
                    }).First();

                    businessLeads.Add(lead);
                }

                businessesWithLeads.Add(business, businessLeads);
            }

            return businessesWithLeads;
        }

        private static DataView GetLeadCompanyPostNotificationDataView(SqlConnection connection, DateTime publishedAfter)
        {
            DataView leadNotificationView = null;
            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadSelectBusinessPostNotificationData]", connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PublishedAfter", publishedAfter);

                leadNotificationView = new DataView(DBHelper.ExecuteCommandToDataTable(cmd));
            }

            return leadNotificationView;
        }

        private static DataView GetLeadBusinessNotificationDataView(SqlConnection connection, Frequency frequency, DateTime publishedAfter)
        {
            DataView leadNotificationView = null;
            using (SqlCommand cmd = new SqlCommand("[dbo].[LeadSelectBusinessNotificationData]", connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PublishedAfter", publishedAfter);
                cmd.Parameters.AddWithValue("@ForFrequencyName", frequency.ToString());

                leadNotificationView = new DataView(DBHelper.ExecuteCommandToDataTable(cmd));
            }

            return leadNotificationView;
        }

        private static List<LeadItem> LoadLeadsFromTheNotificationView(SqlConnection connection, DataView leadNotificationView)
        {
            List<LeadItem> leadsToSend = new List<LeadItem>();
            DataTable distinctLeadIds = leadNotificationView.ToTable(true, "LeadID");
            foreach (DataRow leadIDRow in distinctLeadIds.Rows)
            {
                LeadItem lead = LeadItem.SelectFromDB(connection, leadID: (long)leadIDRow["LeadID"]).First();
                lead.LoadFieldValues(connection);
                leadsToSend.Add(lead);
            }

            return leadsToSend;
        }

        private static List<Business> LoadBusinessesFromTheNotificationView(SqlConnection connection, DataView leadNotificationView)
        {
            List<Business> businessesSendTo = new List<Business>();
            DataTable distinctBusinessIds = leadNotificationView.ToTable(true, "BusinessID");
            foreach (DataRow businessIDRow in distinctBusinessIds.Rows)
            {
                Business business = Business.SelectFromDB(connection, businessID: (long)businessIDRow["BusinessID"]).First();
                business.notification = new NotificationSettings(connection, business.ID, business.notification.frequency);
                businessesSendTo.Add(business);
            }

            return businessesSendTo;
        }

        private static List<MailMessageLeadGen> GenerateEmailBusinessNotificationMessages(Dictionary<Business, List<LeadItem>> businessesWithLeadsToNotifyAbout)
        {
            List<MailMessageLeadGen> messages = new List<MailMessageLeadGen>();

            string mailSubject = "Новые заявки";
            string viewPath = "~/Areas/Business/Views/E-mails/_BusinessLeadNotification.cshtml";

            foreach (KeyValuePair<Business, List<LeadItem>> businessLeads in businessesWithLeadsToNotifyAbout)
            {
                Business business = businessLeads.Key;
                foreach (NotificationEmail email in business.notification.emailList)
                {
                    //try
                    //{
                        MailMessageLeadGen message = new MailMessageLeadGen(email.address);
                        message.Subject = mailSubject;
                        message.Body = ViewHelper.RenderViewToString(viewPath, businessLeads);
                        messages.Add(message);
                    //}
                    //catch (Exception e)
                    //{

                    //    throw;
                    //}

                }
            }

            return messages;
        }


        private static Dictionary<Post, List<LeadItem>> GetCompanyPostsWithLeadsToNotifyAbout(SqlConnection connection, DateTime publishedAfter)
        {
            Dictionary<Post, List<LeadItem>> businessPostsWithLeads = new Dictionary<Post, List<LeadItem>>();

            DataView leadNotificationData = GetLeadCompanyPostNotificationDataView(connection, publishedAfter);
            List<LeadItem> leadsToSend = LoadLeadsFromTheNotificationView(connection, leadNotificationData);
            List<Post> businessesSendTo = LoadBusinessesPostsFromTheNotificationView(connection, leadNotificationData);

            foreach (Post post in businessesSendTo)
            {
                List<LeadItem> businessLeads = new List<LeadItem>();
                DataRow[] businessLeadRows = leadNotificationData.ToTable().Select(string.Format("PostID = {0}", post.ID));
                foreach (DataRow businessLeadRow in businessLeadRows)
                {
                    LeadItem lead = leadsToSend.Where(x => x.ID == (long)businessLeadRow["LeadID"]).Select(x => new LeadItem()
                    {
                        ID = x.ID,
                        email = x.email,
                        fieldGroups = x.fieldGroups,
                        adminDetails = x.adminDetails
                    }).First();

                    businessLeads.Add(lead);
                }

                businessPostsWithLeads.Add(post, businessLeads);
            }

            return businessPostsWithLeads;
        }

        private static List<Post> LoadBusinessesPostsFromTheNotificationView(SqlConnection connection, DataView leadNotificationView)
        {
            List<Post> businessPostsSendTo = new List<Post>();
            DataTable distinctBusinessPostsIDs = leadNotificationView.ToTable(true, "PostID");
            foreach (DataRow PostsIDRow in distinctBusinessPostsIDs.Rows)
            {
                Post businessPost = Post.SelectFromDB(connection, postID: (long)PostsIDRow["PostID"]).First();
                businessPost.LoadFields(connection);
                businessPost.LoadTaxonomies(connection, loadTerms: true);

                businessPostsSendTo.Add(businessPost);
            }

            return businessPostsSendTo;
        }

        private static List<MailMessageLeadGen> GenerateEmailBusinessNotificationMessages(Dictionary<Post, List<LeadItem>> businessPostsWithLeadsToNotifyAbout)
        {
            List<MailMessageLeadGen> messages = new List<MailMessageLeadGen>();

            string mailSubject = "Новые заявки";
            string viewPath = "~/Areas/Business/Views/E-mails/_BusinessPostLeadNotification.cshtml";

            foreach (KeyValuePair<Post, List<LeadItem>> businessPostLeads in businessPostsWithLeadsToNotifyAbout)
            {
                try
                {
                    Post businessPost = businessPostLeads.Key;
                    MailMessageLeadGen message = new MailMessageLeadGen(businessPost.getFieldByCode("master_email").fieldText);
                    message.Subject = mailSubject;
                    message.Body = ViewHelper.RenderViewToString(viewPath, businessPostLeads);
                    messages.Add(message);
                }
                catch (Exception e)
                {
                    //May be master_email does not have a valid email
                }
            }

            return messages;
        }

        private static void PostNotifiedAboutLeadSet(SqlConnection con, long businessPostID, long leadID, DateTime? notifiedDateTime = null)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLeadSetNotifiedPost]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessPostID", businessPostID);
                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@NotifiedDateTime", notifiedDateTime ?? DateTime.UtcNow);

                cmd.ExecuteNonQuery();
            }
        }
    }
}
