-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldValueTaxonomyInsert]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@FieldID int,
	@TermID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FieldTypeID int = NULL
	SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[LeadFieldStructure] WHERE [FieldID] = @FieldID
	
	DECLARE @TaxonomyID int = NULL
	SELECT @TaxonomyID = [TaxonomyID] FROM [dbo].[TaxonomyTerm] WHERE [TermID] = @TermID

	BEGIN TRY
		
		INSERT INTO [LeadFieldValueTaxonomy]
			([LeadID], [FieldID], [FieldTypeID], [TermID], [TaxonomyID]) 
		VALUES 
			(@LeadID, @FieldID, @FieldTypeID, @TermID, @TaxonomyID)
		RETURN 1

	END TRY
	BEGIN CATCH
	END CATCH

RETURN 0


END