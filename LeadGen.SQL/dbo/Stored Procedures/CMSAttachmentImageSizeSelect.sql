-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentImageSizeSelect]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		[ImageSizeID], 
		[Code], 
		[MaxHeight], 
		[MaxWidth], 
		[CropMode]
	FROM [dbo].[CMSAttachmentImageSize] 
END