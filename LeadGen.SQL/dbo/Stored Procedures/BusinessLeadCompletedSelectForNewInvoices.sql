-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadCompletedSelectForNewInvoices]
	-- Add the parameters for the stored procedure here
	@CompletedBeforeDate DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
	[LoginID],
	[BusinessID],
	[LeadID],
	[CompletedDateTime],
	[OrderSum],
	[SystemFeePercent],
	[LeadFee]
	FROM [dbo].[BusinessLeadCompleted]
	WHERE CompletedDateTime < @CompletedBeforeDate
		AND InvoiceID IS NULL
		AND InvoiceLineID IS NULL

END