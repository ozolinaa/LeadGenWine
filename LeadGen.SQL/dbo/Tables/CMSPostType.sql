CREATE TABLE [dbo].[CMSPostType](
	[TypeID] [int] IDENTITY(1,1) NOT NULL,
	[TypeCode] [nvarchar](50) NOT NULL,
	[TypeName] [nvarchar](50) NOT NULL,
	[TypeURL] [nvarchar](50) NOT NULL,
	[IsBrowsable] [bit] NOT NULL,
	[SeoTitle] [nvarchar](255) NULL,
	[SeoMetaDescription] [nvarchar](500) NULL,
	[SeoMetaKeywords] [nvarchar](500) NULL,
	[SeoPriority] [decimal](2, 1) NOT NULL,
	[SeoChangeFrequencyID] [int] NOT NULL,
	[PostSeoTitle] [nvarchar](255) NULL,
	[PostSeoMetaDescription] [nvarchar](500) NULL,
	[PostSeoMetaKeywords] [nvarchar](500) NULL,
	[PostSeoPriority] [decimal](2, 1) NOT NULL,
	[PostSeoChangeFrequencyID] [int] NOT NULL,
	[HasContentIntro] [bit] NOT NULL,
	[HasContentEnding] [bit] NOT NULL,
	[ForTaxonomyID] [int] NULL,
	[ForPostTypeID] [int] NULL,
 CONSTRAINT [PK_CMSPostType] PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSPostType_1] UNIQUE NONCLUSTERED 
(
	[TypeURL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSPostType_2] UNIQUE NONCLUSTERED 
(
	[TypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMSPostType]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type_CMS.Post.Type.Taxonomy] FOREIGN KEY([TypeID], [ForPostTypeID], [ForTaxonomyID])
REFERENCES [dbo].[CMSPostTypeTaxonomy] ([PostTypeID], [ForPostTypeID], [ForTaxonomyID])
GO

ALTER TABLE [dbo].[CMSPostType] CHECK CONSTRAINT [FK_CMS.Post.Type_CMS.Post.Type.Taxonomy]
GO
ALTER TABLE [dbo].[CMSPostType]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type_CMS.Sitemap.ChangeFrequency] FOREIGN KEY([PostSeoChangeFrequencyID])
REFERENCES [dbo].[CMSSitemapChangeFrequency] ([ID])
GO

ALTER TABLE [dbo].[CMSPostType] CHECK CONSTRAINT [FK_CMS.Post.Type_CMS.Sitemap.ChangeFrequency]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_TypeCode]  DEFAULT ('') FOR [TypeCode]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_IsBrowsable]  DEFAULT ((0)) FOR [IsBrowsable]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_SeoPriority]  DEFAULT ((0.5)) FOR [SeoPriority]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_SeoChangeFrequencyID]  DEFAULT ((4)) FOR [SeoChangeFrequencyID]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_PostSeoPriority]  DEFAULT ((0.5)) FOR [PostSeoPriority]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_PostSeoChangeFrequencyID]  DEFAULT ((4)) FOR [PostSeoChangeFrequencyID]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_HasContentIntro]  DEFAULT ((0)) FOR [HasContentIntro]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_HasContentEnding]  DEFAULT ((0)) FOR [HasContentEnding]
GO
/****** Object:  Index [IX_CMSPostType]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CMSPostType] ON [dbo].[CMSPostType]
(
	[TypeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]