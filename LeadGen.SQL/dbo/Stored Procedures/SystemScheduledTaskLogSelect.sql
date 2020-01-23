-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SystemScheduledTaskLogSelect]
	@Offset int = 0,
	@Fetch int = 2147483647,
	@TotalCount int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [ID]
		  ,[TaskName]
		  ,[StartedDateTime]
		  ,[CompletedDateTime]
		  ,[Status]
		  ,[Message]
	  FROM [SystemScheduledTaskLog]
	  ORDER BY [StartedDateTime] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	SELECT @TotalCount = COUNT(*) FROM [SystemScheduledTaskLog]

END