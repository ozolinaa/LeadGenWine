CREATE TABLE [dbo].[LeadFieldValueTaxonomy](
	[LeadID] [bigint] NOT NULL,
	[FieldID] [int] NOT NULL,
	[FieldTypeID] [int] NOT NULL,
	[TermID] [bigint] NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[UniqueIndexComputed]  AS (concat([LeadID],'_',[FieldID],'_',case when [FieldTypeID]=(3) then [TermID] else [FieldID] end)) PERSISTED NOT NULL,
 CONSTRAINT [IX_LeadFieldValueTaxonomy_Unique] UNIQUE NONCLUSTERED 
(
	[UniqueIndexComputed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadFieldValueTaxonomy]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO

ALTER TABLE [dbo].[LeadFieldValueTaxonomy] CHECK CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Lead]
GO
ALTER TABLE [dbo].[LeadFieldValueTaxonomy]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Taxonomy.Term] FOREIGN KEY([TermID], [TaxonomyID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID])
GO

ALTER TABLE [dbo].[LeadFieldValueTaxonomy] CHECK CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Taxonomy.Term]
GO
/****** Object:  Index [IX_LeadFieldValueTaxonomy_LeadTerm]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE CLUSTERED INDEX [IX_LeadFieldValueTaxonomy_LeadTerm] ON [dbo].[LeadFieldValueTaxonomy]
(
	[LeadID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadFieldValueTaxonomy_LeadID]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueTaxonomy_LeadID] ON [dbo].[LeadFieldValueTaxonomy]
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadFieldValueTaxonomy_TermID]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueTaxonomy_TermID] ON [dbo].[LeadFieldValueTaxonomy]
(
	[TermID] ASC
)
INCLUDE ( 	[LeadID],
	[FieldID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadFieldValueTaxonomy_TermTax]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueTaxonomy_TermTax] ON [dbo].[LeadFieldValueTaxonomy]
(
	[TaxonomyID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]