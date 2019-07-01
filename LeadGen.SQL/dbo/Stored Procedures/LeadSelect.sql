-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSelect]
	-- Add the parameters for the stored procedure here
	@LeadID bigint NULL,
	@Status nvarchar(50) = 'All',
	@DateFrom DateTime = NULL,
	@DateTo DateTime = NULL,
	@Query NVARCHAR(50) = NULL,
	@Offset int = 0,
	@Fetch int = 2147483647,
	@TotalCount int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Leads TABLE (
		[LeadID] BIGINT,
		[CreatedDateTime] DATETIME
	)

	IF (@Status = 'All')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], l.[CreatedDateTime]
		FROM [dbo].[Lead] l
		WHERE @LeadID IS NULL OR l.LeadID = @LeadID
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Published')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], l.[CreatedDateTime]
		FROM [dbo].[Lead] l
		WHERE l.[PublishedDateTime] IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Canceled')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], l.[CreatedDateTime]
		FROM [dbo].[Lead] l
		WHERE l.[PublishedDateTime] IS NULL AND l.EmailConfirmedDateTime IS NOT NULL AND (l.AdminCanceledPublishDateTime IS NOT NULL OR l.UserCanceledDateTime IS NOT NULL)
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'NotConfirmed')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		WHERE l.[EmailConfirmedDateTime] IS NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'NotInWork')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM 
			[dbo].[Lead] l
		LEFT OUTER JOIN 
			[dbo].[BusinessLeadContactsRecieved] lcr ON lcr.LeadID = l.LeadID AND lcr.GetContactsDateTime IS NOT NULL
		WHERE l.[PublishedDateTime] IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
		GROUP BY
			l.[LeadID], l.[CreatedDateTime]
		HAVING
			COUNT(lcr.LeadID) = 0
	ELSE IF (@Status = 'ReadyToPublish')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		WHERE [EmailConfirmedDateTime] IS NOT NULL AND [UserCanceledDateTime] IS NULL AND [AdminCanceledPublishDateTime] IS NULL AND [PublishedDateTime] IS NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Completed')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		INNER JOIN [dbo].[BusinessLeadCompleted] lc ON lc.LeadID = l.LeadID
		WHERE lc.CompletedDateTime IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Important')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		INNER JOIN [dbo].[BusinessLeadImportant] li ON li.LeadID = l.LeadID
		WHERE li.ImportantDateTime IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'InWork')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] lcr ON lcr.LeadID = l.LeadID
		WHERE lcr.GetContactsDateTime IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)

	IF (@Query IS NOT NULL)
	BEGIN

		--@QueryNumber would contain only numbers from the @Query
		DECLARE @QueryNumber NVARCHAR(50) = dbo.ExtractNumberFromString(@Query)
		IF(LEN(@QueryNumber) = 0 )
			SET @QueryNumber = NULL
		ELSE
			SET @QueryNumber = CONCAT('%',@QueryNumber,'%')

		SET @Query = CONCAT('%',@Query,'%')

		--Delete @LeadIDs items that were not found in search subquery
		DELETE li
		FROM @Leads li
		LEFT OUTER JOIN (
			SELECT 
				l.[LeadID]
			FROM @Leads t
				INNER JOIN [dbo].[Lead] l ON l.LeadID = t.[LeadID]
				LEFT OUTER JOIN [dbo].[LeadFieldValueScalar] s ON s.LeadID = l.LeadID
				LEFT OUTER JOIN [dbo].[LeadFieldValueTaxonomy] lt ON lt.LeadID = l.LeadID
				LEFT OUTER JOIN [dbo].[TaxonomyTerm] tt ON tt.TermID = lt.TermID
			WHERE l.Email like @Query
				OR s.TextValue like @Query
				OR tt.TermName like @Query
				OR (@QueryNumber IS NOT NULL AND (
					l.NumberFromEmail like @QueryNumber
					OR s.NubmerValueFromText like @QueryNumber
					OR s.NumberValue like @QueryNumber
					)
				)
		) s ON s.LeadID = li.[LeadID]
		WHERE s.LeadID IS NULL

	END

	-- Declare a variable that references the type.
	DECLARE @LeadIDs AS [dbo].[SysBigintTableType];  
  
	-- Add data to the table variable. 
	INSERT INTO @LeadIDs (Item)
	SELECT t.[LeadID]
	FROM @Leads t
	ORDER BY t.[CreatedDateTime] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	--SET @TotalCount
	SELECT @TotalCount = COUNT(*) FROM @Leads

	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[LeadSelectByIDs] (@LeadIDs)
	ORDER BY [CreatedDateTime] DESC


END