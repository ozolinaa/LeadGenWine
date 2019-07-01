-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewMeasureScoreInsert]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@MeasureID smallint,
	@Score smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[LeadReviewMeasureScore]
		([LeadID], [ReviewMeasureID], [Score])
	VALUES
		(@LeadID, @MeasureID, @Score)

END