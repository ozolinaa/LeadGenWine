using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Settings
{

    public struct LeadSettings
    {
        public bool ApprovalLocationEnabled { get; set; }
        public bool ApprovalPermissionEnabled { get; set; }
        public decimal SystemFeeDefaultPercent { get; set; }
        public string FieldMappingEmail { get; set; }
        public string FieldMappingDateDue { get; set; }
        public string FieldMappingLocationZip { get; set; }
        public string FieldMappingLocationRadius { get; set; }
    }
}
