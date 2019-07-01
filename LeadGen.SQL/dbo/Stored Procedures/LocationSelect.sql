-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LocationSelect]
-- Add the parameters for the stored procedure here
	@LocationID BIGINT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  
		[LocationID]
		,[Location]
        ,[AccuracyMeters]
        ,[RadiusMeters]
        ,[StreetAddress]
        ,[PostalCode]
        ,[City]
        ,[Region]
        ,[Country]
		,[Zoom]
        ,[Name]
		,[CreatedDateTime]
		,[UpdatedDateTime]
		FROM [dbo].[Location]
		WHERE [LocationID] = @LocationID
END