-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadTryUnPublishByUser]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@UserCanceledPublishDateTime datetime = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead] 
	SET [PublishedDateTime] = NULL,
	[UserCanceledDateTime] = ISNULL(@UserCanceledPublishDateTime, GETUTCDATE())
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT

END