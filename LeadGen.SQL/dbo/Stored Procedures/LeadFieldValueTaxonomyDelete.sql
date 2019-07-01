-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldValueTaxonomyDelete]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@FieldID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FieldTypeID int = NULL
	SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[LeadFieldStructure] WHERE [FieldID] = @FieldID

	DELETE FROM [dbo].[LeadFieldValueTaxonomy] 
	WHERE [LeadID] = @LeadID 
	AND [FieldID] = @FieldID 
	AND [FieldTypeID] = @FieldTypeID

	RETURN @@ROWCOUNT

END