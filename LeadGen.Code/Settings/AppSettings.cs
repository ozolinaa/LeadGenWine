using LeadGen.Code.Helpers;
using LeadGen.Code.Sys;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace LeadGen.Code.Settings
{
    public interface IAppSettings
    {
        string SQLConnectionString { get; }
        string SystemAccessToken { get; }
        AzureSettings AzureSettings { get; }
        AWSSettings AWSSettings { get; }
        EmailSettings EmailSettings { get;  }
        LeadSettings LeadSettings { get; }
        CMSSettings CMSSettings { get; }
        GoogleSettings GoogleSettings { get; }

        void ReloadAppSettingsFromDB(SqlConnection con);
    }

    public class AppSettings : IAppSettings
    {
        private string _sqlConnectionString;
        private string _systemAccessToken;
        private AzureSettings _azureSettings;
        private AWSSettings _awsSettings;
        private CMSSettings _cmsSettings;
        private EmailSettings _emailSettings;
        private LeadSettings _leadSettings;
        private GoogleSettings _googleSettings;
        private CRMSettings _crmSettings;

        public string SQLConnectionString { get { return _sqlConnectionString; }  }
        public string SystemAccessToken { get { return _systemAccessToken; } }


        public AzureSettings AzureSettings { get { return _azureSettings; } }
        public AWSSettings AWSSettings { get { return _awsSettings; } }
        public EmailSettings EmailSettings { get { return _emailSettings; } }
        public LeadSettings LeadSettings { get { return _leadSettings; } }
        public CMSSettings CMSSettings { get { return _cmsSettings; } }
        public GoogleSettings GoogleSettings { get { return _googleSettings; } }
        public CRMSettings CRMSettings { get { return _crmSettings; } }


        public AppSettings(ICoreSettings coreSettings)
        {
            _sqlConnectionString = Environment.GetEnvironmentVariable("sqlConnectionString");
            if (string.IsNullOrEmpty(_sqlConnectionString))
                _sqlConnectionString = coreSettings.SQLConnectionString;

            using (SqlConnection con = new SqlConnection(_sqlConnectionString))
            {
                con.Open();
                _initSettingOptionsInDB(con);
                ReloadAppSettingsFromDB(con);
            }
        }

        private void _initSettingOptionsInDB(SqlConnection con)
        {
            Dictionary<string, Option> settingOptions = Option.SelectFromDB(con);
            foreach (Option.SettingKey sKey in Enum.GetValues(typeof(Option.SettingKey)))
            {
                if (!settingOptions.ContainsKey(sKey.ToString()))
                {
                    Option option = new Option() { key = sKey.ToString() };
                    option.Update(con);
                }
            }
        }

        public void ReloadAppSettingsFromDB(SqlConnection con)
        {
            Dictionary<string, Option> settingOptions = Option.SelectFromDB(con);

            settingOptions.TryGetValue(Option.SettingKey.GoogleMapsAPIPublicKey.ToString(), out Option googleMapsAPIPublicKeyOption);
            settingOptions.TryGetValue(Option.SettingKey.GoogleMapsAPIServerKey.ToString(), out Option googleMapsAPIServerKeyOption);
            _googleSettings = new GoogleSettings()
            {
                GoogleMapsAPIPublicKey = googleMapsAPIPublicKeyOption?.value,
                GoogleMapsAPIServerKey = googleMapsAPIServerKeyOption?.value
            };

            Option tmpOption;
            if (settingOptions.TryGetValue(Option.SettingKey.SystemAccessToken.ToString(), out tmpOption))
                _systemAccessToken = string.IsNullOrEmpty(tmpOption.value) ? null : tmpOption.value;

            if (settingOptions.ContainsKey(Option.SettingKey.AzureStorageHostName.ToString()) && settingOptions.ContainsKey(Option.SettingKey.AzureStorageConnectionString.ToString())) {
                _azureSettings = new AzureSettings()
                {
                    StorageHostName = settingOptions[Option.SettingKey.AzureStorageHostName.ToString()].value,
                    StorageConnectionString = settingOptions[Option.SettingKey.AzureStorageConnectionString.ToString()].value,
                };
            }

            if (settingOptions.ContainsKey(Option.SettingKey.AWSAccessKeyID.ToString()) 
                && settingOptions.ContainsKey(Option.SettingKey.AWSAccessKeySecret.ToString())
                && settingOptions.ContainsKey(Option.SettingKey.AWSRegionName.ToString())
                && settingOptions.ContainsKey(Option.SettingKey.AWSs3BucketName.ToString())
                && settingOptions.ContainsKey(Option.SettingKey.AWSs3BucketHostName.ToString()))
            {
                _awsSettings = new AWSSettings()
                {
                    AccessKeyID = settingOptions[Option.SettingKey.AWSAccessKeyID.ToString()].value,
                    AccessKeySecret = settingOptions[Option.SettingKey.AWSAccessKeySecret.ToString()].value,
                    RegionName = settingOptions[Option.SettingKey.AWSRegionName.ToString()].value,
                    BucketName = settingOptions[Option.SettingKey.AWSs3BucketName.ToString()].value,
                    BucketHostName = settingOptions[Option.SettingKey.AWSs3BucketHostName.ToString()].value
                };
            }

            int.TryParse(settingOptions[Option.SettingKey.EmailSmtpSendIntervalMilliseconds.ToString()].value, out int emailSmtpSendIntervalMilliseconds);

            int emailSmtpPort = 0;
            int.TryParse(settingOptions[Option.SettingKey.EmailSmtpPort.ToString()].value, out emailSmtpPort);

            _emailSettings = new EmailSettings()
            {
                FromAddress = settingOptions[Option.SettingKey.EmailFromAddress.ToString()].value,
                FromName = settingOptions[Option.SettingKey.EmailFromName.ToString()].value,
                ReplyToAddress = settingOptions[Option.SettingKey.EmailReplyToAddress.ToString()].value,
                SmtpSettings = new SmtpSettings() {
                    SendIntervalMilliseconds = emailSmtpSendIntervalMilliseconds,
                    Host = settingOptions[Option.SettingKey.EmailSmtpHost.ToString()].value,
                    Port = emailSmtpPort,
                    UserName = settingOptions[Option.SettingKey.EmailSmtpUserName.ToString()].value,
                    Password = settingOptions[Option.SettingKey.EmailSmtpPassword.ToString()].value,
                    EnableSsl = SysHelper.ConvertToBoolean(settingOptions[Option.SettingKey.EmailSmtpEnableSsl.ToString()].value)
                }
            };

            _leadSettings = new LeadSettings()
            {
                SystemFeeDefaultPercent = SysHelper.CovertToDecimal(settingOptions[Option.SettingKey.LeadSystemFeeDefaultPercent.ToString()].value),
                ApprovalLocationEnabled = SysHelper.ConvertToBoolean(settingOptions[Option.SettingKey.LeadApprovalLocationEnabled.ToString()].value),
                ApprovalPermissionEnabled = SysHelper.ConvertToBoolean(settingOptions[Option.SettingKey.LeadApprovalPermissionEnabled.ToString()].value),
                FieldMappingEmail = settingOptions[Option.SettingKey.LeadFieldMappingEmail.ToString()].value,
                FieldMappingDateDue = settingOptions[Option.SettingKey.LeadFieldMappingDateDue.ToString()].value,
                FieldMappingLocationRadius = settingOptions[Option.SettingKey.LeadFieldMappingLocationRadius.ToString()].value,
                FieldMappingLocationZip = settingOptions[Option.SettingKey.LeadFieldMappingLocationZip.ToString()].value
            };

            settingOptions.TryGetValue(Option.SettingKey.CMSHtmlHeadInjection.ToString(), out Option cmsHtmlHeadInjectionOption);
            settingOptions.TryGetValue(Option.SettingKey.CMSRobotsTXT.ToString(), out Option cmsRobotsTXTOption);

            _cmsSettings = new CMSSettings()
            {
                HtmlHeadInjection = cmsHtmlHeadInjectionOption?.value?.ToString(),
                RobotsTXT = cmsRobotsTXTOption?.value?.ToString()
            };

            settingOptions.TryGetValue(Option.SettingKey.CRMDBConnectionString.ToString(), out Option crmDBConnectionStringOption);
            _crmSettings = new CRMSettings()
            {
                DBConnectionString = crmDBConnectionStringOption?.value
            };
        }
    }


}
