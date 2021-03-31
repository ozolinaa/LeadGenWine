CREATE TABLE [dbo].[UserLogin](
	[LoginID] [bigint] IDENTITY(1,1) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[PasswordHash] [nvarchar](255) NULL,
	[RegistrationDate] [datetime] NOT NULL,
	[EmailConfirmationDate] [datetime] NULL,
 [DeletedDate] DATETIME NULL, 
    CONSTRAINT [PK_UserLogin] PRIMARY KEY CLUSTERED 
(
	[LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[UserLogin] ADD  CONSTRAINT [DF_User.Login_RegistrationDate]  DEFAULT (getutcdate()) FOR [RegistrationDate]
GO
/****** Object:  Index [IX_UserLogin]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserLogin] ON [dbo].[UserLogin]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[ManageSessionsOnPasswordHashUpdate]
ON [dbo].[UserLogin]
FOR UPDATE
AS 
BEGIN
    SET NOCOUNT ON;

    IF UPDATE ([PasswordHash]) 
    BEGIN
		DECLARE @LoginID bigint
		DECLARE @newPasswordHash nvarchar(255)
		SELECT @LoginID = [LoginID] FROM inserted
		SELECT @newPasswordHash = [PasswordHash] FROM inserted
		
		

		-- Block all Login sessions who did not Initialize the Password Change
 		UPDATE 	[dbo].[UserSession]
 		SET 	[SessionBlockDate] = GETUTCDATE()
		WHERE	
			[LoginID] = @LoginID
			AND [SessionPasswordChangeInitialized] IS NULL 

		-- Update PasswordHash for Session who Initialized the Password Change
 		UPDATE 	[dbo].[UserSession]
 		SET 
			[SessionPasswordHash] = @newPasswordHash,
			[SessionPasswordChangeInitialized] = NULL
		WHERE	
			[LoginID] = @LoginID
			AND [SessionPasswordChangeInitialized] = 1

		-- Restore all Sessions with Session PasswordHash = new PasswordHash
 		UPDATE 	[dbo].[UserSession]
 		SET 	[SessionBlockDate] = NULL
		WHERE 
			[LoginID] = @LoginID
			AND [SessionPasswordHash] = @newPasswordHash
	END

END
GO

ALTER TABLE [dbo].[UserLogin] ENABLE TRIGGER [ManageSessionsOnPasswordHashUpdate]