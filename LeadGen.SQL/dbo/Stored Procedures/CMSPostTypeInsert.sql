-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeInsert] 
	-- Add the parameters for the stored procedure here
	@typeCode nvarchar(50),
	@typeName nvarchar(50),
	@typeURL nvarchar(50),
	@isBrowsable bit,
	@seoTitle nvarchar(255),
	@seoMetaDescription nvarchar(500),
	@seoMetaKeywords nvarchar(500),
	@seoChangeFrequencyID int,
	@seoPriority decimal(2,1),
	@postSeoTitle nvarchar(255),
	@postSeoMetaDescription nvarchar(500),
	@postSeoMetaKeywords nvarchar(500),
	@postSeoChangeFrequencyID int,
	@postSeoPriority decimal(2,1),
	@HasContentIntro bit,
	@HasContentEnding bit,
	@typeID int OUTPUT,
	@errorText nvarchar(100) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @InsertError INT = 0

	--Check if @TermName already exist
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[CMSPostType]
		WHERE [TypeName] = @typeName 
	) > 0
	BEGIN
		Set @InsertError = 1
		SET @errorText = 'FAILED Name'
	END

	--Check if @TermURL already exist in the current @TaxonomyID
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[CMSPostType]
		WHERE TypeURL = @typeURL 
	) > 0
	BEGIN
		Set @InsertError = 1
		SET @errorText = 'FAILED URL'
	END

	If @InsertError = 0
	BEGIN TRY

		INSERT INTO [dbo].[CMSPostType] (
			[TypeCode],
			[TypeName], 
			[TypeURL], 
			[IsBrowsable],
			[SeoTitle], 
			[SeoMetaDescription], 
			[SeoMetaKeywords], 
			[SeoPriority], 
			[SeoChangeFrequencyID], 
			[PostSeoTitle], 
			[PostSeoMetaDescription], 
			[PostSeoMetaKeywords], 
			[PostSeoPriority], 
			[PostSeoChangeFrequencyID],
			[HasContentIntro],
			[HasContentEnding])
		VALUES (
			@typeCode,
			@typeName,
			@typeURL,
			@isBrowsable,
			@seoTitle,
			@seoMetaDescription,
			@seoMetaKeywords,
			@seoPriority,
			@seoChangeFrequencyID,
			@postSeoTitle,
			@postSeoMetaDescription,
			@postSeoMetaKeywords,
			@postSeoPriority,
			@postSeoChangeFrequencyID,
			@HasContentIntro,
			@HasContentEnding
		) 

		SET @typeID = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @errorText = 'FAILED'
	END CATCH 





END