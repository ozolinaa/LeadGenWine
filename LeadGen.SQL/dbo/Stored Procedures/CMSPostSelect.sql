-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostSelect]
	-- Add the parameters for the stored procedure here
	@PostID bigint = null,
	@PostURL nvarchar(100) = NULL,
	@PostParentID bigint = 0,
	@TypeID int = null,
	@TaxonomyID int = null,
	@TermID bigint = null,
	@ForTypeID int = null,
	@ForTermID bigint = null,
	@StatusID int = NULL,
	@ExcludeStartPage bit = 0,
	@Query NVARCHAR(50) = NULL,
	@Offset int = 0,
	@Fetch int = 2147483647,
	@TotalCount int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Posts TABLE (
		[PostID] BIGINT,
		[Order] int,
		[DatePublished] DATETIME
	)

	INSERT INTO @Posts
		SELECT 
			P.[PostID], P.[Order], P.[DatePublished]
		FROM 
			[dbo].[CMSPost] P 
			INNER JOIN [dbo].[CMSPostStatus] PS ON PS.[StatusID] = P.[StatusID] 
			INNER JOIN [dbo].[CMSPostType] PT ON PT.[TypeID] = P.[TypeID] 
			LEFT OUTER JOIN [dbo].[CMSPostTerm] TE ON TE.[PostID] = P.[PostID] 
			LEFT OUTER JOIN [dbo].[TaxonomyTerm] TT ON TT.[TermID] = TE.[TermID] 
		WHERE
			(@PostID IS NULL OR P.[PostID] = @PostID) 
			AND (@PostURL IS NULL OR P.[PostURL] = @PostURL)
			AND (@TypeID IS NULL OR PT.[TypeID] = @TypeID) 
			AND (@StatusID IS NULL OR P.StatusID = @StatusID)
			AND (@PostParentID = 0 OR ISNULL(P.[PostParentID], 0) = ISNULL(@PostParentID, 0))
			AND (@TaxonomyID IS NULL OR TT.[TaxonomyID] = @TaxonomyID)
			AND (@TermID IS NULL OR TT.[TermID] = @TermID)
			AND (@ForTypeID IS NULL OR PT.[ForPostTypeID] = @ForTypeID)
			AND (@ForTermID IS NULL OR P.[PostForTermID] = @ForTermID)
			AND (@ExcludeStartPage = 0 OR P.[PostURL] != '')
		GROUP BY 
			P.[PostID], P.[Order], P.[DatePublished]
	

	IF (@Query IS NOT NULL)
	BEGIN

		DECLARE @LikeQuery AS nvarchar(255) = CONCAT('%',@Query,'%')

		DELETE t
		FROM @Posts t
		LEFT OUTER JOIN (
			SELECT 
				P.[PostID]
			FROM 
				[dbo].[CMSPost] P 
				INNER JOIN @Posts t2 ON t2.PostID = P.[PostID]
			WHERE 
				P.Title like @LikeQuery OR P.PostURL like @LikeQuery
		) s ON s.[PostID] = t.[PostID]
		WHERE s.[PostID] IS NULL

	END

	--SET @TotalCount
	SELECT @TotalCount = COUNT(*) FROM @Posts

	-- Declare a variable that references the type.
	DECLARE @PostIDs AS [dbo].[SysBigintTableType]; 

	-- Add data to the table variable. 
	INSERT INTO @PostIDs (Item)
	SELECT [PostID]
	FROM @Posts t
	ORDER BY [Order] DESC, [DatePublished] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[CMSPostSelectByIDs] (@PostIDs) 
	ORDER BY [Order] ASC, [DatePublished] DESC

END