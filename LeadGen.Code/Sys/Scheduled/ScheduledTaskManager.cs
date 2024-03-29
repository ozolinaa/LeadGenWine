﻿using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using X.PagedList;

namespace LeadGen.Code.Sys.Scheduled
{
    public class ScheduledTaskManager
    {
        public ScheduledTask SelectNextTask(SqlConnection con)
        {
            ScheduledTask scheduledTask = null;

            using (SqlCommand cmd = new SqlCommand("[dbo].[SystemScheduledTasksSelectCurrentTasks]", con))
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

        public static IPagedList<DataRow> SystemScheduledTaskLogSelect(SqlConnection con, int page = 1, int pageSize = Int32.MaxValue)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[SystemScheduledTaskLogSelect]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Offset", pageSize * (page - 1));
                cmd.Parameters.AddWithValue("@Fetch", pageSize);

                SqlParameter totalCountParameter = new SqlParameter();
                totalCountParameter.ParameterName = "@TotalCount";
                totalCountParameter.SqlDbType = SqlDbType.Int;
                totalCountParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(totalCountParameter);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                return new StaticPagedList<DataRow>(dt.Rows.Cast<DataRow>(), page, pageSize, (int)totalCountParameter.Value);
            }
        }


        public static ScheduledTask GetScheduledTaskByName(string taskName)
        {
            Type type = typeof(ScheduledTask);
            IEnumerable<Type> childTypes = AppDomain.CurrentDomain.GetAssemblies()
                .SelectMany(s => s.GetTypes())
                .Where(p => type.IsAssignableFrom(p) && p != type);

            Type scheduledTaskType = childTypes.FirstOrDefault(x => x.Name.ToLower() == taskName.ToLower());
            if (scheduledTaskType == null)
                throw new ArgumentException(string.Format("Task '{0}' is not inherited from ScheduledTask abstract class", taskName));

            ScheduledTask taskInstance = (ScheduledTask)Activator.CreateInstance(scheduledTaskType);
            return taskInstance;
        }

        public static void RunTasksInNewThread(List<Type> types)
        {
            // Validate type names in the same thread
            List<ScheduledTask> scheduledTasks = new List<ScheduledTask>();
            types.ForEach(x => scheduledTasks.Add(GetScheduledTaskByName(x.Name)));

            // Sequentially run ScheduledTask a separate thread
            Task.Factory.StartNew(() => {
                foreach (ScheduledTask scheduledTask in scheduledTasks)
                {
                    scheduledTask.Run();
                }
            });
        }
    }
}
