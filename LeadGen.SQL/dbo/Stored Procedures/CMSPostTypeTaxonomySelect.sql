-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeTaxonomySelect]
	-- Add the parameters for the stored procedure here
	@ForPostTypeID int = null,
	@ForTaxonomyID int = null,
	@EnabledOnly BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		[TypeID], 
		[TypeCode],
		[TypeURL],
		[TypeName],
		[IsBrowsable],
		[seoTitle],
		[seoMetaDescription],
		[seoMetaKeywords],
		[seoPriority],
		[seoChangeFrequencyID],
		[postSeoTitle],
		[postSeoMetaDescription],
		[postSeoMetaKeywords],
		[postSeoPriority],
		[postSeoChangeFrequencyID],
		[HasContentIntro],
		[HasContentEnding],
		PTT.[ForTaxonomyID],
		PTT.[ForPostTypeID],
		T.TaxonomyID,
		TaxonomyCode,
		TaxonomyName,
		IsTag,
		ISNULL(IsEnabled, 0) as IsEnabled

	FROM [dbo].[Taxonomy] T
	LEFT OUTER JOIN [dbo].[CMSPostTypeTaxonomy] PTT ON PTT.ForTaxonomyID = T.TaxonomyID  AND (@ForPostTypeID IS NOT NULL AND PTT.ForPostTypeID = @ForPostTypeID AND PTT.ForTaxonomyID = T.TaxonomyID)
	LEFT OUTER JOIN [dbo].[CMSPostType] PT ON PT.ForPostTypeID = PTT.ForPostTypeID AND PT.ForTaxonomyID = PTT.ForTaxonomyID
	WHERE 
	(@ForTaxonomyID IS NULL OR T.TaxonomyID = @ForTaxonomyID) 
	AND (@EnabledOnly = 0 OR PTT.IsEnabled = @EnabledOnly)
END