CREATE TABLE [dbo].[CMSAttachment](
	[AttachmentID] [bigint] IDENTITY(1,1) NOT NULL,
	[AuthorID] [bigint] NOT NULL,
	[TypeID] [int] NOT NULL,
	[MIME] [nvarchar](50) NOT NULL,
	[URL] [nvarchar](255) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[FileHash] [nvarchar](100) NOT NULL,
	[FileSizeBytes] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_CMSAttachment] PRIMARY KEY CLUSTERED 
(
	[AttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSAttachment] UNIQUE NONCLUSTERED 
(
	[FileHash] ASC,
	[FileSizeBytes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSAttachment_2] UNIQUE NONCLUSTERED 
(
	[URL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMSAttachment]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment_CMS.Attachment.Type] FOREIGN KEY([TypeID])
REFERENCES [dbo].[CMSAttachmentType] ([AttachmentTypeID])
GO

ALTER TABLE [dbo].[CMSAttachment] CHECK CONSTRAINT [FK_CMS.Attachment_CMS.Attachment.Type]
GO
ALTER TABLE [dbo].[CMSAttachment] ADD  CONSTRAINT [DF_CMS.Attachment_MIME]  DEFAULT ('') FOR [MIME]
GO
ALTER TABLE [dbo].[CMSAttachment] ADD  CONSTRAINT [DF_CMS.Attachment_URL]  DEFAULT (CONVERT([varchar],sysdatetime(),(121))) FOR [URL]
GO
ALTER TABLE [dbo].[CMSAttachment] ADD  CONSTRAINT [DF_CMS.Attachment_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[CMSAttachment] ADD  CONSTRAINT [DF_CMS.Attachment_Name]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[CMSAttachment] ADD  CONSTRAINT [DF_CMS.Attachment_Description]  DEFAULT ('') FOR [Description]
GO
/****** Object:  Index [IX_CMSAttachment_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CMSAttachment_1] ON [dbo].[CMSAttachment]
(
	[AttachmentID] ASC,
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]