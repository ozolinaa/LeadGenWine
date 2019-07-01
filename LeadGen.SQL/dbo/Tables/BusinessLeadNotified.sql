CREATE TABLE [dbo].[BusinessLeadNotified](
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[NotifiedDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BuinessLeadNotified] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessLeadNotified]  WITH CHECK ADD  CONSTRAINT [FK_BuinessLeadNotified_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO

ALTER TABLE [dbo].[BusinessLeadNotified] CHECK CONSTRAINT [FK_BuinessLeadNotified_Business]
GO
ALTER TABLE [dbo].[BusinessLeadNotified]  WITH CHECK ADD  CONSTRAINT [FK_BuinessLeadNotified_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO

ALTER TABLE [dbo].[BusinessLeadNotified] CHECK CONSTRAINT [FK_BuinessLeadNotified_Lead]
GO
ALTER TABLE [dbo].[BusinessLeadNotified] ADD  CONSTRAINT [DF_BuinessLeadNotified_NotifiedDateTime]  DEFAULT (getutcdate()) FOR [NotifiedDateTime]