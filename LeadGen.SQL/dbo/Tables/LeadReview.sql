CREATE TABLE [dbo].[LeadReview](
	[LeadID] [bigint] NOT NULL,
	[ReviewDateTime] [datetime] NOT NULL,
	[PublishedDateTime] [datetime] NULL,
	[ReviewText] [nvarchar](max) NULL,
	[AuthorName] [nvarchar](255) NULL,
	[BusinessID] [bigint] NULL,
	[OtherBusinessName] [nvarchar](255) NULL,
	[OrderPricePart1] [decimal](19, 4) NULL,
	[OrderPricePart2] [decimal](19, 4) NULL,
 CONSTRAINT [PK_LeadReview] PRIMARY KEY CLUSTERED 
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadReview]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Review_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO

ALTER TABLE [dbo].[LeadReview] CHECK CONSTRAINT [FK_Lead.Review_Business]
GO
ALTER TABLE [dbo].[LeadReview]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Review_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO

ALTER TABLE [dbo].[LeadReview] CHECK CONSTRAINT [FK_Lead.Review_Lead]
GO
ALTER TABLE [dbo].[LeadReview] ADD  CONSTRAINT [DF_Lead.Review_ReviewDateTime]  DEFAULT (getutcdate()) FOR [ReviewDateTime]