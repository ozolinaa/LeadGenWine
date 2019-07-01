-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SystemScheduledTasksSetCompleted]
	@TaskName NVARCHAR(255),
	@Status NVARCHAR(50),
	@Message NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[SystemScheduledTaskLog]
	SET [CompletedDateTime] = GETUTCDATE(),
	[Status] = @Status,
	[Message] = @Message
	WHERE [TaskName] = @TaskName
	AND [CompletedDateTime] IS NULL	

END