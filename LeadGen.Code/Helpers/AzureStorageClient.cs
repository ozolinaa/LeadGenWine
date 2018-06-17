using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net.Mime;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Helpers
{
    public class AzureStorageClient : IDisposable
    {
        private CloudBlobClient blobStorage = null;

        public AzureStorageClient()
        {
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(ConfigurationManager.ConnectionStrings["AzureStorageConnection"].ConnectionString);
            blobStorage = storageAccount.CreateCloudBlobClient();
        }


        public void SaveFile(Stream fileStream, Uri fileUrl)
        {
            string cantainerName = fileUrl.Segments[1].Trim('/').ToLower();
            string blobName = string.Join("", fileUrl.Segments.Skip(2)).ToLower();

            CloudBlobContainer cloudBlobContainer = blobStorage.GetContainerReference(cantainerName);
            if (cloudBlobContainer.CreateIfNotExists())
            {
                // configure container for public access
                var permissions = cloudBlobContainer.GetPermissions();
                permissions.PublicAccess = BlobContainerPublicAccessType.Container;
                cloudBlobContainer.SetPermissions(permissions);
            }

            CloudBlockBlob blob = cloudBlobContainer.GetBlockBlobReference(blobName);
            blob.Properties.ContentType = System.Web.MimeMapping.GetMimeMapping(Path.GetFileName(fileUrl.LocalPath));
            blob.UploadFromStream(fileStream);
            fileStream.Seek(0, SeekOrigin.Begin);
        }

        public void DeleteFile(Uri fileUrl)
        {
            string cantainerName = fileUrl.Segments[1].Trim('/').ToLower();
            string blobName = string.Join("", fileUrl.Segments.Skip(2)).ToLower();

            CloudBlobContainer cloudBlobContainer = blobStorage.GetContainerReference(cantainerName);
            if (cloudBlobContainer.CreateIfNotExists())
            {
                // configure container for public access
                var permissions = cloudBlobContainer.GetPermissions();
                permissions.PublicAccess = BlobContainerPublicAccessType.Container;
                cloudBlobContainer.SetPermissions(permissions);
            }

            CloudBlockBlob blob = cloudBlobContainer.GetBlockBlobReference(blobName);
            blob.Delete(DeleteSnapshotsOption.IncludeSnapshots);
        }


        public void Dispose()
        {
            blobStorage = null;
        }
    }
}
