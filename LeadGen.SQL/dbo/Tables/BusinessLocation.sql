CREATE TABLE [dbo].[BusinessLocation](
	[LocationID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[ApprovedByAdminDateTime] [DateTime] NULL,
	[IsApprovedByAdmin] AS (CASE WHEN [ApprovedByAdminDateTime] IS NULL THEN 0 ELSE 1 END) PERSISTED,
 CONSTRAINT [PK_BusinessLocation] PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessLocation]  WITH CHECK ADD  CONSTRAINT [FK_Business.Location_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO

ALTER TABLE [dbo].[BusinessLocation] CHECK CONSTRAINT [FK_Business.Location_Business]
GO
ALTER TABLE [dbo].[BusinessLocation]  WITH CHECK ADD  CONSTRAINT [FK_BusinessLocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([LocationId])