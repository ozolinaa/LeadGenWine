CREATE PROCEDURE [dbo].[SystemLogInsert]
	@Value NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO SystemLog ([Value]) VALUES (@Value)

END