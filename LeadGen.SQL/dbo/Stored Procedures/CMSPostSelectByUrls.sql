-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostSelectByUrls]
	-- Add the parameters for the stored procedure here
	@PostURLs nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Declare a variable that references the type.
	DECLARE @PostIDs AS [dbo].[SysBigintTableType]; 

	DECLARE @PostURL nvarchar(MAX)
    DECLARE url_cursor CURSOR FOR   
    SELECT val  
    FROM [dbo].[SysStringSplit] (@PostURLs, ',')
    OPEN url_cursor  
    FETCH NEXT FROM url_cursor INTO @PostURL  
    WHILE @@FETCH_STATUS = 0  
    BEGIN 

		DECLARE @isFirstUrlPart bit = 1
		DECLARE @isFirstAfterPostTypeUrlPart bit = 1

		DECLARE @PostTypeID int = 0
		DECLARE @PostID BIGINT = 0
		DECLARE @Order int = 0
		DECLARE @DatePublished DATETIME

		DECLARE @PostURLPart nvarchar(MAX)
		DECLARE urlpart_cursor CURSOR FOR   
		SELECT val  
		FROM [dbo].[SysStringSplit] (@PostURL, '/')
		OPEN urlpart_cursor  
		FETCH NEXT FROM urlpart_cursor INTO @PostURLPart  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  

			IF (@isFirstUrlPart = 1)
			BEGIN

				SELECT TOP 1 @PostTypeID = [TypeID] FROM [dbo].[CMSPostType] WHERE TypeURL = @PostURLPart
				IF (ISNULL(@PostTypeID,0) = 0)
				BEGIN
					SELECT TOP 1 @PostTypeID = [TypeID] FROM [dbo].[CMSPostType] WHERE TypeURL = ''
					SELECT TOP 1 
						@PostID = ISNULL([PostID],0), 
						@Order = [Order], 
						@DatePublished = ISNULL([DatePublished],[DateCreated]) 
					FROM [dbo].[CMSPost] 
					WHERE TypeID = @PostTypeID AND PostURL = @PostURLPart
				END
				ELSE
					SELECT TOP 1 --Start Post for the PostType
						@PostID = ISNULL([PostID],0), 
						@Order = [Order], 
						@DatePublished = ISNULL([DatePublished],[DateCreated]) 
					FROM [dbo].[CMSPost] 
					WHERE TypeID = @PostTypeID AND PostURL = ''

			END
			ELSE
			BEGIN

				IF(@isFirstAfterPostTypeUrlPart = 1) --First Post URL (after PostType urlPart)
				BEGIN

					SET @PostID = 0
					SET @Order = 0
					SET @DatePublished = NULL
					SELECT TOP 1
						@PostID = ISNULL([PostID],0), 
						@Order = [Order], 
						@DatePublished = ISNULL([DatePublished],[DateCreated]) 
					FROM [dbo].[CMSPost] 
					WHERE @PostTypeID = @PostTypeID AND PostURL = @PostURLPart

				END
				ELSE --Any Other Post URL (childeren of the previous PostURL)
					SELECT TOP 1
						@PostID = ISNULL([PostID],0), 
						@Order = [Order], 
						@DatePublished = ISNULL([DatePublished],[DateCreated]) 
					FROM [dbo].[CMSPost] 
					WHERE @PostTypeID = @PostTypeID AND PostParentID = @PostID AND PostURL = @PostURLPart

				SET @isFirstAfterPostTypeUrlPart = 0
			END
			
			SET @isFirstUrlPart = 0
			FETCH NEXT FROM urlpart_cursor INTO @PostURLPart  
		END  
		CLOSE urlpart_cursor  
		DEALLOCATE urlpart_cursor 

		IF(ISNULL(@PostID, 0) <> 0)
			INSERT INTO @PostIDs ([Item]) VALUES (@PostID)

		FETCH NEXT FROM url_cursor INTO @PostURL  
	END   
	CLOSE url_cursor;  
	DEALLOCATE url_cursor;  

	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[CMSPostSelectByIDs] (@PostIDs) 

END