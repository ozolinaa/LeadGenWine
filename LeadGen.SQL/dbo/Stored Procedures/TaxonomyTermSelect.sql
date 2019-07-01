-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermSelect] 
	-- Add the parameters for the stored procedure here
	@TermID bigint = NULL,
	@TermURL nvarchar(50) = NULL,
	@TermName nvarchar(50) = NULL,
	@TaxonomyID int = NULL,
	@TaxonomyName nvarchar(50) = NULL,
	@TaxonomyCode nvarchar(50) = NULL,
	@TermParentID bigint = 0,
	@OnlyAllowedInLeads bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		TT.[TermID], 
		TT.[TaxonomyID], 
		TT.[TermName], 
		TT.[TermURL], 
		TT.[TermThumbnailURL],
		TT.[TermParentID]
	FROM 
		[dbo].[TaxonomyTerm] TT 
		INNER JOIN [dbo].[Taxonomy] T ON T.[TaxonomyID] = TT.[TaxonomyID] 
		LEFT OUTER JOIN [dbo].[LeadFieldMetaTermsAllowed] LTA ON LTA.[TermID] = TT.TermID 
	WHERE 
		(@TermID IS NULL or TT.[TermID] = @TermID)
		AND (@TermURL IS NULL OR TT.[TermURL] = @TermURL)
		AND (@TermName IS NULL OR TT.[TermName] = @TermName)
		AND (@TaxonomyID IS NULL OR TT.[TaxonomyID] = @TaxonomyID)
		AND (@TaxonomyName IS NULL OR T.[TaxonomyName] = @TaxonomyName)
		AND (@TaxonomyCode IS NULL OR T.[TaxonomyCode] = @TaxonomyCode)
		AND (@TermParentID = 0 OR ISNULL(TT.[TermParentID], 0) = ISNULL(@TermParentID, 0))
		AND (ISNULL(@OnlyAllowedInLeads, 0) = 0 OR LTA.TermID IS NOT NULL)

END