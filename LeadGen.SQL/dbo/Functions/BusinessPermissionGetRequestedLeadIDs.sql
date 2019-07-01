-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[BusinessPermissionGetRequestedLeadIDs]
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
		CASE WHEN SUM(t.isApproved) > 0 THEN 1 ELSE 0 END IsApproved
	FROM (
		SELECT
			L.LeadID, 
			PT.PermissionID, 
			CASE WHEN BP.IsApprovedByAdmin IS NULL THEN 0 ELSE 1 END as IsApproved
		FROM 
			[dbo].[BusinessLeadPermission] BP
			LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] PT ON PT.PermissionID = BP.PermissionID
			CROSS JOIN [dbo].Lead L
			LEFT OUTER JOIN [dbo].[LeadFieldValueTaxonomy] VT ON VT.LeadID = L.LeadID AND VT.TermID = PT.TermID
		WHERE 
			BP.BusinessID = @BusinessID
			AND BP.RequestedDateTime IS NOT NULL
			AND (L.[PublishedDateTime] IS NOT NULL)
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < L.CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= L.CreatedDateTime)
		GROUP BY L.LeadID, PT.PermissionID, BP.IsApprovedByAdmin
		HAVING COUNT(VT.TermID) = COUNT(PT.TermID)
	) t
	GROUP BY t.LeadID
)