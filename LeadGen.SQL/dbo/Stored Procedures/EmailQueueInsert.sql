-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EmailQueueInsert]
	-- Add the parameters for the stored procedure here
	@EmailID uniqueidentifier,
	@CreatedDateTime datetime,
	@SendingScheduledDateTime datetime,
	@FromAddress nvarchar(255),
	@FromName nvarchar(255),
	@ToAddress nvarchar(255),
	@ReplyToAddress nvarchar(255),
	@Subject nvarchar(255),
	@Body nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[EmailQueue] (
		EmailID,
		CreatedDateTime,
		SendingScheduledDateTime,
		FromAddress,
		FromName,
		ToAddress,
		ReplyToAddress,
		[Subject],
		Body
		)
	VALUES (
		@EmailID,
		@CreatedDateTime,
		@SendingScheduledDateTime,
		@FromAddress,
		@FromName,
		@ToAddress,
		@ReplyToAddress,
		@Subject,
		@Body
	)


END