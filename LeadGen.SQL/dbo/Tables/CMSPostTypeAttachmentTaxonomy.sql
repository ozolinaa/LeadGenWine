CREATE TABLE [dbo].[CMSPostTypeAttachmentTaxonomy](
	[PostTypeID] [int] NOT NULL,
	[AttachmentTaxonomyID] [int] NOT NULL,
	[IsEnabled] [bit] NOT NULL,
 CONSTRAINT [PK_CMSPostTypeAttachmentTaxonomy]]] PRIMARY KEY CLUSTERED 
(
	[PostTypeID] ASC,
	[AttachmentTaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMSPostTypeAttachmentTaxonomy]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_CMS.Post.Type] FOREIGN KEY([PostTypeID])
REFERENCES [dbo].[CMSPostType] ([TypeID])
GO

ALTER TABLE [dbo].[CMSPostTypeAttachmentTaxonomy] CHECK CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_CMS.Post.Type]
GO
ALTER TABLE [dbo].[CMSPostTypeAttachmentTaxonomy]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_Taxonomy] FOREIGN KEY([AttachmentTaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO

ALTER TABLE [dbo].[CMSPostTypeAttachmentTaxonomy] CHECK CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_Taxonomy]
GO
ALTER TABLE [dbo].[CMSPostTypeAttachmentTaxonomy] ADD  CONSTRAINT [DF_CMS.Post.Type..Attachment.Taxonomy]]_IsEnabled]  DEFAULT ((0)) FOR [IsEnabled]