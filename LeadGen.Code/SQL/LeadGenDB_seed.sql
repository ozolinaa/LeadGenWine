USE [LeadGenDB]

GO
INSERT [dbo].[NotificationFrequency] ([ID], [Name]) VALUES (1, N'Immediate')
INSERT [dbo].[NotificationFrequency] ([ID], [Name]) VALUES (2, N'Hourly')
INSERT [dbo].[NotificationFrequency] ([ID], [Name]) VALUES (3, N'Daily')
INSERT [dbo].[NotificationFrequency] ([ID], [Name]) VALUES (4, N'DoNotNotify')

GO
INSERT [dbo].[UserRole] ([RoleID], [RoleName], [RoleCode]) VALUES (1, N'system_admin', N'system_admin')
INSERT [dbo].[UserRole] ([RoleID], [RoleName], [RoleCode]) VALUES (2, N'business_admin', N'business_admin')

SET IDENTITY_INSERT [dbo].[UserLogin] ON 
INSERT [dbo].[UserLogin] ([LoginID], [RoleID], [Email], [PasswordHash], [RegistrationDate], [EmailConfirmationDate]) VALUES (1, 1, N'admin@admin.admin', N'admin@admin.admin', CAST(N'2016-08-27 14:15:07.620' AS DateTime), CAST(N'2016-08-27 14:15:07.620' AS DateTime))
SET IDENTITY_INSERT [dbo].[UserLogin] OFF

INSERT [dbo].[CMSAttachmentImageSize] ([ImageSizeID], [Code], [MaxHeight], [MaxWidth], [CropMode]) VALUES (1, N'Thumbnail', 250, 250, NULL)
INSERT [dbo].[CMSAttachmentImageSize] ([ImageSizeID], [Code], [MaxHeight], [MaxWidth], [CropMode]) VALUES (2, N'Medium', 600, 500, NULL)
INSERT [dbo].[CMSAttachmentImageSize] ([ImageSizeID], [Code], [MaxHeight], [MaxWidth], [CropMode]) VALUES (3, N'Large', 1200, 1000, NULL)

INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (3, N'Bool')
INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (2, N'Datetime')
INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (5, N'Location')
INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (4, N'Number')
INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (1, N'Text')

INSERT [dbo].[CMSPostStatus] ([StatusID], [StatusName]) VALUES (0, N'Trash')
INSERT [dbo].[CMSPostStatus] ([StatusID], [StatusName]) VALUES (10, N'Draft')
INSERT [dbo].[CMSPostStatus] ([StatusID], [StatusName]) VALUES (30, N'Pending')
INSERT [dbo].[CMSPostStatus] ([StatusID], [StatusName]) VALUES (50, N'Published')

INSERT [dbo].[CMSSitemapChangeFrequency] ([ID], [Frequency]) VALUES (1, N'Always')
INSERT [dbo].[CMSSitemapChangeFrequency] ([ID], [Frequency]) VALUES (2, N'Hourly')
INSERT [dbo].[CMSSitemapChangeFrequency] ([ID], [Frequency]) VALUES (3, N'Daily')
INSERT [dbo].[CMSSitemapChangeFrequency] ([ID], [Frequency]) VALUES (4, N'Weekly')
INSERT [dbo].[CMSSitemapChangeFrequency] ([ID], [Frequency]) VALUES (5, N'Monthly')
INSERT [dbo].[CMSSitemapChangeFrequency] ([ID], [Frequency]) VALUES (6, N'Yearly')
INSERT [dbo].[CMSSitemapChangeFrequency] ([ID], [Frequency]) VALUES (7, N'Never')


