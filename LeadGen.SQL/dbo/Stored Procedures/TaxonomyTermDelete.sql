-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermDelete] 
	-- Add the parameters for the stored procedure here
	@TermID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	BEGIN TRANSACTION [TermDelete]

	BEGIN TRY

		-- Move current term children to the 'upper level'
		DECLARE @ParentID bigint
	
		SELECT @ParentID = [TermParentID] 
		FROM [dbo].[TaxonomyTerm] 
		WHERE [TermID] = @TermID

		UPDATE [dbo].[TaxonomyTerm] 
		SET [TermParentID] = @ParentID
		WHERE [TermParentID] = @TermID

		--Delete Posts for this term
		DECLARE @DeletePostID bigint
		DECLARE post_cursor CURSOR FOR  
		SELECT [PostID] FROM [dbo].[CMSPost] WHERE [PostForTermID] = @TermID

		OPEN post_cursor   
		FETCH NEXT FROM post_cursor INTO @DeletePostID   

		WHILE @@FETCH_STATUS = 0   
		BEGIN

			EXEC [dbo].[CMSPostDelete] @DeletePostID

		FETCH NEXT FROM post_cursor INTO @DeletePostID   
		END   

		CLOSE post_cursor   
		DEALLOCATE post_cursor

		-- Delete term word assosiasion
		DELETE FROM [dbo].[TaxonomyTermWord] WHERE TermID = @TermID


		-- Delete the Term
		DELETE FROM [dbo].[TaxonomyTerm] 
		WHERE [TermID] = @TermID

		COMMIT TRANSACTION [TermDelete]
		
		RETURN 1

	END TRY
	BEGIN CATCH

		--IF THIS TERM IS USED SOMEWHERE
	  ROLLBACK TRANSACTION [TermDelete]
	  
	  RETURN 0

	END CATCH 

END