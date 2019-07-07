-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysTokenSelect]
	-- Add the parameters for the stored procedure here
	@tokenKey nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [TokenKey], [TokenType], [TokenJson], [TokenDateCreated]
	FROM [dbo].[SystemToken]
	WHERE [TokenKey] = @tokenKey

END