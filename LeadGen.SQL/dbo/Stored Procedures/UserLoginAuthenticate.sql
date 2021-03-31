-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginAuthenticate]
	-- Add the parameters for the stored procedure here
	@email nvarchar(255),
	@passwordHash nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT	
		L.[LoginID],
		L.[Email],
		L.[RegistrationDate],
		L.[EmailConfirmationDate]
	FROM	
		[dbo].[UserLogin] L
	WHERE	
		[Email] = @email 
		AND [PasswordHash] = @passwordHash

END