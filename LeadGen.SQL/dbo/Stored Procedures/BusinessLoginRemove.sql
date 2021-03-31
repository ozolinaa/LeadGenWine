-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLoginRemove]
	-- Add the parameters for the stored procedure here
	@byLoginID bigint,
	@businessID bigint,
	@loginIdToRemove bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@byLoginID = @loginIdToRemove)
	BEGIN
		RETURN 0 -- Can not remove current login
	END;

	IF NOT EXISTS
	(
		SELECT 1
		FROM dbo.BusinessLogin
		WHERE BusinessID = @businessID AND LoginID = @loginIdToRemove
	)
	BEGIN
		RETURN 0 -- @loginToRemove does not belong to this business
	END;

	DECLARE @curDate DATETIME = GETUTCDATE()
	UPDATE dbo.[UserLogin]
	SET 
		[DeletedDate] = @curDate,
		[Email] = CONCAT([Email], '_deleted_', @curDate)
	WHERE [LoginID] = @loginIdToRemove

	DELETE dbo.[UserSession] WHERE [LoginID] = @loginIdToRemove

	-- DO NOT DELETE FROM dbo.[BusinessLogin] for tracking purposes

	RETURN 1

END