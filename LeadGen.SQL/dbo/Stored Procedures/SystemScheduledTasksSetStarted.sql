CREATE PROCEDURE [dbo].[SystemScheduledTasksSetStarted]
	@TaskName NVARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [dbo].[SystemScheduledTaskLog] WHERE [TaskName] = @TaskName AND CompletedDateTime IS NULL)
		BEGIN
			DECLARE @ErrorMessage  NVARCHAR (255) = 'Can not start task ' + @TaskName +' because it is not completed yet (CompletedDateTime IS NULL)'
			RAISERROR(@ErrorMessage, 16,1 )
			RETURN 0;
		END
	ELSE
		INSERT INTO [dbo].[SystemScheduledTaskLog]
			([TaskName], [Status])
		VALUES
			(@TaskName, 'Started')	

END