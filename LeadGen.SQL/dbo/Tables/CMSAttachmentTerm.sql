CREATE TABLE [dbo].[CMSAttachmentTerm](
	[AttachmentID] [bigint] NOT NULL,
	[TermID] [bigint] NOT NULL,
 CONSTRAINT [PK_CMSAttachmentTerm] PRIMARY KEY CLUSTERED 
(
	[AttachmentID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMSAttachmentTerm]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment.Term_CMS.Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].[CMSAttachment] ([AttachmentID])
GO

ALTER TABLE [dbo].[CMSAttachmentTerm] CHECK CONSTRAINT [FK_CMS.Attachment.Term_CMS.Attachment]
GO
ALTER TABLE [dbo].[CMSAttachmentTerm]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment.Term_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO

ALTER TABLE [dbo].[CMSAttachmentTerm] CHECK CONSTRAINT [FK_CMS.Attachment.Term_Taxonomy.Term]