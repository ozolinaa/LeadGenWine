-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldValueScalarDelete]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@FieldID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[LeadFieldValueScalar] WHERE [LeadID] = @LeadID AND [FieldID] = @FieldID 

	RETURN @@ROWCOUNT

END