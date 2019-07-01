-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetGetContact]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint,
	@GetContactDateTime DATETIME = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ISAproved bit = 1
	--SELECT @ISAproved = ISNULL(IsApproved,0) 
	--FROM [dbo].[BusinessLeadSelectRequested](@BusinessID, @LeadID) 

	IF (@ISAproved = 1)
		INSERT INTO [dbo].[BusinessLeadContactsRecieved] 
			([LoginID], [BusinessID], [LeadID], [GetContactsDateTime])
		VALUES 
			(@LoginID, @BusinessID, @LeadID, ISNULL(@GetContactDateTime,GETUTCDATE()) )


	RETURN @ISAproved

END