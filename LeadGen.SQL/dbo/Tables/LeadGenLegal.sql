CREATE TABLE [dbo].[LeadGenLegal](
	[LegalCountryID] [bigint] NOT NULL,
	[LegalAddress] [nvarchar](255) NOT NULL,
	[LegalName] [nvarchar](255) NOT NULL,
	[LegalCode1] [nvarchar](255) NOT NULL,
	[LegalCode2] [nvarchar](255) NOT NULL,
	[LegalBankAccount] [nvarchar](255) NOT NULL,
	[LegalBankCode1] [nvarchar](255) NOT NULL,
	[LegalBankCode2] [nvarchar](255) NOT NULL,
	[LegalBankName] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_LeadGenLegal] PRIMARY KEY CLUSTERED 
(
	[LegalCountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadGenLegal]  WITH CHECK ADD  CONSTRAINT [FK_LeadGen.Legal_Taxonomy.Term] FOREIGN KEY([LegalCountryID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO

ALTER TABLE [dbo].[LeadGenLegal] CHECK CONSTRAINT [FK_LeadGen.Legal_Taxonomy.Term]