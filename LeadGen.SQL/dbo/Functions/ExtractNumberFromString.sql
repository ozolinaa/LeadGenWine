CREATE FUNCTION [dbo].[ExtractNumberFromString]
(@strAlphaNumeric NVARCHAR(255))
RETURNS NVARCHAR(255) WITH SCHEMABINDING
AS
BEGIN
DECLARE @intAlpha INT
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
BEGIN
WHILE @intAlpha > 0
BEGIN
SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha, 1, '' )
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric )
END
END
RETURN NULLIF(CAST(@strAlphaNumeric as NVARCHAR(255)), '')
END