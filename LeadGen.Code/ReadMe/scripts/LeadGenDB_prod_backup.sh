#!/bin/bash

# INSTALL ZIP     | sudo apt-get install zip
# set permissions | chmod +x LeadGenDB_prod_backup.sh |  chmod +x /opt/scripts/LeadGenDB_prod_backup.sh
# run once        | ./LeadGenDB_prod_backup.sh | ./opt/scripts/LeadGenDB_prod_backup.sh
# schedule part 1 | sudo nano /etc/crontab 
# schedule part 2 | 25 5 * * * root /opt/scripts/LeadGenDB_prod_backup.sh

# SET LeadGenDB_prod credentials will set $LeadGenDB_prod_dbName $LeadGenDB_prod_sqlUser $LeadGenDB_prod_sqlPassword
. set_LeadGenDB_prod_credentials.sh
dbName="${LeadGenDB_prod_dbName}"
sqlUser="${LeadGenDB_prod_sqlUser}"
sqlPassword="${LeadGenDB_prod_sqlPassword}"

dockerContainer='mssql'
mssqlVolumePath='/opt/docker/mssql'

# BACKUP SQL DB - container_mssql_db_backup.sh scripts sets backupFilePathAtHost variable
. container_mssql_db_backup.sh "$dockerContainer" "$mssqlVolumePath" "$dbName" "$sqlUser" "$sqlPassword"

# Archive Backup File
backupArchiveFilePathAtHost="${backupFilePathAtHost}.zip"
rm -f "$backupArchiveFilePathAtHost"
#tar -czvf "$backupArchiveFilePathAtHost" "$backupFilePathAtHost"
zip "$backupArchiveFilePathAtHost" "$backupFilePathAtHost" -j
backupFilePathAtHost="${backupFolderAtHost}/${dbName}.bak"

# UPLOAD to S3
./upload_to_s3.sh "$backupArchiveFilePathAtHost" "backups.winecellars.pro" "db/leadgen/prod"
