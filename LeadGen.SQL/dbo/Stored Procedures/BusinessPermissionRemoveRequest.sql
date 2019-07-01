-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessPermissionRemoveRequest]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@PermissionID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BusinessLeadPermission] 
	SET RequestedDateTime = NULL
	WHERE BusinessID = @BusinessID AND PermissionID = @PermissionID 

	RETURN @@ROWCOUNT

END