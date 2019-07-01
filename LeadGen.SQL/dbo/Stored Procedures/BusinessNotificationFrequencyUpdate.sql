-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessNotificationFrequencyUpdate]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@frequencyID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		BEGIN TRY

			UPDATE [dbo].[Business]
			SET [NotificationFrequencyID] = @frequencyID
			WHERE [BusinessID] = @businessID

			RETURN 1
		END TRY
		BEGIN CATCH
			RETURN 0
		END CATCH
END