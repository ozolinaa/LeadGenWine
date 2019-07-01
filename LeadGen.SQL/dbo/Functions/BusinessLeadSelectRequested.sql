-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[BusinessLeadSelectRequested]
(	
	-- Add the parameters for the function here
	@BusinessID bigint,
	@DateFrom datetime = NULL,
	@DateTo datetime = NULL,
	@LeadID bigint = NULL
)
RETURNS @RequestedLeads TABLE 
(
    -- Columns returned by the function
    LeadId bigint PRIMARY KEY NOT NULL, 
    IsApproved bit NOT NULL
)
AS 
BEGIN

	IF([dbo].[SysConvertToBit]([dbo].[SysOptionGet]('LeadApprovalPermissionEnabled')) = 1)
		MERGE @RequestedLeads rl
		USING [dbo].[BusinessPermissionGetRequestedLeadIDs](@BusinessID, @DateFrom, @DateTo, @LeadID) l
		ON l.LeadId = rl.LeadId
		WHEN MATCHED THEN
			UPDATE
			SET rl.IsApproved = Case When l.LeadId = 1 AND rl.LeadId = 1 Then 1 Else 0 END
		WHEN NOT MATCHED THEN  
			INSERT (LeadId, IsApproved)
			VALUES (l.LeadId, l.IsApproved);


	IF([dbo].[SysConvertToBit]([dbo].[SysOptionGet]('LeadApprovalLocationEnabled')) = 1)
		MERGE @RequestedLeads rl
		USING [dbo].[BusinessLocationGetNearByLeadIDs](@BusinessID, @DateFrom, @DateTo, @LeadID) l
		ON l.LeadId = rl.LeadId
		WHEN MATCHED THEN
			UPDATE
			SET rl.IsApproved = Case When l.LeadId = 1 AND rl.LeadId = 1 Then 1 Else 0 END
		WHEN NOT MATCHED THEN  
			INSERT (LeadId, IsApproved)
			VALUES (l.LeadId, l.IsApproved);
	
	RETURN;
END