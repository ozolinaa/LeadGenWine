USE [WineLeadGen]

GO
INSERT [dbo].[Notification.Frequency] ([ID], [Name]) VALUES (1, N'Immediate')
INSERT [dbo].[Notification.Frequency] ([ID], [Name]) VALUES (2, N'Hourly')
INSERT [dbo].[Notification.Frequency] ([ID], [Name]) VALUES (3, N'Daily')
INSERT [dbo].[Notification.Frequency] ([ID], [Name]) VALUES (4, N'DoNotNotify')

GO
INSERT [dbo].[User.Role] ([RoleID], [RoleName], [RoleCode]) VALUES (1, N'system_admin', N'system_admin')
INSERT [dbo].[User.Role] ([RoleID], [RoleName], [RoleCode]) VALUES (2, N'business_admin', N'business_admin')

SET IDENTITY_INSERT [dbo].[User.Login] ON 
INSERT [dbo].[User.Login] ([LoginID], [RoleID], [Email], [PasswordHash], [RegistrationDate], [EmailConfirmationDate]) VALUES (1, 1, N'admin@admin.admin', N'admin@admin.admin', CAST(N'2016-08-27 14:15:07.620' AS DateTime), CAST(N'2016-08-27 14:15:07.620' AS DateTime))
SET IDENTITY_INSERT [dbo].[User.Login] OFF

INSERT [dbo].[CMS.Attachment.Image.Size] ([ImageSizeID], [Code], [MaxHeight], [MaxWidth], [CropMode]) VALUES (1, N'Thumbnail', 250, 250, NULL)
INSERT [dbo].[CMS.Attachment.Image.Size] ([ImageSizeID], [Code], [MaxHeight], [MaxWidth], [CropMode]) VALUES (2, N'Medium', 600, 500, NULL)
INSERT [dbo].[CMS.Attachment.Image.Size] ([ImageSizeID], [Code], [MaxHeight], [MaxWidth], [CropMode]) VALUES (3, N'Large', 1200, 1000, NULL)

