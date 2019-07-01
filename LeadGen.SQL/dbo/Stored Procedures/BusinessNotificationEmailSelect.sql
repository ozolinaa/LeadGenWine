-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessNotificationEmailSelect]
	-- Add the parameters for the stored procedure here
	@businessID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [Email] 
	FROM [BusinessNotificationEmail] 
	WHERE [BusinessID] = @businessID 

END