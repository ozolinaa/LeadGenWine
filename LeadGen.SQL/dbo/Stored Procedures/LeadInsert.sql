-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadInsert]
	-- Add the parameters for the stored procedure here
	@Email nvarchar(255),
	@LeadID bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	EXEC [dbo].[SysGetNewPrimaryKeyValueForTable] 'Lead', @LeadID OUTPUT

	INSERT INTO [dbo].[Lead]
		([LeadID], [CreatedDateTime], [Email])
	VALUES
		(@LeadID, GETUTCDATE(), @Email)
END