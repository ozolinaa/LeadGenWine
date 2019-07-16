CREATE TABLE [dbo].[LeadFieldMetaTextarea](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((8)) PERSISTED NOT NULL,
	[Placeholder] [nvarchar](255) NOT NULL,
	[RegularExpression] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_LeadFieldTextareaMeta] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadFieldMetaTextarea]  WITH CHECK ADD  CONSTRAINT [FK_Lead_Field_Meta_Textarea_Lead_Field_Meta_Textarea] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO

ALTER TABLE [dbo].[LeadFieldMetaTextarea] CHECK CONSTRAINT [FK_Lead_Field_Meta_Textarea_Lead_Field_Meta_Textarea]
GO
ALTER TABLE [dbo].[LeadFieldMetaTextarea] ADD  CONSTRAINT [DF_Lead.Field.Meta.Textarea_Placeholder]  DEFAULT ('') FOR [Placeholder]
GO
ALTER TABLE [dbo].[LeadFieldMetaTextarea] ADD  CONSTRAINT [DF_Lead.Field.Meta.Textarea_RegularExpression]  DEFAULT ('') FOR [RegularExpression]
GO
/****** Object:  Index [IX_LeadFieldMetaTextarea]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadFieldMetaTextarea] ON [dbo].[LeadFieldMetaTextarea]
(
	[FieldID] ASC,
	[FieldTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]