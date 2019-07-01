-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadTryPublish]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@LoginID bigint,
	@PublishDateTime datetime = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead] 
	SET [PublishedDateTime] = ISNULL(@PublishDateTime, GETUTCDATE())
	WHERE [LeadID] = @LeadID 
	AND [EmailConfirmedDateTime] IS NOT NULL 
	--AND [UserCanceledDateTime] IS NULL
	AND [PublishedDateTime] IS NULL

	RETURN @@ROWCOUNT

END