-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetImportant]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint,
	@ImportantDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[BusinessLeadImportant]
		([LoginID], [BusinessID], [LeadID], [ImportantDateTime])
	VALUES (@LoginID, @BusinessID, @LeadID, ISNULL(@ImportantDateTime,GETUTCDATE()) )

	RETURN @@ROWCOUNT

END