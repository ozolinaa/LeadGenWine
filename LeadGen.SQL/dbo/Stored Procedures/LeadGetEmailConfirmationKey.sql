-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadGetEmailConfirmationKey]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TOP 1 TokenKey
	FROM [dbo].[SystemToken]
	WHERE [TokenAction] = 'LeadEmailConfirmation'
	AND [TokenValue] = @LeadID
	ORDER BY [TokenDateCreated] DESC

END