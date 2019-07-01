-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentSetURL]
	-- Add the parameters for the stored procedure here
	@AttachmentID bigint,
	@URL nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [dbo].[CMSAttachment]
	SET [URL] = @URL
	WHERE [AttachmentID] = @AttachmentID

END