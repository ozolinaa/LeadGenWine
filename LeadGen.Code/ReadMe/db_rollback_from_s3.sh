#!/bin/bash

# set permissions        | chmod +x db_rollback_from_s3.sh |  chmod +x /home/anton/leadgen/db_rollback_from_s3.sh
# run once        | sudo ./db_rollback_from_s3.sh  |  sudo ./home/anton/leadgen/db_rollback_from_s3.sh
# sql backup/restore https://docs.microsoft.com/en-us/sql/linux/tutorial-restore-backup-in-sql-server-container?view=sql-server-ver15

echo "Starting rollback..."
dockerContainer='leadgen_mssql_1'
dbName='LeadGenDB'
sqlPassword='*k_U^Jp+PZ6*CDmQ'
s3Key=AKIA5TEQIYORDMDP7ENV
s3Secret=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

# Getting latest file name
lastBackupFileName='LeadGenDB_s3_2019_12_13_07_46_36.bak'

# DOWNLOAD FROM S3
echo "Download from AWS S3..."
restoreFolderAtHost='/home/anton/leadgen/mssql/backup'
restoreFilePathAtHost=''"$restoreFolderAtHost"'/'"$lastBackupFileName"
sudo rm -r "$restoreFilePathAtHost"
bucket=files.winecellars.pro
s3filepath='backup/sql/'"$lastBackupFileName"
resource="/${bucket}/${s3filepath}"
contentType="application/binary"
dateValue=`date -R`
stringToSign="GET\n\n${contentType}\n${dateValue}\n${resource}"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
sudo curl -H "Host: ${bucket}.s3.amazonaws.com" \
 -H "Date: ${dateValue}" \
 -H "Content-Type: ${contentType}" \
 -H "Authorization: AWS ${s3Key}:${signature}" \
 http://${bucket}.s3.amazonaws.com/${s3filepath} -o "$restoreFilePathAtHost"

# DB RESTORE
restoreFolder='/var/opt/mssql/backup'
restoreFilePath=''"$restoreFolder"'/'"$lastBackupFileName"
sqlDBRestoreQuery='
	USE [master]
	GO
	-- section below kills all active connections to database
	DECLARE @kill varchar(8000) = "";
	SELECT @kill = @kill + "kill " + CONVERT(varchar(5), session_id) + ";"
	FROM sys.dm_exec_sessions
	WHERE database_id = db_id("'"$dbName"'")
	EXEC(@kill);
	-- section below switches database to single-user mode in order to prevent any connection during restoration
	ALTER DATABASE ['"$dbName"'] SET Single_User WITH Rollback Immediate
	GO
	-- section below restores database from the specified backup file
	RESTORE DATABASE ['"$dbName"'] FROM DISK = "'"$restoreFilePath"'"
	WITH REPLACE
	GO
	-- section below switches database to multi-user mode
	ALTER DATABASE ['"$dbName"'] SET Multi_User
	GO
'
docker exec -it "$dockerContainer" /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$sqlPassword" -Q "$sqlDBRestoreQuery"

# DB RESTORE
echo "Deleteting local restore file."
sudo rm -r "$restoreFilePathAtHost"
