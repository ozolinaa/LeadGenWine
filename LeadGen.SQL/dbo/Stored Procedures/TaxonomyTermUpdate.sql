-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermUpdate] 
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@TermName nvarchar(255),
	@TermURL nvarchar(255),
	@TermParentID bigint,
	@Result nvarchar(255) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get Current Term Taxonomy
	Declare @TaxonomyID int
	SELECT @TaxonomyID = [TaxonomyID]
	FROM [dbo].[TaxonomyTerm] 
	WHERE [TermID] = @TermID

	Declare @UpdateError bit = 0


	IF @TermParentID IS NOT NULL 
	BEGIN

		--Check if @TermParentID has the same TaxonomyID as the @TermID
		IF 0 = (SELECT COUNT(*) 
				FROM [dbo].[TaxonomyTerm]
				WHERE [TermID] = @TermParentID AND [TaxonomyID] = @TaxonomyID)
		BEGIN
			Set @UpdateError = 1
			SET @Result = 'FAILED ParentID Taxonomy'
		END
		ELSE 
		BEGIN 
			--Check if @TermParentID does not exist in the @TermID offsprings
			DECLARE	@ExistInTermOffsprings bit
			EXEC	@ExistInTermOffsprings = [dbo].[TaxonomyTermIfTermExistInOffsprings] @TermID, @TermParentID
			IF @TermID = @TermParentID OR @ExistInTermOffsprings = 1 BEGIN
				Set @UpdateError = 1
				SET @Result = 'FAILED ParentID Offsprings'
			END
		END

	END


	--Check if @TermName already exist in the current @TaxonomyID
	--IF (
	--	SELECT COUNT(*) 
	--	FROM [dbo].[TaxonomyTerm]
	--	WHERE 
	--		[TermID] != @TermID
	--		AND [TermName] = @TermName 
	--		AND [TaxonomyID] = @TaxonomyID
	--) > 0
	--BEGIN
	--	Set @UpdateError = 1
	--	SET @Result = 'FAILED Name'
	--END

	--Check if @TermURL already exist in the current @TaxonomyID
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[TaxonomyTerm]
		WHERE 
			[TermID] != @TermID
			AND [TermURL] = @TermURL 
			AND [TaxonomyID] = @TaxonomyID
	) > 0
	BEGIN
		Set @UpdateError = 1
		SET @Result = 'FAILED URL'
	END

	If @UpdateError = 0
	BEGIN TRY

		UPDATE [dbo].[TaxonomyTerm] SET 
		[TermName] = @TermName,
		[TermURL] = @TermURL, 
		[TermParentID] = @TermParentID
		WHERE [TermID] = @TermID

		SET @Result = 'SUCCESS'
	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 'FAILED'
	END CATCH 

END