#!/bin/bash

# set permissions | chmod +x container_mssql_db_restore.sh |  chmod +x /opt/scripts/container_mssql_db_restore.sh
# run once        | sudo ./container_mssql_db_restore.sh  |  sudo /opt/scripts/container_mssql_db_restore.sh
# sql backup/restore https://docs.microsoft.com/en-us/sql/linux/tutorial-restore-backup-in-sql-server-container?view=sql-server-ver15

echo "Starting restore..."

# Extract Arguments
dockerContainer="$1"
mssqlVolumePathToRestoreFile="$2"
dbName="$3"
sqlUser="$4"
sqlPassword="$5"

# DB RESTORE
mssqlPath='/var/opt/mssql'
restoreFilePath="${mssqlPath}/${mssqlVolumePathToRestoreFile}"
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
docker exec -it "$dockerContainer" /opt/mssql-tools/bin/sqlcmd -S localhost -U "$sqlUser" -P "$sqlPassword" -Q "$sqlDBRestoreQuery"
