-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeTaxonomyDisable]
	-- Add the parameters for the stored procedure here
	@ForPostTypeID int,
	@ForTaxonomyID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TaxonomyPostTypeID INT = NULL

	UPDATE [dbo].[CMSPostTypeTaxonomy] 
	SET [IsEnabled] = 0
	WHERE [ForTaxonomyID] = @ForTaxonomyID 
	AND [ForPostTypeID] = @ForPostTypeID	

	SELECT @TaxonomyPostTypeID = [PostTypeID]
	FROM [dbo].[CMSPostTypeTaxonomy] 
	WHERE [ForTaxonomyID] = @ForTaxonomyID 
	AND [ForPostTypeID] = @ForPostTypeID 
	AND [IsEnabled] = 0

	EXEC [dbo].[CMSPostDisableMultipleForTaxonomyType] @TaxonomyPostTypeID

END