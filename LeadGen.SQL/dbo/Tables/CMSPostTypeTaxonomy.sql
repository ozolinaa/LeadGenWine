CREATE TABLE [dbo].[CMSPostTypeTaxonomy](
	[PostTypeID] [int] NOT NULL,
	[ForPostTypeID] [int] NOT NULL,
	[ForTaxonomyID] [int] NOT NULL,
	[IsEnabled] [bit] NOT NULL,
 CONSTRAINT [PK_CMSPostTypeTaxonomy] PRIMARY KEY CLUSTERED 
(
	[PostTypeID] ASC,
	[ForPostTypeID] ASC,
	[ForTaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMSPostTypeTaxonomy]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type.Taxonomy_CMS.Taxonomy] FOREIGN KEY([ForTaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO

ALTER TABLE [dbo].[CMSPostTypeTaxonomy] CHECK CONSTRAINT [FK_CMS.Post.Type.Taxonomy_CMS.Taxonomy]
GO
ALTER TABLE [dbo].[CMSPostTypeTaxonomy] ADD  CONSTRAINT [DF_CMS.Post.Type.Taxonomy_IsDisabled]  DEFAULT ((1)) FOR [IsEnabled]
GO
/****** Object:  Index [IX_CMSPostTypeTaxonomy]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CMSPostTypeTaxonomy] ON [dbo].[CMSPostTypeTaxonomy]
(
	[PostTypeID] ASC,
	[ForTaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]