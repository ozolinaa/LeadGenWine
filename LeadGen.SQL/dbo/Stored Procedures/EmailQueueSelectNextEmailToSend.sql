-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EmailQueueSelectNextEmailToSend]
	@CurrentDateTime DateTime
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TOP 1
		EmailID,
		CreatedDateTime,
		SendingScheduledDateTime,
		SendingStartedDateTime,
		SentDateTime,
		FromAddress,
		FromName,
		ToAddress,
		ReplyToAddress,
		[Subject],
		Body
	FROM [dbo].[EmailQueue]
	WHERE SendingStartedDateTime IS NULL AND SendingScheduledDateTime <= @CurrentDateTime
	ORDER BY SendingScheduledDateTime ASC

END