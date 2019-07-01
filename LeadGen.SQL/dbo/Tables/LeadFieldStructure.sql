CREATE TABLE [dbo].[LeadFieldStructure](
	[FieldID] [int] NOT NULL,
	[FieldCode] [nvarchar](50) NOT NULL,
	[GroupID] [int] NOT NULL,
	[FieldName] [nvarchar](100) NOT NULL,
	[FieldTypeID] [int] NOT NULL,
	[LabelText] [nvarchar](255) NOT NULL,
	[IsRequired] [bit] NOT NULL,
	[IsContact] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Order] [int] NULL,
 CONSTRAINT [PK_LeadField] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_LeadFieldStructure] UNIQUE NONCLUSTERED 
(
	[FieldCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadFieldStructure]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Structure_Lead.Field.Structure.Group] FOREIGN KEY([GroupID])
REFERENCES [dbo].[LeadFieldStructureGroup] ([GroupID])
GO

ALTER TABLE [dbo].[LeadFieldStructure] CHECK CONSTRAINT [FK_Lead.Field.Structure_Lead.Field.Structure.Group]
GO
ALTER TABLE [dbo].[LeadFieldStructure]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field_Lead.Field.Type] FOREIGN KEY([FieldTypeID])
REFERENCES [dbo].[LeadFieldType] ([FieldTypeID])
GO

ALTER TABLE [dbo].[LeadFieldStructure] CHECK CONSTRAINT [FK_Lead.Field_Lead.Field.Type]
GO
ALTER TABLE [dbo].[LeadFieldStructure] ADD  CONSTRAINT [DF_Lead.FieldStructure_IsContact]  DEFAULT ((0)) FOR [IsContact]
GO
ALTER TABLE [dbo].[LeadFieldStructure] ADD  CONSTRAINT [DF_Lead.FieldStructure_isActive]  DEFAULT ((1)) FOR [IsActive]
GO
/****** Object:  Index [IX_LeadField]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadField] ON [dbo].[LeadFieldStructure]
(
	[FieldID] ASC,
	[FieldTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadField_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadField_1] ON [dbo].[LeadFieldStructure]
(
	[FieldName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]