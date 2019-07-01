-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetInterested]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[BusinessLeadNotInterested]
	WHERE [BusinessID] = @BusinessID AND [LeadID] = @LeadID

	RETURN @@ROWCOUNT

END