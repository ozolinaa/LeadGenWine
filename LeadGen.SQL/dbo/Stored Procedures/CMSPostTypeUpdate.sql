-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeUpdate]
	-- Add the parameters for the stored procedure here
	@PostTypeID int,
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
	@Result bit OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE [dbo].[CMSPostType] SET 
		[TypeCode] = @TypeCode,
		[TypeName] = @TypeName,
		[TypeURL] = @TypeURL,
		[IsBrowsable] = @isBrowsable,
		[seoTitle] = @seoTitle, 
		[seoMetaDescription] = @seoMetaDescription, 
		[seoMetaKeywords] = @seoMetaKeywords,
		[seoChangeFrequencyID] = @seoChangeFrequencyID,
		[seoPriority] = @seoPriority,
		[postSeoTitle] = @postSeoTitle, 
		[postSeoMetaDescription] = @postSeoMetaDescription, 
		[postSeoMetaKeywords] = @postSeoMetaKeywords,
		[postSeoChangeFrequencyID] = @postSeoChangeFrequencyID,
		[postSeoPriority] = @postSeoPriority,
		[HasContentIntro] = @HasContentIntro,
		[HasContentEnding] = @HasContentEnding
		WHERE [TypeID] = @PostTypeID

		SET @Result = 1
	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 0
	END CATCH 

	Return @Result

END