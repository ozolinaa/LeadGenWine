-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostFieldValueInsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@PostID bigint,
	@FieldID int,
	@TextValue nvarchar(max) = NULL,
	@DatetimeValue datetime = NULL,
	@BoolValue bit = NULL,
	@NumberValue bigint = NULL,
	@LocationID bigint = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[CMSPostFieldValue] WHERE PostID = @PostID AND FieldID = @FieldID)
	BEGIN

		DECLARE @OldLocationID BIGINT
		SELECT  @OldLocationID = [LocationID] 
		FROM [dbo].[CMSPostFieldValue] 
		WHERE [PostID] = @PostID AND [FieldID] = @FieldID

		UPDATE [dbo].[CMSPostFieldValue] 
		SET [TextValue] = @TextValue,
		[DatetimeValue] = @DatetimeValue,
		[BoolValue] = @BoolValue,
		[NumberValue] = @NumberValue,
		[LocationID] = @LocationID
		WHERE [PostID] = @PostID AND [FieldID] = @FieldID

		IF (@LocationID <> @OldLocationID)
		BEGIN
			EXEC [dbo].[LocationDelete] @OldLocationID
		END

		RETURN @@ROWCOUNT

	END
	ELSE 
	BEGIN

		DECLARE @FieldTypeID int = NULL
		SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[CMSPostTypeFieldStructure] WHERE [FieldID] = @FieldID

		DECLARE @PostTypeID int = NULL
		SELECT @PostTypeID = [TypeID] FROM [dbo].[CMSPost] WHERE [PostID] = @PostID

		BEGIN TRY
			INSERT INTO [dbo].[CMSPostFieldValue] 
				(PostID, PostTypeID, [FieldID], [TextValue], [DatetimeValue], [BoolValue], [NumberValue], [LocationID])
			VALUES
				(@PostID, @PostTypeID, @FieldID, @TextValue, @DatetimeValue, @BoolValue, @NumberValue, @LocationID)
			RETURN 1
		END TRY
		BEGIN CATCH
			RETURN 0
		END CATCH

	END




END