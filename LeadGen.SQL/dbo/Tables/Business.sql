CREATE TABLE [dbo].[Business](
	[BusinessID] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[RegistrationDate] [datetime] NOT NULL,
	[WebSite] [nvarchar](255) NOT NULL,
	[CountryID] [bigint] NOT NULL,
	[NotificationFrequencyID] [int] NOT NULL,
	[Address] [nvarchar](255) NULL,
	[ContactName] [nvarchar](255) NULL,
	[ContactEmail] [nvarchar](255) NULL,
	[ContactPhone] [nvarchar](255) NULL,
	[ContactSkype] [nvarchar](255) NULL,
	[BillingName] [nvarchar](255) NULL,
	[BillingCode1] [nvarchar](255) NULL,
	[BillingCode2] [nvarchar](255) NULL,
	[BillingAddress] [nvarchar](255) NULL,
	[OldID] [bigint] NULL,
 CONSTRAINT [PK_Business] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Business]  WITH CHECK ADD  CONSTRAINT [FK_Business_Notification.Frequency] FOREIGN KEY([NotificationFrequencyID])
REFERENCES [dbo].[NotificationFrequency] ([ID])
GO

ALTER TABLE [dbo].[Business] CHECK CONSTRAINT [FK_Business_Notification.Frequency]
GO
ALTER TABLE [dbo].[Business]  WITH CHECK ADD  CONSTRAINT [FK_Business_Taxonomy.Term] FOREIGN KEY([CountryID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO

ALTER TABLE [dbo].[Business] CHECK CONSTRAINT [FK_Business_Taxonomy.Term]
GO
ALTER TABLE [dbo].[Business] ADD  CONSTRAINT [DF_Business_BusinessRegistrationDate]  DEFAULT (getutcdate()) FOR [RegistrationDate]
GO
ALTER TABLE [dbo].[Business] ADD  CONSTRAINT [DF_Business_NotificationFrequencyID]  DEFAULT ((1)) FOR [NotificationFrequencyID]
GO
/****** Object:  Index [IX_Business]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Business] ON [dbo].[Business]
(
	[BusinessID] ASC,
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]