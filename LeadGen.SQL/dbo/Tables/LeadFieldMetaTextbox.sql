CREATE TABLE [dbo].[LeadFieldMetaTextbox](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((1)) PERSISTED NOT NULL,
	[Placeholder] [nvarchar](255) NOT NULL,
	[RegularExpression] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_LeadFieldTexboxMeta] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadFieldMetaTextbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Textbox_Lead.Field.Meta.Textbox] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO

ALTER TABLE [dbo].[LeadFieldMetaTextbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Textbox_Lead.Field.Meta.Textbox]
GO
ALTER TABLE [dbo].[LeadFieldMetaTextbox] ADD  CONSTRAINT [DF_Lead.Field.Meta.Textbox_Placeholder]  DEFAULT ('') FOR [Placeholder]
GO
ALTER TABLE [dbo].[LeadFieldMetaTextbox] ADD  CONSTRAINT [DF_Lead.Field.Meta.Textbox_RegularExpression]  DEFAULT ('') FOR [RegularExpression]
GO
/****** Object:  Index [IX_LeadFieldMetaTextbox]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadFieldMetaTextbox] ON [dbo].[LeadFieldMetaTextbox]
(
	[FieldID] ASC,
	[FieldTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]