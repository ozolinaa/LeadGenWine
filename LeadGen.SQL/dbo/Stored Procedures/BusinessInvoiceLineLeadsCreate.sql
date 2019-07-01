-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineLeadsCreate]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@InvoiceLineDescription NVARCHAR(MAX),
	@InvoiceLineID smallint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @InvoiceLineID = NULL
	
	DECLARE @BusinessID BIGINT
	DECLARE @Year SMALLINT
	DECLARE @Month SMALLINT
	DECLARE @CompletedBeforeDate DATE

	--@CompletedBeforeDate set to the next month because need to pay for servicies till the END for the legal invoice date
	SELECT 
		@BusinessID = BusinessID,
		@CompletedBeforeDate = DateAdd(month,1,
			CAST(CAST(LegalYear AS varchar) + '-' + CAST(LegalMonth AS varchar) + '-01' AS DATETIME)
		)
	FROM [dbo].[BusinessInvoice] WHERE InvoiceID = @InvoiceID

	DECLARE @LeadFeeTotalSum decimal (19,4)
	SET @LeadFeeTotalSum = [dbo].[Business.Lead.Completed.GetCompletedTotalFeeSumBeforeDateForInvoice](@BusinessID, @CompletedBeforeDate);
	
	--If @LeadFeeTotalSum <= 0 that means no leads need to be added to the invoice line, so return and do not perform further 
	IF (@LeadFeeTotalSum <= 0) 
		RETURN

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
		ISNULL(@InvoiceLineDescription,''),
		@LeadFeeTotalSum,
		1,
		0
	)

	--Mark completed leads with the created invoice line
	UPDATE [dbo].[BusinessLeadCompleted]
	SET [InvoiceID] = @InvoiceID,
		[InvoiceLineID] = @InvoiceLineID
	WHERE BusinessID = @BusinessID
		AND CompletedDateTime < @CompletedBeforeDate
		AND InvoiceID IS NULL
		AND InvoiceLineID IS NULL


	EXEC [dbo].[BusinessInvoiceTotalSumUpdate] @InvoiceID

END