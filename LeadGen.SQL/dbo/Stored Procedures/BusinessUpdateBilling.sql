-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessUpdateBilling]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@name nvarchar(255),
	@code1 nvarchar(255),
	@code2 nvarchar(255),
	@address nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business]
	SET
		BillingName = @name,
		BillingCode1 = @code1,
		BillingCode2 = @code2,
		BillingAddress = @address
	WHERE 
		[BusinessID] = @businessID

	return 1
END