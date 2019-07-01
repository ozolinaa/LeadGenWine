CREATE PROCEDURE [dbo].[SysOptionInsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@OptionKey nvarchar(100),
	@OptionValue nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[SystemOptions] 
	SET OptionValue = @OptionValue
	WHERE OptionKey = @OptionKey

	IF @@ROWCOUNT = 0
		INSERT INTO [dbo].[SystemOptions] (OptionKey, OptionValue) VALUES (@OptionKey, @OptionValue)


END