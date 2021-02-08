#!/bin/bash

# INSTALL ZIP     | sudo apt-get install zip
# set permissions | chmod +x backup_LeadGenDB_prod.sh |  chmod +x /opt/scripts/backup_LeadGenDB_prod.sh
# run once        | ./backup_LeadGenDB_prod.sh | ./opt/scripts/backup_LeadGenDB_prod.sh
# schedule part 1 | sudo nano /etc/crontab 
# schedule part 2 | 25 5 * * * root /opt/scripts/backup_LeadGenDB_prod.sh

dockerContainer='mssql'
mssqlVolumePath='/opt/docker/mssql'
dbName='LeadGenDB_prod'
sqlUser='SQL_USER_HERE'
sqlPassword='SQL_PASSWORD_HERE'

# BACKUP SQL DB - container_mssql_db_backup.sh scripts sets $backupArchiveFilePathAtHost variable
. container_mssql_db_backup.sh "$dockerContainer" "$mssqlVolumePath" "$dbName" "$sqlUser" "$sqlPassword"

# UPLOAD to S3
./upload_to_s3.sh "$backupArchiveFilePathAtHost" "backups.winecellars.pro" "db/leadgen/prod"
