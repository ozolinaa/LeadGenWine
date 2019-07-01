-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLocationSelect]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT BL.[BusinessID]
		  ,BL.[ApprovedByAdminDateTime]
		  ,L.[LocationID]
		  ,L.[Location]
		  ,L.[AccuracyMeters]
		  ,L.[RadiusMeters]
		  ,L.[LocationWithRadius]
		  ,L.[StreetAddress]
		  ,L.[PostalCode]
		  ,L.[City]
		  ,L.[Region]
		  ,L.[Country]
		  ,L.[Zoom]
		  ,L.[Name]
		  ,L.[CreatedDateTime]
		  ,L.[UpdatedDateTime]
	  FROM [dbo].[BusinessLocation] BL
	  INNER JOIN [dbo].[Location] L ON L.LocationID = BL.LocationID
	WHERE [BusinessID] = @BusinessID

END