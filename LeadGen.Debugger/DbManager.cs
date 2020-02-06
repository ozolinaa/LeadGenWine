using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Smo;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Text;

namespace LeadGen.Debugger
{
    public class DbManager
    {
        private readonly SqlConnection _con;


        public DbManager(SqlConnection con)
        {
            _con = con;
        }

        public void RecreateIzgPamDatabase()
        {
            Console.WriteLine("Recreating Database Started");
            string path = @"D:\Code\LeadGenWine\LeadGen.Code\SQL\";
            string[] filePaths = new string[] {
                path+"LeadGenDB_drop.sql",
                path+"LeadGenDB.sql",
                path+"LeadGenDB_seed.sql",
            };

            foreach (string filePath in filePaths)
            {
                FileInfo fileInfo = new FileInfo(filePath);
                string script = fileInfo.OpenText().ReadToEnd();
                Server server = new Server(new ServerConnection(_con));
                server.ConnectionContext.ExecuteNonQuery(script);
            }
            Console.WriteLine("Recreating Database Finished");
        }

    }
}
