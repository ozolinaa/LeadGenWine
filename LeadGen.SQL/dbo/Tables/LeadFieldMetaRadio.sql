CREATE TABLE [dbo].[LeadFieldMetaRadio](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((4)) PERSISTED NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermParentID] [bigint] NULL,
 CONSTRAINT [PK_LeadFieldMetaRadio] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadFieldMetaRadio]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Radio_Lead.Field] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO

ALTER TABLE [dbo].[LeadFieldMetaRadio] CHECK CONSTRAINT [FK_Lead.Field.Meta.Radio_Lead.Field]
GO
ALTER TABLE [dbo].[LeadFieldMetaRadio]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO

ALTER TABLE [dbo].[LeadFieldMetaRadio] CHECK CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy]
GO
ALTER TABLE [dbo].[LeadFieldMetaRadio]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy.Term] FOREIGN KEY([TermParentID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO

ALTER TABLE [dbo].[LeadFieldMetaRadio] CHECK CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy.Term]
GO
/****** Object:  Index [IX_LeadFieldMetaRadio]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadFieldMetaRadio] ON [dbo].[LeadFieldMetaRadio]
(
	[FieldID] ASC,
	[FieldTypeID] ASC,
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]