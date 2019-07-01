-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginSessionCreate]
	-- Add the parameters for the stored procedure here
	@loginID bigint,
	@sessionID nvarchar(255) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @PasswordHash nvarchar(255)
	SELECT @PasswordHash = [PasswordHash] FROM [dbo].[UserLogin] WHERE [LoginID] = @loginID

	IF ( @PasswordHash IS NOT NULL AND @PasswordHash <> '')
	BEGIN
		EXEC dbo.[SysGenerateRandomString] 50, @sessionID OUT
		IF (SELECT COUNT(*) FROM dbo.[UserSession] WHERE [SessionID] = @sessionID) = 0
		BEGIN
			INSERT INTO dbo.[UserSession] 
				([SessionID], 
				[LoginID], 
				[SessionPasswordHash], 
				[SessionCreationDate])
			SELECT 
				@sessionID, 
				@loginID,
				[PasswordHash],
				GETUTCDATE()
			FROM [dbo].[UserLogin]
			WHERE [LoginID] = @loginID

			RETURN
		END
		ELSE
			EXEC [dbo].[UserLoginSessionCreate] @loginID, @sessionID OUT
	END



	RETURN

END