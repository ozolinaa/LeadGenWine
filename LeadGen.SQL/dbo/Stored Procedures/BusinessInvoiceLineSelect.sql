-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineSelect]
	-- Add the parameters for the stored procedure here
	@InoiceID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		l.[InvoiceID],
		l.[BusinessID],
		[LineID],
		[Description],
		[UnitPrice],
		[Quantity],
		[Tax],
		[LinePrice],
		[LineTotalPrice],
		CASE WHEN SUM(ISNULL(lc.InvoiceLineID,0)) > 0 THEN 1 ELSE 0 END AS isLeadLine
	FROM [dbo].[BusinessInvoiceLine] l
	LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] lc ON lc.InvoiceID = l.InvoiceID AND lc.InvoiceLineID = l.LineID
	WHERE l.[InvoiceID] = @InoiceID
	GROUP BY
		l.[InvoiceID],
		l.[BusinessID],
		[LineID],
		[Description],
		[UnitPrice],
		[Quantity],
		[Tax],
		[LinePrice],
		[LineTotalPrice]
	ORDER BY [LineID]

END