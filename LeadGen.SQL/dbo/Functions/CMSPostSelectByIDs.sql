-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[CMSPostSelectByIDs]
(	
	-- Add the parameters for the function here
	@PostIDTable [dbo].[SysBigintTableType] READONLY
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		P.[PostID], 
		P.[PostParentID],
		PT.[TypeID], 
		PT.[TypeName],
		PT.[TypeURL], 
		PT.[ForPostTypeID],
		PT.[ForTaxonomyID],
		PT.[HasContentIntro],
		PT.[HasContentEnding],
		PS.[StatusID],
		PS.[StatusName],
		P.[AuthorID], 
		P.[DateCreated],
		P.[DatePublished],
		P.[DateLastModified],
		P.[Title],
		P.[ContentIntro],
		P.[ContentPreview],
		P.[ContentMain],
		P.[ContentEnding],
		P.[CustomCSS],
		CASE WHEN P.[PostParentID] IS NULL 
			THEN ''
			ELSE [dbo].[CMSPostURLGetParentPath](P.[PostParentID],DEFAULT)
		END as ParentPathURL,
		P.[PostURL],
		P.[PostForTermID],
		P.[PostForTaxonomyID],
		P.[ThumbnailAttachmentID],
		P.[Order],
		ISNULL(P.[SeoTitle], REPLACE(PT.[PostSeoTitle], '%PostTitle%', P.[Title])) as [SeoTitle],
		ISNULL(P.[SeoMetaDescription], REPLACE(PT.[PostSeoMetaDescription], '%PostTitle%', P.[Title])) as [SeoMetaDescription],
		ISNULL(P.[SeoMetaKeywords], REPLACE(PT.[PostSeoMetaKeywords], '%PostTitle%', P.[Title])) as [SeoMetaKeywords],
		ISNULL(P.[SeoPriority], PT.[PostSeoPriority]) [SeoPriority],
		ISNULL(P.[SeoChangeFrequencyID], PT.[PostSeoChangeFrequencyID]) [SeoChangeFrequencyID]
	FROM 
		[dbo].[CMSPost] P
		INNER JOIN @PostIDTable T ON T.Item = P.PostID
		INNER JOIN [dbo].[CMSPostStatus] PS ON PS.[StatusID] = P.[StatusID] 
		INNER JOIN [dbo].[CMSPostType] PT ON PT.[TypeID] = P.[TypeID] 
)