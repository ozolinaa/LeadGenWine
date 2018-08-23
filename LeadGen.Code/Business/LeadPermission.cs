using LeadGen.Code.Helpers;
using LeadGen.Code.Taxonomy;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Business
{
    public class LeadPermittion
    {
        public long? ID { get; set; }
        public DateTime? requestedDateTime { get; set; }
        public DateTime? approvedDateTime { get; set; }
        public List<Term> terms { get; set; }

        public LeadPermittion() { }

        public LeadPermittion(DataRow permissionRow, DataRow[] termDataRows)
        {
            ID = (long)permissionRow["PermissionID"];
            requestedDateTime = (DateTime?)(permissionRow["RequestedDateTime"] == DBNull.Value ? null : permissionRow["RequestedDateTime"]);
            approvedDateTime = (DateTime?)(permissionRow["ApprovedDateTime"] == DBNull.Value ? null : permissionRow["ApprovedDateTime"]);

            terms = new List<Term>();
            foreach (DataRow row in termDataRows)
            {
                terms.Add(new Term(row));
            }
        }



        public bool AddRequestToDB(SqlConnection con, long businessID) 
        {
            ID = null;

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessPermissionRequest]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.Add(DBHelper.GetNumericTableTypeParamter("@TermIDTable", "[dbo].[SysBigintTableType]", terms.Select(x=>x.ID).Distinct()));

                SqlParameter permissionIDParameter = new SqlParameter();
                permissionIDParameter.ParameterName = "@PermissionID";
                permissionIDParameter.SqlDbType = SqlDbType.BigInt;
                permissionIDParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(permissionIDParameter);

                cmd.ExecuteNonQuery();

                ID = (long?)(permissionIDParameter.Value);
                if (ID != null)
                    requestedDateTime = DateTime.UtcNow;
            }

            // return TRUE if ID != null;
            return ID != null;
        }

        public bool RemoveRequestFromDB(SqlConnection con, long businessID)
        {
            bool result = false;
            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessPermissionRemoveRequest]", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BusinessID", businessID);
                cmd.Parameters.AddWithValue("@PermissionID", ID);

                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@retValue";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();

                result = Convert.ToBoolean(returnParameter.Value);
            }

            return result;
        }

        public bool Approve(SqlConnection con, long loginID)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessPermissionApprove]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LoginID", loginID);
                cmd.Parameters.AddWithValue("@PermissionID", ID);
                
                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            if (result == true)
                approvedDateTime = DateTime.UtcNow;

            return result;
        }

        public bool ApproveCancel(SqlConnection con, long loginID)
        {
            bool result;

            using (SqlCommand cmd = new SqlCommand("[dbo].[BusinessPermissionCancelApprove]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LoginID", loginID);
                cmd.Parameters.AddWithValue("@PermissionID", ID);

                SqlParameter returnParameter = new SqlParameter();
                returnParameter.ParameterName = "@Result";
                returnParameter.SqlDbType = SqlDbType.Bit;
                returnParameter.Direction = ParameterDirection.ReturnValue;
                cmd.Parameters.Add(returnParameter);

                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(returnParameter.Value);
            }

            if (result == true)
                approvedDateTime = null;

            return result;
        }

    }
}
