CREATE TABLE [dbo].[SystemLog](
	[ID] [UNIQUEIDENTIFIER] NOT NULL DEFAULT NEWID(),
	[Value] [nvarchar](MAX) NOT NULL,
	[LoggedDateTime] [datetime] NOT NULL DEFAULT GETUTCDATE())