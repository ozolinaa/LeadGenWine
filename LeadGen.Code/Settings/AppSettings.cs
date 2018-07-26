using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace LeadGen.Code.Settings
{
    public interface IAppSettings
    {
        string SQLConnection { get; }
        decimal DefaultSystemFeePercent { get; }
        string AzureStorageHostName { get; }
        string AzureStorageConnection { get; }
        string GoogleMapsAPIKey { get; }
        EmailSettings EmailSettings { get;  }
    }

    public class AppSettings : IAppSettings
    {
        public string SQLConnection { get; set; }
        public decimal DefaultSystemFeePercent { get; set; }
        public string AzureStorageHostName { get; set; }
        public string AzureStorageConnection { get; set; }
        public string GoogleMapsAPIKey { get; set; }
        public EmailSettings EmailSettings { get; set; }
    }
}
