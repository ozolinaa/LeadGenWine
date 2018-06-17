using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static LeadGen.Code.Sys.Scheduled.ScheduledTaskManager;

namespace LeadGen.Code.Sys.Scheduled
{
    public abstract class ScheduledTask
    {
        public string TaskName { get { return GetType().Name; } }

        protected string _DBLGconString;

        public ScheduledTask(string DBLGconString)
        {
            _DBLGconString = DBLGconString;
        }

        private void SetStarted(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[System.ScheduledTasks.SetStarted]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TaskName", TaskName);
                cmd.ExecuteNonQuery();
            }
        }

        private void SetCompleted(SqlConnection con, string status, string message)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[System.ScheduledTasks.SetCompleted]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TaskName", TaskName);
                cmd.Parameters.AddWithValue("@Status", status);
                cmd.Parameters.AddWithValue("@Message", message);
                cmd.ExecuteNonQuery();
            }
        }

        protected virtual string RunInternal(SqlConnection con)
        {
            throw new NotImplementedException(string.Format("Task '{0}' was not processed (RunInternal is not overriden)", TaskName.ToString()));
        }

        public void Run()
        {
            using (SqlConnection con = new SqlConnection(_DBLGconString))
            {
                con.Open();

                string status = "Completed";
                string message = "";

                try
                {
                    SetStarted(con);
                    try
                    {
                        message = RunInternal(con);
                    }
                    catch (Exception ex)
                    {
                        status = "Error";
                        message = ex.Message;
                    }
                    finally
                    {
                        SetCompleted(con, status, message);
                    }
                }
                catch (Exception ex)
                {
                    //Can not start the task (probably because it is already running)
                } 
            }
        }
    }
}
