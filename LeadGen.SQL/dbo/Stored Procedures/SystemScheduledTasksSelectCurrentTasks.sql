CREATE PROCEDURE [dbo].[SystemScheduledTasksSelectCurrentTasks]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @now DATETIME = GETUTCDATE();

	SELECT 
		st.ID as TaskID,
		st.[Name] as TaksName,
		lastRun.StartedDateTime,
		st.IntervalID,
		ti.[Name] as IntervalName,
		st.IntervalValue,
		st.StartMonth,
		st.StartMonthDay,
		st.StartWeekDay,
		st.StartMinute,
		st.StartHour
	FROM [dbo].[SystemScheduledTask] st
	INNER JOIN [dbo].[SystemScheduledTaskInterval] ti ON ti.ID = st.IntervalID
	LEFT OUTER JOIN (
		SELECT [TaskName], MAX([StartedDateTime]) as [StartedDateTime] FROM [dbo].[SystemScheduledTaskLog]
		WHERE [CompletedDateTime] IS NOT NULL
		GROUP BY [TaskName]
	) lastRun ON lastRun.TaskName = st.[Name]
	LEFT OUTER JOIN (
		SELECT TaskName FROM [dbo].[SystemScheduledTaskLog]
		WHERE [CompletedDateTime] IS NULL
		GROUP BY [TaskName]
	) runninTask ON runninTask.TaskName = st.ID	
	WHERE runninTask.TaskName IS NULL
	AND (ti.[Name] = 'Hourly' AND DATEDIFF(hour,ISNULL(lastRun.StartedDateTime, DATEADD(hour, -st.IntervalValue, @now)),@now) >= st.IntervalValue)
	AND (ISNULL(st.StartHour, DATEPART(HOUR, @now)) >= DATEPART(HOUR, @now))

END