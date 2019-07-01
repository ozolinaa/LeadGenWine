-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostSelectByScalarField]
	-- Add the parameters for the stored procedure here
      @FieldCode nvarchar(50),
	  @TextValue nvarchar(max),
      @DatetimeValue datetime,
      @BoolValue bit,
      @NumberValue bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Declare a variable that references the type.
	DECLARE @PostIDs AS [dbo].[SysBigintTableType];  
  
	-- Add data to the table variable. 
	INSERT INTO @PostIDs (Item)
	SELECT 
		FL.[PostID]
	FROM [dbo].[CMSPostFieldValue] FL
		INNER JOIN [dbo].[CMSPostTypeFieldStructure] FS ON FS.FieldID = FL.FieldID AND FS.FieldCode = @FieldCode
	WHERE (@TextValue IS NULL OR @TextValue = FL.TextValue) 
		AND (@DatetimeValue IS NULL OR @DatetimeValue = FL.DatetimeValue) 
		AND (@BoolValue IS NULL OR @BoolValue = FL.BoolValue) 
		AND (@NumberValue IS NULL OR @NumberValue = FL.NumberValue) 
	GROUP BY
		FL.[PostID]

	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[CMSPostSelectByIDs] (@PostIDs)

END