CREATE TABLE [dbo].[BusinessLeadImportant](
	[LoginID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[ImportantDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BusinessLeadImportant] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessLeadImportant]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Important_Business.Login] FOREIGN KEY([BusinessID], [LoginID])
REFERENCES [dbo].[BusinessLogin] ([BusinessID], [LoginID])
GO

ALTER TABLE [dbo].[BusinessLeadImportant] CHECK CONSTRAINT [FK_Business.Lead.Important_Business.Login]
GO
ALTER TABLE [dbo].[BusinessLeadImportant]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Important_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO

ALTER TABLE [dbo].[BusinessLeadImportant] CHECK CONSTRAINT [FK_Business.Lead.Important_Lead]
GO
ALTER TABLE [dbo].[BusinessLeadImportant] ADD  CONSTRAINT [DF_Business.Lead.Important_ImportantDateTime]  DEFAULT (getutcdate()) FOR [ImportantDateTime]