CREATE TABLE [dbo].[BusinessLeadPermission](
	[PermissionID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[RequestedDateTime] [datetime] NULL,
	[ApprovedByAdminDateTime] [datetime] NULL,
	[IsApprovedByAdmin] as (CASE WHEN [ApprovedByAdminDateTime] IS NULL THEN 0 ELSE 1 END) PERSISTED,
 CONSTRAINT [PK_BusinessLeadPermission] PRIMARY KEY CLUSTERED 
(
	[PermissionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessLeadPermission]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Permission_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO

ALTER TABLE [dbo].[BusinessLeadPermission] CHECK CONSTRAINT [FK_Business.Lead.Permission_Business]
GO
ALTER TABLE [dbo].[BusinessLeadPermission] ADD  CONSTRAINT [DF_Business.Lead.Permission_RequestedDateTime]  DEFAULT (getutcdate()) FOR [RequestedDateTime]
GO
/****** Object:  Index [BusinessLeadPermission_RequestedDateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [BusinessLeadPermission_RequestedDateTime] ON [dbo].[BusinessLeadPermission]
(
	[BusinessID] ASC,
	[RequestedDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]