-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[BusinessLeadGetLastNotifiedDate]
(
	@BusinessID BIGINT
)
RETURNS DATETIME
AS
BEGIN
	-- Declare the return variable here
	DECLARE @NotifiedDateTime DATETIME

	SELECT TOP 1 @NotifiedDateTime = [NotifiedDateTime]
	FROM [dbo].[BusinessLeadNotified]
	WHERE BusinessID = @BusinessID
	ORDER BY [NotifiedDateTime] DESC


	-- Return the result of the function
	RETURN @NotifiedDateTime

END