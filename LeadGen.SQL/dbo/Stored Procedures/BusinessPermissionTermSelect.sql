-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessPermissionTermSelect]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@RequestedOnly bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT P.[PermissionID], P.[RequestedDateTime], P.[ApprovedByAdminDateTime], 
	TT.TermID, TT.TermName, TT.TermURL, TT.TermParentID, TT.TermThumbnailURL
	FROM [dbo].[BusinessLeadPermission] P
	LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] PT ON PT.PermissionID = P.PermissionID
	INNER JOIN [dbo].[TaxonomyTerm] TT ON TT.TermID = PT.TermID
	WHERE P.[BusinessID] = @BusinessID 
	AND (@RequestedOnly = 0 OR @RequestedOnly = 1 AND P.[RequestedDateTime] IS NOT NULL)
	

END