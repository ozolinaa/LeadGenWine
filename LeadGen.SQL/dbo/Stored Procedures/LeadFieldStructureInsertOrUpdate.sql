-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldStructureInsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@FieldTypeID int,
	@FieldCode nvarchar(50),
	@GroupID int = 1,
	@FieldName nvarchar(100),
	@LabelText nvarchar(100),
	@IsRequired bit,
	@IsContact bit,
	@IsActive bit,
	@Placeholder nvarchar(100)= null,
	@RegularExpression nvarchar(100) = null,
	@MinValue bigint = null,
	@MaxValue bigint = null,
	@TaxonomyID int = null,
	@TermParentID bigint = null,
	@FieldID int OUT,
	@ErrorMessage nvarchar(255) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC [dbo].[SysGetNewPrimaryKeyValueForTable] 'Lead.Field.Structure', @FieldID OUTPUT

	INSERT INTO [dbo].[LeadFieldStructure]
		([FieldID], [FieldCode], [FieldName], [GroupID], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive]) 
	VALUES 
		(@FieldID, @FieldCode, @FieldName, @GroupID, @FieldTypeID, @LabelText, @IsRequired, @IsContact, @IsActive)

	IF @FieldTypeID = 1
	INSERT INTO [dbo].[LeadFieldMetaTextbox]
		([FieldID], [Placeholder], [RegularExpression]) 
	VALUES 
		(@FieldID, @Placeholder, @RegularExpression)

	IF @FieldTypeID = 2
	INSERT INTO [dbo].[LeadFieldMetaDropdown]
		([FieldID], [Placeholder], [TaxonomyID], [TermParentID]) 
	VALUES 
		(@FieldID, @Placeholder, @TaxonomyID, @TermParentID)

	IF @FieldTypeID = 3
	INSERT INTO [dbo].[LeadFieldMetaChekbox]
		([FieldID], [TaxonomyID], [TermParentID]) 
	VALUES 
		(@FieldID, @TaxonomyID, @TermParentID)

	IF @FieldTypeID = 4
	INSERT INTO [dbo].[LeadFieldMetaRadio] 
		([FieldID], [TaxonomyID], [TermParentID]) 
	VALUES 
		(@FieldID, @TaxonomyID, @TermParentID)

	IF @FieldTypeID = 7
	INSERT INTO [dbo].[LeadFieldMetaNumber] 
		([FieldID], [Placeholder], [MinValue], [MaxValue]) 
	VALUES 
		(@FieldID, @Placeholder, @MinValue, @MaxValue)

RETURN 0


END