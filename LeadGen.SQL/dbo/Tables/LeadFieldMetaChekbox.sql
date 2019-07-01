CREATE TABLE [dbo].[LeadFieldMetaChekbox](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((3)) PERSISTED NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermParentID] [bigint] NULL,
 CONSTRAINT [PK_LeadFieldMetaChekbox] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadFieldMetaChekbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Lead.Field.Meta.Chekbox] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO

ALTER TABLE [dbo].[LeadFieldMetaChekbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Lead.Field.Meta.Chekbox]
GO
ALTER TABLE [dbo].[LeadFieldMetaChekbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO

ALTER TABLE [dbo].[LeadFieldMetaChekbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy]
GO
ALTER TABLE [dbo].[LeadFieldMetaChekbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy.Term] FOREIGN KEY([TermParentID], [TaxonomyID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID])
GO

ALTER TABLE [dbo].[LeadFieldMetaChekbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy.Term]
GO
/****** Object:  Index [IX_LeadFieldMetaChekbox]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadFieldMetaChekbox] ON [dbo].[LeadFieldMetaChekbox]
(
	[FieldID] ASC,
	[FieldTypeID] ASC,
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]