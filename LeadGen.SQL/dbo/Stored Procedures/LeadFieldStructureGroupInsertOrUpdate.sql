-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldStructureGroupInsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@GroupID int,
	@GroupCode nvarchar(100),
	@GroupTitle nvarchar(255) = NULL,
	@GroupCSSClass nvarchar(255) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[LeadFieldStructureGroup] WHERE GroupID = @GroupID)
	BEGIN

		UPDATE [dbo].[LeadFieldStructureGroup] 
		SET [GroupCode] = @GroupCode,
		[GroupTitle] = @GroupTitle
		WHERE GroupID = @GroupID
		RETURN @@ROWCOUNT

	END
	ELSE 
	BEGIN

		BEGIN TRY
			INSERT INTO [dbo].[LeadFieldStructureGroup] 
				([GroupCode], [GroupTitle])
			VALUES
				(@GroupCode, @GroupTitle)
			RETURN 1
		END TRY
		BEGIN CATCH
			RETURN 0
		END CATCH

	END




END