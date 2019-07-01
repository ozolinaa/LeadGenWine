-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineCreate]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@InvoiceLineDescription NVARCHAR(MAX),
	@UnitPrice decimal(19,4),
	@Quantity smallint,
	@Tax decimal(4,2),
	@InvoiceLineID smallint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @BusinessID BIGINT
	SELECT @BusinessID = BusinessID
	FROM [dbo].[BusinessInvoice] WHERE InvoiceID = @InvoiceID

	--SELECT MAX @InvoiceLineID
	SELECT 
		@InvoiceLineID = MAX([LineID])
	FROM [dbo].[BusinessInvoiceLine] 
	WHERE InvoiceID = @InvoiceID
	--Increase @InvoiceLineID for the new line
	SET @InvoiceLineID = ISNULL(@InvoiceLineID,0) + 1

	INSERT INTO [dbo].[BusinessInvoiceLine] (
		[InvoiceID],
		[BusinessID],
		[LineID],
		[Description],
		[UnitPrice],
		[Quantity],
		[Tax]
	)
	VALUES
	(
		@InvoiceID,
		@BusinessID,
		@InvoiceLineID,
		ISNULL(@InvoiceLineDescription, ''),
		ISNULL(@UnitPrice,0),
		ISNULL(@Quantity,1),
		ISNULL(@Tax,0)
	)

	EXEC [dbo].[BusinessInvoiceTotalSumUpdate] @InvoiceID
END