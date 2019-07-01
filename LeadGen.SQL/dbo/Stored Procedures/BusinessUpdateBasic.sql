-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessUpdateBasic]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@name nvarchar(255),
	@webSite nvarchar(255),
	@address nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business]
	SET
		[Name] = @name,
		[WebSite] = @webSite,
		[Address] = @address
	WHERE 
		[BusinessID] = @businessID

END