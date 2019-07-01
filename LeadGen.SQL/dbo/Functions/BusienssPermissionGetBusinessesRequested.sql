-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[BusienssPermissionGetBusinessesRequested]
(	
	-- Add the parameters for the function here
	@LeadID bigint
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here

	-- Select IDs only for leads that have all terms in tables TC, TD, TR that were requested by business in table Business.Lead.Permission.Term

	SELECT 
		t.BusinessID,
		CASE WHEN SUM(t.isApproved) > 0 THEN 1 ELSE 0 END IsApproved
	FROM (
		SELECT
			BP.BusinessID,
			BP.PermissionID,
			CASE WHEN BP.IsApprovedByAdmin IS NULL THEN 0 ELSE 1 END as IsApproved
		FROM 
			[dbo].[Lead] L
			CROSS JOIN [dbo].[LeadFieldStructure] LS
			INNER JOIN [dbo].[LeadFieldValueTaxonomy] LT ON LT.LeadID = L.LeadID AND LS.FieldID = LT.FieldID
			LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] BPTLead ON BPTLead.TermID = LT.TermID
			LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] BPTPermission ON BPTPermission.PermissionID = BPTLead.PermissionID
			LEFT OUTER JOIN [dbo].[BusinessLeadPermission] BP ON BP.PermissionID = BPTPermission.PermissionID AND BP.[RequestedDateTime] IS NOT NULL
		WHERE
			L.LeadID = @LeadID
			AND L.[PublishedDateTime] IS NOT NULL
			AND BP.BusinessID IS NOT NULL
		GROUP BY 
			BP.BusinessID, BP.PermissionID, BP.IsApprovedByAdmin
		HAVING 
			SUM(CASE WHEN BPTLead.TermID = BPTPermission.TermID Then 1 ELSE 0 END) = COUNT(DISTINCT BPTPermission.TermID)
	) t
	GROUP BY t.BusinessID
)