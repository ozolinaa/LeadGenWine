-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginSessionDelete]
	-- Add the parameters for the stored procedure here
	@sessionID nvarchar(255),
	@loginID bigint,
	@result bit OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DELETE FROM [dbo].[UserSession]
	WHERE [SessionID] = @sessionID AND [LoginID] = @loginID

	SET @result = @@ROWCOUNT

	RETURN @result

END