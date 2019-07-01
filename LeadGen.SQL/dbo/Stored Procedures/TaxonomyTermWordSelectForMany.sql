CREATE PROCEDURE [dbo].[TaxonomyTermWordSelectForMany] 
	-- Add the parameters for the stored procedure here
	@TermIDTable [dbo].[SysBigintTableType] READONLY,
	@WordCode nvarchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	tw.TermID, 
	tw.TermWordCode, 
	w.*
	FROM [dbo].[TaxonomyTermWord] tw
	INNER JOIN @TermIDTable tt ON tt.Item = tw.TermID
	INNER JOIN [dbo].[SystemWordCase] w on w.WordID = tw.WordID
	WHERE (@WordCode IS NULL OR tw.TermWordCode = @WordCode)
	
END