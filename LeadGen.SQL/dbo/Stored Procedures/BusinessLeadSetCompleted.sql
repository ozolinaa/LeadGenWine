-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetCompleted]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint,
	@OrderSum decimal(19,4),
	@SystemFeePercent decimal(4,2),
	@CompletedDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [dbo].[BusinessLeadContactsRecieved] WHERE BusinessID = @BusinessID AND LeadID = @LeadID)
		INSERT INTO [dbo].[BusinessLeadCompleted]
			([LoginID], [BusinessID], [LeadID], [CompletedDateTime], [OrderSum], [SystemFeePercent])
		VALUES (@LoginID, @BusinessID, @LeadID, ISNULL(@CompletedDateTime,GETUTCDATE()), @OrderSum, @SystemFeePercent )


	RETURN @@ROWCOUNT

END