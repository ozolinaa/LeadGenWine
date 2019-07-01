-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeAttachmentTaxonomySelect]
	-- Add the parameters for the stored procedure here
	@PostTypeID int,
	@EnabledOnly BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		T.TaxonomyID,
		TaxonomyCode,
		TaxonomyName,
		IsTag,
		ISNULL(IsEnabled, 0) as IsEnabled,
		ISNULL(PTAT.PostTypeID, @PostTypeID) as PostTypeID
		
	FROM [dbo].[Taxonomy] T
	LEFT OUTER JOIN [dbo].[CMSPostTypeAttachmentTaxonomy] PTAT ON PTAT.AttachmentTaxonomyID = T.TaxonomyID AND PTAT.PostTypeID = @PostTypeID
	WHERE @EnabledOnly = 0 OR PTAT.IsEnabled = @EnabledOnly
END