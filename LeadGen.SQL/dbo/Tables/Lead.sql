CREATE TABLE [dbo].[Lead](
	[LeadID] [bigint] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[NumberFromEmail]  AS ([dbo].[ExtractNumberFromString]([Email])) PERSISTED,
	[EmailConfirmedDateTime] [datetime] NULL,
	[PublishedDateTime] [datetime] NULL,
	[AdminCanceledPublishDateTime] [datetime] NULL,
	[UserCanceledDateTime] [datetime] NULL,
	[ReviewRequestSentDateTime] [datetime] NULL,
 CONSTRAINT [PK_Lead] PRIMARY KEY CLUSTERED 
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Lead] ADD  CONSTRAINT [DF_Lead_LeadDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
/****** Object:  Index [IX_Lead]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead] ON [dbo].[Lead]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lead_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead_1] ON [dbo].[Lead]
(
	[NumberFromEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lead_2]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead_2] ON [dbo].[Lead]
(
	[LeadID] ASC,
	[PublishedDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PublishedCreatedDateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [PublishedCreatedDateTime] ON [dbo].[Lead]
(
	[PublishedDateTime] ASC
)
INCLUDE ( 	[CreatedDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]