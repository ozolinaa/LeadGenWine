CREATE FUNCTION [dbo].[SysStringSplit]
(
    @param      NVARCHAR(MAX),
    @delimiter  CHAR(1)
)
RETURNS @t TABLE (val NVARCHAR(MAX))
AS
BEGIN
    SET @param += @delimiter

    ;WITH a AS
    (
        SELECT CAST(1 AS BIGINT) f,
               CHARINDEX(@delimiter, @param) t,
               1 seq
        UNION ALL
        SELECT t + 1,
               CHARINDEX(@delimiter, @param, t + 1),
               seq + 1
        FROM   a
        WHERE  CHARINDEX(@delimiter, @param, t + 1) > 0
    )
    INSERT @t
    SELECT SUBSTRING(@param, f, t - f)         
    FROM   a
           OPTION(MAXRECURSION 0)

    RETURN
END