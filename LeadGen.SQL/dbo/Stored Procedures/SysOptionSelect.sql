-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysOptionSelect]
	-- Add the parameters for the stored procedure here
	@OptionKey nvarchar(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT OptionKey, OptionValue
	FROM 
		[dbo].[SystemOptions] 
	WHERE	
		(@OptionKey IS NULL OR @OptionKey = OptionKey)

END