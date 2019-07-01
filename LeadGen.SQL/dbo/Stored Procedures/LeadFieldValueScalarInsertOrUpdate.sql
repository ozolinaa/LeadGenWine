-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldValueScalarInsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@FieldID int,
	@TextValue nvarchar(500) = NULL,
	@BoolValue bit = NULL,
	@DatetimeValue datetime = NULL,
	@NumberValue bigint = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FieldTypeID int = NULL
	SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[LeadFieldStructure] WHERE [FieldID] = @FieldID


	IF EXISTS (SELECT * FROM [dbo].[LeadFieldValueScalar] WHERE [LeadID] = @LeadID AND [FieldID] = @FieldID AND [FieldTypeID] = @FieldTypeID)
	BEGIN

		UPDATE [dbo].[LeadFieldValueScalar]
		SET [TextValue] = @TextValue,
		[DatetimeValue] = @DatetimeValue,
		[BoolValue] = @BoolValue,
		[NumberValue] = @NumberValue
		WHERE [LeadID] = @LeadID AND [FieldID] = @FieldID
		RETURN @@ROWCOUNT

	END
	ELSE 
	BEGIN

		BEGIN TRY
			INSERT INTO [dbo].[LeadFieldValueScalar]
				([LeadID], [FieldID], [FieldTypeID], [TextValue], [DatetimeValue], [BoolValue], [NumberValue])
			VALUES
				(@LeadID, @FieldID, @FieldTypeID, @TextValue, @DatetimeValue, @BoolValue, @NumberValue)
			RETURN 1
		END TRY
		BEGIN CATCH
			RETURN 0
		END CATCH

	END

RETURN 0


END