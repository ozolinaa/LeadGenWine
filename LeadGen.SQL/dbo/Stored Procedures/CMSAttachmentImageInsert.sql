-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentImageInsert]
	-- Add the parameters for the stored procedure here
	@AttachmentID bigint,
	@ImageSizeOptionID int,
	@URL nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

	INSERT INTO [dbo].[CMSAttachmentImage]
		([AttachmentID], [ImageSizeOptionID], [URL])
	VALUES
		(@AttachmentID, @ImageSizeOptionID, @URL)

END