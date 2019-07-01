-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[LeadBusinessSelectRequested]
(	
	-- Add the parameters for the function here
	@LeadId bigint
)
RETURNS @RequestedBusinesses TABLE 
(
    -- Columns returned by the function
    BusinessID bigint PRIMARY KEY NOT NULL, 
    IsApproved bit NOT NULL
)
AS 
BEGIN

	IF([dbo].[SysConvertToBit]([dbo].[SysOptionGet]('LeadApprovalPermissionEnabled')) = 1)
		MERGE @RequestedBusinesses rb
		USING [dbo].[BusienssPermissionGetBusinessesRequested](@LeadId) b
		ON b.BusinessID = rb.BusinessID
		WHEN MATCHED THEN
			UPDATE
			SET rb.IsApproved = Case When b.BusinessID = 1 AND rb.BusinessID = 1 Then 1 Else 0 END
		WHEN NOT MATCHED THEN  
			INSERT (BusinessID, IsApproved)
			VALUES (b.BusinessID, b.IsApproved);


	IF([dbo].[SysConvertToBit]([dbo].[SysOptionGet]('LeadApprovalLocationEnabled')) = 1)
		MERGE @RequestedBusinesses rb
		USING [dbo].[BusienssLocationGetBusinessesNearBy](@LeadId) b
		ON b.BusinessID = rb.BusinessID
		WHEN MATCHED THEN
			UPDATE
			SET rb.IsApproved = Case When b.BusinessID = 1 AND rb.BusinessID = 1 Then 1 Else 0 END
		WHEN NOT MATCHED THEN  
			INSERT (BusinessID, IsApproved)
			VALUES (b.BusinessID, b.IsApproved);
	
	RETURN;
END