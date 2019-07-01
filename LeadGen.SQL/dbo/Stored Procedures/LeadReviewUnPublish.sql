-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewUnPublish]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@LoginID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[LeadReview]
	SET PublishedDateTime = NULL
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT
END