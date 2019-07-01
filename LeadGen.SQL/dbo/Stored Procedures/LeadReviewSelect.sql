-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewSelect]
	-- Add the parameters for the stored procedure here
	@LeadID bigint = NULL,
	@BusinessID bigint = NULL,
	@DateFrom DateTime = NULL,
	@DateTo DateTime = NULL,
	@Published bit = NULL,
	@Offset int = 0,
	@Fetch int = 2147483647,
	@TotalCount int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Reviews TABLE (
		[LeadID] BIGINT,
		[ReviewDateTime] DATETIME
	)

	INSERT INTO @Reviews
	SELECT
		lr.LeadID,
		lr.ReviewDateTime
	FROM
		[dbo].[LeadReview] lr
	WHERE
	(@BusinessID IS NULL OR lr.BusinessID = @BusinessID)
	AND (@LeadID IS NULL OR lr.LeadID = @LeadID)
	AND (@DateFrom IS NULL OR @DateFrom < ReviewDateTime)
	AND (@DateTo IS NULL OR @DateTo >= ReviewDateTime)
	AND (
		@Published IS NULL  
		OR (@Published = 1 AND lr.PublishedDateTime IS NOT NULL) 
		OR (@Published = 0 AND lr.PublishedDateTime IS NULL) 
	)
  	SELECT @TotalCount = COUNT(*) FROM @Reviews


	-- Declare a variable that references the type.
	DECLARE @ReviewIDs AS [dbo].[SysBigintTableType];  
  
	-- Add data to the table variable. 
	INSERT INTO @ReviewIDs (Item)
	SELECT r.[LeadID]
	FROM @Reviews r
	ORDER BY r.[ReviewDateTime] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	-- Perform a Select
	SELECT
		lr.LeadID,
		lr.BusinessID,
		lr.ReviewDateTime,
		lr.PublishedDateTime,
		lr.AuthorName,
		lr.ReviewText,
		lr.OtherBusinessName,
		lr.OrderPricePart1,
		lr.OrderPricePart2,
		lrm.MeasureID,
		lrm.MeasureName,
		lrms.Score
	FROM
		@ReviewIDs ri
		INNER JOIN [dbo].[LeadReview] lr ON lr.LeadID = ri.Item
		LEFT OUTER JOIN [dbo].[LeadReviewMeasureScore] lrms ON lrms.LeadID = lr.LeadID
		LEFT OUTER JOIN [dbo].[LeadReviewMeasure] lrm ON lrm.MeasureID = lrms.ReviewMeasureID
	ORDER BY lr.[ReviewDateTime] DESC

END