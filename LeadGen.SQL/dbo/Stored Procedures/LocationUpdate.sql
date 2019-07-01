-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LocationUpdate]
-- Add the parameters for the stored procedure here
	@LocationID BIGINT
	,@Location geography
	,@AccuracyMeters int
	,@RadiusMeters int
	,@StreetAddress nvarchar(255)
	,@PostalCode nvarchar(255)
	,@City nvarchar(255)
	,@Region nvarchar(255)
	,@Country nvarchar(255)
	,@Zoom int
	,@Name nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Location]
	SET [Location] = @Location,
    [AccuracyMeters] = @AccuracyMeters,
    [RadiusMeters] = @RadiusMeters,
	[StreetAddress] = @StreetAddress,
    [PostalCode] = @PostalCode,
    [City] = @City,
    [Region] = @Region,
	[Country] = @Country,
	[Zoom] = @Zoom,
	[Name] = @Name
	WHERE [LocationId] = @LocationID
END