CREATE FUNCTION [dbo].[CMSPostURLGetParentPath] (@ParentID BIGINT, @ParentPath nvarchar(MAX) = '' ) returns nvarchar(MAX)
AS
BEGIN

	IF @ParentID is null
		return @ParentPath

	DECLARE @newParentID bigint

	SELECT 
		@ParentPath = CONCAT([PostURL], '/', @ParentPath),
		@newParentID = [PostParentID]
	FROM [dbo].[CMSPost] 
	WHERE [PostID] = @ParentID

	RETURN [dbo].[CMSPostURLGetParentPath] (@newParentID, @ParentPath)

END