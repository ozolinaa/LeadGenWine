-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSetReviewRequestSent]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead]
	SET ReviewRequestSentDateTime = GETUTCDATE()
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT
END