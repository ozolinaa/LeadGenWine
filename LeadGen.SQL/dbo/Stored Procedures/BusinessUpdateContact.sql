-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessUpdateContact]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@name nvarchar(255),
	@email nvarchar(255),
	@phone nvarchar(255),
	@skype nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business]
	SET
		ContactName = @name,
		ContactEmail = @email,
		ContactPhone = @phone,
		ContactSkype = @skype
	WHERE 
		[BusinessID] = @businessID

	return 1
END