-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeSelect]
	-- Add the parameters for the stored procedure here
	@TypeID int = NULL,
	@TypeCode nvarchar(50) = NULL,
	@TypeURL nvarchar(50) = NULL,
	@TypeName nvarchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		[TypeID], 
		[TypeCode],
		[TypeURL],
		[TypeName],
		[IsBrowsable],
		[seoTitle],
		[seoMetaDescription],
		[seoMetaKeywords],
		[seoPriority],
		[seoChangeFrequencyID],
		[postSeoTitle],
		[postSeoMetaDescription],
		[postSeoMetaKeywords],
		[postSeoPriority],
		[postSeoChangeFrequencyID],
		[HasContentIntro],
		[HasContentEnding],
		[ForTaxonomyID],
		[ForPostTypeID]
	FROM [dbo].[CMSPostType]
	WHERE
			(@TypeID IS NULL OR [TypeID] = @TypeID) 
		AND (@TypeCode IS NULL OR [TypeCode] = @TypeCode) 
		AND (@TypeName IS NULL OR [TypeName] = @TypeName) 
		AND (@TypeURL IS NULL OR [TypeURL] = @TypeURL) 
END