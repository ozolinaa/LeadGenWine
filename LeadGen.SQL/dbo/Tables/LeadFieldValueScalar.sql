CREATE TABLE [dbo].[LeadFieldValueScalar](
	[ID] [uniqueidentifier] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[FieldID] [int] NOT NULL,
	[FieldTypeID] [int] NOT NULL,
	[TextValue] [nvarchar](max) NULL,
	[DatetimeValue] [datetime] NULL,
	[BoolValue] [bit] NULL,
	[NumberValue] [bigint] NULL,
	[NubmerValueFromText]  AS ([dbo].[ExtractNumberFromString]([TextValue])) PERSISTED,
 CONSTRAINT [PK_LeadFieldValueScalar] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_LeadFieldValueScalar_LeadID_FieldID] UNIQUE NONCLUSTERED 
(
	[LeadID] ASC,
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadFieldValueScalar]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO

ALTER TABLE [dbo].[LeadFieldValueScalar] CHECK CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead]
GO
ALTER TABLE [dbo].[LeadFieldValueScalar]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead.FieldStructure] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO

ALTER TABLE [dbo].[LeadFieldValueScalar] CHECK CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead.FieldStructure]
GO
ALTER TABLE [dbo].[LeadFieldValueScalar] ADD  CONSTRAINT [DF_Lead.Field.Value.Scalar_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[LeadFieldValueScalar]  WITH CHECK ADD  CONSTRAINT [CK_Lead.Field.Value.Scalar.FieldTypeID] CHECK  (([FieldTypeID]=(7) OR [FieldTypeID]=(6) OR [FieldTypeID]=(5) OR [FieldTypeID]=(1) OR [FieldTypeID]=(8)))
GO

ALTER TABLE [dbo].[LeadFieldValueScalar] CHECK CONSTRAINT [CK_Lead.Field.Value.Scalar.FieldTypeID]
GO
/****** Object:  Index [IX_LeadFieldValueScalar_DateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueScalar_DateTime] ON [dbo].[LeadFieldValueScalar]
(
	[DatetimeValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadFieldValueScalar_NubmerValueFromText]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueScalar_NubmerValueFromText] ON [dbo].[LeadFieldValueScalar]
(
	[NubmerValueFromText] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadFieldValueScalar_Number]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueScalar_Number] ON [dbo].[LeadFieldValueScalar]
(
	[NumberValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]