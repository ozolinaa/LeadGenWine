USE [master]
GO

IF (EXISTS (SELECT name 
FROM master.dbo.sysdatabases 
WHERE ('[' + name + ']' = 'LeadGenDB'
OR name = 'LeadGenDB')))
BEGIN
	alter database [LeadGenDB] set single_user with rollback immediate
	drop database [LeadGenDB]
END

