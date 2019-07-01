-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLocationDelete]
	-- Add the parameters for the stored procedure here
	@LocationID bigint,
	@BusinessID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[BusinessLocation]
	WHERE LocationID = @LocationID AND BusinessID = @BusinessID

	DELETE FROM [dbo].[Location]
	WHERE LocationID = @LocationID

END