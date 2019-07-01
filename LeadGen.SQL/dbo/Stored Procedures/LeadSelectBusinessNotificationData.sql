-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSelectBusinessNotificationData]
	-- Add the parameters for the stored procedure here
	@PublishedAfter DateTime,
	@ForFrequencyName NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		LeadID,
		BusinessID,
		IsApproved,
		NextAllowedNotificationDateTime
	 FROM (
		SELECT 
			l.[LeadID], 
			br.BusinessID,
			br.IsApproved,
			[dbo].[BusinessLeadGetNextAllowedNotificationDateTime](br.BusinessID, @ForFrequencyName) as NextAllowedNotificationDateTime
		FROM [dbo].[Lead] l
		CROSS APPLY [dbo].[LeadBusinessSelectRequested](l.LeadID) br
		LEFT OUTER JOIN [dbo].[BusinessLeadNotified] bln on bln.BusinessID = br.BusinessID AND bln.LeadID = l.LeadID
		WHERE l.PublishedDateTime >= @PublishedAfter
		AND bln.NotifiedDateTime IS NULL   
		AND l.UserCanceledDateTime IS NULL 
		AND l.AdminCanceledPublishDateTime IS NULL
	) t
	WHERE t.NextAllowedNotificationDateTime <= GETUTCDATE()

END