-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SystemScheduledTasksSelect]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		st.ID,
		st.IntervalID,
		sti.[Name] as IntervalName,
		st.IntervalValue,
		st.[Name],
		st.StartMonth,
		st.StartMonthDay,
		st.StartWeekDay,
		st.StartMinute,
		st.StartHour
	FROM [dbo].[SystemScheduledTask] st
	INNER JOIN [dbo].[SystemScheduledTaskInterval] sti ON sti.ID = st.IntervalID

END