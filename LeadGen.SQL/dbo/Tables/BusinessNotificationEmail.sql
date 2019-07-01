CREATE TABLE [dbo].[BusinessNotificationEmail](
	[BusinessID] [bigint] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_BusinessNotificationEmail] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessNotificationEmail]  WITH CHECK ADD  CONSTRAINT [FK_Business.Notification.Email_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO

ALTER TABLE [dbo].[BusinessNotificationEmail] CHECK CONSTRAINT [FK_Business.Notification.Email_Business]