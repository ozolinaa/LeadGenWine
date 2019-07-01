-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostAttachmentUnlink]
	-- Add the parameters for the stored procedure here
	@PostID bigint,
	@AttachmentID bigint,
	@AttachmentUsed INT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

		UPDATE [dbo].[CMSPost]
		SET [ThumbnailAttachmentID] = NULL
		WHERE [PostID] = @PostID AND [ThumbnailAttachmentID] = @AttachmentID

		DELETE FROM [dbo].[CMSPostAttachment]
		WHERE [AttachmentID] = @AttachmentID AND [PostID] = @PostID

		SELECT @AttachmentUsed = COUNT(*) 
		FROM [dbo].[CMSPostAttachment]
		WHERE [AttachmentID] = @AttachmentID

END