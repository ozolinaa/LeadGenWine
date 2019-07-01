CREATE TABLE [dbo].[Location](
	[LocationID] [bigint] IDENTITY(1,1) NOT NULL,
	[Location] [geography] NOT NULL,
	[AccuracyMeters] [int] NOT NULL DEFAULT 0,
	[RadiusMeters] [int] NOT NULL DEFAULT 5000,
	[LocationWithRadius]  AS ([Location].[STBuffer]([AccuracyMeters]+[RadiusMeters])) PERSISTED,
	[StreetAddress] [nvarchar](255) NULL,
	[PostalCode] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[Country] [nvarchar](255) NULL,
	[Zoom] [int]  NULL,
	[Name] [nvarchar](255) NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[UpdatedDateTime] [datetime] NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
GO
ALTER TABLE [dbo].[Location] ADD  CONSTRAINT [DF_Location_CreatedDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
/****** Object:  Index [LeadLocationIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE SPATIAL INDEX [LocationIndex] ON [dbo].[Location]
(
	[Location]
)USING  GEOGRAPHY_AUTO_GRID 
WITH (
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [LocationWithRadiusIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE SPATIAL INDEX [LocationWithRadiusIndex] ON [dbo].[Location]
(
	[LocationWithRadius]
)USING  GEOGRAPHY_AUTO_GRID 
WITH (
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]