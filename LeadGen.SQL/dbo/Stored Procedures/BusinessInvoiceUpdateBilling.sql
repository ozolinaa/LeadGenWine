-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceUpdateBilling]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@LegalAddress nvarchar(255),
	@LegalName nvarchar(255),
	@LegalCode1 nvarchar(255),
	@LegalCode2 nvarchar(255),
	@LegalBankAccount nvarchar(255),
	@LegalBankName nvarchar(255),
	@LegalBankCode1 nvarchar(255),
	@LegalBankCode2 nvarchar(255),
	@BillingAddress nvarchar(255),
	@BillingName nvarchar(255),
	@BillingCode1 nvarchar(255),
	@BillingCode2 nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BusinessInvoice] 
	SET [LegalAddress] = @LegalAddress,
		[LegalName] = @LegalName,
		[LegalCode1] = @LegalCode1,
		[LegalCode2] = @LegalCode2,
		[LegalBankAccount] = @LegalBankAccount,
		[LegalBankCode1] = @LegalBankCode1,
		[LegalBankCode2] = @LegalBankCode2,
		[LegalBankName] = @LegalBankName,
		[BillingAddress] = @BillingAddress,
		[BillingName] = @BillingName,
		[BillingCode1] = @BillingCode1,
		[BillingCode2] = @BillingCode2
	WHERE [InvoiceID] = @InvoiceID

END