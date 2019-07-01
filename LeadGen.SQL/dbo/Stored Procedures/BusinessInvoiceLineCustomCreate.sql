-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineCustomCreate]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@InvoiceLineDescription NVARCHAR(MAX),
	@UnitPrice DECIMAL(19,4),
	@Quantity SMALLINT,
	@Tax DECIMAL(4,2),
	@InvoiceLineID smallint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @InvoiceLineID = NULL
	
	DECLARE @BusinessID BIGINT

	--@CompletedBeforeDate set to the next month because need to pay for servicies provided before or INCLUDING legal invoice date
	SELECT 
		@BusinessID = BusinessID
	FROM [dbo].[BusinessInvoice] WHERE InvoiceID = @InvoiceID

	--SELECT MAX @InvoiceLineID
	SELECT 
		@InvoiceLineID = MAX(LineID)
	FROM [dbo].[BusinessInvoiceLine] 
	WHERE InvoiceID = @InvoiceID
	--Increase @InvoiceLineNumber for the new line
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
		ISNULL(@InvoiceLineDescription,''),
		@UnitPrice,
		@Quantity,
		@Tax
	)

	EXEC [dbo].[BusinessInvoiceTotalSumUpdate] @InvoiceID

END