-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyInsert] 
	-- Add the parameters for the stored procedure here
	@TaxonomyCode nvarchar(50),
	@TaxonomyName nvarchar(50),
	@IsTag bit,
	@Result nvarchar(100) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO [dbo].[Taxonomy] ([TaxonomyCode], [TaxonomyName], [IsTag])
		VALUES (@TaxonomyCode, @TaxonomyName, @IsTag) 

		SET @Result = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 'FAILED'
	END CATCH 





END