-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessCreate]
	-- Add the parameters for the stored procedure here
	@name nvarchar(255),
	@webSite nvarchar(255),
	@countryID int,
	@businessID bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[Business](
		[Name],
		[WebSite],
		[CountryID],
		[RegistrationDate]
		)
	VALUES(
		@name,
		@webSite,
		@countryID,
		GETUTCDATE()
	)

	SET @businessID = SCOPE_IDENTITY()

	return @businessID
END