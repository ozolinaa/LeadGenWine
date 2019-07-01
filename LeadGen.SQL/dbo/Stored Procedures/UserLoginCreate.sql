-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginCreate]
	-- Add the parameters for the stored procedure here
	@roleID int,
	@email nvarchar(100),
	@passwordHash nvarchar(255),
	@loginID bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		INSERT INTO [dbo].[UserLogin] (
			[RoleID],
			[Email],
			[PasswordHash],
			[RegistrationDate]
			)
		VALUES(
			@roleID,
			@email,
			@passwordHash,
			GETUTCDATE()
		)

		SET @loginID = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
    -- Execute error retrieval routine.
		SET @loginID = NULL
	END CATCH;

	return @loginID
END