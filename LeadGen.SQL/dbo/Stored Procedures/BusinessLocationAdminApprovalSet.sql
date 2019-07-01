-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLocationAdminApprovalSet]
	-- Add the parameters for the stored procedure here
	@LocationID bigint,
	@BusinessID bigint,
	@ApprovedByAdminDateTime [datetime],
	@LoginID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BusinessLocation]
	   SET [ApprovedByAdminDateTime] = @ApprovedByAdminDateTime
	 WHERE LocationID = @LocationID AND BusinessID = @BusinessID

END