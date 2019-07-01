-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceTotalSumUpdate]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Caluclate @TotalSum
	DECLARE @TotalSum DECIMAL (19,4)
	SELECT 
		@TotalSum = SUM(ISNULL([LineTotalPrice],0))
	FROM [dbo].[BusinessInvoiceLine]
	WHERE [InvoiceID] = @InvoiceID
	GROUP BY [InvoiceID]
	SET @TotalSum = ISNULL(@TotalSum,0)
	
	--UPDATE Invoice TotalSum 
	UPDATE [dbo].[BusinessInvoice]
	SET [TotalSum] = @TotalSum
	WHERE [InvoiceID] = @InvoiceID

END