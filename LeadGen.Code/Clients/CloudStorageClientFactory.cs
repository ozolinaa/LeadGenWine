using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Clients
{
    public static class CloudStorageClientFactory
    {
        public static ICloudStorageClient GetClient()
        {
            if (SysHelper.AppSettings.AWSSettings != null) {
                return new AWSS3Client(SysHelper.AppSettings.AWSSettings);
            } else if (SysHelper.AppSettings.AzureSettings != null) {
                return new AzureStorageClient(SysHelper.AppSettings.AzureSettings);
            }
            throw new Exception("Settings not found for ICloudStorageClient");
        }
    }
}
