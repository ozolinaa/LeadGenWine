using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;

namespace LeadGen.Debugger.Docker
{
    public class ImageTagViewer
    {
        public static List<ImageTag> List(string dockerImage)
        {
            using (HttpClient client = new HttpClient())
            {
                //xtonyx/leadgenweb
                string path = string.Format("https://hub.docker.com/v2/repositories/{0}/tags/", dockerImage);
                HttpResponseMessage response = client.GetAsync(path).Result;
                if (response.IsSuccessStatusCode)
                {
                    string jsonString = response.Content.ReadAsStringAsync().Result;
                    ImageTagResponse imageTagResponse = JsonConvert.DeserializeObject<ImageTagResponse>(jsonString);
                    return imageTagResponse.results;
                }
            }
            return null;
        }
    }
}
