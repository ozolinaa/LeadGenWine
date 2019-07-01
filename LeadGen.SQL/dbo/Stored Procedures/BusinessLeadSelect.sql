CREATE PROCEDURE [dbo].[BusinessLeadSelect]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LeadID bigint = NULL,
	@Status nvarchar(50) = 'All',
	@DateFrom DateTime = NULL,
	@DateTo DateTime = NULL,
	@CompletedBeforeDate DATE = NULL,
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
		[DateTime] DATETIME
	)

	DECLARE @RequestedLeads TABLE (
		[LeadID] BIGINT,
		[IsApproved] BIT
	)

	INSERT INTO @RequestedLeads ([LeadID], [IsApproved])
	SELECT [LeadID], [IsApproved]
	FROM [dbo].[BusinessLeadSelectRequested](@BusinessID,@DateFrom, @DateTo, @LeadID)


	IF (@Status = 'All')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], L.[CreatedDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN @RequestedLeads R ON R.LeadID = L.LeadID
			LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
		WHERE (R.LeadID IS NOT NULL OR LCR.LeadID IS NOT NULL)
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'NewForBusiness')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], L.[CreatedDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN @RequestedLeads R ON R.LeadID = L.LeadID
			LEFT OUTER JOIN [dbo].[BusinessLeadNotInterested] LNR ON LNR.LeadID = L.LeadID AND LNR.BusinessID = @BusinessID
			LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
		WHERE R.LeadID IS NOT NULL AND LNR.NotInterestedDateTime IS NULL AND LCR.GetContactsDateTime IS NULL 
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'ContactReceived')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], LCR.[GetContactsDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
			LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
		WHERE LCR.GetContactsDateTime IS NOT NULL AND BLC.CompletedDateTime IS NULL
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Important')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], BLI.[ImportantDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN [dbo].[BusinessLeadImportant] BLI ON BLI.LeadID = L.LeadID AND BLI.BusinessID = @BusinessID
			LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
		WHERE BLI.ImportantDateTime IS NOT NULL AND BLC.CompletedDateTime IS NULL
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'NotInterested')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], LNR.[NotInterestedDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN [dbo].[BusinessLeadNotInterested] LNR ON LNR.LeadID = L.LeadID AND LNR.BusinessID = @BusinessID
		WHERE LNR.NotInterestedDateTime IS NOT NULL
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Completed')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], BLC.[CompletedDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
		WHERE BLC.CompletedDateTime IS NOT NULL
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'NextInvoice')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], BLC.[CompletedDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
		WHERE BLC.CompletedDateTime < @CompletedBeforeDate AND BLC.InvoiceID IS NULL AND BLC.InvoiceLineID IS NULL
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)

	IF (@Query IS NOT NULL)
	BEGIN

		DECLARE @ContainsQuery NVARCHAR(53) = '"'+ @Query + '*"'
		DECLARE @LikeQuery NVARCHAR(53) = '%'+ @Query + '%'
		--@QueryNumber would contain only numbers from the @Query
		DECLARE @QueryNumber NVARCHAR(50) = dbo.ExtractNumberFromString(@Query)
		IF(LEN(@QueryNumber) = 0 )
			SET @QueryNumber = NULL
		ELSE
			SET @QueryNumber = '%'+ @QueryNumber + '%'

		

		--Delete @LeadIDs items that were not found in search subquery
		DELETE li
		FROM @Leads li
		LEFT OUTER JOIN (
			SELECT
				t.LeadID
			FROM @Leads t
				INNER JOIN [dbo].[Lead] L ON L.LeadID = t.LeadID
				LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] LCR ON LCR.LeadID = t.LeadID AND LCR.BusinessID = @BusinessID
				LEFT OUTER JOIN [dbo].[LeadFieldValueScalar] s ON s.LeadID = t.LeadID
				LEFT OUTER JOIN [dbo].[LeadFieldStructure] ls ON ls.FieldID = s.FieldID
				LEFT OUTER JOIN [dbo].[LeadFieldValueTaxonomy] lt ON lt.LeadID = t.LeadID
				LEFT OUTER JOIN [dbo].[TaxonomyTerm] tt ON tt.TermID = lt.TermID
				--LEFT OUTER JOIN CONTAINSTABLE([dbo].[LeadFieldValueScalar], TextValue, @ContainsQuery ) ft ON ft.[Key] = s.ID
			WHERE 
				--((LCR.GetContactsDateTime IS NOT NULL OR ls.IsContact = 0) AND ft.[Key] IS NOT NULL) -OR
				((LCR.GetContactsDateTime IS NOT NULL OR ls.IsContact = 0) AND s.TextValue like @LikeQuery) OR
				(LCR.GetContactsDateTime IS NOT NULL AND L.Email like @LikeQuery) OR
				(tt.TermName like @Query) OR
				(@QueryNumber IS NOT NULL AND (
					(LCR.GetContactsDateTime IS NOT NULL AND L.NumberFromEmail like @QueryNumber)
					OR ((LCR.GetContactsDateTime IS NOT NULL OR ls.IsContact = 0) AND s.NubmerValueFromText like @QueryNumber)
					OR ((LCR.GetContactsDateTime IS NOT NULL OR ls.IsContact = 0) AND s.NumberValue like @QueryNumber)
					OR dbo.ExtractNumberFromString(tt.TermName) like @QueryNumber
					)
				)
			GROUP BY
				t.LeadID
		) s ON s.LeadID = li.[LeadID]
		WHERE s.LeadID IS NULL

	END

	-- Declare a variable that references the type.
	DECLARE @LeadIDs AS [dbo].[SysBigintTableType]; 

	-- Add data to the table variable. 
	INSERT INTO @LeadIDs (Item)
	SELECT t.[LeadID]
	FROM @Leads t
	ORDER BY t.[DateTime] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	--SET @TotalCount
	SELECT @TotalCount = COUNT(*) FROM @Leads

	
	SELECT 
		@BusinessID as BusinessID, L.[LeadID], L.[CreatedDateTime], L.[Email], L.[EmailConfirmedDateTime], L.[PublishedDateTime], L.AdminCanceledPublishDateTime, L.[UserCanceledDateTime], ISNULL(R.[IsApproved],0) as IsApproved,
		LCR.GetContactsDateTime, LNR.NotInterestedDateTime, BLI.ImportantDateTime, BLC.CompletedDateTime, BLC.OrderSum, BLC.SystemFeePercent, BLC.LeadFee
	FROM 
		@LeadIDs t 
		INNER JOIN [dbo].[Lead] L on L.LeadID = t.Item
		LEFT OUTER JOIN @RequestedLeads R ON R.LeadID = L.LeadID
		LEFT OUTER JOIN [dbo].[BusinessLeadNotInterested] LNR ON LNR.LeadID = L.LeadID AND LNR.BusinessID = @BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadImportant] BLI ON BLI.LeadID = L.LeadID AND BLI.BusinessID = @BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID

END