-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[BusinessLocationGetNearByLeadIDs]
(	
	-- Add the parameters for the function here
	@BusinessID bigint,
	@DateFrom datetime = NULL,
	@DateTo datetime = NULL,
	@LeadID bigint = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		t.LeadID,
		MAX(t.IsApproved) as IsApproved
	FROM (
		SELECT
			le.LeadID, 
			b.LocationID, 
			CASE WHEN b.IsApprovedByAdmin = 1 THEN 1 ELSE 0 END as IsApproved
		FROM 
			[dbo].[Lead] le
			INNER JOIN [dbo].[LeadLocation] ll ON ll.LeadID = le.LeadID
			INNER JOIN [dbo].[Location] lelo with(index([LocationWithRadiusIndex])) ON lelo.LocationID = ll.LocationID
			CROSS JOIN [dbo].[BusinessLocation] b 
			INNER JOIN [dbo].[Location] belo ON belo.LocationID = b.LocationID
			WHERE 
			b.BusinessID = @BusinessID
			AND (le.[PublishedDateTime] IS NOT NULL)
			AND (@LeadID IS NULL OR le.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < le.CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= le.CreatedDateTime)
			AND lelo.LocationWithRadius.STIntersects(belo.[LocationWithRadius]) = 1
		GROUP BY le.LeadID, b.LocationID, b.IsApprovedByAdmin
	) t
	GROUP BY t.LeadID
)