CREATE TABLE [dbo].[BusinessInvoiceLine](
	[InvoiceID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LineID] [smallint] NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[UnitPrice] [decimal](19, 4) NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Tax] [decimal](4, 2) NOT NULL,
	[LinePrice]  AS ([UnitPrice]*[Quantity]) PERSISTED,
	[LineTotalPrice]  AS ([UnitPrice]*[Quantity]+(([UnitPrice]*[Quantity])*[Tax])/(100)) PERSISTED,
 CONSTRAINT [PK_BusinessInvoiceLine] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC,
	[LineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessInvoiceLine]  WITH CHECK ADD  CONSTRAINT [FK_Business.Invoice.Line_Business.Invoice.Line] FOREIGN KEY([InvoiceID], [BusinessID])
REFERENCES [dbo].[BusinessInvoice] ([InvoiceID], [BusinessID])
GO

ALTER TABLE [dbo].[BusinessInvoiceLine] CHECK CONSTRAINT [FK_Business.Invoice.Line_Business.Invoice.Line]
GO
ALTER TABLE [dbo].[BusinessInvoiceLine] ADD  CONSTRAINT [DF_Business.Invoice.Line_Quantaty]  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[BusinessInvoiceLine] ADD  CONSTRAINT [DF_Business.Invoice.Line_Tax]  DEFAULT ((0)) FOR [Tax]