-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetNotified]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LeadID bigint,
	@NotifiedDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM [dbo].[BusinessLeadNotified] WHERE BusinessID = @BusinessID AND LeadID = @LeadID)
		INSERT INTO [dbo].[BusinessLeadNotified]
			(BusinessID, LeadID, [NotifiedDateTime])
		VALUES (@BusinessID, @LeadID, ISNULL(@NotifiedDateTime,GETUTCDATE()))


	RETURN 1

END