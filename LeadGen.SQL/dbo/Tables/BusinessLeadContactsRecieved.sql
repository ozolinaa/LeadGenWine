CREATE TABLE [dbo].[BusinessLeadContactsRecieved](
	[LoginID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[GetContactsDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BusinessLeadContactsRecieve] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessLeadContactsRecieved]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.ContactsRecieve_Business.Login] FOREIGN KEY([BusinessID], [LoginID])
REFERENCES [dbo].[BusinessLogin] ([BusinessID], [LoginID])
GO

ALTER TABLE [dbo].[BusinessLeadContactsRecieved] CHECK CONSTRAINT [FK_Business.Lead.ContactsRecieve_Business.Login]
GO
ALTER TABLE [dbo].[BusinessLeadContactsRecieved]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.ContactsRecieve_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO

ALTER TABLE [dbo].[BusinessLeadContactsRecieved] CHECK CONSTRAINT [FK_Business.Lead.ContactsRecieve_Lead]
GO
ALTER TABLE [dbo].[BusinessLeadContactsRecieved] ADD  CONSTRAINT [DF_Business.Lead.ContactsRecieve_GetContactsDate]  DEFAULT (getutcdate()) FOR [GetContactsDateTime]
GO
/****** Object:  Index [LeadIDIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [LeadIDIndex] ON [dbo].[BusinessLeadContactsRecieved]
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]