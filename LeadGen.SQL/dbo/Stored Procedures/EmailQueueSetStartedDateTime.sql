-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EmailQueueSetStartedDateTime]
	-- Add the parameters for the stored procedure here
	@EmailID uniqueidentifier,
	@SendingStartedDateTime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[EmailQueue]
	SET SendingStartedDateTime = @SendingStartedDateTime
	WHERE EmailID = @EmailID

END