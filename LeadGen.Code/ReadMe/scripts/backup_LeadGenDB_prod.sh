#!/bin/bash

# INSTALL ZIP     | sudo apt-get install zip
# set permissions | chmod +x backup_LeadGenDB_prod.sh |  chmod +x /opt/scripts/backup_LeadGenDB_prod.sh
# run once        | ./backup_LeadGenDB_prod.sh | ./opt/scripts/backup_LeadGenDB_prod.sh
# schedule part 1 | sudo nano /etc/crontab 
# schedule part 2 | 25 5 * * * root /opt/scripts/backup_LeadGenDB_prod.sh
# sql backup/restore https://docs.microsoft.com/en-us/sql/linux/tutorial-restore-backup-in-sql-server-container?view=sql-server-ver15

dockerContainer='mssql'
dbName='LeadGenDB_prod'
sqlUser='SQL_USER_HERE'
sqlPassword='SQL_PASSWORD_HERE'

mssqlBackupFolderName='backup'
backupFolder="/var/opt/mssql/${mssqlBackupFolderName}"
backupFolderAtHost="${mssqlVolumePath}/${mssqlBackupFolderName}"
backupFilePath="${backupFolder}/${dbName}.bak"
backupFilePathAtHost="${backupFolderAtHost}/${dbName}.bak"
backupArchiveFilePathAtHost="${backupFilePathAtHost}.zip"

# BACKUP
echo "Starting backup..."
sqlDBBackupQuery='BACKUP DATABASE ['"$dbName"'] TO DISK = "'"$backupFilePath"'" WITH NOFORMAT, NOINIT, NAME = "'"$dbName"'", SKIP, NOREWIND, NOUNLOAD, STATS = 10'
docker exec -it "$dockerContainer" mkdir -p "$backupFolder"
docker exec -it "$dockerContainer" rm -f "$backupFilePath"
docker exec -it "$dockerContainer" /opt/mssql-tools/bin/sqlcmd -S localhost -U "$sqlUser" -P "$sqlPassword" -Q "$sqlDBBackupQuery"

# Archive Backup File
rm -f "$backupArchiveFilePathAtHost"
#tar -czvf "$backupArchiveFilePathAtHost" "$backupFilePathAtHost"
zip "$backupArchiveFilePathAtHost" "$backupFilePathAtHost" -j

# UPLOAD to S3
./upload_to_s3.sh "$backupArchiveFilePathAtHost" "backups.winecellars.pro" "db/leadgen/prod"
