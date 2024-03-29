IF (NOT EXISTS (SELECT 1 FROM [dbo].[NotificationFrequency])) BEGIN

	INSERT [dbo].[NotificationFrequency] ([ID], [Name]) VALUES (1, N'Immediate')
	INSERT [dbo].[NotificationFrequency] ([ID], [Name]) VALUES (2, N'Hourly')
	INSERT [dbo].[NotificationFrequency] ([ID], [Name]) VALUES (3, N'Daily')
	INSERT [dbo].[NotificationFrequency] ([ID], [Name]) VALUES (4, N'DoNotNotify')

	INSERT [dbo].[UserRole] ([RoleID], [RoleName], [RoleCode]) VALUES (1, N'system_admin', N'system_admin')
	INSERT [dbo].[UserRole] ([RoleID], [RoleName], [RoleCode]) VALUES (2, N'business_admin', N'business_admin')
	INSERT [dbo].[UserRole] ([RoleID], [RoleName], [RoleCode]) VALUES (3, N'business_staff', N'business_staff')

	SET IDENTITY_INSERT [dbo].[UserLogin] ON 
	INSERT [dbo].[UserLogin] ([LoginID], [Email], [PasswordHash], [RegistrationDate], [EmailConfirmationDate]) VALUES (1, N'admin@admin.admin', N'admin@admin.admin', CAST(N'2016-08-27 14:15:07.620' AS DateTime), CAST(N'2016-08-27 14:15:07.620' AS DateTime))
	SET IDENTITY_INSERT [dbo].[UserLogin] OFF

	INSERT [dbo].[CMSAttachmentImageSize] ([ImageSizeID], [Code], [MaxHeight], [MaxWidth], [CropMode]) VALUES (1, N'Thumbnail', 250, 250, NULL)
	INSERT [dbo].[CMSAttachmentImageSize] ([ImageSizeID], [Code], [MaxHeight], [MaxWidth], [CropMode]) VALUES (2, N'Medium', 600, 500, NULL)
	INSERT [dbo].[CMSAttachmentImageSize] ([ImageSizeID], [Code], [MaxHeight], [MaxWidth], [CropMode]) VALUES (3, N'Large', 1200, 1000, NULL)

	INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (1, N'Text')
	INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (2, N'Datetime')
	INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (3, N'Bool')
	INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (4, N'Number')
	INSERT [dbo].[CMSFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (5, N'Location')


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
	INSERT [dbo].[LeadFieldType] ([FieldTypeID], [FieldTypeName]) VALUES (8, N'Textarea')


	INSERT [dbo].[CMSAttachmentType] ([AttachmentTypeID], [AttachmentTypeName]) VALUES (1, N'Image')
	INSERT [dbo].[CMSAttachmentType] ([AttachmentTypeID], [AttachmentTypeName]) VALUES (2, N'Audio')
	INSERT [dbo].[CMSAttachmentType] ([AttachmentTypeID], [AttachmentTypeName]) VALUES (3, N'Other')

	INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (1, N'Yearly')
	INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (2, N'Monthly')
	INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (3, N'Weekly')
	INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (4, N'Daily')
	INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (5, N'Hourly')
	INSERT [dbo].[SystemScheduledTaskInterval] ([ID], [Name]) VALUES (6, N'Minutely')

END