using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LeadGen.Code.Helpers;
using LeadGen.Code.Settings;

namespace LeadGen.Code.Clients
{
    public class AzureStorageClient : ICloudStorageClient
    {
        private AzureSettings _azureSettings = null;
        private CloudBlobClient _client = null;

        public AzureStorageClient(AzureSettings azureSettings)
        {
            _azureSettings = azureSettings;
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(_azureSettings.StorageConnectionString);
            _client = storageAccount.CreateCloudBlobClient();
        }


        public void SaveFile(Stream fileStream, Uri fileUrl)
        {
            string cantainerName = fileUrl.Segments[1].Trim('/').ToLower();
            string blobName = string.Join("", fileUrl.Segments.Skip(2)).ToLower();

            CloudBlobContainer cloudBlobContainer = _client.GetContainerReference(cantainerName);
            if (cloudBlobContainer.CreateIfNotExistsAsync().Result)
            {
                // configure container for public access
                var permissions = cloudBlobContainer.GetPermissionsAsync().Result;
                permissions.PublicAccess = BlobContainerPublicAccessType.Container;
                cloudBlobContainer.SetPermissionsAsync(permissions).Wait();
            }

            CloudBlockBlob blob = cloudBlobContainer.GetBlockBlobReference(blobName);

            blob.Properties.ContentType = SysHelper.GetFileContentType(Path.GetFileName(fileUrl.LocalPath));
            blob.UploadFromStreamAsync(fileStream).Wait();
            fileStream.Seek(0, SeekOrigin.Begin);
        }

        public void DeleteFile(Uri fileUrl)
        {
            string cantainerName = fileUrl.Segments[1].Trim('/').ToLower();
            string blobName = string.Join("", fileUrl.Segments.Skip(2)).ToLower();

            CloudBlobContainer cloudBlobContainer = _client.GetContainerReference(cantainerName);
            if (cloudBlobContainer.CreateIfNotExistsAsync().Result)
            {
                // configure container for public access
                var permissions = cloudBlobContainer.GetPermissionsAsync().Result;
                permissions.PublicAccess = BlobContainerPublicAccessType.Container;
                cloudBlobContainer.SetPermissionsAsync(permissions).Wait();
            }

            CloudBlockBlob blob = cloudBlobContainer.GetBlockBlobReference(blobName);
            blob.DeleteAsync().Wait();
        }

        public string GetFileHostName()
        {
            return _azureSettings.StorageHostName.Trim('/');
        }

        public void Dispose()
        {
            _azureSettings = null;
            _client = null;
        }
    }
}
