using LeadGen.Code.Lead;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Business
{
    public class LeadManager
    {
        private long businessID { get; set; }
        private long loginID { get; set; }
        private SqlConnection con { get; set; }
        public decimal systemFeePercent { get; set; }

        public LeadManager(SqlConnection con, long businessID, long loginID, long? leadID = null)
        {
            this.con = con;
            this.businessID = businessID;
            this.loginID = loginID;
            systemFeePercent = Convert.ToDecimal(Helpers.SysHelper.AppSettings.LeadSettings.SystemFeeDefaultPercent);
        }

        public bool GetContacts(ref LeadItem lead, DateTime? getContactsDateTime = null)
        {
            bool result = GetContacts(lead.ID, getContactsDateTime);

            if (result == true)
                lead.businessDetails.businessContactReceivedDateTime = getContactsDateTime ?? DateTime.UtcNow;

            return result;
        }
        public bool GetContacts(long leadID, DateTime? getContactsDateTime = null)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLeadSetGetContact]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.AddWithValue("@LoginID", loginID);
                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@GetContactDateTime", getContactsDateTime ?? (Object)DBNull.Value);

                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            return result;
        }


        public bool SetCompleted(ref LeadItem lead, decimal orderSum, DateTime? completedDateTime = null)
        {
            bool result = SetCompleted(lead.ID, orderSum, completedDateTime);

            if (result == true)
            {
                lead.businessDetails.businessCompletedDateTime = completedDateTime ?? DateTime.UtcNow;
                lead.businessDetails.orderSum = orderSum;
                lead.businessDetails.systemFeePercent = systemFeePercent;
                lead.businessDetails.leadFee = orderSum * systemFeePercent / 100;
            }

            return result;
        }
        public bool SetCompleted(long leadID, decimal orderSum, DateTime? completedDateTime = null)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLeadSetCompleted]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.AddWithValue("@LoginID", loginID);
                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@OrderSum", orderSum);
                cmd.Parameters.AddWithValue("@SystemFeePercent", systemFeePercent);
                cmd.Parameters.AddWithValue("@CompletedDateTime", completedDateTime ?? (Object)DBNull.Value);
                

                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }
                       
            return result;
        }


        public bool SetNotInterested(ref LeadItem lead, DateTime? notInterestedDateTime = null)
        {
            bool result = SetNotInterested(lead.ID, notInterestedDateTime);

            if (result == true)
                lead.businessDetails.businessNotInterestedDateTime = notInterestedDateTime ?? DateTime.UtcNow;

            return result;
        }
        public bool SetNotInterested(long leadID, DateTime? notInterestedDateTime = null)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLeadSetNotInterested]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.AddWithValue("@LoginID", loginID);
                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@NotInterestedDateTime", notInterestedDateTime ?? (Object)DBNull.Value);


                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            return result;
        }


        public bool SetInterested(ref LeadItem lead)
        {
            bool result = SetInterested(lead.ID);

            if (result == true)
                lead.businessDetails.businessNotInterestedDateTime = null;

            return result;
        }
        public bool SetInterested(long leadID)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLeadSetInterested]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.AddWithValue("@LoginID", loginID);
                cmd.Parameters.AddWithValue("@LeadID", leadID);


                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            return result;
        }


        public bool SetImportant(ref LeadItem lead, DateTime? importantDateTime = null)
        {
            bool result = SetImportant(lead.ID, importantDateTime);
            if (result == true)
                lead.businessDetails.businessImportantDateTime = importantDateTime ?? DateTime.UtcNow;

            return result;
        }
        public bool SetImportant(long leadID, DateTime? importantDateTime = null)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLeadSetImportant]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.AddWithValue("@LoginID", loginID);
                cmd.Parameters.AddWithValue("@LeadID", leadID);
                cmd.Parameters.AddWithValue("@ImportantDateTime", importantDateTime ?? (Object)DBNull.Value);


                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            return result;
        }


        public bool SetNotImportant(ref LeadItem lead)
        {
            bool result = SetNotImportant(lead.ID);

            if (result == true)
                lead.businessDetails.businessImportantDateTime = null;

            return result;
        }
        public bool SetNotImportant(long leadID)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessLeadSetNotImportant]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.AddWithValue("@LoginID", loginID);
                cmd.Parameters.AddWithValue("@LeadID", leadID);

                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            return result;
        }

    }
}
