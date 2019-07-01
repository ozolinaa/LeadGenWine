-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[CMSPostDelete]
	-- Add the parameters for the stored procedure here
	@PostID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION [PostDelete]

	BEGIN TRY

		DELETE FROM [dbo].[CMSPostTerm]
		WHERE [PostID] = @PostID

		DELETE FROM [dbo].[CMSPostAttachment]
		WHERE [PostID] = @PostID

		DELETE FROM [dbo].[CMSPostFieldValue]
		WHERE [PostID] = @PostID

		DELETE FROM [dbo].[CMSPost]
		WHERE [PostID] = @PostID

		COMMIT TRANSACTION [PostDelete]
		
		RETURN 1

	END TRY
	BEGIN CATCH

	  ROLLBACK TRANSACTION [PostDelete]
	  
	  RETURN 0

	END CATCH 

END