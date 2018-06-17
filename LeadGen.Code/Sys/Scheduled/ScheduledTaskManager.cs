using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Sys.Scheduled
{
    public class ScheduledTaskManager
    {
        private string DBLGconString;

        public enum KnownScheduledTask
        {
            SendQueuedMail = 1,
        };

        public ScheduledTask SelectNextTask(SqlConnection con)
        {
            ScheduledTask scheduledTask = null;

            using (SqlCommand cmd = new SqlCommand("[dbo].[System.ScheduledTasks.SelectCurrentTasks]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);

                foreach (DataRow taksRow in dt.Rows)
                {
                    scheduledTask = GetScheduledTaskByName((string)taksRow["TaksName"]);
                }
            }

            return scheduledTask;
        }


        public ScheduledTask GetScheduledTaskByName(string taskName)
        {
            Type type = typeof(ScheduledTask);
            IEnumerable<Type> childTypes = AppDomain.CurrentDomain.GetAssemblies()
                .SelectMany(s => s.GetTypes())
                .Where(p => type.IsAssignableFrom(p) && p != type);

            Type scheduledTaskType = childTypes.FirstOrDefault(x => x.Name.ToLower() == taskName.ToLower());
            if (scheduledTaskType == null)
                throw new ArgumentException(string.Format("Task '{0}' is not inherited from ScheduledTask abstract class", taskName));


            ScheduledTask taskInstance = (ScheduledTask)Activator.CreateInstance(scheduledTaskType, new object[] { DBLGconString });
            return taskInstance;
        }

        public ScheduledTaskManager(string connectionString)
        {
            DBLGconString = connectionString;
        }

    }
}
