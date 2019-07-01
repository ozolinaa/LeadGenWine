-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetNotifiedPost]
	-- Add the parameters for the stored procedure here
	@BusinessPostID bigint,
	@LeadID bigint,
	@NotifiedDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM [dbo].[BusinessLeadNotifiedPost] WHERE BusinessPostID = @BusinessPostID AND LeadID = @LeadID)
		INSERT INTO [dbo].[BusinessLeadNotifiedPost]
			(BusinessPostID, LeadID, [NotifiedDateTime])
		VALUES (@BusinessPostID, @LeadID, ISNULL(@NotifiedDateTime,GETUTCDATE()))


	RETURN 1

END