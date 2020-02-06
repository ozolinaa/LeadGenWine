using LeadGen.Debugger.Docker;
using Renci.SshNet;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;

namespace LeadGen.Debugger
{
    public class ServerManager : IDisposable
    {
        private string password = null;
        private SshClient _client = null;

        public ServerManager(string host, string user, string password)
        {
            this.password = password;
            _client = new SshClient(host, user, this.password);
            _client.Connect();
        }

        private string _directory = null;

        public void RunCommand(string commandStr)
        {
            if (!string.IsNullOrEmpty(_directory))
                commandStr = string.Format("cd {0}; {1}", _directory, commandStr);

            Console.WriteLine(commandStr);
            SshCommand command = _client.RunCommand(commandStr);
            string responseString = command.Error.ToString() + command.Result.ToString();
            Console.WriteLine(responseString);
        }

        public void NavigateToDirecotry(string directory)
        {
            _directory = directory;
        }

        public void RunAaRemoveUnknown()
        {
            // sudo aa-remove-unknown //https://stackoverflow.com/questions/49104733/docker-on-ubuntu-16-04-error-when-killing-container

            var modes = new Dictionary<Renci.SshNet.Common.TerminalModes, uint>();

            using (var stream = _client.CreateShellStream("xterm", 255, 50, 800, 600, 1024, modes))
            {
                stream.Write("sudo aa-remove-unknown\n");
                var t1 = stream.Expect("password");
                Thread.Sleep(1000);
                stream.Write(string.Format("{0}\n", password));
                Thread.Sleep(1000);
            }
        }

        public void DockerComposeUpdateService(string serviceName)
        {
            RunCommand(string.Format("docker-compose pull {0}", serviceName));
            RunAaRemoveUnknown();
            RunCommand(string.Format("docker-compose up -d --no-deps --build {0}", serviceName));
            RunCommand("docker rmi $(docker images -a -q)"); //clean unused images
        }

        public void DeployLatestDockerContainer(string containerName,string imageName)
        {
            Console.WriteLine("DeployLatestDockerContainer started");

            List<ImageTag> imageTags = ImageTagViewer.List(imageName);
            ImageTag tag = imageTags.OrderByDescending(x => x.last_updated).First();

            _client.RunCommand(string.Format("docker stop {0}", containerName));
            _client.RunCommand(string.Format("docker rm {0}", containerName));
            _client.RunCommand("docker rmi $(docker images -a -q)");
            _client.RunCommand(string.Format("docker run -d --net=isolated_network --restart=unless-stopped -p 8080:80 -e sqlConnectionString='Data Source=mssql;Initial Catalog=WineLeadGen;User ID=sa;Password=pass@word1;' --name {0} {1}:{2}", containerName, imageName, tag.name));

            Console.WriteLine("DeployLatestDockerContainer completed");
        }

        public void Dispose()
        {
            _client.Dispose();
        }
    }

}
