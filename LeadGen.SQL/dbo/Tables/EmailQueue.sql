CREATE TABLE [dbo].[EmailQueue](
	[EmailID] [uniqueidentifier] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[SendingScheduledDateTime] [datetime] NOT NULL,
	[SendingStartedDateTime] [datetime] NULL,
	[SentDateTime] [datetime] NULL,
	[FromAddress] [nvarchar](255) NOT NULL,
	[FromName] [nvarchar](255) NOT NULL,
	[ReplyToAddress] [nvarchar](255) NULL,
	[ToAddress] [nvarchar](255) NOT NULL,
	[Subject] [nvarchar](255) NOT NULL,
	[Body] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_SystemEmailQueue] PRIMARY KEY CLUSTERED 
(
	[EmailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmailQueue] ADD  CONSTRAINT [DF_System.Email.Queue_Id]  DEFAULT (newid()) FOR [EmailID]
GO
ALTER TABLE [dbo].[EmailQueue] ADD  CONSTRAINT [DF_System.Email.Queue_CreatedDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[EmailQueue] ADD  CONSTRAINT [DF_System.Email.Queue_SendingScheduledDateTime]  DEFAULT (getutcdate()) FOR [SendingScheduledDateTime]