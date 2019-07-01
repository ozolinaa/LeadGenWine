CREATE TABLE [dbo].[BusinessInvoice](
	[InvoiceID] [bigint] IDENTITY(1,1) NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[TotalSum] [decimal](19, 4) NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[PublishedDatetime] [datetime] NULL,
	[PaidDateTime] [datetime] NULL,
	[LegalMonth] [smallint] NOT NULL,
	[LegalYear] [smallint] NOT NULL,
	[LegalNumber] [int] NOT NULL,
	[LegalFacturaNumber] [int] NULL,
	[LegalCountryID] [bigint] NOT NULL,
	[LegalAddress] [nvarchar](255) NOT NULL,
	[LegalName] [nvarchar](255) NOT NULL,
	[LegalCode1] [nvarchar](255) NOT NULL,
	[LegalCode2] [nvarchar](255) NOT NULL,
	[LegalBankName] [nvarchar](255) NOT NULL,
	[LegalBankCode1] [nvarchar](255) NOT NULL,
	[LegalBankCode2] [nvarchar](255) NOT NULL,
	[LegalBankAccount] [nvarchar](255) NOT NULL,
	[BillingCountryID] [bigint] NOT NULL,
	[BillingAddress] [nvarchar](255) NOT NULL,
	[BillingName] [nvarchar](255) NOT NULL,
	[BillingCode1] [nvarchar](255) NOT NULL,
	[BillingCode2] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_BusinessInvoice] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_BusinessInvoice] UNIQUE NONCLUSTERED 
(
	[InvoiceID] ASC,
	[BusinessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessInvoice]  WITH CHECK ADD  CONSTRAINT [FK_Business.Invoice_Business] FOREIGN KEY([BusinessID], [BillingCountryID])
REFERENCES [dbo].[Business] ([BusinessID], [CountryID])
GO

ALTER TABLE [dbo].[BusinessInvoice] CHECK CONSTRAINT [FK_Business.Invoice_Business]
GO
ALTER TABLE [dbo].[BusinessInvoice] ADD  CONSTRAINT [DF_Business.Invoice_InvoceCreatedDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
/****** Object:  Index [IX_BusinessInvoice_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_BusinessInvoice_1] ON [dbo].[BusinessInvoice]
(
	[LegalYear] ASC,
	[LegalFacturaNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BusinessInvoice_2]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_BusinessInvoice_2] ON [dbo].[BusinessInvoice]
(
	[BusinessID] ASC,
	[LegalYear] ASC,
	[LegalMonth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]