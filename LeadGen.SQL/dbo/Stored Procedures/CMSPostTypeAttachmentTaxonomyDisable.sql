-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeAttachmentTaxonomyDisable]
	-- Add the parameters for the stored procedure here
	@PostTypeID int,
	@AttachmentTaxonomyID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[CMSPostTypeAttachmentTaxonomy]
	SET IsEnabled = 0
	WHERE [PostTypeID] = @PostTypeID
	AND [AttachmentTaxonomyID] = @AttachmentTaxonomyID

END