using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Importer.EPESI
{
    public class Group
    {
        public string code { get; set; }
        public string name { get; set; }
        public Group child { get; set; }

        public Group(string groupCompoundKey, Dictionary<string, string> availebleGroups)
        {
            string[] groupKeyParts = groupCompoundKey.Split('/');

            code = groupKeyParts[0];
            name = availebleGroups[groupKeyParts[0]];

            //If there is a "/" char, repeat the process for the child and the next piece (skip the first / part)
            if (groupKeyParts.Count() > 1)
                child = new Group(string.Join("/", groupKeyParts.Skip(1)), availebleGroups);
        }

        public Group(string code, string name = "")
        {
            this.code = code;
            this.name = String.IsNullOrEmpty(name) ? code : name;
        }

        public override string ToString()
        {
            if (child == null)
                return code;
            else
                return code + "/" + child.ToString();
        }

    }
}
