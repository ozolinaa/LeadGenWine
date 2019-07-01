-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSelectBusinessDetails]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		blw.LeadID, blw.BusinessID, 
		lcr.GetContactsDateTime, lni.NotInterestedDateTime, li.ImportantDateTime, lc.CompletedDateTime, lc.OrderSum, lc.SystemFeePercent, lc.LeadFee
	FROM [dbo].[BusinessLeadWorked] blw 
		LEFT OUTER JOIN [dbo].[BusinessLeadNotInterested] lni ON lni.LeadID = blw.LeadID AND lni.BusinessID = blw.BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadImportant] li ON li.LeadID = blw.LeadID AND li.BusinessID = blw.BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] lcr ON lcr.LeadID = blw.LeadID AND lcr.BusinessID = blw.BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] lc ON lc.LeadID = blw.LeadID AND lc.BusinessID = blw.BusinessID
	WHERE blw.LeadID = @LeadID
	GROUP BY 
		blw.LeadID, blw.BusinessID, 
		lcr.GetContactsDateTime, lni.NotInterestedDateTime, li.ImportantDateTime, lc.CompletedDateTime, lc.OrderSum, lc.SystemFeePercent, lc.LeadFee

END