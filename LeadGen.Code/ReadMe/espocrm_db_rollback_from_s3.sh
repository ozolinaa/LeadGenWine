#!/bin/bash

# set permissions | chmod +x espocrm_db_rollback_from_s3.sh |  chmod 777 /opt/leadgen/espocrm_db_rollback_from_s3.sh
# run once        | sudo ./espocrm_db_rollback_from_s3.sh  |  sudo /opt/leadgen/espocrm_db_rollback_from_s3.sh
# sql backup/restore https://docs.microsoft.com/en-us/sql/linux/tutorial-restore-backup-in-sql-server-container?view=sql-server-ver15

echo "Starting rollback..."
dockerContainer='leadgen_mysql_1'
dbName='espocrm'
sqlUser='espocrm'
sqlPassword='h!!?F:_-O^Jp+TB4B*HYt3'
s3Key=AKIA5TEQIYORDMDP7ENV
s3Secret=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

# Getting latest file name
lastBackupArchiveFileName='espocrmDB_s3_2020_01_15_04_00_04.sql.zip'

# DOWNLOAD FROM S3
echo "Download from AWS S3..."
restoreFolderAtHost='/opt/leadgen/mysql/restore'
restoreArchivePathAtHost=''"$restoreFolderAtHost"'/'"$lastBackupArchiveFileName"
mkdir -p "$restoreFolderAtHost"
sudo rm -r "$restoreArchivePathAtHost"
bucket=files.winecellars.pro
s3filepath='backup/sql/'"$lastBackupArchiveFileName"
resource="/${bucket}/${s3filepath}"
contentType="application/binary"
dateValue=`date -R`
stringToSign="GET\n\n${contentType}\n${dateValue}\n${resource}"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
sudo curl -H "Host: ${bucket}.s3.amazonaws.com" \
 -H "Date: ${dateValue}" \
 -H "Content-Type: ${contentType}" \
 -H "Authorization: AWS ${s3Key}:${signature}" \
 http://${bucket}.s3.amazonaws.com/${s3filepath} -o "$restoreArchivePathAtHost"

 sudo rm -r ''"$restoreFolderAtHost"'/espocrm.sql'
 unzip "$restoreArchivePathAtHost" -d "$restoreFolderAtHost"
 sudo rm -r "$restoreArchivePathAtHost"

# DB RESTORE
lastBackupFileName='espocrm.sql'
restoreFolder='/opt/leadgen/mysql/restore'
restoreFilePath=''"$restoreFolder"'/'"$lastBackupFileName"

cat $restoreFilePath | docker exec -i "$dockerContainer" /usr/bin/mysql -u $sqlUser --password="$sqlPassword" $dbName
