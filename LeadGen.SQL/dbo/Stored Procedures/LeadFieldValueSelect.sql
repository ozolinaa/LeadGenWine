-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldValueSelect]
	-- Add the parameters for the stored procedure here
	@LeadIDTable [dbo].[SysBigintTableType] READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT L.LeadID, LF.FieldID, LF.FieldCode, LF.FieldName, LF.LabelText, LF.FieldTypeID, LFT.FieldTypeName, 
	LF.IsRequired, LF.IsContact, LF.IsActive, LF.[Description],
	LFG.GroupID, LFG.GroupCode, LFG.GroupTitle,
	FVS.TextValue, FVS.DatetimeValue, FVS.BoolValue, FVS.NumberValue, 
	TT.TermID,
	TT.TermURL,
	TT.TermName,
	TT.TermThumbnailURL,
	TT.TaxonomyID
	FROM [dbo].[Lead] L
	INNER JOIN @LeadIDTable LT ON LT.Item = L.LeadID
	CROSS JOIN [dbo].[LeadFieldStructure] LF
	INNER JOIN [dbo].[LeadFieldStructureGroup] LFG ON LFG.GroupID = LF.GroupID 
	INNER JOIN [dbo].[LeadFieldType] LFT ON LFT.FieldTypeID = LF.FieldTypeID
	LEFT OUTER JOIN [dbo].[LeadFieldValueScalar] FVS ON FVS.[LeadID] = L.[LeadID] AND FVS.[FieldID] = LF.[FieldID]
	LEFT OUTER JOIN [dbo].[LeadFieldValueTaxonomy] FVT ON FVT.[LeadID] = L.[LeadID] AND LF.[FieldID] = FVT.[FieldID]
	LEFT OUTER JOIN [dbo].[TaxonomyTerm] TT ON TT.TermID = FVT.TermID
	ORDER BY L.LeadID, LFG.GroupID, LF.[Order]

END