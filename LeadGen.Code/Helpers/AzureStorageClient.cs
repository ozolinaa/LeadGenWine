﻿using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.Helpers
{
    public class AzureStorageClient : IDisposable
    {
        private CloudBlobClient blobStorage = null;

        public AzureStorageClient()
        {
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(SysHelper.AppSettings.AzureStorageConnectionString);
            blobStorage = storageAccount.CreateCloudBlobClient();
        }


        public void SaveFile(Stream fileStream, Uri fileUrl)
        {
            string cantainerName = fileUrl.Segments[1].Trim('/').ToLower();
            string blobName = string.Join("", fileUrl.Segments.Skip(2)).ToLower();

            CloudBlobContainer cloudBlobContainer = blobStorage.GetContainerReference(cantainerName);
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

            CloudBlobContainer cloudBlobContainer = blobStorage.GetContainerReference(cantainerName);
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


        public void Dispose()
        {
            blobStorage = null;
        }
    }
}
