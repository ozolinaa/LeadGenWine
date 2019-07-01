-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[SysOptionGet]
(
	@OptionKey nvarchar(100)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @OptionValue nvarchar(MAX)

	SELECT @OptionValue = OptionValue
	FROM 
		[dbo].[SystemOptions] 
	WHERE	
		@OptionKey = OptionKey


	-- Return the result of the function
	RETURN @OptionValue

END