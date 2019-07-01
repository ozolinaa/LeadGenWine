-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostIfPostExistInOffsprings] 
	-- Add the parameters for the stored procedure here
	@PostParentID INT,
	@TestPostID INT,
	@isExist BIT = 0 OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Find Term Children
	DECLARE @ChildrenPostsCursor CURSOR
	DECLARE @ChildID BIGINT
	
	
	SET @ChildrenPostsCursor = CURSOR FOR
		SELECT [PostID]
		FROM [dbo].[CMSPost]
		WHERE [PostParentID] = @PostParentID
	
	OPEN @ChildrenPostsCursor;
	FETCH NEXT FROM @ChildrenPostsCursor INTO @ChildID

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF @ChildID = @TestPostID BEGIN
			SET @isExist = 1
			RETURN @isExist
		END
		ELSE BEGIN
			--DECLARE @RecursiveResult BIT = 0
			EXEC [dbo].[CMSPostIfPostExistInOffsprings] @ChildID, @TestPostID, @isExist OUT
			--SET @isExist = @RecursiveResult
			
		END

		FETCH NEXT FROM @ChildrenPostsCursor INTO @ChildID
	END
	CLOSE @ChildrenPostsCursor
	DEALLOCATE @ChildrenPostsCursor

	RETURN @isExist

END