-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermInsert] 
	-- Add the parameters for the stored procedure here
	@TaxonomyID int,
	@TermName nvarchar(255),
	@TermURL nvarchar(255),
	@TermParentID bigint = null,
	@Result nvarchar(100) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @InsertError bit = 0


	IF 
		@TermParentID IS NOT NULL 
		AND 0 = (SELECT COUNT(*) 
				FROM [dbo].[TaxonomyTerm]
				WHERE [TermID] = @TermParentID AND [TaxonomyID] = @TaxonomyID)
	BEGIN
		Set @InsertError = 1
		SET @Result = 'FAILED ParentID Taxonomy'
	END


	--Check if @TermName already exist in the current @TaxonomyID
	--IF (
	--	SELECT COUNT(*) 
	--	FROM [dbo].[TaxonomyTerm]
	--	WHERE 
	--		[TermName] = @TermName 
	--		AND [TaxonomyID] = @TaxonomyID
	--) > 0
	--BEGIN
	--	Set @InsertError = 1
	--	SET @Result = 'FAILED Name'
	--END

	--Check if @TermURL already exist in the current @TaxonomyID
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[TaxonomyTerm]
		WHERE 
			[TermURL] = @TermURL 
			AND [TaxonomyID] = @TaxonomyID
	) > 0
	BEGIN
		Set @InsertError = 1
		SET @Result = 'FAILED URL'
	END

	If @InsertError = 0
	BEGIN TRY

		INSERT INTO [dbo].[TaxonomyTerm] ([TaxonomyID], [TermName], [TermURL], [TermParentID])
		VALUES (@TaxonomyID, @TermName, @TermURL, @TermParentID) 

		SET @Result = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 'FAILED'
	END CATCH 





END