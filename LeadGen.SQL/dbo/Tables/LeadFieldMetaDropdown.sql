CREATE TABLE [dbo].[LeadFieldMetaDropdown](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((2)) PERSISTED NOT NULL,
	[Placeholder] [nvarchar](100) NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermParentID] [bigint] NULL,
	[TermDepthMaxLevel] [int] NULL,
 CONSTRAINT [PK_LeadFieldMetaDropdown] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadFieldMetaDropdown]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Lead.Field] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO

ALTER TABLE [dbo].[LeadFieldMetaDropdown] CHECK CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Lead.Field]
GO
ALTER TABLE [dbo].[LeadFieldMetaDropdown]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO

ALTER TABLE [dbo].[LeadFieldMetaDropdown] CHECK CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy]
GO
ALTER TABLE [dbo].[LeadFieldMetaDropdown]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy.Term] FOREIGN KEY([TermParentID], [TaxonomyID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID])
GO

ALTER TABLE [dbo].[LeadFieldMetaDropdown] CHECK CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy.Term]
GO
/****** Object:  Index [IX_LeadFieldMetaDropdown]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadFieldMetaDropdown] ON [dbo].[LeadFieldMetaDropdown]
(
	[FieldID] ASC,
	[FieldTypeID] ASC,
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]