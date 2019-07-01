﻿-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysTokenCreate]
	-- Add the parameters for the stored procedure here
	@tokenAction nvarchar(255),
	@tokenValue nvarchar(255),
	@tokenKeySet nvarchar(255),
	@tokenKey nvarchar(255) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--@tokenKeySet is null, generete new token, else use tokenKeySet as @tokenKey
	IF @tokenKeySet IS NULL
		EXEC dbo.[SysGenerateRandomString] 60, @tokenKey OUT
	ELSE
		SET @tokenKey = @tokenKeySet

	IF NOT EXISTS (SELECT 1 FROM [dbo].[SystemToken] WHERE [TokenKey] = @tokenKey)
	BEGIN
		INSERT INTO [dbo].[SystemToken]
			([TokenKey], 
			[TokenAction],
			[TokenValue],
			[TokenDateCreated])
		VALUES 
			(@tokenKey,
			@tokenAction,
			@tokenValue,
			GETUTCDATE())
		RETURN
	END
	ELSE
		EXEC [dbo].[SysTokenCreate] @tokenAction, @tokenValue, NULL, @tokenKey OUT

END