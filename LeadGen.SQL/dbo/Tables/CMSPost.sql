CREATE TABLE [dbo].[CMSPost](
	[PostID] [bigint] IDENTITY(1,1) NOT NULL,
	[PostParentID] [bigint] NULL,
	[TypeID] [int] NOT NULL,
	[StatusID] [int] NOT NULL,
	[AuthorID] [bigint] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DatePublished] [datetime] NULL,
	[DateLastModified] [datetime] NOT NULL,
	[Title] [nvarchar](255) NOT NULL,
	[ContentIntro] [nvarchar](max) NULL,
	[ContentPreview] [nvarchar](max) NULL,
	[ContentMain] [nvarchar](max) NOT NULL,
	[ContentEnding] [nvarchar](max) NULL,
	[CustomCSS] [nvarchar](max) NULL,
	[PostURL] [nvarchar](100) NOT NULL,
	[SeoTitle] [nvarchar](255) NULL,
	[SeoMetaDescription] [nvarchar](500) NULL,
	[SeoMetaKeywords] [nvarchar](500) NULL,
	[SeoPriority] [decimal](2, 1) NULL,
	[SeoChangeFrequencyID] [int] NULL,
	[ThumbnailAttachmentID] [bigint] NULL,
	[PostForTermID] [bigint] NULL,
	[PostForTaxonomyID] [int] NULL,
	[Order] [int] NOT NULL,
 CONSTRAINT [PK_CMSPost] PRIMARY KEY CLUSTERED 
(
	[PostID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSPost] UNIQUE NONCLUSTERED 
(
	[PostID] ASC,
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSPost_1] UNIQUE NONCLUSTERED 
(
	[PostURL] ASC,
	[TypeID] ASC,
	[PostParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post] FOREIGN KEY([PostParentID])
REFERENCES [dbo].[CMSPost] ([PostID])
GO

ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post.Status] FOREIGN KEY([StatusID])
REFERENCES [dbo].[CMSPostStatus] ([StatusID])
GO

ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post.Status]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post.Type] FOREIGN KEY([TypeID])
REFERENCES [dbo].[CMSPostType] ([TypeID])
GO

ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post.Type]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post.Type.Taxonomy] FOREIGN KEY([TypeID], [PostForTaxonomyID])
REFERENCES [dbo].[CMSPostTypeTaxonomy] ([PostTypeID], [ForTaxonomyID])
GO

ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post.Type.Taxonomy]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_SEO.Sitemap.ChangeFrequency] FOREIGN KEY([SeoChangeFrequencyID])
REFERENCES [dbo].[CMSSitemapChangeFrequency] ([ID])
GO

ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_SEO.Sitemap.ChangeFrequency]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_Taxonomy.Term] FOREIGN KEY([PostForTermID], [PostForTaxonomyID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID])
GO

ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_Taxonomy.Term]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_User.Login] FOREIGN KEY([AuthorID])
REFERENCES [dbo].[UserLogin] ([LoginID])
GO

ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_User.Login]
GO
ALTER TABLE [dbo].[CMSPost] ADD  CONSTRAINT [DF_CMS.Post_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[CMSPost] ADD  CONSTRAINT [DF_CMS.Post_DateLastModified]  DEFAULT (getutcdate()) FOR [DateLastModified]
GO
ALTER TABLE [dbo].[CMSPost] ADD  CONSTRAINT [DF_CMS.Post_Order]  DEFAULT ((0)) FOR [Order]
GO
/****** Object:  Index [IX_CMSPost_2]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_CMSPost_2] ON [dbo].[CMSPost]
(
	[TypeID] ASC,
	[Order] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [SelectIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [SelectIndex] ON [dbo].[CMSPost]
(
	[TypeID] ASC
)
INCLUDE ( 	[PostID],
	[PostParentID],
	[StatusID],
	[PostURL],
	[PostForTermID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]