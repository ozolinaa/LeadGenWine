-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeAttachmentTaxonomyAddOrUpdate]
	-- Add the parameters for the stored procedure here
	@PostTypeID int,
	@AttachmentTaxonomyID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT * FROM [dbo].[CMSPostTypeAttachmentTaxonomy] WHERE [PostTypeID] = @PostTypeID AND [AttachmentTaxonomyID] = @AttachmentTaxonomyID)
		BEGIN

			INSERT INTO [dbo].[CMSPostTypeAttachmentTaxonomy]
				([PostTypeID], [AttachmentTaxonomyID], [IsEnabled])
			VALUES
				(@PostTypeID, @AttachmentTaxonomyID, 1)

		END
	ELSE
	BEGIN

		UPDATE [dbo].[CMSPostTypeAttachmentTaxonomy]
		SET IsEnabled = 1
		WHERE [PostTypeID] = @PostTypeID
		AND [AttachmentTaxonomyID] = @AttachmentTaxonomyID

	END

END