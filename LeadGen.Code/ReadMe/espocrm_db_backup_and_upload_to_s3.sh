#!/bin/bash

# set permissions  | chmod +x espocrm_db_backup_and_upload_to_s3.sh |  chmod +x /opt/leadgen/espocrm_db_backup_and_upload_to_s3.sh
# run once        | sudo ./espocrm_db_backup_and_upload_to_s3.sh | sudo /opt/leadgen/espocrm_db_backup_and_upload_to_s3.sh
# schedule part 1 | sudo nano /etc/crontab 
# schedule part 2 | 0 4 * * * root /opt/leadgen/espocrm_db_backup_and_upload_to_s3.sh
# sql backup/restore https://docs.microsoft.com/en-us/sql/linux/tutorial-restore-backup-in-sql-server-container?view=sql-server-ver15

# BACKUP
echo "Starting backup..."
dockerContainer='leadgen_mysql_1'
dbName='espocrm'
sqlUser='espocrm'
sqlPassword='h!!?F:_-O^Jp+TB4B*HYt3'
backupFolderAtHost='/opt/leadgen/mysql/backup'
backupFilePathAtHost=''"$backupFolderAtHost"'/'"$dbName"'.sql'
sqlDBBackupQuery=''
mkdir -p "$backupFolderAtHost"
rm -f "$backupFilePathAtHost"
docker exec "$dockerContainer" mysqldump --user=$sqlUser --password="$sqlPassword" $dbName > $backupFilePathAtHost


# Archive Backup File
backupArchiveFilePathAtHost=''"$backupFilePathAtHost"'.zip'
rm -f "$backupArchiveFilePathAtHost"
#tar -czvf "$backupArchiveFilePathAtHost" "$backupFilePathAtHost"
zip "$backupArchiveFilePathAtHost" "$backupFilePathAtHost" -j

echo "Uploading to AWS S3..."
# UPLOAD TO S3
bucket=files.winecellars.pro
now=$(date +"%Y_%m_%d_%H_%M_%S")
s3filepath='backup/sql/espocrmDB_s3_'"$now"'.sql.zip'
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
