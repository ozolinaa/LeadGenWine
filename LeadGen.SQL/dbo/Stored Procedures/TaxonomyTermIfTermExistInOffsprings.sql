-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermIfTermExistInOffsprings] 
	-- Add the parameters for the stored procedure here
	@ParentID BIGINT,
	@TestTermID BIGINT,
	@isExist BIT = 0 OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Find Term Children
	DECLARE @ChildrenTermsCursor CURSOR
	DECLARE @ChildID BIGINT
	
	
	SET @ChildrenTermsCursor = CURSOR FOR
		SELECT [TermID]
		FROM [dbo].[TaxonomyTerm]
		WHERE [TermParentID] = @ParentID
	
	OPEN @ChildrenTermsCursor;
	FETCH NEXT FROM @ChildrenTermsCursor INTO @ChildID

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF @ChildID = @TestTermID BEGIN
			SET @isExist = 1
			RETURN @isExist
		END
		ELSE BEGIN
			--DECLARE @RecursiveResult BIT = 0
			EXEC [dbo].[TaxonomyTermIfTermExistInOffsprings] @ChildID, @TestTermID, @isExist OUT
			--SET @isExist = @RecursiveResult
			
		END

		FETCH NEXT FROM @ChildrenTermsCursor INTO @ChildID
	END
	CLOSE @ChildrenTermsCursor
	DEALLOCATE @ChildrenTermsCursor

	RETURN @isExist

END