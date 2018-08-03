sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update
sudo apt-get install docker-ce

docker network create --driver bridge isolated_network

docker run -d --net=isolated_network --restart=unless-stopped -p 1433:1433 -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=pass@word1' --name mssql -d microsoft/mssql-server-linux:2017-latest
docker inspect mssql  