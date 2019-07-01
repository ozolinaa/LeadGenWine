-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentTermAdd]
	@Attachment bigint,
	@TermID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		INSERT INTO [dbo].[CMSAttachmentTerm]
			([AttachmentID], [TermID])
		VALUES 
			(@Attachment, @TermID)
		RETURN 1
	END TRY
	BEGIN CATCH
		RETURN 0
	END CATCH 
END