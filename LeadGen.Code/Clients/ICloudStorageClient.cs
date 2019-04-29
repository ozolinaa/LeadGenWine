using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace LeadGen.Code.Clients
{
    public interface ICloudStorageClient : IDisposable
    {
        void SaveFile(Stream fileStream, Uri fileUrl);
        void DeleteFile(Uri fileUrl);
        string GetFileHostName();
    }
}
