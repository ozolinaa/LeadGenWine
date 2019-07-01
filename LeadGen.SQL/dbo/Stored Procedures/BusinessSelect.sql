-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessSelect]
	-- Add the parameters for the stored procedure here
	@businessID bigint = NULL,
	@registeredFrom datetime = NULL,
	@registeredTo datetime = NULL,
	@Query nvarchar(255) = null,
	@Offset int = 0,
	@Fetch int = 2147483647,
	@TotalCount int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Businesses TABLE (
		[BusinessID] BIGINT,
		[RegistrationDate] DATETIME
	)

	INSERT INTO @Businesses
	SELECT
		B.[BusinessID],
		B.[RegistrationDate]
	FROM
		[dbo].[Business] B 
	WHERE	
		(@businessID IS NULL OR B.BusinessID = @businessID)
		AND (@registeredFrom IS NULL OR B.[RegistrationDate] >= @registeredFrom)
		AND (@registeredTo IS NULL OR B.[RegistrationDate] < @registeredTo)

	IF (@Query IS NOT NULL)
	BEGIN

			--@QueryNumber would contain only numbers from the @Query
		DECLARE @QueryNumber NVARCHAR(50) = dbo.ExtractNumberFromString(@Query)
		IF(LEN(@QueryNumber) = 0 )
			SET @QueryNumber = NULL
		ELSE
			SET @QueryNumber = CONCAT('%',@QueryNumber,'%')

		SET @Query = CONCAT('%',@Query,'%')

		DELETE bi
		FROM @Businesses bi
		LEFT OUTER JOIN (
			SELECT
				B.[BusinessID]
			FROM
				[dbo].[Business] B 
				LEFT OUTER JOIN [dbo].[BusinessLogin] BL ON BL.BusinessID = B.BusinessID
				LEFT OUTER JOIN [dbo].[UserLogin] UL ON UL.LoginID = BL.LoginID 
				LEFT OUTER JOIN @Businesses BI ON BI.BusinessID = B.BusinessID
			WHERE
				BI.BusinessID IS NULL
				OR B.[Name] like @Query
				OR B.[WebSite] like @Query
				OR B.[Address] like @Query
				OR B.[ContactName] like @Query
				OR B.[ContactEmail] like @Query
				OR dbo.ExtractNumberFromString(B.[ContactPhone]) like @QueryNumber
				OR B.[ContactSkype] like @Query
				OR B.[BillingName] like @Query
				OR B.[BillingCode1] like @Query
				OR B.[BillingCode2] like @Query
				OR B.[BillingAddress] like @Query
				OR UL.[Email] like @Query
			GROUP BY B.[BusinessID]
		) s ON s.[BusinessID] = bi.[BusinessID]
		WHERE s.[BusinessID] IS NULL

	END

	SELECT @TotalCount = COUNT(*) FROM @Businesses

	-- Declare a variable that references the type.
	DECLARE @BusinessIDs AS [dbo].[SysBigintTableType]; 

	-- Add data to the table variable. 
	INSERT INTO @BusinessIDs (Item)
	SELECT BusinessID
	FROM @Businesses
	ORDER BY [RegistrationDate] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	SELECT
		B.BusinessID,
		BL.LoginID as BusinessAdminLoginID,
		B.Name as BusinessName,
		B.RegistrationDate as BusinessRegistrationDate,
		B.WebSite,
		B.CountryID,
		T.TermID,
		T.TermName,
		T.TermParentID,
		T.TermURL,
		T.TaxonomyID,
		T.TermThumbnailURL,
		B.NotificationFrequencyID,
		B.[Address],
		B.ContactName,
		B.ContactEmail,
		B.ContactPhone,
		B.ContactSkype,
		B.[BillingName],
		B.[BillingCode1],
		B.[BillingCode2],
		B.[BillingAddress]
	FROM
		@BusinessIDs bi
		INNER JOIN [dbo].[Business] B ON B.BusinessID = bi.Item
		INNER JOIN [dbo].[TaxonomyTerm] T ON T.TermID = B.CountryID
		INNER JOIN [dbo].[BusinessLogin] BL ON BL.BusinessID = B.BusinessID AND BL.RoleID = 2
	ORDER BY B.[RegistrationDate] DESC

END