-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentProcessNew]
	-- Add the parameters for the stored procedure here
	@AuthorID bigint,
	@AttachmentTypeID int,
	@MIME nvarchar(50),
	@FileHash nvarchar(100),
	@FileSizeBytes int,
	@isNewAttachment BIT OUT,
	@AttachmentID bigint OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

	SELECT @AttachmentID = AttachmentID
	FROM [dbo].[CMSAttachment] 
	WHERE [FileHash] = @FileHash 
	AND [FileSizeBytes] = @FileSizeBytes

	IF (@AttachmentID IS NULL)
		SET @isNewAttachment = 1
	ELSE
		SET @isNewAttachment = 0

	IF (@isNewAttachment = 1)
	BEGIN

		INSERT INTO [dbo].[CMSAttachment]
			([AuthorID], [TypeID], [MIME], [URL], [DateCreated], [FileHash], [FileSizeBytes])
		VALUES 
			(@AuthorID, @AttachmentTypeID, @MIME, '', GETUTCDATE(), @FileHash, @FileSizeBytes) 

		SET @AttachmentID = SCOPE_IDENTITY() 

	END



END