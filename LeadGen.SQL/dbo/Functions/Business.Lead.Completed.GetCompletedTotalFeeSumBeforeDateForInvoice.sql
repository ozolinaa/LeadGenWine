-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Business.Lead.Completed.GetCompletedTotalFeeSumBeforeDateForInvoice]
(
	@BusinessID BIGINT,
	@CompletedBeforeDate DATE
)
RETURNS DECIMAL (19,4)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @LeadFeeTotalSum decimal (19,4)

	--Calculate Lead Fee Total Sum that needs to be paid this month (that were completed before @CompletedBeforeDate)
	SELECT @LeadFeeTotalSum = SUM(ISNULL([LeadFee],0)) 
	FROM [dbo].[BusinessLeadCompleted]
	WHERE BusinessID = @BusinessID
		AND CompletedDateTime < @CompletedBeforeDate
		AND InvoiceID IS NULL
		AND InvoiceLineID IS NULL
	GROUP BY BusinessID

	-- Return the result of the function
	RETURN ISNULL(@LeadFeeTotalSum,0)

END