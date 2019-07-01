-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceCreate]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LegalYear smallint,
	@LegalMonth smallint,
	@CreatedDateTime datetime = null,
	@InvoiceID bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @CreatedDateTime = ISNULL(@CreatedDateTime, GETUTCDATE())

	DECLARE @LegalCountryID INT 
	SELECT @LegalCountryID = CountryID FROM [dbo].[Business] WHERE BusinessID = @BusinessID

	--@LegalNumber must grow since the beginning of each year CREATED
	DECLARE @LegalNumber INT = NULL
	SELECT @LegalNumber = MAX(ISNULL(LegalNumber,0)) + 1
	FROM [dbo].[BusinessInvoice]
	WHERE [LegalCountryID] = @LegalCountryID
		AND YEAR(CreatedDateTime) = YEAR(@CreatedDateTime) 
	GROUP BY [LegalCountryID]
	SET @LegalNumber = ISNULL(@LegalNumber, 1);

	INSERT INTO [dbo].[BusinessInvoice] 
	(
		[BusinessID],
		[CreatedDateTime],
		[LegalMonth],
		[LegalYear],
		[LegalNumber],
		[TotalSum],
		[LegalCountryID],
		[LegalAddress],
		[LegalName],
		[LegalCode1],
		[LegalCode2],
		[LegalBankAccount],
		[LegalBankCode1],
		[LegalBankCode2],
		[LegalBankName],
		[BillingCountryID],
		[BillingAddress],
		[BillingName],
		[BillingCode1],
		[BillingCode2]
	)
	SELECT 
		b.BusinessID,
		@CreatedDateTime as CreatedDateTime,
		@LegalMonth as LegalMonth, 
		@LegalYear as LegalYear,
		@LegalNumber as LegalNumber,
		0 as TotalSum,
		l.[LegalCountryID],
		l.[LegalAddress],
		l.[LegalName],
		l.[LegalCode1],
		l.[LegalCode2],
		l.[LegalBankAccount],
		l.[LegalBankCode1],
		l.[LegalBankCode2],
		l.[LegalBankName],
		b.[CountryID] as BillingCountryID,
		ISNULL(b.[BillingAddress], ''),
		ISNULL(b.[BillingName], ''),
		ISNULL(b.[BillingCode1], ''),
		ISNULL(b.[BillingCode2], '')
	FROM [dbo].[Business] b
	INNER JOIN [dbo].[LeadGenLegal] l ON l.LegalCountryID = b.CountryID
	WHERE b.[BusinessID] = @BusinessID 

	SET @InvoiceID = SCOPE_IDENTITY()
END