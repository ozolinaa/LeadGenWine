# https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-16-04
# Configure NGINX /etc/nginx/sites-available/default
____________________________
server {
	server_name winecellars.pro;
	location / {
		proxy_set_header HOST $host;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass http://localhost:8080;
	}
}
server {
	server_name crm.winecellars.pro;
	client_max_body_size 50M;
	location / {
		proxy_set_header HOST $host;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass http://localhost:8081;
	}
}
____________________________

# sudo nginx -t
# sudo systemctl reload nginx

# https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04
sudo certbot --nginx -d wine.lalala.space
sudo certbot --nginx -d lalala.space -d www.lalala.space
sudo certbot renew --dry-run

____________________________

sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update
sudo apt-get install docker-ce

mkdir mssql
chown 10001:0 /opt/docker/mssql
docker build -t mssql:2019 -f SQLServerDockerfile .
docker run -d --restart=unless-stopped -p 1433:1433 -e 'ACCEPT_EULA=Y' -e 'MSSQL_PID=Express' -e 'SA_PASSWORD=pass@word1' -v /opt/docker/mssql:/var/opt/mssql:rw --name mssql mssql:2019
# docker stop mssql
# docker rm mssql



leadgenweb:latest

# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04
docker run -d --restart=unless-stopped -p 8080:80 -e sqlConnectionString='Data Source=DBHOST;Initial Catalog=DBNAME;Persist Security Info=True;User ID=USERNAME;Password=PASSWORD;' --name leadgenweb xtonyx/leadgenweb:v14
/var/lib/docker/overlay2
# docker stop leadgenweb
# docker rm leadgenweb
# docker rmi $(docker images -a -q)
# docker attach leadgenweb



#deploy docker
docker-compose up -d
#update app
sudo docker-compose up -d --no-deps --build app
#if errors stopping container - https://stackoverflow.com/questions/49104733/docker-on-ubuntu-16-04-error-when-killing-container


____________________________

