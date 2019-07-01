-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewMeasureSelect]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		lrm.MeasureID,
		lrm.MeasureName,
		ISNULL(lrms.Score,0) as Score
	FROM
		[dbo].[Lead] l
		CROSS JOIN [dbo].[LeadReviewMeasure] lrm 
		LEFT OUTER JOIN [dbo].[LeadReviewMeasureScore] lrms ON lrms.LeadID = l.LeadID AND lrm.MeasureID = lrms.ReviewMeasureID
	WHERE
		l.LeadID = @LeadID
	ORDER BY lrm.[Order] ASC

END