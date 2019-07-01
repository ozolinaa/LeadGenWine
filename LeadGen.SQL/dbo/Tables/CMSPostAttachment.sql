CREATE TABLE [dbo].[CMSPostAttachment](
	[PostID] [bigint] NOT NULL,
	[AttachmentID] [bigint] NOT NULL,
	[LinkDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CMSPostAttachment] PRIMARY KEY CLUSTERED 
(
	[PostID] ASC,
	[AttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMSPostAttachment]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post] FOREIGN KEY([PostID])
REFERENCES [dbo].[CMSPost] ([PostID])
GO

ALTER TABLE [dbo].[CMSPostAttachment] CHECK CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post]
GO
ALTER TABLE [dbo].[CMSPostAttachment]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post.Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].[CMSAttachment] ([AttachmentID])
GO

ALTER TABLE [dbo].[CMSPostAttachment] CHECK CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post.Attachment]
GO
ALTER TABLE [dbo].[CMSPostAttachment] ADD  CONSTRAINT [DF_CMS.Post.Attachment_LinkDate]  DEFAULT (getutcdate()) FOR [LinkDate]