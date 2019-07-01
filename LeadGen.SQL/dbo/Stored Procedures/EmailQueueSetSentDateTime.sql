-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EmailQueueSetSentDateTime]
	-- Add the parameters for the stored procedure here
	@EmailID uniqueidentifier,
	@SentDateTime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[EmailQueue]
	SET SentDateTime = @SentDateTime
	WHERE EmailID = @EmailID

END