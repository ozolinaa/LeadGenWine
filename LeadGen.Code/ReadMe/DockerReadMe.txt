# https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-16-04
# Configure NGINX /etc/nginx/sites-available/default
____________________________
server {
	server_name wine.lalala.space;
	location / {
		proxy_set_header HOST $host;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass http://localhost:8080;
	}
}
server {
	server_name lalala.space www.lalala.space;
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

docker network create --driver bridge isolated_network

docker run -d --net=isolated_network --restart=unless-stopped -p 1433:1433 -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=pass@word1' -v /var/opt/docker/mssql:/var/opt/mssql --name mssql -d microsoft/mssql-server-linux:2017-latest
# docker stop mssql
# docker rm mssql

docker run --restart=unless-stopped -p 1433:1433 -e 'ACCEPT_EULA=Y' -e 'MSSQL_PID=Express' -e 'SA_PASSWORD=pass@word1' -v /home/anton/leadgen/mssql:/var/opt/mssql --name mssql -d microsoft/mssql-server-linux:2017-latest



leadgenweb:latest

# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04
docker run -d --net=isolated_network --restart=unless-stopped -p 8080:80 -e sqlConnectionString='Data Source=mssql;Initial Catalog=WineLeadGen;User ID=sa;Password=pass@word1;' --name leadgenweb xtonyx/leadgenweb:20180828070953
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

backup https://docs.microsoft.com/en-us/sql/linux/tutorial-restore-backup-in-sql-server-container?view=sql-server-ver15
# init (create folder for backup)
sudo docker exec -it leadgen_mssql_1 mkdir /var/opt/mssql/backup

dbname='LeadGenDB'
backupfilepath='/var/opt/mssql/backup/LeadGenDB.bak'
sqlpassword='*k_U^Jp+PZ6*CDmQ'
sqldbbackupquery='BACKUP DATABASE ['"$dbname"'] TO DISK = "'"$backupfilepath"'" WITH NOFORMAT, NOINIT, NAME = "'"$dbname"'", SKIP, NOREWIND, NOUNLOAD, STATS = 10'

# db-bakup
sudo docker exec -it leadgen_mssql_1 /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$sqlpassword" -Q "$sqldbbackupquery"

# db-restore
sqldbrestorequery='
	USE [master]
	GO
	-- section below kills all active connections to database
	DECLARE @kill varchar(8000) = "";
	SELECT @kill = @kill + "kill " + CONVERT(varchar(5), session_id) + ";"
	FROM sys.dm_exec_sessions
	WHERE database_id = db_id("'"$dbname"'")
	EXEC(@kill);
	-- section below switches database to single-user mode in order to prevent any connection during restoration
	ALTER DATABASE ['"$dbname"'] SET Single_User WITH Rollback Immediate
	GO
	-- section below restores database from the specified backup file
	RESTORE DATABASE ['"$dbname"'] FROM DISK = "'"$backupfilepath"'"
	WITH REPLACE
	GO
	-- section below switches database to multi-user mode
	ALTER DATABASE ['"$dbname"'] SET Multi_User
	GO
'
sudo docker exec -it leadgen_mssql_1 /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$sqlpassword" -Q "$sqldbrestorequery"

# db upload to s3
backupfilepath='/home/anton/leadgen/mssql/backup/LeadGenDB.bak'
bucket=files.winecellars.pro
s3filepath=backup/sql/LeadGenDB_s3.bak
resource="/${bucket}/${s3filepath}"
contentType="application/binary"
dateValue=`date -R`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
s3Key=s3Keys3Keys3Keys3Keys3Key
s3Secret=s3Secrets3Secrets3Secrets3Secrets3Secret
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
sudo curl -L -X PUT -T "${backupfilepath}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  http://${bucket}.s3.amazonaws.com/${s3filepath}