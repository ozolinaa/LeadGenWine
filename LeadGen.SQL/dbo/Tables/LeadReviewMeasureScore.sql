CREATE TABLE [dbo].[LeadReviewMeasureScore](
	[LeadID] [bigint] NOT NULL,
	[ReviewMeasureID] [smallint] NOT NULL,
	[Score] [smallint] NOT NULL,
 CONSTRAINT [PK_ReviewMeasureScore] PRIMARY KEY CLUSTERED 
(
	[LeadID] ASC,
	[ReviewMeasureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadReviewMeasureScore]  WITH CHECK ADD  CONSTRAINT [FK_Review.Measure.Score_Lead.Review] FOREIGN KEY([LeadID])
REFERENCES [dbo].[LeadReview] ([LeadID])
GO

ALTER TABLE [dbo].[LeadReviewMeasureScore] CHECK CONSTRAINT [FK_Review.Measure.Score_Lead.Review]
GO
ALTER TABLE [dbo].[LeadReviewMeasureScore]  WITH CHECK ADD  CONSTRAINT [FK_Review.Measure.Score_Review.Measure] FOREIGN KEY([ReviewMeasureID])
REFERENCES [dbo].[LeadReviewMeasure] ([MeasureID])
GO

ALTER TABLE [dbo].[LeadReviewMeasureScore] CHECK CONSTRAINT [FK_Review.Measure.Score_Review.Measure]