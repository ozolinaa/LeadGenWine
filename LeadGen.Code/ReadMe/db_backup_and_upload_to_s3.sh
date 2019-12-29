#!/bin/bash

# set permissions  | chmod +x db_backup_and_upload_to_s3.sh |  chmod +x /opt/leadgen/db_backup_and_upload_to_s3.sh
# run once        | sudo ./db_backup_and_upload_to_s3.sh | sudo /opt/leadgen/db_backup_and_upload_to_s3.sh
# schedule part 1 | sudo nano /etc/crontab 
# schedule part 2 | 25 6 * * * root /opt/leadgen/db_backup_and_upload_to_s3.sh
# sql backup/restore https://docs.microsoft.com/en-us/sql/linux/tutorial-restore-backup-in-sql-server-container?view=sql-server-ver15

# BACKUP
echo "Starting backup..."
dockerContainer='leadgen_mssql_1'
dbName='LeadGenDB'
sqlPassword='*k_U^Jp+PZ6*CDmQ'
backupFolder='/var/opt/mssql/backup'
backupFilePath=''"$backupFolder"'/'"$dbName"'.bak'
sqlDBBackupQuery='BACKUP DATABASE ['"$dbName"'] TO DISK = "'"$backupFilePath"'" WITH NOFORMAT, NOINIT, NAME = "'"$dbName"'", SKIP, NOREWIND, NOUNLOAD, STATS = 10'
docker exec -it "$dockerContainer" mkdir -p "$backupFolder"
docker exec -it "$dockerContainer" rm -f "$backupFilePath"
docker exec -it "$dockerContainer" /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$sqlPassword" -Q "$sqlDBBackupQuery"

# Archive Backup File
backupFolderAtHost='/opt/leadgen/mssql/backup'
backupFilePathAtHost=''"$backupFolderAtHost"'/'"$dbName"'.bak'
backupArchiveFilePathAtHost=''"$backupFilePathAtHost"'.zip'
rm -f "$backupArchiveFilePathAtHost"
#tar -czvf "$backupArchiveFilePathAtHost" "$backupFilePathAtHost"
zip "$backupArchiveFilePathAtHost" "$backupFilePathAtHost" -j

echo "Uploading to AWS S3..."
# UPLOAD TO S3
bucket=files.winecellars.pro
now=$(date +"%Y_%m_%d_%H_%M_%S")
s3filepath='backup/sql/LeadGenDB_s3_'"$now"'.bak.zip'
resource="/${bucket}/${s3filepath}"
contentType="application/binary"
dateValue=`date -R`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
s3Key=AKIA5TEQIYORDMDP7ENV
s3Secret=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
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
sudo curl -L -X PUT -T "${backupArchiveFilePathAtHost}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  http://${bucket}.s3.amazonaws.com/${s3filepath}

rm -f "$backupArchiveFilePathAtHost"

echo "Uploaded to AWS S3"
