-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLoginSelect]
	-- Add the parameters for the stored procedure here
	@businessID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT bl.LoginID, ur.RoleID, ur.RoleCode, ul.Email, bl.LinkDate, ul.EmailConfirmationDate
	FROM dbo.[BusinessLogin] bl
	INNER JOIN dbo.[UserRole] ur ON ur.RoleID = bl.RoleID
	INNER JOIN dbo.[UserLogin] ul ON ul.LoginID = bl.LoginID
	WHERE bl.[BusinessID] = @businessID AND ul.[DeletedDate] IS NULL;

END