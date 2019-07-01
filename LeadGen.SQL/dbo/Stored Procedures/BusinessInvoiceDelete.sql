-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceDelete]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- IF the invoice is paid, then return 0 and do not delete the invoice
	IF EXISTS (
		SELECT 1 FROM [dbo].[BusinessInvoice] WHERE InvoiceID = @InvoiceID AND (PublishedDatetime IS NOT NULL OR PaidDateTime IS NOT NULL)
	)
		RETURN 0

    DECLARE invoiceLine_cursor CURSOR FOR   
    SELECT [LineID] FROM [dbo].[BusinessInvoiceLine]
	WHERE InvoiceID = @InvoiceID

	DECLARE @InvoiceLineID smallint

    OPEN invoiceLine_cursor  
    FETCH NEXT FROM invoiceLine_cursor INTO @InvoiceLineID  

    WHILE @@FETCH_STATUS = 0  
    BEGIN  

		EXEC [dbo].[BusinessInvoiceLineDelete] @InvoiceID, @InvoiceLineID

        FETCH NEXT FROM invoiceLine_cursor INTO @InvoiceLineID  
        END  
  
    CLOSE invoiceLine_cursor  
    DEALLOCATE invoiceLine_cursor 

	DELETE FROM [dbo].[BusinessInvoice] WHERE InvoiceID = @InvoiceID

END