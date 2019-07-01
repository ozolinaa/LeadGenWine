-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LocationCreate]
-- Add the parameters for the stored procedure here
	@Location geography
	,@AccuracyMeters int
	,@RadiusMeters int
	,@StreetAddress nvarchar(255)
	,@PostalCode nvarchar(255)
	,@City nvarchar(255)
	,@Region nvarchar(255)
	,@Country nvarchar(255)
	,@Zoom int
	,@Name nvarchar(255)
	,@LocationID BIGINT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[Location]
           ([Location]
           ,[AccuracyMeters]
           ,[RadiusMeters]
           ,[StreetAddress]
           ,[PostalCode]
           ,[City]
           ,[Region]
           ,[Country]
		   ,[Zoom]
           ,[Name])
     VALUES
           (@Location
           ,@AccuracyMeters
           ,@RadiusMeters
           ,@StreetAddress
           ,@PostalCode
           ,@City
           ,@Region
           ,@Country
		   ,@Zoom
		   ,@Name)

	SET @LocationID = SCOPE_IDENTITY()
END