-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[LeadSelectByIDs]
(	
	-- Add the parameters for the function here
	@LeadIDTable [dbo].[SysBigintTableType] READONLY
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		l.[LeadID], 
		l.[CreatedDateTime], 
		l.[Email], 
		l.[EmailConfirmedDateTime], 
		l.[PublishedDateTime], 
		l.[AdminCanceledPublishDateTime],
		l.[UserCanceledDateTime]
	FROM  @LeadIDTable t
	INNER JOIN [dbo].[Lead] l ON l.LeadID = t.Item
)