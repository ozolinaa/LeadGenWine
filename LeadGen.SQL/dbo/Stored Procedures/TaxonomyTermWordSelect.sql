-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermWordSelect] 
	-- Add the parameters for the stored procedure here
	@TermID bigint,
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
	INNER JOIN [dbo].[SystemWordCase] w on w.WordID = tw.WordID
	WHERE @TermID = tw.TermID AND (@WordCode IS NULL OR tw.TermWordCode = @WordCode)
	
END