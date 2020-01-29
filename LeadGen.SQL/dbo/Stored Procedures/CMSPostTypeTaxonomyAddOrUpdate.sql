-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeTaxonomyAddOrUpdate]
	-- Add the parameters for the stored procedure here
	@ForPostTypeID int,
	@ForTaxonomyID int,
	@SeoTitle nvarchar(255),
	@SeoMetaDescription nvarchar(500),
	@SeoMetaKeywords nvarchar(500),
	@SeoChangeFrequencyID int = 4,
	@SeoPriority decimal(2,1) = 0.5,
	@URL nvarchar(100),
	@Result BIT OUT
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @TaxonomyPostTypeID INT = NULL
	DECLARE @IsBrowsable bit = 0
	SELECT @IsBrowsable = [IsBrowsable] FROM [dbo].[CMSPostType] WHERE [TypeID] = @ForPostTypeID

	IF NOT EXISTS (SELECT * FROM [dbo].[CMSPostTypeTaxonomy] WHERE [ForPostTypeID] = @ForPostTypeID AND [ForTaxonomyID] = @ForTaxonomyID)
	BEGIN

		BEGIN TRAN T1  
			BEGIN TRY
			
				declare @PostTypeName nvarchar(255) = Concat('PostTypeFor Tax:',@ForTaxonomyID,' PostType:',@ForPostTypeID)
				declare @TypeCode nvarchar(255) = Concat('tax_',@ForTaxonomyID,'__posttype_',@ForPostTypeID)

				--Add new post type for the taxonomy
				INSERT INTO [dbo].[CMSPostType] 
				([TypeCode], [TypeName], [TypeURL], [SeoTitle], [SeoMetaDescription], [SeoMetaKeywords], [SeoPriority], [SeoChangeFrequencyID], [IsBrowsable])
				VALUES 
				(@TypeCode, @PostTypeName, @URL, @SeoTitle, @SeoMetaDescription, @SeoMetaKeywords, @SeoPriority, @SeoChangeFrequencyID, @IsBrowsable) 

				SELECT @TaxonomyPostTypeID = @@IDENTITY;  

				--Add new mapping between simple post type and taxonomy post type
				INSERT INTO [dbo].[CMSPostTypeTaxonomy]
				([PostTypeID], [ForPostTypeID], [ForTaxonomyID], [IsEnabled])
				VALUES
				(@TaxonomyPostTypeID, @ForPostTypeID, @ForTaxonomyID, 1)

				--Update [ForTaxonomyID] [ForPostTypeID]. Can do that only now because there is a constraint [dbo].[CMSPostTypeTaxonomy] table
				UPDATE [dbo].[CMSPostType] 
				SET [ForTaxonomyID] = @ForTaxonomyID,
				[ForPostTypeID] = @ForPostTypeID
				WHERE [TypeID] = @TaxonomyPostTypeID

				SET @Result = 1
				COMMIT TRAN T1
			END TRY		
			BEGIN CATCH
				--IF HAD ERRORS
				ROLLBACK TRAN T1
				SET @Result = 0

				DECLARE @msg nvarchar(2048) = error_message()  
			    RAISERROR (@msg, 16, 1)
			END CATCH 
		
		

	END

	ELSE
	BEGIN

		SELECT @TaxonomyPostTypeID = [PostTypeID]
		FROM [dbo].[CMSPostTypeTaxonomy]
		WHERE [ForTaxonomyID] = @ForTaxonomyID AND [ForPostTypeID] = @ForPostTypeID


		UPDATE [dbo].[CMSPostTypeTaxonomy] 
		SET [IsEnabled] = 1
		WHERE [ForTaxonomyID] = @ForTaxonomyID 
		AND [ForPostTypeID] = @ForPostTypeID	

		UPDATE [dbo].[CMSPostType] 
		SET [TypeName] = @URL,
		[TypeURL] = @URL,
		[SeoTitle] = @SeoTitle,
		[SeoMetaDescription] = @SeoMetaDescription,
		[SeoMetaKeywords] = @SeoMetaKeywords,
		[SeoPriority] = @SeoPriority,
		[SeoChangeFrequencyID] = @SeoChangeFrequencyID,
		[IsBrowsable] = @IsBrowsable
		WHERE [ForTaxonomyID] = @ForTaxonomyID AND [ForPostTypeID] = @ForPostTypeID

		SET @Result = @@ROWCOUNT

	END



	IF @Result = 1 AND @TaxonomyPostTypeID IS NOT NULL
	BEGIN
		EXEC [dbo].[CMSPostCreateMultipleForTaxonomyType] @TaxonomyPostTypeID
	END



END