INSERT [dbo].[CMS.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (3, N'Bool')
INSERT [dbo].[CMS.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (2, N'Datetime')
INSERT [dbo].[CMS.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (5, N'Location')
INSERT [dbo].[CMS.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (4, N'Number')
INSERT [dbo].[CMS.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (1, N'Text')

INSERT [dbo].[CMS.Post.Status] ([StatusID], [StatusName]) VALUES (0, N'Trash')
INSERT [dbo].[CMS.Post.Status] ([StatusID], [StatusName]) VALUES (10, N'Draft')
INSERT [dbo].[CMS.Post.Status] ([StatusID], [StatusName]) VALUES (30, N'Pending')
INSERT [dbo].[CMS.Post.Status] ([StatusID], [StatusName]) VALUES (50, N'Published')

INSERT [dbo].[CMS.Sitemap.ChangeFrequency] ([ID], [Frequency]) VALUES (1, N'Always')
INSERT [dbo].[CMS.Sitemap.ChangeFrequency] ([ID], [Frequency]) VALUES (2, N'Hourly')
INSERT [dbo].[CMS.Sitemap.ChangeFrequency] ([ID], [Frequency]) VALUES (3, N'Daily')
INSERT [dbo].[CMS.Sitemap.ChangeFrequency] ([ID], [Frequency]) VALUES (4, N'Weekly')
INSERT [dbo].[CMS.Sitemap.ChangeFrequency] ([ID], [Frequency]) VALUES (5, N'Monthly')
INSERT [dbo].[CMS.Sitemap.ChangeFrequency] ([ID], [Frequency]) VALUES (6, N'Yearly')
INSERT [dbo].[CMS.Sitemap.ChangeFrequency] ([ID], [Frequency]) VALUES (7, N'Never')


INSERT [dbo].[Lead.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (1, N'Textbox')
INSERT [dbo].[Lead.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (2, N'Dropdown')
INSERT [dbo].[Lead.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (3, N'Checkbox')
INSERT [dbo].[Lead.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (4, N'Radio')
INSERT [dbo].[Lead.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (5, N'Boolean')
INSERT [dbo].[Lead.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (6, N'Datetime')
INSERT [dbo].[Lead.Field.Type] ([FieldTypeID], [FieldTypeName]) VALUES (7, N'Number')


INSERT [dbo].[CMS.Attachment.Type] ([AttachmentTypeID], [AttachmentTypeName]) VALUES (1, N'Image')
INSERT [dbo].[CMS.Attachment.Type] ([AttachmentTypeID], [AttachmentTypeName]) VALUES (2, N'Audio')
INSERT [dbo].[CMS.Attachment.Type] ([AttachmentTypeID], [AttachmentTypeName]) VALUES (3, N'Other')


INSERT [dbo].[System.ScheduledTaskInterval] ([ID], [Name]) VALUES (1, N'Yearly')
INSERT [dbo].[System.ScheduledTaskInterval] ([ID], [Name]) VALUES (2, N'Monthly')
INSERT [dbo].[System.ScheduledTaskInterval] ([ID], [Name]) VALUES (3, N'Weekly')
INSERT [dbo].[System.ScheduledTaskInterval] ([ID], [Name]) VALUES (4, N'Daily')
INSERT [dbo].[System.ScheduledTaskInterval] ([ID], [Name]) VALUES (5, N'Hourly')
INSERT [dbo].[System.ScheduledTaskInterval] ([ID], [Name]) VALUES (6, N'Minutely')

EXEC [dbo].[Sys.Option.InsertOrUpdate] N'systemAccessToken', N'12345'



SET IDENTITY_INSERT [dbo].[Taxonomy] ON 
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (1, N'cms_category', N'Category', 0)
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (2, N'cms_tag', N'Tag', 1)
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (3, N'city', N'City', 0)
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (4, N'layout_location', N'Layout Location', 0)
SET IDENTITY_INSERT [dbo].[Taxonomy] OFF


SET IDENTITY_INSERT [dbo].[Taxonomy.Term] ON 
INSERT [dbo].[Taxonomy.Term] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (1, 3, N'USA', N'usa', NULL, NULL)
INSERT [dbo].[Taxonomy.Term] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (2, 4, N'Right Sidebar', N'right-sidebar', NULL, NULL)
INSERT [dbo].[Taxonomy.Term] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (3, 4, N'Under Post Content', N'under-post-content', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Taxonomy.Term] OFF



SET IDENTITY_INSERT [dbo].[CMS.Post.Type] ON
INSERT [dbo].[CMS.Post.Type] ([TypeID],  [TypeCode], [TypeName], [TypeURL], [SeoTitle], [SeoMetaDescription], [SeoMetaKeywords], [SeoPriority], [SeoChangeFrequencyID], [PostSeoTitle], [PostSeoMetaDescription], [PostSeoMetaKeywords], [PostSeoPriority], [PostSeoChangeFrequencyID], [HasContentIntro], [HasContentEnding], [ForTaxonomyID], [ForPostTypeID]) VALUES (1, N'page', N'Page', N'', NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, 0, 0, NULL, NULL)
INSERT [dbo].[CMS.Post.Type] ([TypeID],  [TypeCode], [TypeName], [TypeURL], [SeoTitle], [SeoMetaDescription], [SeoMetaKeywords], [SeoPriority], [SeoChangeFrequencyID], [PostSeoTitle], [PostSeoMetaDescription], [PostSeoMetaKeywords], [PostSeoPriority], [PostSeoChangeFrequencyID], [HasContentIntro], [HasContentEnding], [ForTaxonomyID], [ForPostTypeID]) VALUES (2, N'widget', N'Widget', N'widget', NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, 1, 0, NULL, NULL)
SET IDENTITY_INSERT [dbo].[CMS.Post.Type] OFF


INSERT INTO [dbo].[Lead.Review.Measure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (1, N'Price' ,1)
INSERT INTO [dbo].[Lead.Review.Measure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (2, N'Quality' ,2)
INSERT INTO [dbo].[Lead.Review.Measure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (3, N'Speed' ,3)
INSERT INTO [dbo].[Lead.Review.Measure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (4, N'Comfort' ,4)



INSERT [dbo].[LeadGen.Legal] ([LegalCountryID], [LegalAddress], [LegalName], [LegalCode1], [LegalCode2], [LegalBankAccount], [LegalBankCode1], [LegalBankCode2], [LegalBankName]) VALUES (1, N'Legal Address Value', N'Company Name', N'Code1', N'Code2', N'BankCode', N'BankCode2', N'BankAccount', N'Bank Name')





