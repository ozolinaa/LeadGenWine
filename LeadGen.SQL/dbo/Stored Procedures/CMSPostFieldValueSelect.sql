-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostFieldValueSelect]
	-- Add the parameters for the stored procedure here
	@PostID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		FS.FieldID, 
		FS.FieldCode, 
		FS.FieldLabelText, 
		FT.FieldTypeID, 
		FT.FieldTypeName, 
		FV.TextValue, 
		FV.DatetimeValue, 
		FV.BoolValue, 
		FV.NumberValue,
		FV.LocationID
	FROM [dbo].[CMSPost] P 
	INNER JOIN [dbo].[CMSPostTypeFieldStructure] FS ON FS.PostTypeID = P.TypeID
	INNER JOIN [dbo].[CMSFieldType] FT ON FT.FieldTypeID = FS.FieldTypeID
	LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FV ON FV.PostID = P.PostID AND FV.FieldID = FS.FieldID
	WHERE P.PostID = @PostID
	ORDER BY FV.FieldID

END