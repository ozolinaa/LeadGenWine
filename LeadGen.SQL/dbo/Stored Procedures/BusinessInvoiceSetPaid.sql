-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceSetPaid]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@PaidDatetime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @PaidDatetime = ISNULL(@PaidDatetime, GETUTCDATE())

	DECLARE @LegalCountryID INT 
	DECLARE @LegalYear INT 
	SELECT 
		@LegalCountryID = LegalCountryID, 
		@LegalYear = [LegalYear] 
	FROM 
		[dbo].[BusinessInvoice] 
	WHERE 
		[InvoiceID] = @InvoiceID

	--@LegalFacturaNumber must grow since the beginning of year LEGAL
	DECLARE @LegalFacturaNumber INT = NULL
	SELECT @LegalFacturaNumber = MAX(ISNULL(LegalFacturaNumber,0)) + 1
	FROM [dbo].[BusinessInvoice] 
	WHERE [LegalCountryID] = @LegalCountryID
		AND [LegalYear] = @LegalYear 
	GROUP BY [LegalCountryID]
	SET @LegalFacturaNumber = ISNULL(@LegalFacturaNumber, 1);

	UPDATE [dbo].[BusinessInvoice] 
	SET [PaidDateTime] = @PaidDatetime,
		[LegalFacturaNumber] = ISNULL([LegalFacturaNumber], @LegalFacturaNumber) --Keep the esisting [LegalFacturaNumber] if exists 
	WHERE [InvoiceID] = @InvoiceID

END