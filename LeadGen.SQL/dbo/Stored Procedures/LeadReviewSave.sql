-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewSave]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@ReviewDateTime datetime,
	@BusinessID bigint,
	@OtherBusinessName nvarchar(255),
	@AuthorName nvarchar(255),
	@ReviewText nvarchar(max),
	@OrderPricePart1 decimal(19,4),
	@OrderPricePart2 decimal(19,4)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM [dbo].[LeadReview] WHERE [LeadID] = @LeadID)
		INSERT INTO [dbo].[LeadReview] ([LeadID], [ReviewDateTime]) VALUES (@LeadID, @ReviewDateTime)

	UPDATE [dbo].[LeadReview]
	SET ReviewDateTime = @ReviewDateTime,
		BusinessID = @BusinessID,
		OtherBusinessName = @OtherBusinessName,
		AuthorName = @AuthorName,
		ReviewText = @ReviewText,
		OrderPricePart1 = @OrderPricePart1,
		OrderPricePart2 = @OrderPricePart2
	WHERE [LeadID] = @LeadID

END