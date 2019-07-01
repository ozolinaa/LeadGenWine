-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetNotInterested]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint,
	@NotInterestedDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[BusinessLeadNotInterested]
		([LoginID], [BusinessID], [LeadID], [NotInterestedDateTime])
	VALUES (@LoginID, @BusinessID, @LeadID, ISNULL(@NotInterestedDateTime,GETUTCDATE()) )

	RETURN @@ROWCOUNT

END