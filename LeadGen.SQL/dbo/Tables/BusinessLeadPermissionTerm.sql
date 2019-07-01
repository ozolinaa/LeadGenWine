CREATE TABLE [dbo].[BusinessLeadPermissionTerm](
	[PermissionID] [bigint] NOT NULL,
	[TermID] [bigint] NOT NULL,
 CONSTRAINT [PK_BusinessLeadPermissionTerm_1] PRIMARY KEY CLUSTERED 
(
	[PermissionID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessLeadPermissionTerm]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Permission.Term_Business.Lead.Permission] FOREIGN KEY([PermissionID])
REFERENCES [dbo].[BusinessLeadPermission] ([PermissionID])
GO

ALTER TABLE [dbo].[BusinessLeadPermissionTerm] CHECK CONSTRAINT [FK_Business.Lead.Permission.Term_Business.Lead.Permission]
GO
ALTER TABLE [dbo].[BusinessLeadPermissionTerm]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Permission.Term_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO

ALTER TABLE [dbo].[BusinessLeadPermissionTerm] CHECK CONSTRAINT [FK_Business.Lead.Permission.Term_Taxonomy.Term]