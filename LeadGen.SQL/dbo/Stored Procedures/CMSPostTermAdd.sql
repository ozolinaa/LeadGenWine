-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTermAdd]
	@PostID bigint,
	@TermID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	DECLARE @PostTypeID INT
	SELECT @PostTypeID = [TypeID] FROM [dbo].[CMSPost] WHERE [PostID] = @PostID

	DECLARE @TaxonomyID INT
	SELECT @TaxonomyID = [TaxonomyID] FROM [dbo].[TaxonomyTerm] WHERE [TermID] = @TermID

	BEGIN TRY
		INSERT INTO [dbo].[CMSPostTerm] 
			([PostID], [PostTypeID], [TermID], [TaxonomyID])
		VALUES 
			(@PostID, @PostTypeID, @TermID, @TaxonomyID)
		RETURN 1
	END TRY
	BEGIN CATCH
		RETURN 0
	END CATCH 
END