-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineUpdate]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@LineID smallint,
	@InvoiceLineDescription NVARCHAR(MAX),
	@UnitPrice decimal(19,4),
	@Quantity smallint,
	@Tax decimal(4,2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BusinessInvoiceLine] 
	SET [Description] = @InvoiceLineDescription,
		[UnitPrice] = @UnitPrice,
		[Quantity] = @Quantity,
		[Tax] = @Tax
	WHERE [InvoiceID] = @InvoiceID AND [LineID] = @LineID

	EXEC [dbo].[BusinessInvoiceTotalSumUpdate] @InvoiceID
END