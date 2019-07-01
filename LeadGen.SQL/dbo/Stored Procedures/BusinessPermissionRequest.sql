-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessPermissionRequest]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@TermIDTable [dbo].[SysBigintTableType] READONLY,
	@PermissionID bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Try to find existing permission of this business with these termIDs 
	DECLARE @TermIDTableNumRows INT
	SELECT @TermIDTableNumRows = COUNT(*) FROM @TermIDTable

	SELECT @PermissionID = PT.PermissionID
	FROM [dbo].[BusinessLeadPermission] P
	LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] PT ON PT.PermissionID = P.PermissionID
	LEFT OUTER JOIN @TermIDTable TT ON TT.Item = PT.TermID
	WHERE P.BusinessID = @BusinessID
	GROUP BY PT.PermissionID
	HAVING SUM (TT.Item) IS NOT NULL AND COUNT(TT.Item) = @TermIDTableNumRows

	IF @PermissionID IS NULL
	BEGIN
		-- If @PermissionID IS NULL, ALTER new Permission ID
		EXEC [dbo].[SysGetNewPrimaryKeyValueForTable] 'Business.Lead.Permission', @PermissionID OUTPUT

		INSERT INTO [dbo].[BusinessLeadPermission] 
			([PermissionID], [BusinessID], [RequestedDateTime])
		VALUES
			(@PermissionID, @BusinessID, GETUTCDATE())

		INSERT INTO [dbo].[BusinessLeadPermissionTerm] 
			([PermissionID], [TermID])
		SELECT @PermissionID, Item FROM @TermIDTable	
	END
	ELSE
		-- Update Permission RequestedDateTime
		UPDATE [dbo].[BusinessLeadPermission] 
		SET [RequestedDateTime] = GETUTCDATE()
		WHERE PermissionID = @PermissionID AND BusinessID = @BusinessID AND [RequestedDateTime] IS NULL


END