-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldStructureSelect]
	-- Add the parameters for the stored procedure here
	@ActiveStatus bit = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		FS.FieldID, FS.FieldName, FS.FieldCode, FS.FieldTypeID, FT.FieldTypeName, FS.LabelText,
		FS.IsRequired, FS.IsContact, FS.IsActive, FS.[Description],
		FSG.GroupID, FSG.GroupCode, FSG.GroupTitle,
		MT.RegularExpression,
		COALESCE(MN.Placeholder, MD.Placeholder, MT.Placeholder, MTA.Placeholder) as Placeholder,
		MN.MaxValue, MN.MinValue,
		COALESCE(MC.TaxonomyID, MD.TaxonomyID, MR.TaxonomyID) AS TaxonomyID,
		COALESCE(MC.TermParentID, MD.TermParentID, MR.TermParentID) AS TermParentID,
		MD.TermDepthMaxLevel
	FROM [dbo].[LeadFieldStructureGroup] FSG
	LEFT OUTER JOIN [dbo].[LeadFieldStructure] FS ON FS.GroupID = FSG.GroupID
	LEFT OUTER JOIN [dbo].[LeadFieldType] FT ON FT.FieldTypeID = FS.FieldTypeID
	LEFT OUTER JOIN [dbo].[LeadFieldMetaChekbox] MC ON FS.[FieldID] = MC.FieldID
	LEFT OUTER JOIN [dbo].[LeadFieldMetaDropdown] MD ON FS.[FieldID] = MD.FieldID 
	LEFT OUTER JOIN [dbo].[LeadFieldMetaRadio] MR ON FS.[FieldID] = MR.FieldID
	LEFT OUTER JOIN [dbo].[LeadFieldMetaTextbox] MT ON FS.[FieldID] = MT.FieldID
	LEFT OUTER JOIN [dbo].[LeadFieldMetaTextarea] MTA ON FS.[FieldID] = MTA.FieldID
	LEFT OUTER JOIN [dbo].[LeadFieldMetaNumber] MN ON FS.[FieldID] = MN.FieldID
	WHERE @ActiveStatus IS NULL OR FS.isActive = @ActiveStatus
	ORDER BY FS.[Order] ASC
END