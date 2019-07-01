-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldMetaTermIsAllowed]
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@isAllowed bit OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [dbo].[LeadFieldMetaTermsAllowed] WHERE [TermID] = @TermID)
		SET @isAllowed = 1;
	ELSE 
		SET @isAllowed = 0;

RETURN 0
END