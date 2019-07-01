CREATE TABLE [dbo].[UserSession](
	[SessionID] [nvarchar](255) NOT NULL,
	[LoginID] [bigint] NOT NULL,
	[SessionCreationDate] [datetime] NOT NULL,
	[SessionBlockDate] [datetime] NULL,
	[SessionPasswordHash] [nvarchar](255) NOT NULL,
	[SessionPasswordChangeInitialized] [bit] NULL,
 CONSTRAINT [PK_UserSessions] PRIMARY KEY CLUSTERED 
(
	[SessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserSession]  WITH CHECK ADD  CONSTRAINT [FK_User.Session_User.Login] FOREIGN KEY([LoginID])
REFERENCES [dbo].[UserLogin] ([LoginID])
GO

ALTER TABLE [dbo].[UserSession] CHECK CONSTRAINT [FK_User.Session_User.Login]