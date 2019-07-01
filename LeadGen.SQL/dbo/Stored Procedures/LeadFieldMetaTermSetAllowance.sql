-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldMetaTermSetAllowance]
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@isAllowed bit = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [dbo].[LeadFieldMetaTermsAllowed] WHERE [TermID] = @TermID)
	BEGIN

		IF (@isAllowed = 0)
			DELETE FROM [dbo].[LeadFieldMetaTermsAllowed] WHERE [TermID] = @TermID

	END
	ELSE 
	BEGIN

		IF (@isAllowed = 1)
			INSERT INTO [dbo].[LeadFieldMetaTermsAllowed] ([TermID]) VALUES (@TermID)

	END


RETURN 0
END