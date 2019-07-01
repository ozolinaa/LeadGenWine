-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeSelect_SiteMapData]
	-- Add the parameters for the stored procedure here
	@PageSize int = 100
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT 
		t.TypeID, 
		t.TypeCode, 
		t.TypeURL, 
		ROW_NUMBER() OVER(PARTITION BY t.TypeID ORDER BY MAX([Order]) DESC, MAX([DatePublished]) DESC) as PageNumber,
		MAX(t.DateLastModified) as DateLastModified, 
		COUNT(t.PostNumber) as PostCount ,
		AVG(t.PostNumber)
	FROM (
		SELECT 
			--Need to use the same ordering in PostNumber as in [dbo].[CMSPostSelect] procedure
			ROW_NUMBER() OVER(PARTITION BY pt.[TypeID] ORDER BY [Order] DESC, [DatePublished] DESC) AS PostNumber
			,pt.[TypeID]
			,pt.[TypeURL]
			,pt.[TypeCode]
			,p.[PostID]
			,p.[Order]
			,p.[DatePublished]
			,p.[DateLastModified]
		FROM [dbo].[CMSPostType] pt
		INNER JOIN [dbo].[CMSPost] p ON p.TypeID = pt.TypeID
		WHERE 
		pt.IsBrowsable = 1 
		AND p.DatePublished IS NOT NULL
	) t
	GROUP BY t.TypeID, t.TypeURL, t.TypeCode, (t.PostNumber-1)/@PageSize
	ORDER BY t.TypeID DESC--, [DatePublished] DESC
END