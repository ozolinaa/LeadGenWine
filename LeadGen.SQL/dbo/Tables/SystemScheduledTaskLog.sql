CREATE TABLE [dbo].[SystemScheduledTaskLog](
	[ID] [uniqueidentifier] NOT NULL,
	[TaskName] [nvarchar](255) NOT NULL,
	[StartedDateTime] [datetime] NOT NULL,
	[CompletedDateTime] [datetime] NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Message] [nvarchar](max) NULL,
 CONSTRAINT [PK_SystemScheduledTaskLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SystemScheduledTaskLog] ADD  CONSTRAINT [DF_System.ScheduledTaskLog_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[SystemScheduledTaskLog] ADD  CONSTRAINT [DF_System.ScheduledTaskLog_StartedDateTime]  DEFAULT (getutcdate()) FOR [StartedDateTime]
GO
ALTER TABLE [dbo].[SystemScheduledTaskLog] ADD  CONSTRAINT [DF_System.ScheduledTaskLog_Status]  DEFAULT (N'Started') FOR [Status]
GO
/****** Object:  Index [IX_SystemScheduledTaskLog]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_SystemScheduledTaskLog] ON [dbo].[SystemScheduledTaskLog]
(
	[TaskName] ASC,
	[CompletedDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]