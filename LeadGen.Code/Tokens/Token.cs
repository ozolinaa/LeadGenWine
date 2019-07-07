using LeadGen.Code.Helpers;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Tokens
{
    public abstract class Token
    {
        [JsonIgnore()]
        public string Key { get; set; }
        
        [JsonIgnore()]
        public DateTime DateCreated { get; set; }

        [JsonIgnore()]
        public string Json => JsonConvert.SerializeObject(this, Formatting.None);


        public Token()
        {
        }

        public static Token BuildToken(DataRow row)
        {
            return BuildToken(row["TokenType"].ToString(), row["TokenKey"].ToString(), row["TokenJson"].ToString(), 
                Convert.ToDateTime(row["TokenDateCreated"]));
        }

        public static Token BuildToken(string typeName, string key, string json, DateTime dateCreated)
        {
            Type parentTokenType = typeof(Token);
            IEnumerable<Type> tokenTypes = AppDomain.CurrentDomain.GetAssemblies()
                .SelectMany(s => s.GetTypes())
                .Where(p => parentTokenType.IsAssignableFrom(p) && p != parentTokenType);

            Type tokenType = tokenTypes.FirstOrDefault(x => x.Name.Equals(typeName, StringComparison.OrdinalIgnoreCase));
            if (tokenType == null)
                throw new ArgumentException(string.Format("Token '{0}' is not inherited from Token abstract class", typeName));


            Token token = JsonConvert.DeserializeObject(json, tokenType) as Token;
            token.Key = key;
            token.DateCreated = dateCreated;
            return token;
        }

        public void CreateInDB(SqlConnection con, string tokenKey = "")
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[SysTokenCreate]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@tokenType", GetType().Name);
                cmd.Parameters.AddWithValue("@tokenJson", Json);
                cmd.Parameters.AddWithValue("@tokenKeySet", string.IsNullOrEmpty(tokenKey) ? (object)DBNull.Value : tokenKey);


                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@tokenKey";
                outputParameter.SqlDbType = SqlDbType.NVarChar;
                outputParameter.Size = 255;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                Key = outputParameter.Value.ToString();
                DateCreated = DateTime.UtcNow;
            }
        }

        public static Token LoadFromDB(SqlConnection con, string tokenKey)
        {
            Token token = null;

            SqlCommand cmd = new SqlCommand("[dbo].[SysTokenSelect]", con);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@tokenKey", tokenKey);

            DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
            if (dt.Rows.Count > 0)
                token = BuildToken(dt.Rows[0]);

            return token;
        }

        public void DeleteFromDB(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[SysTokenDelete]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@tokenKey", Key);

                cmd.ExecuteNonQuery();
            }
        }
        

    }
}
