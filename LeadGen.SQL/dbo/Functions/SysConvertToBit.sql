-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[SysConvertToBit]
(
	@Str nvarchar(MAX)
)
RETURNS bit
AS
BEGIN

	IF (@Str = 'true' OR @Str = 'yes' OR @Str = '1')
		RETURN 1

	RETURN 0

END