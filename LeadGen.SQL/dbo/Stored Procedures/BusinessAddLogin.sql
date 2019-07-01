-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessAddLogin]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@loginID bigint,
	@roleID int,
	@result bit OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	BEGIN TRY
		INSERT INTO [dbo].[BusinessLogin] (
			[BusinessID],
			[LoginID],
			[RoleID]
			)
		VALUES(
			@businessID,
			@loginID,
			@roleID
		)
		SET @result = 1;
		
	END TRY
	BEGIN CATCH
		-- Execute error retrieval routine.
		SET @result = NULL;
	END CATCH

	return @result

END