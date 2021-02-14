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

	SELECT L.LeadID, LF.FieldID, LF.[Order], LF.FieldCode, LF.FieldName, LF.LabelText, LF.FieldTypeID, LFT.FieldTypeName, 
	LF.IsRequired, LF.IsContact, LF.IsActive, LF.[Description],
	LFG.GroupID, LFG.GroupCode, LFG.GroupTitle,
	FVS.TextValue, FVS.DatetimeValue, FVS.BoolValue, FVS.NumberValue, 
	TT.TermID, TT.TermURL, TT.TermName, TT.TermThumbnailURL, TT.TaxonomyID
	FROM [dbo].[Lead] L
	INNER JOIN @LeadIDTable LT ON LT.Item = L.LeadID
	CROSS JOIN [dbo].[LeadFieldStructure] LF
	INNER JOIN [dbo].[LeadFieldStructureGroup] LFG ON LFG.GroupID = LF.GroupID 
	INNER JOIN [dbo].[LeadFieldType] LFT ON LFT.FieldTypeID = LF.FieldTypeID
	LEFT OUTER JOIN [dbo].[LeadFieldValueScalar] FVS ON FVS.[LeadID] = L.[LeadID] AND FVS.[FieldID] = LF.[FieldID]
	LEFT OUTER JOIN [dbo].[LeadFieldValueTaxonomy] FVT ON FVT.[LeadID] = L.[LeadID] AND LF.[FieldID] = FVT.[FieldID]
	LEFT OUTER JOIN [dbo].[TaxonomyTerm] TT ON TT.TermID = FVT.TermID
	UNION ALL
	SELECT 
	LL.LeadID, -1 as FieldID, -1 as [Order], '_system_location_address' as [FieldCode], 'Address' as [FieldName], 'Address' as [LabelText], LFT.[FieldTypeID], LFT.[FieldTypeName], 
	0 as [IsRequired], 0 as [IsContact], 1 as [IsActive], '' as [Description],
	-1 as [LFG.GroupID], '_system' as [GroupCode], 'System' as [GroupTitle],
	StreetAddress as TextValue, NULL as DatetimeValue, NULL as BoolValue, NULL as NumberValue,
	NULL as [TermID], NULL as [TermURL], NULL as [TermName], NULL as [TermThumbnailURL], NULL as [TaxonomyID]
	FROM @LeadIDTable as L
	LEFT OUTER JOIN 
	( 
	 SELECT LeadID, MAX(LocationID) as LocationID, -1 as [Order]
	 FROM LeadLocation
	 GROUP BY LeadID -- DB schema allows to have multiple locations per lead, but business logic not
	) LL ON LL.LeadID = L.Item
	LEFT OUTER JOIN [dbo].[Location] LOC ON LOC.LocationID = LL.LocationID
	LEFT OUTER JOIN [dbo].[LeadFieldType] LFT ON LFT.FieldTypeID = 1 --Textbox

	ORDER BY [LeadID], [GroupID], [Order]

END