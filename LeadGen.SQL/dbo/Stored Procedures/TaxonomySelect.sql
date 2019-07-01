-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomySelect]
	@TaxonomyID int = NULL,
	@TaxonomyCode nvarchar(50) = NULL,
	@TaxonomyName nvarchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		T.[TaxonomyID],
		T.[TaxonomyCode],
		T.[TaxonomyName],
		T.[IsTag]
	FROM 
		[dbo].[Taxonomy] T 
	WHERE 
		(@TaxonomyID IS NULL OR T.[TaxonomyID] = @TaxonomyID)
		AND (@TaxonomyCode IS NULL OR T.[TaxonomyCode] = @TaxonomyCode)
		AND (@TaxonomyName IS NULL OR T.[TaxonomyName] = @TaxonomyName)
END