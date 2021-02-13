-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginEmailConfirm]
	-- Add the parameters for the stored procedure here
	@loginID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[UserLogin]
	SET [EmailConfirmationDate] = ISNULL([EmailConfirmationDate], GETUTCDATE()) 
	WHERE [LoginID] = @loginID

	RETURN @@ROWCOUNT
END