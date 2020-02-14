CREATE PROCEDURE [dbo].[LeadSelectBusinessPostNotificationData]
	-- Add the parameters for the stored procedure here
	@PublishedAfter DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @BusinessPostTypeID int = 3

	DECLARE @BusinessLeadRelationTaxonomyID bigint = 0

	DECLARE @BusinessPostFieldIDAllowSendEmails int = 13
	DECLARE @BusinessPostFieldIDDoNotSendEmails int = 8
	DECLARE @BusinessPostFieldIDBusiness int = 9
	DECLARE @BusinessPostFieldIDLocation int = 7

	DECLARE @BusinessCityPostTypeID int = 4
	DECLARE @BusinessCityFieldIDLocation int = 11

	DECLARE @TaxonomyMatches TABLE
	(
		LeadID BIGINT NOT NULL,
		PostID BIGINT NOT NULL
	)
	DECLARE @BusinessLocationMatches TABLE
	(
		LeadID BIGINT NOT NULL,
		PostID BIGINT NOT NULL
	)
	DECLARE @BusinessCityLocationMatches TABLE
	(
		LeadID BIGINT NOT NULL,
		PostID BIGINT NOT NULL
	)
	DECLARE @ResultMatches TABLE
	(
		LeadID BIGINT NOT NULL,
		PostID BIGINT NOT NULL
	)

	IF @BusinessLeadRelationTaxonomyID > 0 BEGIN
		INSERT INTO @TaxonomyMatches (LeadID, PostID)
		SELECT T.[LeadID], T.[PostID]
		FROM (
			SELECT 
				LE.[LeadID], 
				PT.[PostID]
			FROM 
				[dbo].[Lead] LE
				INNER JOIN [dbo].[LeadFieldValueTaxonomy] LT ON LT.LeadID = LE.LeadID 
				INNER JOIN [dbo].[CMSPostTerm] PT ON PT.TermID = LT.TermID AND PT.PostTypeID = @BusinessPostTypeID AND LT.TaxonomyID = @BusinessLeadRelationTaxonomyID
			WHERE 
				LE.PublishedDateTime >= @PublishedAfter 
				
				AND LE.PublishedDateTime IS NOT NULL -- IsPublished

			GROUP BY 
				LE.[LeadID], 
				PT.[PostID]
		) T
		LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVB ON FVB.PostID = T.PostID AND FVB.FieldID = @BusinessPostFieldIDBusiness
		WHERE 
			FVB.NumberValue IS NULL -- Post is not assosiated with Business
		GROUP BY 
			T.[LeadID], 
			T.[PostID]
	END

	IF @BusinessPostFieldIDLocation > 0 BEGIN
		INSERT INTO @BusinessLocationMatches (LeadID, PostID)
		SELECT LE.[LeadID], FVL.PostID 
		FROM [dbo].[Lead] LE 
		INNER JOIN [dbo].[LeadLocation] LL ON LL.LeadID = LE.LeadID
		INNER JOIN [dbo].[Location] L1 with(index([LocationWithRadiusIndex])) ON L1.LocationID = LL.LocationID
		INNER JOIN [dbo].[Location] L2 ON L2.LocationWithRadius.STIntersects(L1.[LocationWithRadius]) = 1
		INNER JOIN [dbo].[CMSPostFieldValue] FVL ON FVL.PostTypeID = @BusinessPostTypeID AND FVL.LocationID = L2.LocationID
		WHERE 
			LE.PublishedDateTime >= @PublishedAfter 
		GROUP BY 
			LE.[LeadID], 
			FVL.[PostID]
	END

	IF @BusinessCityPostTypeID > 0 AND @BusinessCityFieldIDLocation > 0 BEGIN
		INSERT INTO @BusinessCityLocationMatches (LeadID, PostID)
		SELECT LE.[LeadID], PT.PostID 
		FROM [dbo].[Lead] LE 
		INNER JOIN [dbo].[LeadLocation] LL ON LL.LeadID = LE.LeadID
		INNER JOIN [dbo].[Location] L1 with(index([LocationWithRadiusIndex])) ON L1.LocationID = LL.LocationID
		INNER JOIN [dbo].[Location] L2 ON L2.LocationWithRadius.STIntersects(L1.[LocationWithRadius]) = 1
		INNER JOIN [dbo].[CMSPostFieldValue] FVL ON FVL.PostTypeID = @BusinessCityPostTypeID AND FVL.FieldID = @BusinessCityFieldIDLocation AND FVL.LocationID = L2.LocationID
		INNER JOIN [dbo].[CMSPost] TP ON TP.PostID = FVL.PostID
		INNER JOIN [dbo].[CMSPostTerm] PT ON PT.TermID = TP.PostForTermID AND PT.PostTypeID = @BusinessPostTypeID
		WHERE 
			LE.PublishedDateTime >= @PublishedAfter 
		GROUP BY 
			LE.[LeadID], PT.PostID 
	END

	INSERT INTO @ResultMatches (LeadID, PostID)
	SELECT LeadID, PostID
	FROM @TaxonomyMatches

	INSERT INTO @ResultMatches (LeadID, PostID)
	SELECT LeadID, PostID
	FROM @BusinessLocationMatches

	INSERT INTO @ResultMatches (LeadID, PostID)
	SELECT LeadID, PostID
	FROM @BusinessCityLocationMatches

	DELETE R FROM @ResultMatches R
		LEFT OUTER JOIN [dbo].[CMSPost] P ON P.PostID = R.PostID
		LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVSA ON FVSA.PostID = R.PostID AND FVSA.FieldID = @BusinessPostFieldIDAllowSendEmails
		LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVS ON FVS.PostID = R.PostID AND FVS.FieldID = @BusinessPostFieldIDDoNotSendEmails
		LEFT OUTER JOIN [dbo].[BusinessLeadNotifiedPost] BLN on BLN.BusinessPostID = R.PostID AND BLN.LeadID = R.LeadID
		LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVB ON FVB.PostID = R.PostID AND FVB.FieldID = @BusinessPostFieldIDBusiness
		LEFT OUTER JOIN [dbo].[Business] B ON B.BusinessID = FVB.NumberValue
		LEFT OUTER JOIN [dbo].[Lead] LE ON LE.LeadID = R.LeadID
	WHERE 
		P.StatusID < 30 -- Status is below "Pending"
		OR BLN.NotifiedDateTime IS NOT NULL -- Has already been Notified
		OR ISNULL(FVSA.BoolValue,0) = 0  -- AllowSendEmails = FALSE
		OR FVS.BoolValue = 1  -- DoNotSendEmails = TRUE
		OR B.BusinessID IS NOT NULL  -- Post is linked to Business
		OR LE.UserCanceledDateTime IS NOT NULL -- User Cancelled Publishing

	SELECT LeadID, PostID
	FROM @ResultMatches
	GROUP BY LeadID, PostID
END