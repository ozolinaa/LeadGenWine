-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadLocationInsertOrUpdate]
	-- Add the parameters for the stored procedure here
           @LeadID bigint,
		   @LocationId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @OldLocationId bigint
	SELECT @OldLocationId = LocationId FROM [dbo].[LeadLocation] WHERE LeadId = @LeadID

	IF @OldLocationId IS NOT NULL
	BEGIN
		--Delete OLD Location
		DELETE FROM [dbo].[LeadLocation] WHERE LocationId = @OldLocationId
		EXEC [dbo].[LocationDelete] @OldLocationId
	END


	INSERT INTO [dbo].[LeadLocation]
           ([LocationID]
		   ,[LeadID])
     VALUES
           (@LocationId
		   ,@LeadID)
END