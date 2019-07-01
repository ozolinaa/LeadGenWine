-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentUpdate]
	-- Add the parameters for the stored procedure here
	@AttachmentID bigint,
	@Name nvarchar(100),
	@Description nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [dbo].[CMSAttachment]
	SET [Name] = @Name,
	[Description] = @Description
	WHERE [AttachmentID] = @AttachmentID

END