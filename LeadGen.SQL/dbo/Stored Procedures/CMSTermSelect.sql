-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSTermSelect] 
	-- Add the parameters for the stored procedure here
	@TaxonomyID int = NULL,
	@PostID bigint = NULL,
	@AttachmentID bigint = NULL
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
		LEFT OUTER JOIN [dbo].[CMSPostTerm] PT ON PT.[PostID] = @PostID AND PT.[TermID] = TT.[TermID] 
		LEFT OUTER JOIN [dbo].[CMSAttachmentTerm] AT ON AT.[AttachmentID] = @AttachmentID AND AT.[TermID] = TT.[TermID] 
	WHERE 
		(@TaxonomyID IS NULL OR TT.[TaxonomyID] = @TaxonomyID)
		AND (@PostID IS NULL OR PT.[PostID] = @PostID)
		AND (@AttachmentID IS NULL OR AT.[AttachmentID] = @AttachmentID)
	GROUP BY 
		TT.[TermID], 
		TT.[TaxonomyID], 
		TT.[TermName], 
		TT.[TermURL], 
		TT.[TermThumbnailURL],
		TT.[TermParentID]
END