-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessPermissionApprove]
	-- Add the parameters for the stored procedure here
	@LoginID bigint,
	@PermissionID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BusinessLeadPermission] 
	SET ApprovedByAdminDateTime = GETUTCDATE()
	WHERE [PermissionID] = @PermissionID AND ApprovedByAdminDateTime IS NULL

	RETURN @@ROWCOUNT
END