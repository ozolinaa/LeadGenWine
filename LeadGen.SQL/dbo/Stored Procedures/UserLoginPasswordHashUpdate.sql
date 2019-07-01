-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginPasswordHashUpdate]
	-- Add the parameters for the stored procedure here
	@loginID bigint,
	@sessionID nvarchar(255) = '',
	@passwordHash nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[UserSession]
	SET [SessionPasswordChangeInitialized] = 1
	WHERE [SessionID] = @SessionID AND [LoginID] = @LoginID

	UPDATE [dbo].[UserLogin]
	SET [PasswordHash] = @PasswordHash 
	WHERE [LoginID] = @LoginID

	return @@ROWCOUNT
END