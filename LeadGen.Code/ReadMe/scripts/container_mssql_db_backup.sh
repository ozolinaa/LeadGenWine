#!/bin/bash

# INSTALL ZIP     | sudo apt-get install zip
# set permissions | chmod +x container_mssql_db_backup.sh |  chmod +x /opt/scripts/container_mssql_db_backup.sh
# run once        | . container_mssql_db_backup.sh "$dockerContainer" "$mssqlVolumePath" "$dbName" "$sqlUser" "$sqlPassword"
# sql backup/restore https://docs.microsoft.com/en-us/sql/linux/tutorial-restore-backup-in-sql-server-container?view=sql-server-ver15

# Extract Arguments
dockerContainer="$1"
mssqlVolumePath="$2"
dbName="$3"
sqlUser="$4"
sqlPassword="$5"

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

export backupArchiveFilePathAtHost=$backupArchiveFilePathAtHost
