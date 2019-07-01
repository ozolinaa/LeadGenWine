CREATE TABLE [dbo].[SystemScheduledTask](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[IntervalID] [int] NOT NULL,
	[IntervalValue] [int] NOT NULL,
	[StartMonth] [int] NULL,
	[StartMonthDay] [int] NULL,
	[StartWeekDay] [int] NULL,
	[StartHour] [int] NULL,
	[StartMinute] [int] NULL,
 CONSTRAINT [PK_SystemTask] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SystemScheduledTask]  WITH CHECK ADD  CONSTRAINT [FK_System.Task_System.TaskPeriod] FOREIGN KEY([IntervalID])
REFERENCES [dbo].[SystemScheduledTaskInterval] ([ID])
GO

ALTER TABLE [dbo].[SystemScheduledTask] CHECK CONSTRAINT [FK_System.Task_System.TaskPeriod]