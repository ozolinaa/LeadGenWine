-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysGenerateRandomString]
	-- Add the parameters for the stored procedure here
	@Length int,
	@RandomString nvarchar(255) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CharPool nvarchar(255) = 'abcdefghijkmnopqrstuvwxyz123456789'
	DECLARE @Upper int = Len(@CharPool)
	DECLARE @Lower int = 1
	DECLARE @LoopCount int = 0
	
	SET @RandomString = ''

	WHILE (@LoopCount < @Length) BEGIN
		SET @RandomString = @RandomString + 
			SUBSTRING(@Charpool, CONVERT(int, ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)), 1)
		SET @LoopCount = @LoopCount + 1
	END


	RETURN

END