CREATE TABLE [dbo].[LeadFieldMetaNumber](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((7)) PERSISTED NOT NULL,
	[Placeholder] [nvarchar](100) NOT NULL,
	[MinValue] [bigint] NULL,
	[MaxValue] [bigint] NULL,
 CONSTRAINT [PK_LeadFieldMetaNumber] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadFieldMetaNumber]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Number_Lead.FieldStructure] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO

ALTER TABLE [dbo].[LeadFieldMetaNumber] CHECK CONSTRAINT [FK_Lead.Field.Meta.Number_Lead.FieldStructure]