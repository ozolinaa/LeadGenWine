-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
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

	DECLARE @BusinessPostFieldIDDoNotSendEmails int = 8
	DECLARE @BusinessPostFieldIDBusiness int = 9
	DECLARE @BusinessPostFieldIDLocation int = 7

	DECLARE @TaxonomyMatches TABLE
	(
		LeadID BIGINT NOT NULL,
		PostID BIGINT NOT NULL
	)
	DECLARE @LocationMatches TABLE
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
				LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVS ON FVS.PostID = PT.PostID AND FVS.FieldID = @BusinessPostFieldIDDoNotSendEmails
				LEFT OUTER JOIN [dbo].[BusinessLeadNotifiedPost] BLN on BLN.BusinessPostID = PT.PostID AND BLN.LeadID = LE.LeadID
				LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVB ON FVB.PostID = PT.PostID AND FVB.FieldID = @BusinessPostFieldIDBusiness

			WHERE 
				LE.PublishedDateTime >= @PublishedAfter 
				AND LE.UserCanceledDateTime IS NULL -- User Did Not RemoveEmail
				AND LE.PublishedDateTime IS NOT NULL -- IsPublished
				AND BLN.NotifiedDateTime IS NULL -- Was Not Yet Notified
				AND ISNULL(FVS.BoolValue, 0) = 0  -- DoNotSendEmails = FALSE
				AND ISNULL(FVB.NumberValue, 0) = 0  -- Has no link to Business
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
		INSERT INTO @LocationMatches (LeadID, PostID)
		SELECT LE.[LeadID], FVL.PostID 
		FROM [dbo].[Lead] LE 
		INNER JOIN [dbo].[LeadLocation] LL ON LL.LeadID = LE.LeadID
		INNER JOIN [dbo].[Location] L1 with(index([LocationWithRadiusIndex])) ON L1.LocationID = LL.LocationID
		INNER JOIN [dbo].[Location] L2 ON L2.LocationWithRadius.STIntersects(L1.[LocationWithRadius]) = 1
		INNER JOIN [dbo].[CMSPostFieldValue] FVL ON FVL.PostTypeID = @BusinessPostTypeID AND FVL.LocationID = L2.LocationID
		LEFT OUTER JOIN [dbo].[BusinessLeadNotifiedPost] BLN on BLN.BusinessPostID = FVL.PostID AND BLN.LeadID = LE.LeadID
		LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVS ON FVS.PostID = FVL.PostID AND FVS.FieldID = @BusinessPostFieldIDDoNotSendEmails
		LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVB ON FVB.PostID = FVL.PostID AND FVB.FieldID = @BusinessPostFieldIDBusiness
		WHERE 
			LE.PublishedDateTime >= @PublishedAfter 
			AND LE.UserCanceledDateTime IS NULL -- User Did Not RemoveEmail
			AND LE.PublishedDateTime IS NOT NULL -- IsPublished
			AND BLN.NotifiedDateTime IS NULL -- Was Not Yet Notified
			AND ISNULL(FVS.BoolValue, 0) = 0  -- DoNotSendEmails = FALSE
			AND ISNULL(FVB.NumberValue, 0) = 0  -- Has no link to Business
		GROUP BY 
			LE.[LeadID], 
			FVL.[PostID]
	END

	INSERT INTO @ResultMatches (LeadID, PostID)
	SELECT LeadID, PostID
	FROM @LocationMatches

	INSERT INTO @ResultMatches (LeadID, PostID)
	SELECT LeadID, PostID
	FROM @TaxonomyMatches

	SELECT LeadID, PostID
	FROM @ResultMatches
END