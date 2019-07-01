CREATE TABLE [dbo].[TaxonomyTermWord](
	[TermID] [bigint] NOT NULL,
	[WordID] [bigint] NOT NULL,
	[TermWordCode] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_TaxonomyTermWord] PRIMARY KEY CLUSTERED 
(
	[TermID] ASC,
	[WordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_TaxonomyTermWord] UNIQUE NONCLUSTERED 
(
	[TermID] ASC,
	[TermWordCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TaxonomyTermWord]  WITH CHECK ADD  CONSTRAINT [FK_Taxonomy.Term.Word_System.WordCase] FOREIGN KEY([WordID])
REFERENCES [dbo].[SystemWordCase] ([WordID])
GO

ALTER TABLE [dbo].[TaxonomyTermWord] CHECK CONSTRAINT [FK_Taxonomy.Term.Word_System.WordCase]
GO
ALTER TABLE [dbo].[TaxonomyTermWord]  WITH CHECK ADD  CONSTRAINT [FK_Taxonomy.Term.Word_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO

ALTER TABLE [dbo].[TaxonomyTermWord] CHECK CONSTRAINT [FK_Taxonomy.Term.Word_Taxonomy.Term]