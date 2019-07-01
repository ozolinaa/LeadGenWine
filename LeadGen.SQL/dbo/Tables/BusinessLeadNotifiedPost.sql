CREATE TABLE [dbo].[BusinessLeadNotifiedPost](
	[BusinessPostID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[NotifiedDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BusinessLeadNotifiedPost] PRIMARY KEY CLUSTERED 
(
	[BusinessPostID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessLeadNotifiedPost]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Notified.Post_CMS.Post] FOREIGN KEY([BusinessPostID])
REFERENCES [dbo].[CMSPost] ([PostID])
GO

ALTER TABLE [dbo].[BusinessLeadNotifiedPost] CHECK CONSTRAINT [FK_Business.Lead.Notified.Post_CMS.Post]
GO
ALTER TABLE [dbo].[BusinessLeadNotifiedPost]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Notified.Post_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO

ALTER TABLE [dbo].[BusinessLeadNotifiedPost] CHECK CONSTRAINT [FK_Business.Lead.Notified.Post_Lead]
GO
ALTER TABLE [dbo].[BusinessLeadNotifiedPost] ADD  CONSTRAINT [DF_Business.Lead.Notified.Post_NotifiedDateTime]  DEFAULT (getutcdate()) FOR [NotifiedDateTime]