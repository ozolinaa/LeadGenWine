IF (NOT EXISTS (SELECT 1 FROM [dbo].[SystemOptions] WHERE OptionKey = 'LeadApprovalLocationEnabled')) BEGIN

	EXEC [dbo].[SysOptionInsertOrUpdate] N'LeadApprovalLocationEnabled', N'true'
	EXEC [dbo].[SysOptionInsertOrUpdate] N'LeadSystemFeeDefaultPercent', N'5'
	EXEC [dbo].[SysOptionInsertOrUpdate] N'LeadFieldMappingLocationZip', N'address_zip'

	SET IDENTITY_INSERT [dbo].[Taxonomy] ON 
	INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (1, N'category', N'Category', 0)
	INSERT [dbo].[Taxonomy] ([TaxonomyID], [TaxonomyCode], [TaxonomyName], [IsTag]) VALUES (2, N'tag', N'Tag', 1)
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

	INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (4, 5, N'Room', N'room', NULL, NULL)
	INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (5, 5, N'Cabinet', N'cabinet', NULL, NULL)
	INSERT [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID], [TermName], [TermURL], [TermThumbnailURL], [TermParentID]) VALUES (6, 5, N'Racks', N'rack', NULL, NULL)

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
	INSERT [dbo].[LeadFieldStructureGroup] ([GroupID], [GroupCode], [GroupTitle]) VALUES (1, N'cellar_type', N'Wine Cellar Design')
	INSERT [dbo].[LeadFieldStructureGroup] ([GroupID], [GroupCode], [GroupTitle]) VALUES (2, N'order_type', N'Order Details')
	INSERT [dbo].[LeadFieldStructureGroup] ([GroupID], [GroupCode], [GroupTitle]) VALUES (3, N'contacts', N'Contact Details')


	SET IDENTITY_INSERT [dbo].[LeadFieldStructureGroup] OFF

	INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (1, 1, N'cellar_type', N'Cellar Type', 3, N'Cellar Type', 1, 0, 1, NULL, 1)
	INSERT [dbo].[LeadFieldMetaChekbox] ([FieldID], [TaxonomyID], [TermParentID]) VALUES (1, 5, NULL)

	INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (2, 1, N'climate_required', N'Climate System Required', 5, N'Climate System Required?', 0, 0, 1, NULL, 2)

	INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (3, 1, N'cellar_material', N'Material', 3, N'Cellar Material', 1, 0, 1, NULL, 3)
	INSERT [dbo].[LeadFieldMetaChekbox] ([FieldID], [TaxonomyID], [TermParentID]) VALUES (3, 6, NULL)

	INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (4, 1, N'cellar_accessories', N'Accessories', 3, N'Accessories', 0, 0, 1, NULL, 4)
	INSERT [dbo].[LeadFieldMetaChekbox] ([FieldID], [TaxonomyID], [TermParentID]) VALUES (4, 7, NULL)

	INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (5, 1, N'cellar_comment', N'Comment', 8 , N'Comment', 0, 0, 1, NULL, 5)
	INSERT [dbo].[LeadFieldMetaTextarea] ([FieldID], [Placeholder]) VALUES (5, N'Want anything specific?')
	
	---

	INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (6, 2, N'price_range', N'Price Range', 2, N'Price Range', 0, 0, 0, NULL, 1)
	INSERT [dbo].[LeadFieldMetaDropdown] ([FieldID], [TaxonomyID], [Placeholder], [TermParentID], [TermDepthMaxLevel]) VALUES (6, 8,  N'Select Price Range', NULL, NULL)

	INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (7, 2, N'legal_entity', N'Status', 4, N'Status', 0, 0, 0, NULL, 2)
	INSERT [dbo].[LeadFieldMetaRadio] ([FieldID], [TaxonomyID], [TermParentID]) VALUES (7, 9, NULL)

	---

	INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (8, 3, N'name', N'Name', 1 , N'Your Name', 1, 1, 1, NULL, 1)
	INSERT [dbo].[LeadFieldMetaTextbox] ([FieldID], [Placeholder]) VALUES (8, N'Your Name')

	INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (9, 3, N'address_zip', N'ZIP', 7, N'ZIP', 1, 0, 1, NULL, 2)
	INSERT [dbo].[LeadFieldMetaNumber] ([FieldID], [Placeholder]) VALUES (9, N'ZIP')

	INSERT [dbo].[LeadFieldStructure] ([FieldID], [GroupID], [FieldCode], [FieldName], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive], [Description], [Order]) VALUES (10, 3, N'phone', N'Phone', 7, N'Your Phone', 0, 1, 1, NULL, 3)
	INSERT [dbo].[LeadFieldMetaNumber] ([FieldID], [Placeholder]) VALUES (10, N'Phone')

	SET IDENTITY_INSERT [dbo].[CMSPostType] ON
	INSERT [dbo].[CMSPostType] ([TypeID],  [TypeCode], [TypeName], [TypeURL], [SeoTitle], [SeoMetaDescription], [SeoMetaKeywords], [SeoPriority], [SeoChangeFrequencyID], [PostSeoTitle], [PostSeoMetaDescription], [PostSeoMetaKeywords], [PostSeoPriority], [PostSeoChangeFrequencyID], [HasContentIntro], [HasContentEnding], [ForTaxonomyID], [ForPostTypeID], [IsBrowsable]) VALUES (1, N'page', N'Page', N'', NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, 0, 0, NULL, NULL, 1)
	INSERT [dbo].[CMSPostType] ([TypeID],  [TypeCode], [TypeName], [TypeURL], [SeoTitle], [SeoMetaDescription], [SeoMetaKeywords], [SeoPriority], [SeoChangeFrequencyID], [PostSeoTitle], [PostSeoMetaDescription], [PostSeoMetaKeywords], [PostSeoPriority], [PostSeoChangeFrequencyID], [HasContentIntro], [HasContentEnding], [ForTaxonomyID], [ForPostTypeID], [IsBrowsable]) VALUES (2, N'widget', N'Widget', N'widget', NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, 1, 0, NULL, NULL, 0)
	INSERT [dbo].[CMSPostType] ([TypeID],  [TypeCode], [TypeName], [TypeURL], [SeoTitle], [SeoMetaDescription], [SeoMetaKeywords], [SeoPriority], [SeoChangeFrequencyID], [PostSeoTitle], [PostSeoMetaDescription], [PostSeoMetaKeywords], [PostSeoPriority], [PostSeoChangeFrequencyID], [HasContentIntro], [HasContentEnding], [ForTaxonomyID], [ForPostTypeID], [IsBrowsable]) VALUES (3, N'company', N'Company', N'companies', NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, NULL, NULL, NULL, CAST(0.5 AS Decimal(2, 1)), 3, 1, 1, NULL, NULL, 1)
	SET IDENTITY_INSERT [dbo].[CMSPostType] OFF


	--COMPANY - CITY - postType
	DECLARE	@return_value int,
			@Result bit
	EXEC	@return_value = [dbo].[CMSPostTypeTaxonomyAddOrUpdate]
			@ForPostTypeID = 3,
			@ForTaxonomyID = 3,
			@SeoTitle = NULL,
			@SeoMetaDescription = NULL,
			@SeoMetaKeywords = NULL,
			@SeoChangeFrequencyID = 4,
			@SeoPriority = 0.5,
			@URL = N'companies',
			@Result = @Result OUTPUT

	--INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (1, N'Text')
	--INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (2, N'Datetime')
	--INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (3, N'Bool')
	--INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (4, N'Number')
	--INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (5, N'Location')

	--DELETE FROM [dbo].[CMSPostTypeFieldStructure]
	SET IDENTITY_INSERT [dbo].[CMSPostTypeFieldStructure] ON 
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (1, 3, 1, N'company_web_site_official', N'Web-Site - Official')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (2, 3, 1, N'company_web_site_other', N'Web-Site - Other')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (3, 3, 4, N'company_public_phone', N'Public Phone')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (4, 3, 1, N'company_public_email', N'Public Email')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (5, 3, 4, N'company_notification_phone', N'Notification Phone')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (6, 3, 1, N'company_notification_email', N'Notification Email')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (7, 3, 5, N'company_notification_location', N'Notification Location')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (8, 3, 3, N'company_notification_do_not_send_leads', N'Do not send lead notifications')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (9, 3, 4, N'company_businessId', N'BusinessId')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (10, 3, 1, N'company_crmId', N'CRMId')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (11, 4, 5, N'company_city_location', N'Location')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (12, 2, 1, N'widget_exclude_render_at_url', N'Exclude Render at URL')
	INSERT [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID], [FieldTypeID], [FieldCode], [FieldLabelText]) VALUES (13, 3, 3, N'company_notification_allow_send_leads', N'Allow to send lead notifications')
	SET IDENTITY_INSERT [dbo].[CMSPostTypeFieldStructure] OFF


	INSERT INTO [dbo].[LeadReviewMeasure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (1, N'Price' ,1)
	INSERT INTO [dbo].[LeadReviewMeasure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (2, N'Quality' ,2)
	INSERT INTO [dbo].[LeadReviewMeasure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (3, N'Speed' ,3)
	INSERT INTO [dbo].[LeadReviewMeasure] ([MeasureID] ,[MeasureName] ,[Order]) VALUES (4, N'Comfort' ,4)


	INSERT [dbo].[LeadGenLegal] ([LegalCountryID], [LegalAddress], [LegalName], [LegalCode1], [LegalCode2], [LegalBankAccount], [LegalBankCode1], [LegalBankCode2], [LegalBankName]) VALUES (1, N'Legal Address Value', N'Company Name', N'Code1', N'Code2', N'BankCode', N'BankCode2', N'BankAccount', N'Bank Name')

	EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailFromName', N'WineCellars.Pro'
	EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailFromAddress', N'noreply@winecellars.pro'
	EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailReplyToAddress', N'anton.ozolin@winecellars.pro'
	EXEC [dbo].[SysOptionInsertOrUpdate] N'EmailSmtpSendIntervalMilliseconds', N'15'

	EXEC [dbo].[SysOptionInsertOrUpdate] N'CMSHtmlHeadInjection', N''

END
