-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessNotificationEmailInsert]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@email nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @returnValue bit = 0

	IF NOT EXISTS (SELECT *	FROM [dbo].[BusinessNotificationEmail]
	WHERE [BusinessID] = @businessID AND [Email] = @email)
		BEGIN TRY
			INSERT INTO [dbo].[BusinessNotificationEmail] 
				([BusinessID], [Email])
			VALUES
				(@businessID, @email)
			SET @returnValue = 1
		END TRY
		BEGIN CATCH
		END CATCH

	return @returnValue

END