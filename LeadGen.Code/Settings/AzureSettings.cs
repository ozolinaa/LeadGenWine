using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Settings
{
    public class AWSSettings
    {
        public string AccessKeyID { get; set; }
        public string AccessKeySecret { get; set; }
        public string RegionName { get; set; }
        public string BucketName { get; set; }
        public string BucketHostName { get; set; }
    }
}
