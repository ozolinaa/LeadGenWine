-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[CMSPostCreateEmpty]
	-- Add the parameters for the stored procedure here
	@AuthorID bigint,
	@PostTypeID int,
	@PostID BIGINT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


    -- Insert statements for procedure here
	INSERT INTO [dbo].[CMSPost] 
		([TypeID], 
		[StatusID], 
		[AuthorID], 
		[DateCreated], 
		[seoPriority],
		[seoChangeFrequencyID],
		[Title], 
		[ContentMain], 
		[PostURL],
		[Order])
	VALUES (
		@PostTypeID, 
		10, 
		@AuthorID, 
		GETUTCDATE(), 
		0.5,
		4,
		'',
		'',
		'The string that nobody would ever enter',
		0) 


	SET @PostID = SCOPE_IDENTITY()

	-- Update [Title] to so it has the Post ID
	UPDATE [dbo].[CMSPost] 
	SET [Title] = Concat('Title for Post #', @PostID)
	WHERE [PostID] = @PostID

	-- Update [PostURL] to make it unique
	Declare @URLEnding bigint = 1
	Declare @NewURL nvarchar(100)
	WHILE 1=1
	BEGIN
		IF @URLEnding = 1
			SET @NewURL = Concat('ulr-for-post-', @PostID)
		ELSE
			SET @NewURL = Concat('ulr-for-post-', @PostID, '-', @URLEnding)

		BEGIN TRY
			UPDATE [dbo].[CMSPost] 
			SET [PostURL] = @NewURL
			WHERE [PostID] = @PostID
			BREAK
		END TRY
		BEGIN CATCH
			SET @URLEnding = @URLEnding + 1
		END CATCH 
	END


END