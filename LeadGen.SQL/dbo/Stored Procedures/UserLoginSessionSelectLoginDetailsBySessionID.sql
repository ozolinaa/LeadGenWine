-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginSessionSelectLoginDetailsBySessionID]
	-- Add the parameters for the stored procedure here
	@sessionID nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		L.[LoginID],
		L.[Email],
		BL.[LinkDate],
		R.[RoleID],
		R.[RoleName],
		R.[RoleCode],
		L.[RegistrationDate],
		B.[BusinessID],
		B.[Name] as BusinessName,
		B.[RegistrationDate] as BusinessRegistrationDate,
		L.[EmailConfirmationDate]
	FROM [dbo].[UserSession] S
	INNER JOIN [dbo].[UserLogin] L ON L.[LoginID] = S.[LoginID] AND L.[EmailConfirmationDate] IS NOT NULL 
	LEFT OUTER JOIN [dbo].[BusinessLogin] BL ON BL.[LoginID] = L.LoginID 
	LEFT OUTER JOIN [dbo].[UserRole] R ON R.[RoleID] = BL.[RoleID] 
	LEFT OUTER JOIN [dbo].[Business] B ON B.[BusinessID] = BL.[BusinessID]
	WHERE S.[SessionID] = @sessionID AND S.[SessionBlockDate] IS NULL


	RETURN

END