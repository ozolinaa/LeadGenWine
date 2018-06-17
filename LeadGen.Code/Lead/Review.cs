using LeadGen.Code.Helpers;
using LeadGen.Code.Sys;
using PagedList;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace LeadGen.Code.Lead
{
    public class Review
    {
        public enum Status
        {
            New,
            Published
        }

        public static Dictionary<Status, string> statusDictionary = new Dictionary<Status, string>() {
            { Status.New, "New" },
            { Status.Published, "Published" }
        };

        public enum Measure
        {
            Price = 1,
            Quality = 2,
            Speed = 3,
            Comfort = 4
        }
        public long leadID { get; set; }
        public DateTime reviewDateTime { get; set; }
        public DateTime? publishedDateTime { get; set; }
        public string authorName { get; set; }

        [AllowHtml]
        public string reviewText { get; set; }
        public Dictionary<Measure, Int16> measureScores { get; set; }
        public List<Business.Business> businessOptions { get; set; }
        public bool? otherBusiness { get; set; }
        public bool? notCompleted { get; set; }
        public long? businessID { get; set; }
        public string otherBusinessName { get; set; }
        public decimal? orderPricePart1 { get; set; }
        public decimal? orderPricePart2 { get; set; }

        public Review() { }
        public Review(long leadID)
        {
            this.leadID = leadID;
            reviewDateTime = DateTime.UtcNow;
        }
        public Review(DataRow reviewRow)
        {
            leadID = (long)reviewRow["LeadID"];
            businessID = null;
            if (reviewRow["BusinessID"] != DBNull.Value)
                businessID = (long)reviewRow["BusinessID"];
            publishedDateTime = null;
            if (reviewRow["PublishedDateTime"] != DBNull.Value)
                publishedDateTime = Convert.ToDateTime(reviewRow["PublishedDateTime"]);
            reviewDateTime = Convert.ToDateTime(reviewRow["ReviewDateTime"]);
            authorName = reviewRow["AuthorName"].ToString();
            reviewText = reviewRow["ReviewText"].ToString();
            otherBusinessName = reviewRow["OtherBusinessName"].ToString();
            if (businessID == null && string.IsNullOrEmpty(otherBusinessName) == false)
                otherBusiness = true;
            orderPricePart1 = null;
            if (reviewRow["OrderPricePart1"] != DBNull.Value)
                orderPricePart1 =  (decimal)reviewRow["OrderPricePart1"];
            orderPricePart2 = null;
            if (reviewRow["OrderPricePart2"] != DBNull.Value)
                orderPricePart2 = (decimal)reviewRow["OrderPricePart2"];

            if (businessID == null && (otherBusiness ?? false == false))
                notCompleted = true;
        }
        public Review(DataRow reviewRow, DataRow[] measureRows) : this(reviewRow)
        {
            InitializeMeasureScores(measureRows);
        }

        public static StaticPagedList<Review> SelectFromDB(SqlConnection connection, 
            long? leadID = null, 
            long? businessID = null, 
            DateTime? dateFrom = null, 
            DateTime? dateTo = null, 
            bool? published = true, 
            int page = 1,
            int pageSize = Int32.MaxValue)
        {
            List<Review> reviewsList = new List<Review>();
            int totalCount = 0;
            DataTable reviewsData = null;
            using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.Review.Select]", connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", leadID ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@BusinessID", businessID ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@DateFrom", dateFrom ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@DateTo", dateTo ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Published", (object)published ?? DBNull.Value);

                cmd.Parameters.AddWithValue("@Offset", pageSize * (page - 1));
                cmd.Parameters.AddWithValue("@Fetch", pageSize);

                SqlParameter totalCountParameter = new SqlParameter();
                totalCountParameter.ParameterName = "@TotalCount";
                totalCountParameter.SqlDbType = SqlDbType.Int;
                totalCountParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(totalCountParameter);

                reviewsData = DBHelper.ExecuteCommandToDataTable(cmd);
                totalCount = (int)totalCountParameter.Value;
            }

            DataView view = new DataView(reviewsData);
            DataTable distinctReviews = view.ToTable(true, "LeadID", "BusinessID", "ReviewDateTime", "PublishedDateTime", "AuthorName", "ReviewText", "OtherBusinessName", "OrderPricePart1", "OrderPricePart2");
            foreach (DataRow reviewRow in distinctReviews.Rows)
            {
                DataRow[] measureRows = reviewsData.Select(string.Format("LeadID = {0} AND MeasureID IS NOT NULL", reviewRow["LeadID"]));
                reviewsList.Add(new Review(reviewRow, measureRows));
            }

            return new StaticPagedList<Review>(reviewsList, page, pageSize, totalCount);
        }

        public void LoadMeasures(SqlConnection connection)
        {
            DataTable dt = null;
            using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.Review.Measure.Select]", connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LeadID", leadID);
                dt = DBHelper.ExecuteCommandToDataTable(cmd);
            }
            InitializeMeasureScores(dt.Select());
        }

        private void InitializeMeasureScores(IEnumerable<DataRow> measureRows)
        {
            measureScores = new Dictionary<Measure, Int16>();
            foreach (DataRow measureRow in measureRows)
                measureScores.Add((Measure)(Int16)measureRow["MeasureID"], (Int16)measureRow["Score"]);
        }

        public void LoadBusinessOptions(SqlConnection connection, bool setDefaultBusinessID = false)
        {
            businessOptions = new List<Business.Business>();

            DataTable dt = null;
            using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.Review.SelectBuisnessOptions]", connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LeadID", leadID);
                dt = DBHelper.ExecuteCommandToDataTable(cmd);
            }
            foreach (DataRow row in dt.Rows)
            {
                Business.Business business = new Business.Business(row);
                businessOptions.Add(business);
                if (setDefaultBusinessID == true && businessID == null && row["CompletedDateTime"] != DBNull.Value)
                    businessID = business.ID;
            }
        }

        public void SaveInDB(SqlConnection connection)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.Review.Save]", connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@ReviewDateTime", reviewDateTime);
                cmd.Parameters.AddWithValue("@BusinessID", businessID ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@OtherBusinessName", string.IsNullOrEmpty(otherBusinessName) ? (object)DBNull.Value : otherBusinessName);
                cmd.Parameters.AddWithValue("@AuthorName", string.IsNullOrEmpty(authorName) ? (object)DBNull.Value : authorName);
                cmd.Parameters.AddWithValue("@ReviewText", string.IsNullOrEmpty(reviewText) ? (object)DBNull.Value : reviewText);
                cmd.Parameters.AddWithValue("@OrderPricePart1", orderPricePart1 ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@OrderPricePart2", orderPricePart2 ?? (object)DBNull.Value);

                cmd.ExecuteNonQuery();
            }

            SaveMeasuresInDB(connection);
        }

        private void SaveMeasuresInDB(SqlConnection connection)
        {
            if (measureScores == null)
                return;

            using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.Review.Measure.Score.DeleteAll]", connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.ExecuteNonQuery();
            }

            foreach (KeyValuePair<Measure, short> item in measureScores)
            {
                if (item.Value < 1)
                    continue;

                using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.Review.Measure.Score.Insert]", connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@LeadID", leadID);
                    cmd.Parameters.AddWithValue("@MeasureID", (short)(int)item.Key);
                    cmd.Parameters.AddWithValue("@Score", item.Value);

                    cmd.ExecuteNonQuery();
                }
            }

        }

        public void scheduleReviewRequestAfterDays(SqlConnection connection, int days)
        {
            LeadItem leadItem = LeadItem.SelectFromDB(connection, leadID: leadID, loadFieldValues: true).First();
            QueueMailMessage message = Notification.NotificationManager.ReviewRequestGenerateEmailMessages(connection, new List<LeadItem>() { leadItem }).First();
            message.QueueToDB(connection, DateTime.UtcNow.AddDays(days));
        }

        public bool Publish(SqlConnection con, long loginID)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.Review.Publish]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@LoginID", loginID);

                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            if (result == true)
                publishedDateTime = DateTime.UtcNow;

            return result;
        }

        public bool UnPublish(SqlConnection con, long loginID)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[Lead.Review.UnPublish]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@LoginID", loginID);

                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            if (result == true)
                publishedDateTime = null;

            return result;
        }

        public void adjustProvidedStarValues()
        {
            //Multiply measureScores by 2 (as we have only 5 stars but store scores 0 to 10)
            foreach (Measure measure in measureScores.Keys.ToArray())
                measureScores[measure] = (short)(measureScores[measure] * 2);
        }


    }
}
