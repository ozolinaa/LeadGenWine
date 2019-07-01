-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostIsUniqueURL]
	-- Add the parameters for the stored procedure here
	@PostURL nvarchar(50),
	@PostTypeID int,
	@PostParentID bigint,
	@ExcludePostID bigint = NULL,
	@Result bit OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @Result = CASE WHEN COUNT(*) = 0 Then 1 Else 0 End
	FROM [dbo].[CMSPost] P
	WHERE 
		P.[PostURL] = @PostURL 
		AND P.[TypeID] = @PostTypeID
		AND (ISNULL(P.[PostParentID], 0) = ISNULL(@PostParentID, 0))
		AND (@ExcludePostID IS NULL OR P.PostID != @ExcludePostID)
END