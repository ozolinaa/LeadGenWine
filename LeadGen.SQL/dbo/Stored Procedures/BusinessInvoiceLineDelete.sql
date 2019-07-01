-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineDelete]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@InvoiceLineID smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Release completed leads from invoice line
	UPDATE [dbo].[BusinessLeadCompleted]
	SET [InvoiceID] = NULL,
		[InvoiceLineID] = NULL
	WHERE InvoiceID = @InvoiceID
		AND InvoiceLineID = @InvoiceLineID

	--Delete Line
	DELETE FROM [dbo].[BusinessInvoiceLine]
	WHERE InvoiceID = @InvoiceID
		AND LineID = @InvoiceLineID

	DECLARE @Result BIT
	SET @Result = @@ROWCOUNT

	--Update Invoice Total Sum
	EXEC [dbo].[BusinessInvoiceTotalSumUpdate] @InvoiceID

	Return @Result

END