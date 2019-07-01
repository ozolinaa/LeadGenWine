CREATE PROCEDURE [dbo].[LeadSelect_SiteMapData]
	-- Add the parameters for the stored procedure here
	@PageSize int = 100
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT  
		ROW_NUMBER() OVER(ORDER BY MAX([CreatedDateTime]) DESC) as PageNumber,
		MAX(t.PublishedDateTime) as PublishedDateTime, 
		COUNT(t.LeadNumber) as LeadCount 
	FROM (
		SELECT 
			--Need to use the same ordering in LeadNumber as in [dbo].[LeadSelect] procedure
			ROW_NUMBER() OVER(ORDER BY [CreatedDateTime] DESC) AS LeadNumber
			,l.CreatedDateTime
			,l.PublishedDateTime
		FROM [dbo].[Lead] l
		WHERE l.PublishedDateTime IS NOT NULL
	) t
	GROUP BY (t.LeadNumber-1)/@PageSize
	ORDER BY PageNumber ASC

END