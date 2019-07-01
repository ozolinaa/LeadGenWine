CREATE TABLE [dbo].[BusinessLeadCompleted](
	[LoginID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[CompletedDateTime] [datetime] NOT NULL,
	[OrderSum] [decimal](19, 4) NOT NULL,
	[SystemFeePercent] [decimal](4, 2) NOT NULL,
	[LeadFee]  AS (([OrderSum]*[SystemFeePercent])/(100)) PERSISTED,
	[InvoiceID] [bigint] NULL,
	[InvoiceLineID] [smallint] NULL,
 CONSTRAINT [PK_BusinessLeadCompleted] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice] FOREIGN KEY([InvoiceID], [BusinessID])
REFERENCES [dbo].[BusinessInvoice] ([InvoiceID], [BusinessID])
GO

ALTER TABLE [dbo].[BusinessLeadCompleted] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice.Line] FOREIGN KEY([InvoiceID], [InvoiceLineID])
REFERENCES [dbo].[BusinessInvoiceLine] ([InvoiceID], [LineID])
GO

ALTER TABLE [dbo].[BusinessLeadCompleted] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice.Line]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Lead.ContactsRecieve] FOREIGN KEY([BusinessID], [LeadID])
REFERENCES [dbo].[BusinessLeadContactsRecieved] ([BusinessID], [LeadID])
GO

ALTER TABLE [dbo].[BusinessLeadCompleted] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Lead.ContactsRecieve]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Login] FOREIGN KEY([BusinessID], [LoginID])
REFERENCES [dbo].[BusinessLogin] ([BusinessID], [LoginID])
GO

ALTER TABLE [dbo].[BusinessLeadCompleted] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Login]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO

ALTER TABLE [dbo].[BusinessLeadCompleted] CHECK CONSTRAINT [FK_Business.Lead.Completed_Lead]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted] ADD  CONSTRAINT [DF_Business.Lead.Completed_CompletedDateTime]  DEFAULT (getutcdate()) FOR [CompletedDateTime]