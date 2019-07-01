-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostAttachmentLink]
	-- Add the parameters for the stored procedure here
	@PostID bigint,
	@AttachmentID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO [dbo].[CMSPostAttachment]
			([AttachmentID], [PostID], [LinkDate])
		VALUES (@AttachmentID, @PostID, GETUTCDATE()) 
		
		RETURN 1

	END TRY
	BEGIN CATCH

	  RETURN 0

	END CATCH 




END