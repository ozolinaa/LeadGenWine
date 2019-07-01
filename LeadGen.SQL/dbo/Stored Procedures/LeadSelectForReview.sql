-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSelectForReview]
	-- Add the parameters for the stored procedure here
	@CompletedDaysBefore INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DueDateCode NVARCHAR(50)
	SELECT @DueDateCode = [dbo].[SysOptionGet]('LeadSettingFieldMappingDateDue')

	-- Declare a variable that references the type.
	DECLARE @LeadIDs AS [dbo].[SysBigintTableType]; 

	-- Add data to the table variable. 
	IF (ISNULL(@DueDateCode,'') = '')
		-- Select leads which @CreatedDateTime is passed and that do not yet have tokens for Creating reviews
		INSERT INTO @LeadIDs (Item)
		SELECT L.LeadID
		FROM [dbo].[Lead] L 
		WHERE
		L.EmailConfirmedDateTime IS NOT NULL --That were confirmed
		AND L.ReviewRequestSentDateTime IS NULL --Where ReviewRequest has not yet been sent
		AND l.CreatedDateTime <= DateAdd(DAY, -@CompletedDaysBefore, GETUTCDATE() )
	ELSE
		-- Select leads which @DueDateCode is passed and that do not yet have tokens for Creating reviews
		INSERT INTO @LeadIDs (Item)
		SELECT L.LeadID
		FROM [dbo].[LeadFieldValueScalar] FVS
		INNER JOIN [dbo].[LeadFieldStructure] FS ON FS.[FieldID] = FVS.[FieldID]
		INNER JOIN [dbo].[Lead] L ON L.LeadID = FVS.LeadID
		WHERE
		L.EmailConfirmedDateTime IS NOT NULL --That were confirmed
		AND L.ReviewRequestSentDateTime IS NULL --Where ReviewRequest has not yet been sent
		AND FS.[FieldCode] = @DueDateCode 
		AND FVS.[DatetimeValue] <= DateAdd(DAY, -@CompletedDaysBefore, GETUTCDATE() )

	
	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[LeadSelectByIDs] (@LeadIDs)

END