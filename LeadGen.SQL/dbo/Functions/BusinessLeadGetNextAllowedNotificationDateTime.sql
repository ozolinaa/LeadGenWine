-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[BusinessLeadGetNextAllowedNotificationDateTime]
(
	@BusinessID BIGINT,
	@ForFrequencyName NVARCHAR(50)
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @AllowedDateTime DATETIME = DATEADD(year, -1, GETUTCDATE()) --Previus year

	-- Declare the return variable here
	DECLARE @LastNotifiedDateTime DATETIME = [dbo].[BusinessLeadGetLastNotifiedDate](@BusinessID)
	SET @LastNotifiedDateTime = ISNULL (@LastNotifiedDateTime, @AllowedDateTime) --Previus year (if never notified)

	DECLARE @NextAllowedNotificationDateTime DATETIME
	SELECT @NextAllowedNotificationDateTime = CASE 
		WHEN nf.[Name] = 'Immediate' THEN @AllowedDateTime
		WHEN nf.[Name] = 'Hourly' THEN DATEADD(hour, 1, @LastNotifiedDateTime )
		WHEN nf.[Name] = 'Daily' THEN DATEADD(day, 1, @LastNotifiedDateTime )
		ELSE NULL
		END
	FROM [dbo].[Business] b
	INNER JOIN [dbo].[NotificationFrequency] nf ON nf.ID = b.NotificationFrequencyID
	WHERE b.BusinessID = @BusinessID AND nf.[Name] = @ForFrequencyName

	--set to next year (means NOT NOW)
	SET @NextAllowedNotificationDateTime = ISNULL (@NextAllowedNotificationDateTime, DATEADD(year, 1, GETUTCDATE()))  

	-- Return the result of the function
	RETURN @NextAllowedNotificationDateTime

END