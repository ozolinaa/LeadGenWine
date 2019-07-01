-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostUpdate]
	-- Add the parameters for the stored procedure here
	@PostID bigint,
	@PostParentID bigint = NULL,
	@AuthorID bigint,
	@StatusID int,
	@Title nvarchar(255),
	@ContentIntro nvarchar(MAX) = NULL,
	@ContentPreview nvarchar(MAX) = NULL,
	@ContentMain nvarchar(MAX),
	@ContentEnding nvarchar(MAX) = NULL,
	@CustomCSS nvarchar(MAX) = NULL,
	@PostURL nvarchar(100) = NULL,
	@seoTitle nvarchar(255),
	@seoMetaDescription nvarchar(500),
	@seoMetaKeywords nvarchar(500),
	@seoChangeFrequencyID int,
	@seoPriority decimal(2,1),
	@DatePublished datetime = NULL,
	@ThumbnailAttachmentID bigint,
	@Order int,
	@Result nvarchar(255) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get Current Post Type
	Declare @PostTypeID int
	SELECT @PostTypeID = [TypeID]
	FROM [dbo].[CMSPost] 
	WHERE [PostID] = @PostID


	Declare @UpdateError bit = 0


	IF @PostParentID IS NOT NULL 
	BEGIN
		--Check if @TermParentID has the same TaxonomyID as the @TermID
		IF 0 = (SELECT COUNT(*) 
				FROM [dbo].[CMSPost] 
				WHERE [PostID] = @PostParentID AND [TypeID] = @PostTypeID)
		BEGIN
			Set @UpdateError = 1
			SET @Result = 'FAILED PostParentID Type'
		END
		ELSE 
		BEGIN 
			--Check if @TermParentID does not exist in the @TermID offsprings
			DECLARE	@ExistInPostOffsprings bit
			EXEC	@ExistInPostOffsprings = [dbo].[CMSPostIfPostExistInOffsprings] @PostID, @PostParentID
			IF @PostID = @PostParentID OR @ExistInPostOffsprings = 1 BEGIN
				Set @UpdateError = 1
				SET @Result = 'FAILED PostParentID Offsprings'
			END
		END
	END

	--Check if @PostURL already exist in the current @PostTypeID and @PostParentID
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[CMSPost]
		WHERE 
			[PostID] != @PostID
			AND [PostURL] = @PostURL 
			AND [TypeID] = @PostTypeID 
			AND ISNULL([PostParentID], 0) = ISNULL(@PostParentID, 0)
	) > 0
	BEGIN
		Set @UpdateError = 1
		SET @Result = 'FAILED URL'
	END

	If @UpdateError = 0
	BEGIN TRY

		UPDATE [dbo].[CMSPost]
		SET [PostParentID] = @PostParentID,
			[StatusID] = @StatusID, 
			[AuthorID] = @AuthorID,
			[Title] = @Title, 
			[DateLastModified] = GETUTCDATE(),
			[ContentIntro] = @ContentIntro,
			[ContentPreview] = @ContentPreview,
			[ContentMain] = @ContentMain, 
			[ContentEnding] = @ContentEnding, 
			[CustomCSS] = @CustomCSS,
			[PostURL] = @PostURL, 
			[seoTitle] = @seoTitle, 
			[seoMetaDescription] = @seoMetaDescription, 
			[seoMetaKeywords] = @seoMetaKeywords,
			[seoChangeFrequencyID] = @seoChangeFrequencyID,
			[seoPriority] = @seoPriority,
			[ThumbnailAttachmentID] = @ThumbnailAttachmentID,
			[Order] = @Order
		WHERE [PostID] = @PostID

		--Update Post PublishDate
		IF (@StatusID = 50) 
			IF (@DatePublished IS NULL)
				UPDATE	[dbo].[CMSPost] 
				SET		[DatePublished] = GETUTCDATE()
				WHERE	[PostID] = @PostID AND 
						[DatePublished] IS NULL
			ELSE
				UPDATE	[dbo].[CMSPost] 
				SET		[DatePublished] = @DatePublished
				WHERE	[PostID] = @PostID
		ELSE 
			UPDATE	[dbo].[CMSPost] 
			SET		[DatePublished] = NULL
			WHERE	
				[PostID] = @PostID AND 
				[DatePublished] IS NOT NULL

		SET @Result = 'SUCCESS'

	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 'FAILED'
	END CATCH 
	

END