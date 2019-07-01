-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostCreateMultipleForTaxonomyType]
	-- Add the parameters for the stored procedure here
	@TaxonomyTypeID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- ALTER POSTS
	INSERT INTO [dbo].[CMSPost] 
		([TypeID], 
		[StatusID], 
		[AuthorID], 
		[DatePublished], 
		[Title], 
		[ContentIntro], 
		[ContentPreview], 
		[ContentMain], 
		[PostURL],
		[PostForTermID],
		[PostForTaxonomyID])
	SELECT 
		ptt.PostTypeID,
		50,
		1,
		GETUTCDATE(),
		t.TermName, 
		null,
		null,
		'',
		t.TermURL, 
		t.TermID, 
		t.TaxonomyID
	FROM [dbo].[CMSPostTypeTaxonomy] ptt
	LEFT OUTER JOIN [dbo].[TaxonomyTerm] t on t.TaxonomyID = ptt.ForTaxonomyID
	LEFT OUTER JOIN [dbo].[CMSPost] p on p.TypeID = ptt.PostTypeID AND p.PostForTermID = t.TermID
	WHERE ptt.PostTypeID = @TaxonomyTypeID AND p.PostID IS NULL AND t.TermID IS NOT NULL

	-- PUBLISH CREATED AND EXISTED POSTS
	UPDATE [dbo].[CMSPost]
	SET [StatusID] = 50,
	[DatePublished] = GETUTCDATE()
	WHERE TypeID = @TaxonomyTypeID AND ([StatusID] <> 50 OR [DatePublished] IS NULL)

END