using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Debug
{
    public class Blob
    {
        public int MyProperty { get; set; }
        public void test()
        {
            string filename = @"D:\OneDrive\Фотографии\Photos\IMG_2616.jpg";

            using (FileStream SourceStream = File.Open(filename, FileMode.OpenOrCreate))
            {
                Uri fileUri = new Uri("https://portal.azure.com/CMS/2016/10/subfolder/testphoto.jpg");
            }

            
        }
    }
}
