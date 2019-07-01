-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[BusienssLocationGetBusinessesNearBy]
(	
	-- Add the parameters for the function here
	@LeadID bigint
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT 
		t.BusinessID,
		MAX(t.IsApproved) as IsApproved
	FROM (
		SELECT
			b.BusinessID,
			b.LocationID, 
			CASE WHEN b.IsApprovedByAdmin = 1 THEN 1 ELSE 0 END as IsApproved
		FROM 
			[dbo].[Lead] le
			INNER JOIN [dbo].[LeadLocation] ll ON ll.LeadID = le.LeadID
			INNER JOIN [dbo].[Location] lelo with(index([LocationWithRadiusIndex])) ON lelo.LocationID = ll.LocationID
			CROSS JOIN [dbo].[BusinessLocation] b 
			INNER JOIN [dbo].[Location] belo ON belo.LocationID = b.LocationID
			WHERE 
			le.LeadID = @LeadID
			AND (le.[PublishedDateTime] IS NOT NULL)
			AND lelo.LocationWithRadius.STIntersects(belo.[LocationWithRadius]) = 1
		GROUP BY b.BusinessID, b.LocationID, b.IsApprovedByAdmin
	) t
	GROUP BY t.BusinessID
)