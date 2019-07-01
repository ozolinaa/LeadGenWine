CREATE TABLE [dbo].[BusinessLogin](
	[BusinessID] [bigint] NOT NULL,
	[LoginID] [bigint] NOT NULL,
	[RoleID] [int] NOT NULL,
	[LinkDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BusinessLogin_1] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessLogin]  WITH CHECK ADD  CONSTRAINT [FK_Business.Login_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO

ALTER TABLE [dbo].[BusinessLogin] CHECK CONSTRAINT [FK_Business.Login_Business]
GO
ALTER TABLE [dbo].[BusinessLogin]  WITH CHECK ADD  CONSTRAINT [FK_Business.Login_User.Login1] FOREIGN KEY([LoginID], [RoleID])
REFERENCES [dbo].[UserLogin] ([LoginID], [RoleID])
GO

ALTER TABLE [dbo].[BusinessLogin] CHECK CONSTRAINT [FK_Business.Login_User.Login1]
GO
ALTER TABLE [dbo].[BusinessLogin] ADD  CONSTRAINT [DF_Business.Login_LinkDate]  DEFAULT (getutcdate()) FOR [LinkDate]