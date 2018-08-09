using System;
using System.Collections.Generic;
using System.Text;

namespace LeadGen.Code.Settings
{
    public interface ICoreSettings
    {
        string SQLConnectionString { get; }

    }

    public class CoreSettings : ICoreSettings
    {
        public string SQLConnectionString { get; set; }
    }
}
