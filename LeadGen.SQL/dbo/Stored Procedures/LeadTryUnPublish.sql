-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadTryUnPublish]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@LoginID bigint,
	@AdminCanceledPublishDateTime datetime = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead] 
	SET [PublishedDateTime] = NULL,
	[AdminCanceledPublishDateTime] = ISNULL(@AdminCanceledPublishDateTime, GETUTCDATE())
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT

END