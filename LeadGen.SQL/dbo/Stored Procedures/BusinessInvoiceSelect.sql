-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceSelect]
	-- Add the parameters for the stored procedure here
	@InoiceID bigint,
	@BusinessID bigint,
	@LegalYear smallint,
	@LegalNumber int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		[InvoiceID],
		[BusinessID],
		[CreatedDateTime],
		[LegalMonth],
		[LegalYear],
		[LegalNumber],
		[LegalFacturaNumber],
		[TotalSum],
		[LegalCountryID],
		[LegalAddress],
		[LegalName],
		[LegalCode1],
		[LegalCode2],
		[LegalBankName],
		[LegalBankCode1],
		[LegalBankCode2],
		[LegalBankAccount],
		[BillingCountryID],
		[BillingAddress],
		[BillingName],
		[BillingCode1],
		[BillingCode2],
		[PaidDateTime],
		[PublishedDateTime]
	FROM [dbo].[BusinessInvoice] 
	WHERE (@InoiceID IS NULL OR [InvoiceID] = @InoiceID)
	AND (@BusinessID IS NULL OR [BusinessID] = @BusinessID)
	AND (@LegalYear IS NULL OR [LegalYear] = @LegalYear)
	AND (@LegalNumber IS NULL OR [LegalNumber] = @LegalNumber)

END