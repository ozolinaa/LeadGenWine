using LeadGen.Code;
using LeadGen.Code.Clients.CRM;
using LeadGen.Code.Clients;
using LeadGen.Code.Helpers;
using LeadGen.Debugger.Docker;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace LeadGen.Debugger
{
    class Program
    {
        static void Main(string[] args)
        {
            ParseRun();
            Console.ReadLine();
        }

        private static void ParseRun()
        {
            using (WebOrgParser parser = new WebOrgParser())
            {
                var rrr = parser.ParseOrganizations(new Uri("https://www.houzz.com/professionals/wine-cellars/los-angeles"));
                ;
            }
        }
    }
}
