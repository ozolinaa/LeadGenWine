-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessNotificationEmailDelete]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@email nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[BusinessNotificationEmail] WHERE [BusinessID] = @businessID AND [Email] = @email)
	BEGIN
		DELETE FROM [dbo].[BusinessNotificationEmail] WHERE [BusinessID] = @businessID AND [Email] = @email
		RETURN 1
	END
	ELSE
		RETURN 0

END