using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LeadGen.Code.Settings;
using Amazon.S3;
using Amazon.S3.Util;
using Amazon.S3.Model;
using Amazon.S3.Transfer;

namespace LeadGen.Code.Clients
{
    public class AWSS3Client : ICloudStorageClient
    {
        private AWSSettings _awsSettings = null;
        private AmazonS3Client _client = null;

        public AWSS3Client(AWSSettings awsSettings)
        {
            _awsSettings = awsSettings;
            _client = new AmazonS3Client(_awsSettings.AccessKeyID, _awsSettings.AccessKeySecret, Amazon.RegionEndpoint.GetBySystemName(_awsSettings.RegionName));
            if (AmazonS3Util.DoesS3BucketExistAsync(_client, _awsSettings.BucketName).Result == false)
            {
                _client.PutBucketAsync(new PutBucketRequest() {
                    BucketName = _awsSettings.BucketName,
                    UseClientRegion = true
                }).Wait();
            }
        }

        public void SaveFile(Stream fileStream, Uri fileUrl)
        {
            using (TransferUtility fileTranferUtility = new TransferUtility(_client)) {
                fileTranferUtility.Upload(new TransferUtilityUploadRequest() {
                    InputStream = fileStream,
                    BucketName = _awsSettings.BucketName,
                    Key = _getFileKey(fileUrl),
                    CannedACL = S3CannedACL.PublicRead,
                    AutoCloseStream = false
                });
            }
            fileStream.Seek(0, SeekOrigin.Begin);
        }

        public void DeleteFile(Uri fileUrl)
        {
            _client.DeleteObjectAsync(_awsSettings.BucketName, _getFileKey(fileUrl)).Wait();
        }

        private string _getFileKey(Uri fileUrl)
        {
            return fileUrl.ToString().Replace(_awsSettings.BucketHostName, "").TrimStart('/');
        }

        public string GetFileHostName()
        {
            return _awsSettings.BucketHostName.TrimEnd('/');
        }

        public void Dispose()
        {
            _awsSettings = null;
            _client.Dispose();
        }
    }
}
