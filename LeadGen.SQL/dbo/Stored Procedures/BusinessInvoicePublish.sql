-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoicePublish]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@PublishedDatetime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BusinessInvoice] 
	SET [PublishedDatetime] = ISNULL(@PublishedDatetime, GETUTCDATE())
	WHERE [InvoiceID] = @InvoiceID

END