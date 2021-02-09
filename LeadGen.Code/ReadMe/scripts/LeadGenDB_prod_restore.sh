#!/bin/bash

# INSTALL UNZIP     | sudo apt-get install unzip
# set permissions | chmod +x LeadGenDB_prod_restore.sh |  chmod +x /opt/scripts/LeadGenDB_prod_restore.sh
# run once        | ./LeadGenDB_prod_restore.sh | ./opt/scripts/LeadGenDB_prod_restore.sh

# SET LeadGenDB_prod credentials will set $LeadGenDB_prod_dbName $LeadGenDB_prod_sqlUser $LeadGenDB_prod_sqlPassword
. set_LeadGenDB_prod_credentials.sh
dbName="${LeadGenDB_prod_dbName}"
sqlUser="${LeadGenDB_prod_sqlUser}"
sqlPassword="${LeadGenDB_prod_sqlPassword}"

dockerContainer='mssql'
mssqlVolumePath='/opt/docker/mssql'
restoreArchiveFileName='LeadGenDB_prod.bak_2021_02_08_22_06_25.zip'
s3FilePath="db/leadgen/prod/${restoreArchiveFileName}"

mssqlRestoreFolderName='restore'
restorePathAtHost="${mssqlVolumePath}/${mssqlRestoreFolderName}"
mkdir -p "${restorePathAtHost}"
restoreFileName="${dbName}.bak"
restoreArchiveFilePathAtHost="${restorePathAtHost}/${restoreArchiveFileName}"
restoreFilePathAtHost="${restorePathAtHost}/${restoreFileName}"
mssqlVolumePathToRestoreFile="${mssqlRestoreFolderName}/${restoreFileName}"
rm -f "${restoreArchiveFilePathAtHost}"

# DOWNLOAD FROM S3
./download_from_s3.sh "backups.winecellars.pro" "${s3FilePath}" "${restoreArchiveFilePathAtHost}" 

rm -f "${restoreFilePathAtHost}"
unzip "${restoreArchiveFilePathAtHost}" -d "${restorePathAtHost}"

# RESTORE SQL DB
. container_mssql_db_restore.sh "$dockerContainer" "$mssqlVolumePathToRestoreFile" "$dbName" "$sqlUser" "$sqlPassword"