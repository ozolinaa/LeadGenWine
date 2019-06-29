using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Helpers
{
    public static class DBHelper
    {
        public static bool IsColumnExists(this IDataReader dataReader, string columnName)
        {
            bool retVal = false;

            try
            {
                dataReader.GetSchemaTable().DefaultView.RowFilter = string.Format("ColumnName= '{0}'", columnName);
                if (dataReader.GetSchemaTable().DefaultView.Count > 0)
                {
                    retVal = true;
                }
            }
            catch (Exception)
            {
            }

            return retVal;
        }

        public static DataTable ExecuteCommandToDataTable(SqlCommand cmd)
        {
            DataTable dt = new DataTable();
            using (SqlDataReader rdr = cmd.ExecuteReader())
            {
                dt.Load(rdr);
            }
            return dt;
        }

        public static SqlParameter GetNumericTableTypeParamter(string paramterName, string parameterTypeName, IEnumerable<long> values)
        {
            //Create DataTable to pass to stored procedure
            DataTable numericDataTable = new DataTable();
            numericDataTable.Columns.Add("Item", typeof(long));
            foreach (long item in values)
                numericDataTable.Rows.Add(item);

            SqlParameter numericTableTypeParamter = new SqlParameter(paramterName, numericDataTable);
            numericTableTypeParamter.SqlDbType = SqlDbType.Structured;
            numericTableTypeParamter.TypeName = parameterTypeName;

            return numericTableTypeParamter;
        }

        public struct SQLfilter
        {
            public string fieldName;
            public string parameterName;
            public string parameterOperator;
            public object parameterValue;
        }
    }
}
