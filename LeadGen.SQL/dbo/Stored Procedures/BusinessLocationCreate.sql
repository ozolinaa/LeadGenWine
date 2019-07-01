-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLocationCreate]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LocationID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	INSERT INTO [dbo].[BusinessLocation]
           ([LocationID]
		   ,[BusinessID]
           ,[ApprovedByAdminDateTime])
     VALUES
           (@LocationID
		   ,@BusinessID
           ,NULL)

END