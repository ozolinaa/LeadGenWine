using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace LeadGen.Code
{
    public interface IAppSettings
    {
        string DefaultSystemFeePercent { get; }
        string AzureStorageConnection { get; }
        string GoogleMapsAPIKey { get; }
        string AzureStorageHostName { get; }
        string AmazonSESMailIntervalMilliseconds { get; }
        string EmailDefaultFromAddress { get; }
        string EmailDefaultFromName { get; }
        string EmailDefaultReplyToAddress { get; }
        string SQLConnectionString { get; }
    }

    public class AppSettings : IAppSettings
    {
        public string DefaultSystemFeePercent { get; set; }
        public string AzureStorageConnection { get; set; }
        public string GoogleMapsAPIKey { get; set; }
        public string AzureStorageHostName { get; set; }
        public string AmazonSESMailIntervalMilliseconds { get; set; }
        public string EmailDefaultFromAddress { get; set; }
        public string EmailDefaultFromName { get; set; }
        public string EmailDefaultReplyToAddress { get; set; }
        public string SQLConnectionString { get; set; }
    }
}
