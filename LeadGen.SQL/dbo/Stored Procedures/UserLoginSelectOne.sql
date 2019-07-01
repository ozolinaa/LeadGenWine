-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginSelectOne]
	-- Add the parameters for the stored procedure here
	@loginID bigint,
	@email nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TOP 1	
		L.[LoginID],
		R.[RoleID],
		R.[RoleName],
		R.[RoleCode],
		L.[Email],
		L.[RegistrationDate],
		L.[EmailConfirmationDate]
	FROM	
		[dbo].[UserLogin] L INNER JOIN
		[dbo].[UserRole] R ON R.[RoleID] = L.[RoleID]
	WHERE	
		(@loginID IS NOT NULL AND L.[LoginID] = @loginID)
		OR 
		(@email IS NOT NULL AND L.[Email] = @email)

END