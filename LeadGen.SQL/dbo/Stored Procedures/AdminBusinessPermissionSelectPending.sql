-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AdminBusinessPermissionSelectPending]
	-- Add the parameters for the stored procedure here
	@CountryID bigint = NULL,
	@RegionID bigint = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		B.BusinessID, B.BusinessName, B.BusinessRegistrationDate,
		COUNT (Distinct BLP.PermissionID) RequestsCount,
		Min(BLP.RequestedDateTime) as LatestRequestDateTime
	FROM 
		[dbo].[BusinessLeadPermission] BLP 
		INNER JOIN [dbo].[BusinessRegionCountry] B ON B.BusinessID = BLP.BusinessID
		--INNER JOIN [dbo].[Business] B ON B.BusinessID = BLP.BusinessID
		--LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] BLPT ON BLPT.PermissionID = BLP.PermissionID
		--INNER JOIN [dbo].[TaxonomyTerm] TT ON TT.TermID = BLPT.TermID
	WHERE 
		BLP.ApprovedByAdminDateTime IS NULL 
		AND BLP.RequestedDateTime IS NOT NULL
		AND (@CountryID IS NULL OR @CountryID = B.CountryID)
		AND (@RegionID IS NULL OR @RegionID = B.RegionID)
	GROUP BY
		B.BusinessID, B.BusinessName, B.BusinessRegistrationDate
	ORDER BY Min(BLP.RequestedDateTime) DESC
END