-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentDelete]
	-- Add the parameters for the stored procedure here
	@AttachmentID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @Result INT = 0;

    -- Insert statements for procedure here
	BEGIN TRAN T1  

		BEGIN TRY

				DELETE FROM [dbo].[CMSAttachmentTerm]
				WHERE [AttachmentID] = @AttachmentID

				DELETE FROM [dbo].[CMSAttachmentImage]
				WHERE [AttachmentID] = @AttachmentID

				DELETE FROM [dbo].[CMSAttachment]
				WHERE [AttachmentID] = @AttachmentID

				SET @Result = 1
		END TRY
		BEGIN CATCH
			--IF HAD ERRORS
			SET @Result = 0
		END CATCH 
	
	IF @Result = 1
		COMMIT TRANSACTION T1
	ELSE
		ROLLBACK TRANSACTION T1

	RETURN @Result

END