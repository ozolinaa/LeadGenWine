-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLeadsSelectCompleted]
	-- Add the parameters for the stored procedure here
	@InoiceID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		LC.[LoginID], 
		LC.[BusinessID], 
		LC.[LeadID], 
		LC.[CompletedDateTime], 
		LC.[OrderSum], 
		LC.[SystemFeePercent], 
		LC.[LeadFee], 
		LC.[InvoiceID],
		LC.[InvoiceLineID]
	FROM [dbo].[BusinessLeadCompleted] LC
	WHERE LC.InvoiceID = @InoiceID

END