INSERT [dbo].[LeadFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (1, N'Textbox')
INSERT [dbo].[LeadFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (2, N'Dropdown')
INSERT [dbo].[LeadFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (3, N'Checkbox')
INSERT [dbo].[LeadFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (4, N'Radio')
INSERT [dbo].[LeadFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (5, N'Boolean')
INSERT [dbo].[LeadFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (6, N'Datetime')
INSERT [dbo].[LeadFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (7, N'Number')


INSERT [dbo].[CMSAttachmentType] ([AttachmentTypeID], [AttachmentTypeName]) VALUES (1, N'Image')
INSERT [dbo].[CMSAttachmentType] ([AttachmentTypeID], [AttachmentTypeName]) VALUES (2, N'Audio')
INSERT [dbo].[CMSAttachmentType] ([AttachmentTypeID], [AttachmentTypeName]) VALUES (3, N'Other')


INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (1, N'Yearly')
INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (2, N'Monthly')
INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (3, N'Weekly')
INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (4, N'Daily')
INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (5, N'Hourly')
INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (6, N'Minutely')

EXEC [dbo].[SysOptionInsertOrUpdate] N'SystemAccessToken', N'12345'
EXEC [dbo].[SysOptionInsertOrUpdate] N'AzureStorageConnectionString', N'DefaultEndpointsProtocol=https;AccountName=winecellarspro;AccountKey=Q/U0N3aSXbcjpFReEXkRsvipIJZmp93afK+V7oXLinUg7vw1I7IxsLhXLVjpG47lDDRl7WAl9ziiBLfTHH3SYQ==;EndpointSuffix=core.windows.net'
EXEC [dbo].[SysOptionInsertOrUpdate] N'AzureStorageHostName', N'https://winecellarspro.blob.core.windows.net'
EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailFromName', N'WineCellars.Pro'
EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailFromAddress', N'noreply@winecellars.pro'
EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailReplyToAddress', N'anton.ozolin@winecellars.pro'
EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailSmtpEnableSsl', N'true'
EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailSmtpHost', N'email-smtp.us-west-2.amazonaws.com'
EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailSmtpUserName', N'AKIA5TEQIYORAPNX5QRU'
EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailSmtpPassword', N'BM7/Zb+IUGpwf/CGsTelGqx8x8E9XGdRHulsenVnjhfc'
EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailSmtpPort', N'587'
EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailSmtpSendIntervalMilliseconds', N'1000'
EXEC [dbo].[SysOptionInsertOrUpdate] N'GoogleMapsAPIKey', N'AIzaSyAnypsez9yrFjc16DCZK90v2-hC6Q_j5jk'
EXEC [dbo].[SysOptionInsertOrUpdate] N'LeadApprovalLocationEnabled', N'true'
EXEC [dbo].[SysOptionInsertOrUpdate] N'LeadSystemFeeDefaultPercent', N'5'
EXEC [dbo].[SysOptionInsertOrUpdate] N'LeadFieldMappingLocationZip', N'address_zip'

SET IDENTITY_INSERT [dbo].[Taxonomy] ON 
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (1, N'cms_category', N'Category', 0)
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (2, N'cms_tag', N'Tag', 1)
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (3, N'city', N'City', 0)
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (4, N'layout_location', N'Layout Location', 0)
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (5, N'cellar_type', N'Cellar Type', 0)
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (6, N'cellar_material', N'Cellar Material', 0)
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (7, N'cellar_accessories', N'Cellar Accessories', 0)
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (8, N'price_range', N'Price Range', 0)
INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (9, N'legal_entity', N'Legal Entity', 0)
SET IDENTITY_INSERT [dbo].[Taxonomy] OFF


SET IDENTITY_INSERT [dbo].[TaxonomyTerm] ON 
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (1, 3, N'USA', N'usa', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (2, 4, N'Right Sidebar', N'right-sidebar', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (3, 4, N'Under Post Content', N'under-post-content', NULL, NULL)

INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (4, 5, N'Dedicated Room', N'room', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (5, 5, N'Wine Cabinet', N'cabinet', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (6, 5, N'Wine Racks', N'rack', NULL, NULL)

INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (7, 6, N'Wood', N'wood', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (8, 6, N'Glass/Metal', N'glass_metal', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (9, 6, N'Wrought Iron', N'iron_wrought', NULL, NULL)

INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (10, 7, N'Tables, Chairs', N'furniture', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (12, 7, N'Glasses, Bottles', N'glasses_bottles', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (11, 7, N'Decor', N'decor', NULL, NULL)

INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (13, 8, N'Low', N'low', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (14, 8, N'Medium', N'medium', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (15, 8, N'Premium', N'premium', NULL, NULL)

INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (16, 9, N'Residential', N'residential', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (17, 9, N'Business', N'business', NULL, NULL)
INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (18, 3, N'California', N'ca', NULL, 1)

SET IDENTITY_INSERT [dbo].[TaxonomyTerm] OFF

--Allow Terms in the 
INSERT INTO [dbo].[LeadFieldMetaTermsAllowed] ([TermID]) VALUES 
(4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15), (16), (17);


SET IDENTITY_INSERT [dbo].[LeadFieldStructureGroup] ON 
INSERT [dbo].[LeadFieldStructureGroup] ([GroupID], [GroupCode], [GroupTitle]) VALUES (1, N'cellar_type', N'Cellar Details')
INSERT [dbo].[LeadFieldStructureGroup] ([GroupID], [GroupCode], [GroupTitle]) VALUES (2, N'order_type', N'Order Details')
INSERT [dbo].[LeadFieldStructureGroup] ([GroupID], [GroupCode], [GroupTitle]) VALUES (3, N'contacts', N'Contact Details')


SET IDENTITY_INSERT [dbo].[LeadFieldStructureGroup] OFF

INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (1, 1, N'cellar_type', N'Cellar Type', 3, N'Cellar Type', 1, 0, 1, NULL, 1)
INSERT [dbo].[LeadFieldMetaChekbox] ([FieldID], [TaxonomyID], [TermParentID]) VALUES (1, 5, NULL)

INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (2, 1, N'cellar_material', N'Material', 3, N'Cellar Material', 1, 0, 1, NULL, 2)
INSERT [dbo].[LeadFieldMetaChekbox] ([FieldID], [TaxonomyID], [TermParentID]) VALUES (2, 6, NULL)

INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (3, 1, N'cellar_accessories', N'Accessories', 3, N'Accessories', 0, 0, 1, NULL, 3)
INSERT [dbo].[LeadFieldMetaChekbox] ([FieldID], [TaxonomyID], [TermParentID]) VALUES (3, 7, NULL)

---

INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (4, 2, N'price_range', N'Price Range', 2, N'Price Range', 1, 0, 1, NULL, 1)
INSERT [dbo].[LeadFieldMetaDropdown] ([FieldID], [TaxonomyID], [Placeholder], [TermParentID], [TermDepthMaxLevel]) VALUES (4, 8,  N'Select Price Range', NULL, NULL)

INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (5, 2, N'legal_entity', N'Status', 4, N'Status', 1, 0, 1, NULL, 2)
INSERT [dbo].[LeadFieldMetaRadio] ([FieldID], [TaxonomyID], [TermParentID]) VALUES (5, 9, NULL)

INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (6, 2, N'address_zip', N'ZIP', 7, N'ZIP', 1, 0, 1, NULL, 3)
INSERT [dbo].[LeadFieldMetaNumber] ([FieldID], [Placeholder]) VALUES (6, N'ZIP')

---

INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (7, 3, N'name', N'Name', 1 , N'Your Name', 1, 1, 1, NULL, 1)
INSERT [dbo].[LeadFieldMetaTextbox] ([FieldID], [Placeholder]) VALUES (7, N'Your Name')

INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (8, 3, N'phone', N'Phone', 7, N'Your Phone', 0, 1, 1, NULL, 2)
INSERT [dbo].[LeadFieldMetaNumber] ([FieldID], [Placeholder]) VALUES (8, N'Phone')

SET IDENTITY_INSERT [dbo].[CMSPostType] ON
INSERT [dbo].[CMSPostType] ([TypeID],  [TypeCode], [TypeName], [TypeURL], [SeoTitle], [SeoMetaDescription], [SeoMetaKeywords], [SeoPriority], [SeoChangeFrequencyID], [PostSeoTitle], [PostSeoMetaDescription], [PostSeoMetaKeywords], [PostSeoPriority], [PostSeoChangeFrequencyID], [HasContentIntro], [HasContentEnding], [ForTaxonomyID], [ForPostTypeID]) VALUES (1, N'page', N'Page', N'', NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, 0, 0, NULL, NULL)
INSERT [dbo].[CMSPostType] ([TypeID],  [TypeCode], [TypeName], [TypeURL], [SeoTitle], [SeoMetaDescription], [SeoMetaKeywords], [SeoPriority], [SeoChangeFrequencyID], [PostSeoTitle], [PostSeoMetaDescription], [PostSeoMetaKeywords], [PostSeoPriority], [PostSeoChangeFrequencyID], [HasContentIntro], [HasContentEnding], [ForTaxonomyID], [ForPostTypeID]) VALUES (2, N'widget', N'Widget', N'widget', NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, 1, 0, NULL, NULL)
SET IDENTITY_INSERT [dbo].[CMSPostType] OFF


INSERT INTO [dbo].[LeadReviewMeasure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (1, N'Price' ,1)
INSERT INTO [dbo].[LeadReviewMeasure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (2, N'Quality' ,2)
INSERT INTO [dbo].[LeadReviewMeasure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (3, N'Speed' ,3)
INSERT INTO [dbo].[LeadReviewMeasure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (4, N'Comfort' ,4)



INSERT [dbo].[LeadGenLegal] ([LegalCountryID], [LegalAddress], [LegalName], [LegalCode1], [LegalCode2], [LegalBankAccount], [LegalBankCode1], [LegalBankCode2], [LegalBankName]) VALUES (1, N'Legal Address Value', N'Company Name', N'Code1', N'Code2', N'BankCode', N'BankCode2', N'BankAccount', N'Bank Name')





