-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermWordSet] 
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@WordID bigint,
	@WordCode nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[TaxonomyTermWord] 
	([TermID], [WordID], [TermWordCode]) 
	VALUES 
	(@TermID, @WordID, @WordCode)
	
END