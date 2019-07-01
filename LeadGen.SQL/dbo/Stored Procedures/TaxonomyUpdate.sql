-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyUpdate] 
	-- Add the parameters for the stored procedure here
	@TaxonomyID int,
	@TaxonomyCode nvarchar(50),
	@TaxonomyName nvarchar(50),
	@IsTag bit,
	@Result bit OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE [dbo].[Taxonomy] 
		SET [TaxonomyCode] = @TaxonomyCode, 
		[TaxonomyName] = @TaxonomyName,
		[IsTag] = @IsTag
		WHERE [TaxonomyID] = @TaxonomyID

		SET @Result = 1

	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 0
	END CATCH 

END