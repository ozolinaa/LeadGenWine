CREATE TABLE [dbo].[LeadFieldMetaTermsAllowed](
	[TermID] [bigint] NOT NULL,
 CONSTRAINT [PK_LeadFieldMetaTermsAllowed] PRIMARY KEY CLUSTERED 
(
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadFieldMetaTermsAllowed]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.TermsAllowed_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO

ALTER TABLE [dbo].[LeadFieldMetaTermsAllowed] CHECK CONSTRAINT [FK_Lead.Field.Meta.TermsAllowed_Taxonomy.Term]