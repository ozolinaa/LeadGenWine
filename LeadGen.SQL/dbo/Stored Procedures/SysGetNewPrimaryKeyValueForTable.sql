-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysGetNewPrimaryKeyValueForTable]
	-- Add the parameters for the stored procedure here
	@TableName nvarchar(100),
	@PrimaryKeyValue bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @PrimaryKeyColumnName as nvarchar(100)
	SELECT @PrimaryKeyColumnName = COL_NAME(ic.OBJECT_ID,ic.column_id)
	FROM sys.indexes AS i
	INNER JOIN sys.index_columns AS ic ON i.OBJECT_ID = ic.OBJECT_ID
	AND i.index_id = ic.index_id
	WHERE OBJECT_NAME(ic.OBJECT_ID) = @TableName AND i.is_primary_key = 1

	DECLARE @dynsql NVARCHAR(1000)
	SET @dynsql = 'select  @id =isnull(max([' + @PrimaryKeyColumnName + ']),0)+1 from [' + @TableName + '];'
	EXEC sp_executesql  @dynsql, N'@id bigint output',  @PrimaryKeyValue  OUTPUT

END