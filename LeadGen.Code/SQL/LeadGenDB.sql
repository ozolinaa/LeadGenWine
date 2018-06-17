USE [master]
GO
/****** Object:  Database [LeadGenDB]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE DATABASE [LeadGenDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'LeadGenDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\LeadGenDB.mdf' , SIZE = 187392KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'LeadGenDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\LeadGenDB_log.ldf' , SIZE = 353216KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [LeadGenDB] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [LeadGenDB].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [LeadGenDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [LeadGenDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [LeadGenDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [LeadGenDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [LeadGenDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [LeadGenDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [LeadGenDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [LeadGenDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [LeadGenDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [LeadGenDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [LeadGenDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [LeadGenDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [LeadGenDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [LeadGenDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [LeadGenDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [LeadGenDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [LeadGenDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [LeadGenDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [LeadGenDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [LeadGenDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [LeadGenDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [LeadGenDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [LeadGenDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [LeadGenDB] SET  MULTI_USER 
GO
ALTER DATABASE [LeadGenDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [LeadGenDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [LeadGenDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [LeadGenDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [LeadGenDB] SET DELAYED_DURABILITY = DISABLED 
GO
USE [LeadGenDB]
GO
/****** Object:  FullTextCatalog [leadScalarTextCatalog]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE FULLTEXT CATALOG [leadScalarTextCatalog]WITH ACCENT_SENSITIVITY = ON

GO
/****** Object:  UserDefinedTableType [dbo].[Sys.Bigint.TableType]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE TYPE [dbo].[Sys.Bigint.TableType] AS TABLE(
	[Item] [bigint] NOT NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[Business.Lead.Completed.GetCompletedTotalFeeSumBeforeDateForInvoice]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Business.Lead.Completed.GetCompletedTotalFeeSumBeforeDateForInvoice]
(
	@BusinessID BIGINT,
	@CompletedBeforeDate DATE
)
RETURNS DECIMAL (19,4)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @LeadFeeTotalSum decimal (19,4)

	--Calculate Lead Fee Total Sum that needs to be paid this month (that were completed before @CompletedBeforeDate)
	SELECT @LeadFeeTotalSum = SUM(ISNULL([LeadFee],0)) 
	FROM [dbo].[Business.Lead.Completed]
	WHERE BusinessID = @BusinessID
		AND CompletedDateTime < @CompletedBeforeDate
		AND InvoiceID IS NULL
		AND InvoiceLineID IS NULL
	GROUP BY BusinessID

	-- Return the result of the function
	RETURN ISNULL(@LeadFeeTotalSum,0)

END















GO
/****** Object:  UserDefinedFunction [dbo].[Business.Lead.GetLastNotifiedDate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Business.Lead.GetLastNotifiedDate]
(
	@BusinessID BIGINT
)
RETURNS DATETIME
AS
BEGIN
	-- Declare the return variable here
	DECLARE @NotifiedDateTime DATETIME

	SELECT TOP 1 @NotifiedDateTime = [NotifiedDateTime]
	FROM [dbo].[Business.Lead.Notified]
	WHERE BusinessID = @BusinessID
	ORDER BY [NotifiedDateTime] DESC


	-- Return the result of the function
	RETURN @NotifiedDateTime

END















GO
/****** Object:  UserDefinedFunction [dbo].[Business.Lead.GetNextAllowedNotificationDateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Business.Lead.GetNextAllowedNotificationDateTime]
(
	@BusinessID BIGINT,
	@ForFrequencyName NVARCHAR(50)
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @AllowedDateTime DATETIME = DATEADD(year, -1, GETUTCDATE()) --Previus year

	-- Declare the return variable here
	DECLARE @LastNotifiedDateTime DATETIME = [dbo].[Business.Lead.GetLastNotifiedDate](@BusinessID)
	SET @LastNotifiedDateTime = ISNULL (@LastNotifiedDateTime, @AllowedDateTime) --Previus year (if never notified)

	DECLARE @NextAllowedNotificationDateTime DATETIME
	SELECT @NextAllowedNotificationDateTime = CASE 
		WHEN nf.[Name] = 'Immediate' THEN @AllowedDateTime
		WHEN nf.[Name] = 'Hourly' THEN DATEADD(hour, 1, @LastNotifiedDateTime )
		WHEN nf.[Name] = 'Daily' THEN DATEADD(day, 1, @LastNotifiedDateTime )
		ELSE NULL
		END
	FROM [dbo].[Business] b
	INNER JOIN [dbo].[Notification.Frequency] nf ON nf.ID = b.NotificationFrequencyID
	WHERE b.BusinessID = @BusinessID AND nf.[Name] = @ForFrequencyName

	--set to next year (means NOT NOW)
	SET @NextAllowedNotificationDateTime = ISNULL (@NextAllowedNotificationDateTime, DATEADD(year, 1, GETUTCDATE()))  

	-- Return the result of the function
	RETURN @NextAllowedNotificationDateTime

END















GO
/****** Object:  UserDefinedFunction [dbo].[Business.Lead.SelectRequested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[Business.Lead.SelectRequested]
(	
	-- Add the parameters for the function here
	@BusinessID bigint,
	@DateFrom datetime = NULL,
	@DateTo datetime = NULL,
	@LeadID bigint = NULL
)
RETURNS @RequestedLeads TABLE 
(
    -- Columns returned by the function
    LeadId bigint PRIMARY KEY NOT NULL, 
    IsApproved bit NOT NULL
)
AS 
BEGIN

	IF([dbo].[Sys.ConvertToBit]([dbo].[Sys.Option.Get]('LeadSettingApprovalPermissionEnabled')) = 1)
		MERGE @RequestedLeads rl
		USING [dbo].[Business.Permission.GetRequestedLeadIDs](@BusinessID, @DateFrom, @DateTo, @LeadID) l
		ON l.LeadId = rl.LeadId
		WHEN MATCHED THEN
			UPDATE
			SET rl.IsApproved = Case When l.LeadId = 1 AND rl.LeadId = 1 Then 1 Else 0 END
		WHEN NOT MATCHED THEN  
			INSERT (LeadId, IsApproved)
			VALUES (l.LeadId, l.IsApproved);


	IF([dbo].[Sys.ConvertToBit]([dbo].[Sys.Option.Get]('LeadSettingApprovalLocationEnabled')) = 1)
		MERGE @RequestedLeads rl
		USING [dbo].[Business.Location.GetNearByLeadIDs](@BusinessID, @DateFrom, @DateTo, @LeadID) l
		ON l.LeadId = rl.LeadId
		WHEN MATCHED THEN
			UPDATE
			SET rl.IsApproved = Case When l.LeadId = 1 AND rl.LeadId = 1 Then 1 Else 0 END
		WHEN NOT MATCHED THEN  
			INSERT (LeadId, IsApproved)
			VALUES (l.LeadId, l.IsApproved);
	
	RETURN;
END







GO
/****** Object:  UserDefinedFunction [dbo].[CMS.Post.URL.GetParentPath]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CMS.Post.URL.GetParentPath] (@ParentID BIGINT, @ParentPath nvarchar(MAX) = '' ) returns nvarchar(MAX)
AS
BEGIN

	IF @ParentID is null
		return @ParentPath

	DECLARE @newParentID bigint

	SELECT 
		@ParentPath = CONCAT([PostURL], '/', @ParentPath),
		@newParentID = [PostParentID]
	FROM [dbo].[CMS.Post] 
	WHERE [PostID] = @ParentID

	RETURN [dbo].[CMS.Post.URL.GetParentPath] (@newParentID, @ParentPath)

END




















GO
/****** Object:  UserDefinedFunction [dbo].[Lead.Business.SelectRequested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[Lead.Business.SelectRequested]
(	
	-- Add the parameters for the function here
	@LeadId bigint
)
RETURNS @RequestedBusinesses TABLE 
(
    -- Columns returned by the function
    BusinessID bigint PRIMARY KEY NOT NULL, 
    IsApproved bit NOT NULL
)
AS 
BEGIN

	IF([dbo].[Sys.ConvertToBit]([dbo].[Sys.Option.Get]('LeadSettingApprovalPermissionEnabled')) = 1)
		MERGE @RequestedBusinesses rb
		USING [dbo].[Busienss.Permission.GetBusinessesRequested](@LeadId) b
		ON b.BusinessID = rb.BusinessID
		WHEN MATCHED THEN
			UPDATE
			SET rb.IsApproved = Case When b.BusinessID = 1 AND rb.BusinessID = 1 Then 1 Else 0 END
		WHEN NOT MATCHED THEN  
			INSERT (BusinessID, IsApproved)
			VALUES (b.BusinessID, b.IsApproved);


	IF([dbo].[Sys.ConvertToBit]([dbo].[Sys.Option.Get]('LeadSettingApprovalLocationEnabled')) = 1)
		MERGE @RequestedBusinesses rb
		USING [dbo].[Busienss.Location.GetBusinessesNearBy](@LeadId) b
		ON b.BusinessID = rb.BusinessID
		WHEN MATCHED THEN
			UPDATE
			SET rb.IsApproved = Case When b.BusinessID = 1 AND rb.BusinessID = 1 Then 1 Else 0 END
		WHEN NOT MATCHED THEN  
			INSERT (BusinessID, IsApproved)
			VALUES (b.BusinessID, b.IsApproved);
	
	RETURN;
END







GO
/****** Object:  UserDefinedFunction [dbo].[Sys.ConvertToBit]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Sys.ConvertToBit]
(
	@Str nvarchar(MAX)
)
RETURNS bit
AS
BEGIN

	IF (@Str = 'true' OR @Str = 'yes' OR @Str = '1')
		RETURN 1

	RETURN 0

END















GO
/****** Object:  UserDefinedFunction [dbo].[Sys.Option.Get]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Sys.Option.Get]
(
	@OptionKey nvarchar(100)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @OptionValue nvarchar(MAX)

	SELECT @OptionValue = OptionValue
	FROM 
		[dbo].[System.Options] 
	WHERE	
		@OptionKey = OptionKey


	-- Return the result of the function
	RETURN @OptionValue

END















GO
/****** Object:  UserDefinedFunction [dbo].[Sys.StringSplit]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Sys.StringSplit]
(
    @param      NVARCHAR(MAX),
    @delimiter  CHAR(1)
)
RETURNS @t TABLE (val NVARCHAR(MAX))
AS
BEGIN
    SET @param += @delimiter

    ;WITH a AS
    (
        SELECT CAST(1 AS BIGINT) f,
               CHARINDEX(@delimiter, @param) t,
               1 seq
        UNION ALL
        SELECT t + 1,
               CHARINDEX(@delimiter, @param, t + 1),
               seq + 1
        FROM   a
        WHERE  CHARINDEX(@delimiter, @param, t + 1) > 0
    )
    INSERT @t
    SELECT SUBSTRING(@param, f, t - f)         
    FROM   a
           OPTION(MAXRECURSION 0)

    RETURN
END




GO
/****** Object:  Table [dbo].[Business.Lead.Permission]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Lead.Permission](
	[PermissionID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[RequestedDateTime] [datetime] NULL,
	[ApprovedDateTime] [datetime] NULL,
 CONSTRAINT [PK_Business.Lead.Permission] PRIMARY KEY CLUSTERED 
(
	[PermissionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Business.Lead.Permission.Term]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Lead.Permission.Term](
	[PermissionID] [bigint] NOT NULL,
	[TermID] [bigint] NOT NULL,
 CONSTRAINT [PK_Business.Lead.Permission.Term_1] PRIMARY KEY CLUSTERED 
(
	[PermissionID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[ExtractNumberFromString]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ExtractNumberFromString]
(@strAlphaNumeric NVARCHAR(255))
RETURNS NVARCHAR(255) WITH SCHEMABINDING
AS
BEGIN
DECLARE @intAlpha INT
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
BEGIN
WHILE @intAlpha > 0
BEGIN
SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha, 1, '' )
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric )
END
END
RETURN NULLIF(CAST(@strAlphaNumeric as NVARCHAR(255)), '')
END





GO
/****** Object:  Table [dbo].[Lead]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead](
	[LeadID] [bigint] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[NumberFromEmail]  AS ([dbo].[ExtractNumberFromString]([Email])) PERSISTED,
	[EmailConfirmedDateTime] [datetime] NULL,
	[PublishedDateTime] [datetime] NULL,
	[AdminCanceledPublishDateTime] [datetime] NULL,
	[UserCanceledDateTime] [datetime] NULL,
	[ReviewRequestSentDateTime] [datetime] NULL,
 CONSTRAINT [PK_Lead] PRIMARY KEY CLUSTERED 
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Field.Value.Taxonomy]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [dbo].[Lead.Field.Value.Taxonomy](
	[LeadID] [bigint] NOT NULL,
	[FieldID] [int] NOT NULL,
	[FieldTypeID] [int] NOT NULL,
	[TermID] [bigint] NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[UniqueIndexComputed]  AS (concat([LeadID],'_',[FieldID],'_',case when [FieldTypeID]=(3) then [TermID] else [FieldID] end)) PERSISTED NOT NULL,
 CONSTRAINT [IX_Lead.Field.Value.Taxonomy_Unique] UNIQUE NONCLUSTERED 
(
	[UniqueIndexComputed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [IX_Lead.Field.Value.Taxonomy_LeadTerm]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE CLUSTERED INDEX [IX_Lead.Field.Value.Taxonomy_LeadTerm] ON [dbo].[Lead.Field.Value.Taxonomy]
(
	[LeadID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[Business.Permission.GetRequestedLeadIDs]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[Business.Permission.GetRequestedLeadIDs]
(	
	-- Add the parameters for the function here
	@BusinessID bigint,
	@DateFrom datetime = NULL,
	@DateTo datetime = NULL,
	@LeadID bigint = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		t.LeadID,
		CASE WHEN SUM(t.isApproved) > 0 THEN 1 ELSE 0 END IsApproved
	FROM (
		SELECT
			L.LeadID, 
			PT.PermissionID, 
			CASE WHEN BP.ApprovedDateTime IS NULL THEN 0 ELSE 1 END as IsApproved
		FROM 
			[dbo].[Business.Lead.Permission] BP
			LEFT OUTER JOIN [dbo].[Business.Lead.Permission.Term] PT ON PT.PermissionID = BP.PermissionID
			CROSS JOIN [dbo].Lead L
			LEFT OUTER JOIN [dbo].[Lead.Field.Value.Taxonomy] VT ON VT.LeadID = L.LeadID AND VT.TermID = PT.TermID
		WHERE 
			BP.BusinessID = @BusinessID
			AND BP.RequestedDateTime IS NOT NULL
			AND (L.[PublishedDateTime] IS NOT NULL)
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < L.CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= L.CreatedDateTime)
		GROUP BY L.LeadID, PT.PermissionID, BP.ApprovedDateTime
		HAVING COUNT(VT.TermID) = COUNT(PT.TermID)
	) t
	GROUP BY t.LeadID
)








GO
/****** Object:  Table [dbo].[Lead.Field.Structure]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Field.Structure](
	[FieldID] [int] NOT NULL,
	[FieldCode] [nvarchar](50) NOT NULL,
	[GroupID] [int] NOT NULL,
	[FieldName] [nvarchar](100) NOT NULL,
	[FieldTypeID] [int] NOT NULL,
	[LabelText] [nvarchar](255) NOT NULL,
	[IsRequired] [bit] NOT NULL,
	[IsContact] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Order] [int] NULL,
 CONSTRAINT [PK_Lead.Field] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Lead.Field.Structure] UNIQUE NONCLUSTERED 
(
	[FieldCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[Busienss.Permission.GetBusinessesRequested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[Busienss.Permission.GetBusinessesRequested]
(	
	-- Add the parameters for the function here
	@LeadID bigint
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here

	-- Select IDs only for leads that have all terms in tables TC, TD, TR that were requested by business in table Business.Lead.Permission.Term

	SELECT 
		t.BusinessID,
		CASE WHEN SUM(t.isApproved) > 0 THEN 1 ELSE 0 END IsApproved
	FROM (
		SELECT
			BP.BusinessID,
			BP.PermissionID,
			CASE WHEN BP.ApprovedDateTime IS NULL THEN 0 ELSE 1 END as IsApproved
		FROM 
			[dbo].[Lead] L
			CROSS JOIN [dbo].[Lead.Field.Structure] LS
			INNER JOIN [dbo].[Lead.Field.Value.Taxonomy] LT ON LT.LeadID = L.LeadID AND LS.FieldID = LT.FieldID
			LEFT OUTER JOIN [dbo].[Business.Lead.Permission.Term] BPTLead ON BPTLead.TermID = LT.TermID
			LEFT OUTER JOIN [dbo].[Business.Lead.Permission.Term] BPTPermission ON BPTPermission.PermissionID = BPTLead.PermissionID
			LEFT OUTER JOIN [dbo].[Business.Lead.Permission] BP ON BP.PermissionID = BPTPermission.PermissionID AND BP.[RequestedDateTime] IS NOT NULL
		WHERE
			L.LeadID = @LeadID
			AND L.[PublishedDateTime] IS NOT NULL
			AND BP.BusinessID IS NOT NULL
		GROUP BY 
			BP.BusinessID, BP.PermissionID, BP.ApprovedDateTime
		HAVING 
			SUM(CASE WHEN BPTLead.TermID = BPTPermission.TermID Then 1 ELSE 0 END) = COUNT(DISTINCT BPTPermission.TermID)
	) t
	GROUP BY t.BusinessID
)




















GO
/****** Object:  Table [dbo].[Business.Location]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Location](
	[LocationID] [bigint] IDENTITY(1,1) NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[Location] [geography] NOT NULL,
	[IsAprovedByAdmin] [bit] NOT NULL,
	[LocationAddress] [nvarchar](max) NULL,
	[LocationName] [nvarchar](255) NULL,
	[CreatedDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Business.Location] PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Location]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Location](
	[LeadID] [bigint] NOT NULL,
	[Location] [geography] NOT NULL,
	[LocationAccuracyMeters] [int] NOT NULL,
	[LeadRadiusMeters] [int] NOT NULL,
	[LocationWithRadius]  AS ([Location].[STBuffer]([LocationAccuracyMeters]+[LeadRadiusMeters])) PERSISTED,
	[StreetAddress] [nvarchar](255) NULL,
	[PostalCode] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[Country] [nvarchar](255) NULL,
 CONSTRAINT [PK_Lead.Location] PRIMARY KEY CLUSTERED 
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[Business.Location.GetNearByLeadIDs]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[Business.Location.GetNearByLeadIDs]
(	
	-- Add the parameters for the function here
	@BusinessID bigint,
	@DateFrom datetime = NULL,
	@DateTo datetime = NULL,
	@LeadID bigint = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		t.LeadID,
		MAX(t.IsApproved) as IsApproved
	FROM (
		SELECT
			L.LeadID, 
			b.LocationID, 
			CASE WHEN b.IsAprovedByAdmin = 1 THEN 1 ELSE 0 END as IsApproved
		FROM 
			[dbo].[Lead.Location] ll with(index([LocationWithRadiusIndex]))
			INNER JOIN [dbo].[Lead] l ON l.LeadID = ll.LeadID
			CROSS JOIN [dbo].[Business.Location] b 
			WHERE 
			b.BusinessID = @BusinessID
			AND (L.[PublishedDateTime] IS NOT NULL)
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < L.CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= L.CreatedDateTime)
			AND ll.LocationWithRadius IS NOT NULL 
			AND ll.LocationWithRadius.STIntersects(b.[Location]) = 1
		GROUP BY L.LeadID, b.LocationID, b.IsAprovedByAdmin
	) t
	GROUP BY t.LeadID
)








GO
/****** Object:  Table [dbo].[CMS.Post]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Post](
	[PostID] [bigint] IDENTITY(1,1) NOT NULL,
	[PostParentID] [bigint] NULL,
	[TypeID] [int] NOT NULL,
	[StatusID] [int] NOT NULL,
	[AuthorID] [bigint] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DatePublished] [datetime] NULL,
	[DateLastModified] [datetime] NOT NULL,
	[Title] [nvarchar](255) NOT NULL,
	[ContentIntro] [nvarchar](max) NULL,
	[ContentPreview] [nvarchar](max) NULL,
	[ContentMain] [nvarchar](max) NOT NULL,
	[ContentEnding] [nvarchar](max) NULL,
	[PostURL] [nvarchar](100) NOT NULL,
	[SeoTitle] [nvarchar](255) NULL,
	[SeoMetaDescription] [nvarchar](500) NULL,
	[SeoMetaKeywords] [nvarchar](500) NULL,
	[SeoPriority] [decimal](2, 1) NULL,
	[SeoChangeFrequencyID] [int] NULL,
	[ThumbnailAttachmentID] [bigint] NULL,
	[PostForTermID] [bigint] NULL,
	[PostForTaxonomyID] [int] NULL,
	[Order] [int] NOT NULL,
 CONSTRAINT [PK_CMS.Post] PRIMARY KEY CLUSTERED 
(
	[PostID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMS.Post] UNIQUE NONCLUSTERED 
(
	[PostID] ASC,
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMS.Post_1] UNIQUE NONCLUSTERED 
(
	[PostURL] ASC,
	[TypeID] ASC,
	[PostParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Post.Status]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Post.Status](
	[StatusID] [int] NOT NULL,
	[StatusName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_CMS.Post.Status] PRIMARY KEY CLUSTERED 
(
	[StatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Post.Type]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Post.Type](
	[TypeID] [int] IDENTITY(1,1) NOT NULL,
	[TypeCode] [nvarchar](50) NOT NULL,
	[TypeName] [nvarchar](50) NOT NULL,
	[TypeURL] [nvarchar](50) NOT NULL,
	[IsBrowsable] [bit] NOT NULL,
	[SeoTitle] [nvarchar](255) NULL,
	[SeoMetaDescription] [nvarchar](500) NULL,
	[SeoMetaKeywords] [nvarchar](500) NULL,
	[SeoPriority] [decimal](2, 1) NOT NULL,
	[SeoChangeFrequencyID] [int] NOT NULL,
	[PostSeoTitle] [nvarchar](255) NULL,
	[PostSeoMetaDescription] [nvarchar](500) NULL,
	[PostSeoMetaKeywords] [nvarchar](500) NULL,
	[PostSeoPriority] [decimal](2, 1) NOT NULL,
	[PostSeoChangeFrequencyID] [int] NOT NULL,
	[HasContentIntro] [bit] NOT NULL,
	[HasContentEnding] [bit] NOT NULL,
	[ForTaxonomyID] [int] NULL,
	[ForPostTypeID] [int] NULL,
 CONSTRAINT [PK_CMS.Post.Type] PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMS.Post.Type_1] UNIQUE NONCLUSTERED 
(
	[TypeURL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMS.Post.Type_2] UNIQUE NONCLUSTERED 
(
	[TypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[CMS.Post.SelectByIDs]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[CMS.Post.SelectByIDs]
(	
	-- Add the parameters for the function here
	@PostIDTable [dbo].[Sys.Bigint.TableType] READONLY
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		P.[PostID], 
		P.[PostParentID],
		PT.[TypeID], 
		PT.[TypeName],
		PT.[TypeURL], 
		PT.[ForPostTypeID],
		PT.[ForTaxonomyID],
		PT.[HasContentIntro],
		PT.[HasContentEnding],
		PS.[StatusID],
		PS.[StatusName],
		P.[AuthorID], 
		P.[DateCreated],
		P.[DatePublished],
		P.[DateLastModified],
		P.[Title],
		P.[ContentIntro],
		P.[ContentPreview],
		P.[ContentMain],
		P.[ContentEnding],
		CASE WHEN P.[PostParentID] IS NULL 
			THEN ''
			ELSE [dbo].[CMS.Post.URL.GetParentPath](P.[PostParentID],DEFAULT)
		END as ParentPathURL,
		P.[PostURL],
		P.[PostForTermID],
		P.[PostForTaxonomyID],
		P.[ThumbnailAttachmentID],
		P.[Order],
		ISNULL(P.[SeoTitle], REPLACE(PT.[PostSeoTitle], '%PostTitle%', P.[Title])) as [SeoTitle],
		ISNULL(P.[SeoMetaDescription], REPLACE(PT.[PostSeoMetaDescription], '%PostTitle%', P.[Title])) as [SeoMetaDescription],
		ISNULL(P.[SeoMetaKeywords], REPLACE(PT.[PostSeoMetaKeywords], '%PostTitle%', P.[Title])) as [SeoMetaKeywords],
		ISNULL(P.[SeoPriority], PT.[PostSeoPriority]) [SeoPriority],
		ISNULL(P.[SeoChangeFrequencyID], PT.[PostSeoChangeFrequencyID]) [SeoChangeFrequencyID]
	FROM 
		[dbo].[CMS.Post] P
		INNER JOIN @PostIDTable T ON T.Item = P.PostID
		INNER JOIN [dbo].[CMS.Post.Status] PS ON PS.[StatusID] = P.[StatusID] 
		INNER JOIN [dbo].[CMS.Post.Type] PT ON PT.[TypeID] = P.[TypeID] 
)









GO
/****** Object:  UserDefinedFunction [dbo].[Lead.SelectByIDs]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[Lead.SelectByIDs]
(	
	-- Add the parameters for the function here
	@LeadIDTable [dbo].[Sys.Bigint.TableType] READONLY
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		l.[LeadID], 
		l.[CreatedDateTime], 
		l.[Email], 
		l.[EmailConfirmedDateTime], 
		l.[PublishedDateTime], 
		l.[AdminCanceledPublishDateTime],
		l.[UserCanceledDateTime]
	FROM  @LeadIDTable t
	INNER JOIN [dbo].[Lead] l ON l.LeadID = t.Item
)













GO
/****** Object:  Table [dbo].[Business.Lead.Completed]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Lead.Completed](
	[LoginID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[CompletedDateTime] [datetime] NOT NULL,
	[OrderSum] [decimal](19, 4) NOT NULL,
	[SystemFeePercent] [decimal](4, 2) NOT NULL,
	[LeadFee]  AS (([OrderSum]*[SystemFeePercent])/(100)) PERSISTED,
	[InvoiceID] [bigint] NULL,
	[InvoiceLineID] [smallint] NULL,
 CONSTRAINT [PK_Business.Lead.Completed] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Business.Lead.ContactsRecieved]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Lead.ContactsRecieved](
	[LoginID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[GetContactsDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Business.Lead.ContactsRecieve] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Business.Lead.Important]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Lead.Important](
	[LoginID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[ImportantDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Business.Lead.Important] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Business.Lead.NotInterested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Lead.NotInterested](
	[LoginID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[NotInterestedDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Business.Lead.NotInterested] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[Business.Lead.Worked]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Business.Lead.Worked]
AS
SELECT        BusinessID, LeadID
FROM            (SELECT        BusinessID, LeadID
                          FROM            dbo.[Business.Lead.NotInterested]
                          UNION ALL
                          SELECT        BusinessID, LeadID
                          FROM            dbo.[Business.Lead.Important]
                          UNION ALL
                          SELECT        BusinessID, LeadID
                          FROM            dbo.[Business.Lead.ContactsRecieved]
                          UNION ALL
                          SELECT        BusinessID, LeadID
                          FROM            dbo.[Business.Lead.Completed]) AS t
GROUP BY BusinessID, LeadID














GO
/****** Object:  Table [dbo].[Business]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business](
	[BusinessID] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[RegistrationDate] [datetime] NOT NULL,
	[WebSite] [nvarchar](255) NOT NULL,
	[CountryID] [bigint] NOT NULL,
	[NotificationFrequencyID] [int] NOT NULL,
	[Address] [nvarchar](255) NULL,
	[ContactName] [nvarchar](255) NULL,
	[ContactEmail] [nvarchar](255) NULL,
	[ContactPhone] [nvarchar](255) NULL,
	[ContactSkype] [nvarchar](255) NULL,
	[BillingName] [nvarchar](255) NULL,
	[BillingCode1] [nvarchar](255) NULL,
	[BillingCode2] [nvarchar](255) NULL,
	[BillingAddress] [nvarchar](255) NULL,
	[OldID] [bigint] NULL,
 CONSTRAINT [PK_Business] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Taxonomy]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Taxonomy](
	[TaxonomyID] [int] IDENTITY(1,1) NOT NULL,
	[TaxonomyCode] [nvarchar](50) NOT NULL,
	[TaxonomyName] [nvarchar](50) NOT NULL,
	[IsTag] [bit] NOT NULL,
 CONSTRAINT [PK_CMS.Taxonomy] PRIMARY KEY CLUSTERED 
(
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Taxonomy.Term]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Taxonomy.Term](
	[TermID] [bigint] IDENTITY(1,1) NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermName] [nvarchar](255) NOT NULL,
	[TermURL] [nvarchar](255) NOT NULL,
	[TermThumbnailURL] [nvarchar](255) NULL,
	[TermParentID] [bigint] NULL,
 CONSTRAINT [PK_CMS.Taxonomy.Term] PRIMARY KEY CLUSTERED 
(
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[Business.Region.Country]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Business.Region.Country]
AS
SELECT        B.BusinessID, B.Name AS BusinessName, B.RegistrationDate AS BusinessRegistrationDate, TT.TermID AS RegionID, TT.TermName AS RegionName, TT.TermURL AS RegionURL, TTC.TermID AS CountryID, 
                         TTC.TermName AS CountryName, TTC.TermURL AS CountryURL
FROM            dbo.Business AS B LEFT OUTER JOIN
                         dbo.[Business.Lead.Permission] AS BLP ON BLP.BusinessID = B.BusinessID INNER JOIN
                         dbo.[Business.Lead.Permission.Term] AS BLPT ON BLPT.PermissionID = BLP.PermissionID INNER JOIN
                         dbo.[Taxonomy.Term] AS TT ON TT.TermID = BLPT.TermID INNER JOIN
                         dbo.Taxonomy AS T ON T.TaxonomyID = TT.TaxonomyID AND T.TaxonomyCode = 'city' INNER JOIN
                         dbo.[Taxonomy.Term] AS TTC ON TTC.TermID = TT.TermParentID
GROUP BY B.BusinessID, B.Name, B.RegistrationDate, TT.TermID, TT.TermName, TT.TermURL, TTC.TermID, TTC.TermName, TTC.TermURL


















GO
/****** Object:  UserDefinedFunction [dbo].[Busienss.Location.GetBusinessesNearBy]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[Busienss.Location.GetBusinessesNearBy]
(	
	-- Add the parameters for the function here
	@LeadID bigint
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT 
		t.BusinessID,
		MAX(t.IsApproved) as IsApproved
	FROM (
		SELECT
			b.BusinessID,
			b.LocationID, 
			CASE WHEN b.IsAprovedByAdmin = 1 THEN 1 ELSE 0 END as IsApproved
		FROM 
			[dbo].[Lead.Location] ll with(index([LocationWithRadiusIndex]))
			INNER JOIN [dbo].[Lead] l ON l.LeadID = ll.LeadID
			CROSS JOIN [dbo].[Business.Location] b 
			WHERE 
			ll.LeadID = @LeadID
			AND (L.[PublishedDateTime] IS NOT NULL)
			AND ll.LocationWithRadius IS NOT NULL 
			AND ll.LocationWithRadius.STIntersects(b.[Location]) = 1
		GROUP BY b.BusinessID, b.LocationID, b.IsAprovedByAdmin
	) t
	GROUP BY t.BusinessID
)




















GO
/****** Object:  Table [dbo].[Lead.Field.Value.Scalar]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Field.Value.Scalar](
	[ID] [uniqueidentifier] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[FieldID] [int] NOT NULL,
	[FieldTypeID] [int] NOT NULL,
	[TextValue] [nvarchar](max) NULL,
	[DatetimeValue] [datetime] NULL,
	[BoolValue] [bit] NULL,
	[NumberValue] [bigint] NULL,
	[NubmerValueFromText]  AS ([dbo].[ExtractNumberFromString]([TextValue])) PERSISTED,
 CONSTRAINT [PK_Lead.Field.Value.Scalar] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Lead.Field.Value.Scalar_LeadID_FieldID] UNIQUE NONCLUSTERED 
(
	[LeadID] ASC,
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Business.Invoice]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Invoice](
	[InvoiceID] [bigint] IDENTITY(1,1) NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[TotalSum] [decimal](19, 4) NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[PublishedDatetime] [datetime] NULL,
	[PaidDateTime] [datetime] NULL,
	[LegalMonth] [smallint] NOT NULL,
	[LegalYear] [smallint] NOT NULL,
	[LegalNumber] [int] NOT NULL,
	[LegalFacturaNumber] [int] NULL,
	[LegalCountryID] [bigint] NOT NULL,
	[LegalAddress] [nvarchar](255) NOT NULL,
	[LegalName] [nvarchar](255) NOT NULL,
	[LegalCode1] [nvarchar](255) NOT NULL,
	[LegalCode2] [nvarchar](255) NOT NULL,
	[LegalBankName] [nvarchar](255) NOT NULL,
	[LegalBankCode1] [nvarchar](255) NOT NULL,
	[LegalBankCode2] [nvarchar](255) NOT NULL,
	[LegalBankAccount] [nvarchar](255) NOT NULL,
	[BillingCountryID] [bigint] NOT NULL,
	[BillingAddress] [nvarchar](255) NOT NULL,
	[BillingName] [nvarchar](255) NOT NULL,
	[BillingCode1] [nvarchar](255) NOT NULL,
	[BillingCode2] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_Business.Invoice] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Business.Invoice] UNIQUE NONCLUSTERED 
(
	[InvoiceID] ASC,
	[BusinessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Business.Invoice.Line]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Invoice.Line](
	[InvoiceID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LineID] [smallint] NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[UnitPrice] [decimal](19, 4) NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Tax] [decimal](4, 2) NOT NULL,
	[LinePrice]  AS ([UnitPrice]*[Quantity]) PERSISTED,
	[LineTotalPrice]  AS ([UnitPrice]*[Quantity]+(([UnitPrice]*[Quantity])*[Tax])/(100)) PERSISTED,
 CONSTRAINT [PK_Business.Invoice.Line] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC,
	[LineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Business.Lead.Notified]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Lead.Notified](
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[NotifiedDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BuinessLeadNotified] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Business.Lead.Notified.Post]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Lead.Notified.Post](
	[BusinessPostID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[NotifiedDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Business.Lead.Notified.Post] PRIMARY KEY CLUSTERED 
(
	[BusinessPostID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Business.Login]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Login](
	[BusinessID] [bigint] NOT NULL,
	[LoginID] [bigint] NOT NULL,
	[RoleID] [int] NOT NULL,
	[LinkDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Business.Login_1] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Business.Notification.Email]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business.Notification.Email](
	[BusinessID] [bigint] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Business.Notification.Email] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Attachment]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Attachment](
	[AttachmentID] [bigint] IDENTITY(1,1) NOT NULL,
	[AuthorID] [bigint] NOT NULL,
	[TypeID] [int] NOT NULL,
	[MIME] [nvarchar](50) NOT NULL,
	[URL] [nvarchar](255) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[FileHash] [nvarchar](100) NOT NULL,
	[FileSizeBytes] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_CMS.Attachment] PRIMARY KEY CLUSTERED 
(
	[AttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMS.Attachment] UNIQUE NONCLUSTERED 
(
	[FileHash] ASC,
	[FileSizeBytes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMS.Attachment_2] UNIQUE NONCLUSTERED 
(
	[URL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Attachment.Image]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Attachment.Image](
	[AttachmentID] [bigint] NOT NULL,
	[TypeID]  AS ((1)) PERSISTED NOT NULL,
	[ImageSizeOptionID] [int] NOT NULL,
	[URL] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_CMS.Attachment.Image_1] PRIMARY KEY CLUSTERED 
(
	[AttachmentID] ASC,
	[ImageSizeOptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Attachment.Image.Size]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Attachment.Image.Size](
	[ImageSizeID] [int] NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[MaxHeight] [int] NOT NULL,
	[MaxWidth] [int] NOT NULL,
	[CropMode] [nvarchar](50) NULL,
 CONSTRAINT [PK_CMS.Attachment.Image.Size] PRIMARY KEY CLUSTERED 
(
	[ImageSizeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMS.Attachment.Image.Size] UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Attachment.Term]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Attachment.Term](
	[AttachmentID] [bigint] NOT NULL,
	[TermID] [bigint] NOT NULL,
 CONSTRAINT [PK_CMS.Attachment.Term] PRIMARY KEY CLUSTERED 
(
	[AttachmentID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Attachment.Type]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Attachment.Type](
	[AttachmentTypeID] [int] NOT NULL,
	[AttachmentTypeName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_CMS.Attachment.Type] PRIMARY KEY CLUSTERED 
(
	[AttachmentTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Field.Type]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Field.Type](
	[FieldTypeID] [int] NOT NULL,
	[FieldTypeName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_CMS.Field.Types] PRIMARY KEY CLUSTERED 
(
	[FieldTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMS.Field.Types] UNIQUE NONCLUSTERED 
(
	[FieldTypeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Post.Attachment]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Post.Attachment](
	[PostID] [bigint] NOT NULL,
	[AttachmentID] [bigint] NOT NULL,
	[LinkDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CMS.Post.Attachment] PRIMARY KEY CLUSTERED 
(
	[PostID] ASC,
	[AttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Post.Field.Value]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Post.Field.Value](
	[PostID] [bigint] NOT NULL,
	[PostTypeID] [int] NOT NULL,
	[FieldID] [int] NOT NULL,
	[TextValue] [nvarchar](max) NULL,
	[DatetimeValue] [datetime] NULL,
	[BoolValue] [bit] NULL,
	[NumberValue] [bigint] NULL,
 CONSTRAINT [PK_CMS.Post.Field.Values] PRIMARY KEY CLUSTERED 
(
	[PostID] ASC,
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Post.Term]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Post.Term](
	[PostID] [bigint] NOT NULL,
	[TermID] [bigint] NOT NULL,
	[PostTypeID] [int] NOT NULL,
	[TaxonomyID] [int] NOT NULL,
 CONSTRAINT [PK_CMS.Post.Term] PRIMARY KEY CLUSTERED 
(
	[PostID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Post.Type.Attachment.Taxonomy]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Post.Type.Attachment.Taxonomy](
	[PostTypeID] [int] NOT NULL,
	[AttachmentTaxonomyID] [int] NOT NULL,
	[IsEnabled] [bit] NOT NULL,
 CONSTRAINT [PK_CMS.Post.Type..Attachment.Taxonomy]]] PRIMARY KEY CLUSTERED 
(
	[PostTypeID] ASC,
	[AttachmentTaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Post.Type.Field.Structure]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Post.Type.Field.Structure](
	[FieldID] [int] IDENTITY(1,1) NOT NULL,
	[PostTypeID] [int] NOT NULL,
	[FieldTypeID] [int] NOT NULL,
	[FieldCode] [nvarchar](50) NOT NULL,
	[FieldLabelText] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_CMS.Post.Field.Structure] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMS.Post.Field.Structure] UNIQUE NONCLUSTERED 
(
	[FieldCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMS.Post.Type.Field.Structure] UNIQUE NONCLUSTERED 
(
	[FieldID] ASC,
	[PostTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Post.Type.Taxonomy]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Post.Type.Taxonomy](
	[PostTypeID] [int] NOT NULL,
	[ForPostTypeID] [int] NOT NULL,
	[ForTaxonomyID] [int] NOT NULL,
	[IsEnabled] [bit] NOT NULL,
 CONSTRAINT [PK_CMS.Post.Type.Taxonomy] PRIMARY KEY CLUSTERED 
(
	[PostTypeID] ASC,
	[ForPostTypeID] ASC,
	[ForTaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMS.Sitemap.ChangeFrequency]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS.Sitemap.ChangeFrequency](
	[ID] [int] NOT NULL,
	[Frequency] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_SEO.Sitemap.ChangeFrequency] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Email.Queue]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Email.Queue](
	[EmailID] [uniqueidentifier] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[SendingScheduledDateTime] [datetime] NOT NULL,
	[SendingStartedDateTime] [datetime] NULL,
	[SentDateTime] [datetime] NULL,
	[FromAddress] [nvarchar](255) NOT NULL,
	[FromName] [nvarchar](255) NOT NULL,
	[ReplyToAddress] [nvarchar](255) NULL,
	[ToAddress] [nvarchar](255) NOT NULL,
	[Subject] [nvarchar](255) NOT NULL,
	[Body] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_System.Email.Queue] PRIMARY KEY CLUSTERED 
(
	[EmailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Field.Meta.Chekbox]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Field.Meta.Chekbox](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((3)) PERSISTED NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermParentID] [bigint] NULL,
 CONSTRAINT [PK_Lead.Field.Meta.Chekbox] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Field.Meta.Dropdown]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Field.Meta.Dropdown](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((2)) PERSISTED NOT NULL,
	[Placeholder] [nvarchar](100) NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermParentID] [bigint] NULL,
	[TermDepthMaxLevel] [int] NULL,
 CONSTRAINT [PK_Lead.Field.Meta.Dropdown] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Field.Meta.Number]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Field.Meta.Number](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((7)) PERSISTED NOT NULL,
	[Placeholder] [nvarchar](100) NOT NULL,
	[MinValue] [bigint] NULL,
	[MaxValue] [bigint] NULL,
 CONSTRAINT [PK_Lead.Field.Meta.Number] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Field.Meta.Radio]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Field.Meta.Radio](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((4)) PERSISTED NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermParentID] [bigint] NULL,
 CONSTRAINT [PK_Lead.Field.Meta.Radio] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Field.Meta.TermsAllowed]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Field.Meta.TermsAllowed](
	[TermID] [bigint] NOT NULL,
 CONSTRAINT [PK_Lead.Field.Meta.TermsAllowed] PRIMARY KEY CLUSTERED 
(
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Field.Meta.Texbox]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Field.Meta.Texbox](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((1)) PERSISTED NOT NULL,
	[Placeholder] [nvarchar](255) NOT NULL,
	[RegularExpression] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_Lead.Field.Texbox.Meta] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Field.Structure.Group]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Field.Structure.Group](
	[GroupID] [int] IDENTITY(1,1) NOT NULL,
	[GroupCode] [nvarchar](100) NOT NULL,
	[GroupTitle] [nvarchar](255) NULL,
	[GroupOrder] [int] NULL,
 CONSTRAINT [PK_Lead.Field.Structure.Group] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Lead.Field.Structure.Group] UNIQUE NONCLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Field.Type]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Field.Type](
	[FieldTypeID] [int] NOT NULL,
	[FieldTypeName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Lead.Field.Type] PRIMARY KEY CLUSTERED 
(
	[FieldTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Review]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Review](
	[LeadID] [bigint] NOT NULL,
	[ReviewDateTime] [datetime] NOT NULL,
	[PublishedDateTime] [datetime] NULL,
	[ReviewText] [nvarchar](max) NULL,
	[AuthorName] [nvarchar](255) NULL,
	[BusinessID] [bigint] NULL,
	[OtherBusinessName] [nvarchar](255) NULL,
	[OrderPricePart1] [decimal](19, 4) NULL,
	[OrderPricePart2] [decimal](19, 4) NULL,
 CONSTRAINT [PK_Lead.Review] PRIMARY KEY CLUSTERED 
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Review.Measure]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Review.Measure](
	[MeasureID] [smallint] NOT NULL,
	[MeasureName] [nvarchar](255) NOT NULL,
	[Order] [smallint] NULL,
 CONSTRAINT [PK_Review.Measure] PRIMARY KEY CLUSTERED 
(
	[MeasureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Review.Measure] UNIQUE NONCLUSTERED 
(
	[MeasureName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lead.Review.Measure.Score]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lead.Review.Measure.Score](
	[LeadID] [bigint] NOT NULL,
	[ReviewMeasureID] [smallint] NOT NULL,
	[Score] [smallint] NOT NULL,
 CONSTRAINT [PK_Review.Measure.Score] PRIMARY KEY CLUSTERED 
(
	[LeadID] ASC,
	[ReviewMeasureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadGen.Legal]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadGen.Legal](
	[LegalCountryID] [bigint] NOT NULL,
	[LegalAddress] [nvarchar](255) NOT NULL,
	[LegalName] [nvarchar](255) NOT NULL,
	[LegalCode1] [nvarchar](255) NOT NULL,
	[LegalCode2] [nvarchar](255) NOT NULL,
	[LegalBankAccount] [nvarchar](255) NOT NULL,
	[LegalBankCode1] [nvarchar](255) NOT NULL,
	[LegalBankCode2] [nvarchar](255) NOT NULL,
	[LegalBankName] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_LeadGen.Legal] PRIMARY KEY CLUSTERED 
(
	[LegalCountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Notification.Frequency]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notification.Frequency](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_NotificationFrequency] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[System.Options]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[System.Options](
	[OptionKey] [nvarchar](100) NOT NULL,
	[OptionValue] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_System.Options] PRIMARY KEY CLUSTERED 
(
	[OptionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[System.ScheduledTask]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[System.ScheduledTask](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[IntervalID] [int] NOT NULL,
	[IntervalValue] [int] NOT NULL,
	[StartMonth] [int] NULL,
	[StartMonthDay] [int] NULL,
	[StartWeekDay] [int] NULL,
	[StartHour] [int] NULL,
	[StartMinute] [int] NULL,
 CONSTRAINT [PK_System.Task] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[System.ScheduledTaskInterval]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[System.ScheduledTaskInterval](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_System.TaskPeriod] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_System.TaskPeriod] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[System.ScheduledTaskLog]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[System.ScheduledTaskLog](
	[ID] [uniqueidentifier] NOT NULL,
	[TaskName] [nvarchar](255) NOT NULL,
	[StartedDateTime] [datetime] NOT NULL,
	[CompletedDateTime] [datetime] NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Message] [nvarchar](max) NULL,
 CONSTRAINT [PK_System.ScheduledTaskLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[System.Token]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[System.Token](
	[TokenKey] [nvarchar](255) NOT NULL,
	[TokenAction] [nvarchar](255) NOT NULL,
	[TokenValue] [nvarchar](255) NOT NULL,
	[TokenDateCreated] [datetime] NOT NULL,
 CONSTRAINT [PK_Token] PRIMARY KEY CLUSTERED 
(
	[TokenKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[System.WordCase]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[System.WordCase](
	[WordID] [bigint] IDENTITY(1,1) NOT NULL,
	[NominativeSingular] [nvarchar](50) NULL,
	[GenitiveSingular] [nvarchar](50) NULL,
	[DativeSingular] [nvarchar](50) NULL,
	[AccusativeSingular] [nvarchar](50) NULL,
	[InstrumentalSingular] [nvarchar](50) NULL,
	[PrepositionalSingular] [nvarchar](50) NULL,
	[NominativePlural] [nvarchar](50) NULL,
	[GenitivePlural] [nvarchar](50) NULL,
	[DativePlural] [nvarchar](50) NULL,
	[AccusativePlural] [nvarchar](50) NULL,
	[InstrumentalPlural] [nvarchar](50) NULL,
	[PrepositionalPlural] [nvarchar](50) NULL,
 CONSTRAINT [PK_System.Word.Case] PRIMARY KEY CLUSTERED 
(
	[WordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Taxonomy.Term.Word]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Taxonomy.Term.Word](
	[TermID] [bigint] NOT NULL,
	[WordID] [bigint] NOT NULL,
	[TermWordCode] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Taxonomy.Term.Word] PRIMARY KEY CLUSTERED 
(
	[TermID] ASC,
	[WordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Taxonomy.Term.Word] UNIQUE NONCLUSTERED 
(
	[TermID] ASC,
	[TermWordCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[User.Login]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User.Login](
	[LoginID] [bigint] IDENTITY(1,1) NOT NULL,
	[RoleID] [int] NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[PasswordHash] [nvarchar](255) NOT NULL,
	[RegistrationDate] [datetime] NOT NULL,
	[EmailConfirmationDate] [datetime] NULL,
 CONSTRAINT [PK_User.Login] PRIMARY KEY CLUSTERED 
(
	[LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[User.Role]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User.Role](
	[RoleID] [int] NOT NULL,
	[RoleName] [nvarchar](50) NOT NULL,
	[RoleCode] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_User.Role] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[User.Session]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User.Session](
	[SessionID] [nvarchar](255) NOT NULL,
	[LoginID] [bigint] NOT NULL,
	[SessionCreationDate] [datetime] NOT NULL,
	[SessionBlockDate] [datetime] NULL,
	[SessionPasswordHash] [nvarchar](255) NOT NULL,
	[SessionPasswordChangeInitialized] [bit] NULL,
 CONSTRAINT [PK_User.Sessions] PRIMARY KEY CLUSTERED 
(
	[SessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [IX_Business]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Business] ON [dbo].[Business]
(
	[BusinessID] ASC,
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Business.Invoice_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Business.Invoice_1] ON [dbo].[Business.Invoice]
(
	[LegalYear] ASC,
	[LegalFacturaNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Business.Invoice_2]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Business.Invoice_2] ON [dbo].[Business.Invoice]
(
	[BusinessID] ASC,
	[LegalYear] ASC,
	[LegalMonth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [LeadIDIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [LeadIDIndex] ON [dbo].[Business.Lead.ContactsRecieved]
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [LeadIDIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [LeadIDIndex] ON [dbo].[Business.Lead.NotInterested]
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [Business.Lead.Permission_RequestedDateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [Business.Lead.Permission_RequestedDateTime] ON [dbo].[Business.Lead.Permission]
(
	[BusinessID] ASC,
	[RequestedDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CMS.Attachment_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CMS.Attachment_1] ON [dbo].[CMS.Attachment]
(
	[AttachmentID] ASC,
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CMS.Post_2]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_CMS.Post_2] ON [dbo].[CMS.Post]
(
	[TypeID] ASC,
	[Order] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SelectIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [SelectIndex] ON [dbo].[CMS.Post]
(
	[TypeID] ASC
)
INCLUDE ( 	[PostID],
	[PostParentID],
	[StatusID],
	[PostURL],
	[PostForTermID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CMS.Post.Type]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CMS.Post.Type] ON [dbo].[CMS.Post.Type]
(
	[TypeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CMS.Post.Type.Taxonomy]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CMS.Post.Type.Taxonomy] ON [dbo].[CMS.Post.Type.Taxonomy]
(
	[PostTypeID] ASC,
	[ForTaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Lead]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead] ON [dbo].[Lead]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_Lead_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead_1] ON [dbo].[Lead]
(
	[NumberFromEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lead_2]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead_2] ON [dbo].[Lead]
(
	[LeadID] ASC,
	[PublishedDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PublishedCreatedDateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [PublishedCreatedDateTime] ON [dbo].[Lead]
(
	[PublishedDateTime] ASC
)
INCLUDE ( 	[CreatedDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_Lead.Field.Meta.Chekbox]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Lead.Field.Meta.Chekbox] ON [dbo].[Lead.Field.Meta.Chekbox]
(
	[FieldID] ASC,
	[FieldTypeID] ASC,
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_Lead.Field.Meta.Dropdown]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Lead.Field.Meta.Dropdown] ON [dbo].[Lead.Field.Meta.Dropdown]
(
	[FieldID] ASC,
	[FieldTypeID] ASC,
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_Lead.Field.Meta.Radio]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Lead.Field.Meta.Radio] ON [dbo].[Lead.Field.Meta.Radio]
(
	[FieldID] ASC,
	[FieldTypeID] ASC,
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_Lead.Field.Meta.Texbox]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Lead.Field.Meta.Texbox] ON [dbo].[Lead.Field.Meta.Texbox]
(
	[FieldID] ASC,
	[FieldTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lead.Field]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Lead.Field] ON [dbo].[Lead.Field.Structure]
(
	[FieldID] ASC,
	[FieldTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Lead.Field_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Lead.Field_1] ON [dbo].[Lead.Field.Structure]
(
	[FieldName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lead.Field.Value.Scalar_DateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead.Field.Value.Scalar_DateTime] ON [dbo].[Lead.Field.Value.Scalar]
(
	[DatetimeValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_Lead.Field.Value.Scalar_NubmerValueFromText]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead.Field.Value.Scalar_NubmerValueFromText] ON [dbo].[Lead.Field.Value.Scalar]
(
	[NubmerValueFromText] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lead.Field.Value.Scalar_Number]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead.Field.Value.Scalar_Number] ON [dbo].[Lead.Field.Value.Scalar]
(
	[NumberValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lead.Field.Value.Taxonomy_LeadID]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead.Field.Value.Taxonomy_LeadID] ON [dbo].[Lead.Field.Value.Taxonomy]
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lead.Field.Value.Taxonomy_TermID]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead.Field.Value.Taxonomy_TermID] ON [dbo].[Lead.Field.Value.Taxonomy]
(
	[TermID] ASC
)
INCLUDE ( 	[LeadID],
	[FieldID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lead.Field.Value.Taxonomy_TermTax]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Lead.Field.Value.Taxonomy_TermTax] ON [dbo].[Lead.Field.Value.Taxonomy]
(
	[TaxonomyID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_NotificationFrequency]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_NotificationFrequency] ON [dbo].[Notification.Frequency]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_System.ScheduledTaskLog]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_System.ScheduledTaskLog] ON [dbo].[System.ScheduledTaskLog]
(
	[TaskName] ASC,
	[CompletedDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Taxonomy]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Taxonomy] ON [dbo].[Taxonomy]
(
	[TaxonomyCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Taxonomy_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Taxonomy_1] ON [dbo].[Taxonomy]
(
	[TaxonomyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Taxonomy.Term]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Taxonomy.Term] ON [dbo].[Taxonomy.Term]
(
	[TermID] ASC,
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Taxonomy.Term_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Taxonomy.Term_1] ON [dbo].[Taxonomy.Term]
(
	[TermURL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Taxonomy.Term_2]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Taxonomy.Term_2] ON [dbo].[Taxonomy.Term]
(
	[TermName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_User.Login]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_User.Login] ON [dbo].[User.Login]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_User.Login_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_User.Login_1] ON [dbo].[User.Login]
(
	[LoginID] ASC,
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_User.Role]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_User.Role] ON [dbo].[User.Role]
(
	[RoleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_User.Role_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_User.Role_1] ON [dbo].[User.Role]
(
	[RoleCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Business] ADD  CONSTRAINT [DF_Business_BusinessRegistrationDate]  DEFAULT (getutcdate()) FOR [RegistrationDate]
GO
ALTER TABLE [dbo].[Business] ADD  CONSTRAINT [DF_Business_NotificationFrequencyID]  DEFAULT ((1)) FOR [NotificationFrequencyID]
GO
ALTER TABLE [dbo].[Business.Invoice] ADD  CONSTRAINT [DF_Business.Invoice_InvoceCreatedDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[Business.Invoice.Line] ADD  CONSTRAINT [DF_Business.Invoice.Line_Quantaty]  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[Business.Invoice.Line] ADD  CONSTRAINT [DF_Business.Invoice.Line_Tax]  DEFAULT ((0)) FOR [Tax]
GO
ALTER TABLE [dbo].[Business.Lead.Completed] ADD  CONSTRAINT [DF_Business.Lead.Completed_CompletedDateTime]  DEFAULT (getutcdate()) FOR [CompletedDateTime]
GO
ALTER TABLE [dbo].[Business.Lead.ContactsRecieved] ADD  CONSTRAINT [DF_Business.Lead.ContactsRecieve_GetContactsDate]  DEFAULT (getutcdate()) FOR [GetContactsDateTime]
GO
ALTER TABLE [dbo].[Business.Lead.Important] ADD  CONSTRAINT [DF_Business.Lead.Important_ImportantDateTime]  DEFAULT (getutcdate()) FOR [ImportantDateTime]
GO
ALTER TABLE [dbo].[Business.Lead.Notified] ADD  CONSTRAINT [DF_BuinessLeadNotified_NotifiedDateTime]  DEFAULT (getutcdate()) FOR [NotifiedDateTime]
GO
ALTER TABLE [dbo].[Business.Lead.Notified.Post] ADD  CONSTRAINT [DF_Business.Lead.Notified.Post_NotifiedDateTime]  DEFAULT (getutcdate()) FOR [NotifiedDateTime]
GO
ALTER TABLE [dbo].[Business.Lead.Permission] ADD  CONSTRAINT [DF_Business.Lead.Permission_RequestedDateTime]  DEFAULT (getutcdate()) FOR [RequestedDateTime]
GO
ALTER TABLE [dbo].[Business.Location] ADD  CONSTRAINT [DF_Business.Location_IsAprovedByAdmin]  DEFAULT ((0)) FOR [IsAprovedByAdmin]
GO
ALTER TABLE [dbo].[Business.Location] ADD  CONSTRAINT [DF_Business.Location_CreatedDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[Business.Login] ADD  CONSTRAINT [DF_Business.Login_LinkDate]  DEFAULT (getutcdate()) FOR [LinkDate]
GO
ALTER TABLE [dbo].[CMS.Attachment] ADD  CONSTRAINT [DF_CMS.Attachment_MIME]  DEFAULT ('') FOR [MIME]
GO
ALTER TABLE [dbo].[CMS.Attachment] ADD  CONSTRAINT [DF_CMS.Attachment_URL]  DEFAULT (CONVERT([varchar],sysdatetime(),(121))) FOR [URL]
GO
ALTER TABLE [dbo].[CMS.Attachment] ADD  CONSTRAINT [DF_CMS.Attachment_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[CMS.Attachment] ADD  CONSTRAINT [DF_CMS.Attachment_Name]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[CMS.Attachment] ADD  CONSTRAINT [DF_CMS.Attachment_Description]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[CMS.Post] ADD  CONSTRAINT [DF_CMS.Post_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[CMS.Post] ADD  CONSTRAINT [DF_CMS.Post_DateLastModified]  DEFAULT (getutcdate()) FOR [DateLastModified]
GO
ALTER TABLE [dbo].[CMS.Post] ADD  CONSTRAINT [DF_CMS.Post_Order]  DEFAULT ((0)) FOR [Order]
GO
ALTER TABLE [dbo].[CMS.Post.Attachment] ADD  CONSTRAINT [DF_CMS.Post.Attachment_LinkDate]  DEFAULT (getutcdate()) FOR [LinkDate]
GO
ALTER TABLE [dbo].[CMS.Post.Type] ADD  CONSTRAINT [DF_CMS.Post.Type_TypeCode]  DEFAULT ('') FOR [TypeCode]
GO
ALTER TABLE [dbo].[CMS.Post.Type] ADD  CONSTRAINT [DF_CMS.Post.Type_IsBrowsable]  DEFAULT ((0)) FOR [IsBrowsable]
GO
ALTER TABLE [dbo].[CMS.Post.Type] ADD  CONSTRAINT [DF_CMS.Post.Type_SeoPriority]  DEFAULT ((0.5)) FOR [SeoPriority]
GO
ALTER TABLE [dbo].[CMS.Post.Type] ADD  CONSTRAINT [DF_CMS.Post.Type_SeoChangeFrequencyID]  DEFAULT ((4)) FOR [SeoChangeFrequencyID]
GO
ALTER TABLE [dbo].[CMS.Post.Type] ADD  CONSTRAINT [DF_CMS.Post.Type_PostSeoPriority]  DEFAULT ((0.5)) FOR [PostSeoPriority]
GO
ALTER TABLE [dbo].[CMS.Post.Type] ADD  CONSTRAINT [DF_CMS.Post.Type_PostSeoChangeFrequencyID]  DEFAULT ((4)) FOR [PostSeoChangeFrequencyID]
GO
ALTER TABLE [dbo].[CMS.Post.Type] ADD  CONSTRAINT [DF_CMS.Post.Type_HasContentIntro]  DEFAULT ((0)) FOR [HasContentIntro]
GO
ALTER TABLE [dbo].[CMS.Post.Type] ADD  CONSTRAINT [DF_CMS.Post.Type_HasContentEnding]  DEFAULT ((0)) FOR [HasContentEnding]
GO
ALTER TABLE [dbo].[CMS.Post.Type.Attachment.Taxonomy] ADD  CONSTRAINT [DF_CMS.Post.Type..Attachment.Taxonomy]]_IsEnabled]  DEFAULT ((0)) FOR [IsEnabled]
GO
ALTER TABLE [dbo].[CMS.Post.Type.Taxonomy] ADD  CONSTRAINT [DF_CMS.Post.Type.Taxonomy_IsDisabled]  DEFAULT ((1)) FOR [IsEnabled]
GO
ALTER TABLE [dbo].[Email.Queue] ADD  CONSTRAINT [DF_System.Email.Queue_Id]  DEFAULT (newid()) FOR [EmailID]
GO
ALTER TABLE [dbo].[Email.Queue] ADD  CONSTRAINT [DF_System.Email.Queue_CreatedDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[Email.Queue] ADD  CONSTRAINT [DF_System.Email.Queue_SendingScheduledDateTime]  DEFAULT (getutcdate()) FOR [SendingScheduledDateTime]
GO
ALTER TABLE [dbo].[Lead] ADD  CONSTRAINT [DF_Lead_LeadDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Texbox] ADD  CONSTRAINT [DF_Lead.Field.Meta.Texbox_Placeholder]  DEFAULT ('') FOR [Placeholder]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Texbox] ADD  CONSTRAINT [DF_Lead.Field.Meta.Texbox_RegularExpression]  DEFAULT ('') FOR [RegularExpression]
GO
ALTER TABLE [dbo].[Lead.Field.Structure] ADD  CONSTRAINT [DF_Lead.FieldStructure_IsContact]  DEFAULT ((0)) FOR [IsContact]
GO
ALTER TABLE [dbo].[Lead.Field.Structure] ADD  CONSTRAINT [DF_Lead.FieldStructure_isActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Lead.Field.Value.Scalar] ADD  CONSTRAINT [DF_Lead.Field.Value.Scalar_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Lead.Location] ADD  CONSTRAINT [DF_Lead.Location_LocationAccuracyMeters]  DEFAULT ((0)) FOR [LocationAccuracyMeters]
GO
ALTER TABLE [dbo].[Lead.Location] ADD  CONSTRAINT [DF_Lead.Location_LeadRadius]  DEFAULT ((5000)) FOR [LeadRadiusMeters]
GO
ALTER TABLE [dbo].[Lead.Review] ADD  CONSTRAINT [DF_Lead.Review_ReviewDateTime]  DEFAULT (getutcdate()) FOR [ReviewDateTime]
GO
ALTER TABLE [dbo].[System.ScheduledTaskLog] ADD  CONSTRAINT [DF_System.ScheduledTaskLog_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[System.ScheduledTaskLog] ADD  CONSTRAINT [DF_System.ScheduledTaskLog_StartedDateTime]  DEFAULT (getutcdate()) FOR [StartedDateTime]
GO
ALTER TABLE [dbo].[System.ScheduledTaskLog] ADD  CONSTRAINT [DF_System.ScheduledTaskLog_Status]  DEFAULT (N'Started') FOR [Status]
GO
ALTER TABLE [dbo].[System.Token] ADD  CONSTRAINT [DF_Token_TokenDateCreated]  DEFAULT (getutcdate()) FOR [TokenDateCreated]
GO
ALTER TABLE [dbo].[Taxonomy] ADD  CONSTRAINT [DF_Taxonomy_IsTag]  DEFAULT ((0)) FOR [IsTag]
GO
ALTER TABLE [dbo].[User.Login] ADD  CONSTRAINT [DF_User.Login_RegistrationDate]  DEFAULT (getutcdate()) FOR [RegistrationDate]
GO
ALTER TABLE [dbo].[Business]  WITH CHECK ADD  CONSTRAINT [FK_Business_Notification.Frequency] FOREIGN KEY([NotificationFrequencyID])
REFERENCES [dbo].[Notification.Frequency] ([ID])
GO
ALTER TABLE [dbo].[Business] CHECK CONSTRAINT [FK_Business_Notification.Frequency]
GO
ALTER TABLE [dbo].[Business]  WITH CHECK ADD  CONSTRAINT [FK_Business_Taxonomy.Term] FOREIGN KEY([CountryID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID])
GO
ALTER TABLE [dbo].[Business] CHECK CONSTRAINT [FK_Business_Taxonomy.Term]
GO
ALTER TABLE [dbo].[Business.Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Business.Invoice_Business] FOREIGN KEY([BusinessID], [BillingCountryID])
REFERENCES [dbo].[Business] ([BusinessID], [CountryID])
GO
ALTER TABLE [dbo].[Business.Invoice] CHECK CONSTRAINT [FK_Business.Invoice_Business]
GO
ALTER TABLE [dbo].[Business.Invoice.Line]  WITH CHECK ADD  CONSTRAINT [FK_Business.Invoice.Line_Business.Invoice.Line] FOREIGN KEY([InvoiceID], [BusinessID])
REFERENCES [dbo].[Business.Invoice] ([InvoiceID], [BusinessID])
GO
ALTER TABLE [dbo].[Business.Invoice.Line] CHECK CONSTRAINT [FK_Business.Invoice.Line_Business.Invoice.Line]
GO
ALTER TABLE [dbo].[Business.Lead.Completed]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice] FOREIGN KEY([InvoiceID], [BusinessID])
REFERENCES [dbo].[Business.Invoice] ([InvoiceID], [BusinessID])
GO
ALTER TABLE [dbo].[Business.Lead.Completed] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice]
GO
ALTER TABLE [dbo].[Business.Lead.Completed]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice.Line] FOREIGN KEY([InvoiceID], [InvoiceLineID])
REFERENCES [dbo].[Business.Invoice.Line] ([InvoiceID], [LineID])
GO
ALTER TABLE [dbo].[Business.Lead.Completed] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice.Line]
GO
ALTER TABLE [dbo].[Business.Lead.Completed]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Lead.ContactsRecieve] FOREIGN KEY([BusinessID], [LeadID])
REFERENCES [dbo].[Business.Lead.ContactsRecieved] ([BusinessID], [LeadID])
GO
ALTER TABLE [dbo].[Business.Lead.Completed] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Lead.ContactsRecieve]
GO
ALTER TABLE [dbo].[Business.Lead.Completed]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Login] FOREIGN KEY([BusinessID], [LoginID])
REFERENCES [dbo].[Business.Login] ([BusinessID], [LoginID])
GO
ALTER TABLE [dbo].[Business.Lead.Completed] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Login]
GO
ALTER TABLE [dbo].[Business.Lead.Completed]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[Business.Lead.Completed] CHECK CONSTRAINT [FK_Business.Lead.Completed_Lead]
GO
ALTER TABLE [dbo].[Business.Lead.ContactsRecieved]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.ContactsRecieve_Business.Login] FOREIGN KEY([BusinessID], [LoginID])
REFERENCES [dbo].[Business.Login] ([BusinessID], [LoginID])
GO
ALTER TABLE [dbo].[Business.Lead.ContactsRecieved] CHECK CONSTRAINT [FK_Business.Lead.ContactsRecieve_Business.Login]
GO
ALTER TABLE [dbo].[Business.Lead.ContactsRecieved]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.ContactsRecieve_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[Business.Lead.ContactsRecieved] CHECK CONSTRAINT [FK_Business.Lead.ContactsRecieve_Lead]
GO
ALTER TABLE [dbo].[Business.Lead.Important]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Important_Business.Login] FOREIGN KEY([BusinessID], [LoginID])
REFERENCES [dbo].[Business.Login] ([BusinessID], [LoginID])
GO
ALTER TABLE [dbo].[Business.Lead.Important] CHECK CONSTRAINT [FK_Business.Lead.Important_Business.Login]
GO
ALTER TABLE [dbo].[Business.Lead.Important]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Important_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[Business.Lead.Important] CHECK CONSTRAINT [FK_Business.Lead.Important_Lead]
GO
ALTER TABLE [dbo].[Business.Lead.Notified]  WITH CHECK ADD  CONSTRAINT [FK_BuinessLeadNotified_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[Business.Lead.Notified] CHECK CONSTRAINT [FK_BuinessLeadNotified_Business]
GO
ALTER TABLE [dbo].[Business.Lead.Notified]  WITH CHECK ADD  CONSTRAINT [FK_BuinessLeadNotified_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[Business.Lead.Notified] CHECK CONSTRAINT [FK_BuinessLeadNotified_Lead]
GO
ALTER TABLE [dbo].[Business.Lead.Notified.Post]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Notified.Post_CMS.Post] FOREIGN KEY([BusinessPostID])
REFERENCES [dbo].[CMS.Post] ([PostID])
GO
ALTER TABLE [dbo].[Business.Lead.Notified.Post] CHECK CONSTRAINT [FK_Business.Lead.Notified.Post_CMS.Post]
GO
ALTER TABLE [dbo].[Business.Lead.Notified.Post]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Notified.Post_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[Business.Lead.Notified.Post] CHECK CONSTRAINT [FK_Business.Lead.Notified.Post_Lead]
GO
ALTER TABLE [dbo].[Business.Lead.NotInterested]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.NotInterested_Business.Login] FOREIGN KEY([BusinessID], [LoginID])
REFERENCES [dbo].[Business.Login] ([BusinessID], [LoginID])
GO
ALTER TABLE [dbo].[Business.Lead.NotInterested] CHECK CONSTRAINT [FK_Business.Lead.NotInterested_Business.Login]
GO
ALTER TABLE [dbo].[Business.Lead.NotInterested]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.NotInterested_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[Business.Lead.NotInterested] CHECK CONSTRAINT [FK_Business.Lead.NotInterested_Lead]
GO
ALTER TABLE [dbo].[Business.Lead.Permission]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Permission_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[Business.Lead.Permission] CHECK CONSTRAINT [FK_Business.Lead.Permission_Business]
GO
ALTER TABLE [dbo].[Business.Lead.Permission.Term]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Permission.Term_Business.Lead.Permission] FOREIGN KEY([PermissionID])
REFERENCES [dbo].[Business.Lead.Permission] ([PermissionID])
GO
ALTER TABLE [dbo].[Business.Lead.Permission.Term] CHECK CONSTRAINT [FK_Business.Lead.Permission.Term_Business.Lead.Permission]
GO
ALTER TABLE [dbo].[Business.Lead.Permission.Term]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Permission.Term_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID])
GO
ALTER TABLE [dbo].[Business.Lead.Permission.Term] CHECK CONSTRAINT [FK_Business.Lead.Permission.Term_Taxonomy.Term]
GO
ALTER TABLE [dbo].[Business.Location]  WITH CHECK ADD  CONSTRAINT [FK_Business.Location_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[Business.Location] CHECK CONSTRAINT [FK_Business.Location_Business]
GO
ALTER TABLE [dbo].[Business.Login]  WITH CHECK ADD  CONSTRAINT [FK_Business.Login_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[Business.Login] CHECK CONSTRAINT [FK_Business.Login_Business]
GO
ALTER TABLE [dbo].[Business.Login]  WITH CHECK ADD  CONSTRAINT [FK_Business.Login_User.Login1] FOREIGN KEY([LoginID], [RoleID])
REFERENCES [dbo].[User.Login] ([LoginID], [RoleID])
GO
ALTER TABLE [dbo].[Business.Login] CHECK CONSTRAINT [FK_Business.Login_User.Login1]
GO
ALTER TABLE [dbo].[Business.Notification.Email]  WITH CHECK ADD  CONSTRAINT [FK_Business.Notification.Email_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[Business.Notification.Email] CHECK CONSTRAINT [FK_Business.Notification.Email_Business]
GO
ALTER TABLE [dbo].[CMS.Attachment]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment_CMS.Attachment.Type] FOREIGN KEY([TypeID])
REFERENCES [dbo].[CMS.Attachment.Type] ([AttachmentTypeID])
GO
ALTER TABLE [dbo].[CMS.Attachment] CHECK CONSTRAINT [FK_CMS.Attachment_CMS.Attachment.Type]
GO
ALTER TABLE [dbo].[CMS.Attachment.Image]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment.Image_CMS.Attachment] FOREIGN KEY([AttachmentID], [TypeID])
REFERENCES [dbo].[CMS.Attachment] ([AttachmentID], [TypeID])
GO
ALTER TABLE [dbo].[CMS.Attachment.Image] CHECK CONSTRAINT [FK_CMS.Attachment.Image_CMS.Attachment]
GO
ALTER TABLE [dbo].[CMS.Attachment.Term]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment.Term_CMS.Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].[CMS.Attachment] ([AttachmentID])
GO
ALTER TABLE [dbo].[CMS.Attachment.Term] CHECK CONSTRAINT [FK_CMS.Attachment.Term_CMS.Attachment]
GO
ALTER TABLE [dbo].[CMS.Attachment.Term]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment.Term_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID])
GO
ALTER TABLE [dbo].[CMS.Attachment.Term] CHECK CONSTRAINT [FK_CMS.Attachment.Term_Taxonomy.Term]
GO
ALTER TABLE [dbo].[CMS.Post]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post] FOREIGN KEY([PostParentID])
REFERENCES [dbo].[CMS.Post] ([PostID])
GO
ALTER TABLE [dbo].[CMS.Post] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post]
GO
ALTER TABLE [dbo].[CMS.Post]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post.Status] FOREIGN KEY([StatusID])
REFERENCES [dbo].[CMS.Post.Status] ([StatusID])
GO
ALTER TABLE [dbo].[CMS.Post] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post.Status]
GO
ALTER TABLE [dbo].[CMS.Post]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post.Type] FOREIGN KEY([TypeID])
REFERENCES [dbo].[CMS.Post.Type] ([TypeID])
GO
ALTER TABLE [dbo].[CMS.Post] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post.Type]
GO
ALTER TABLE [dbo].[CMS.Post]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post.Type.Taxonomy] FOREIGN KEY([TypeID], [PostForTaxonomyID])
REFERENCES [dbo].[CMS.Post.Type.Taxonomy] ([PostTypeID], [ForTaxonomyID])
GO
ALTER TABLE [dbo].[CMS.Post] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post.Type.Taxonomy]
GO
ALTER TABLE [dbo].[CMS.Post]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_SEO.Sitemap.ChangeFrequency] FOREIGN KEY([SeoChangeFrequencyID])
REFERENCES [dbo].[CMS.Sitemap.ChangeFrequency] ([ID])
GO
ALTER TABLE [dbo].[CMS.Post] CHECK CONSTRAINT [FK_CMS.Post_SEO.Sitemap.ChangeFrequency]
GO
ALTER TABLE [dbo].[CMS.Post]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_Taxonomy.Term] FOREIGN KEY([PostForTermID], [PostForTaxonomyID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID], [TaxonomyID])
GO
ALTER TABLE [dbo].[CMS.Post] CHECK CONSTRAINT [FK_CMS.Post_Taxonomy.Term]
GO
ALTER TABLE [dbo].[CMS.Post]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_User.Login] FOREIGN KEY([AuthorID])
REFERENCES [dbo].[User.Login] ([LoginID])
GO
ALTER TABLE [dbo].[CMS.Post] CHECK CONSTRAINT [FK_CMS.Post_User.Login]
GO
ALTER TABLE [dbo].[CMS.Post.Attachment]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post] FOREIGN KEY([PostID])
REFERENCES [dbo].[CMS.Post] ([PostID])
GO
ALTER TABLE [dbo].[CMS.Post.Attachment] CHECK CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post]
GO
ALTER TABLE [dbo].[CMS.Post.Attachment]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post.Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].[CMS.Attachment] ([AttachmentID])
GO
ALTER TABLE [dbo].[CMS.Post.Attachment] CHECK CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post.Attachment]
GO
ALTER TABLE [dbo].[CMS.Post.Field.Value]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Field.Values_CMS.Post.Field.Values] FOREIGN KEY([PostID], [PostTypeID])
REFERENCES [dbo].[CMS.Post] ([PostID], [TypeID])
GO
ALTER TABLE [dbo].[CMS.Post.Field.Value] CHECK CONSTRAINT [FK_CMS.Post.Field.Values_CMS.Post.Field.Values]
GO
ALTER TABLE [dbo].[CMS.Post.Field.Value]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Field.Values_CMS.Post.Field.Values1] FOREIGN KEY([FieldID], [PostTypeID])
REFERENCES [dbo].[CMS.Post.Type.Field.Structure] ([FieldID], [PostTypeID])
GO
ALTER TABLE [dbo].[CMS.Post.Field.Value] CHECK CONSTRAINT [FK_CMS.Post.Field.Values_CMS.Post.Field.Values1]
GO
ALTER TABLE [dbo].[CMS.Post.Term]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Term_CMS.Post] FOREIGN KEY([PostID], [PostTypeID])
REFERENCES [dbo].[CMS.Post] ([PostID], [TypeID])
GO
ALTER TABLE [dbo].[CMS.Post.Term] CHECK CONSTRAINT [FK_CMS.Post.Term_CMS.Post]
GO
ALTER TABLE [dbo].[CMS.Post.Term]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Term_CMS.Taxonomy.Term] FOREIGN KEY([TermID], [TaxonomyID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID], [TaxonomyID])
GO
ALTER TABLE [dbo].[CMS.Post.Term] CHECK CONSTRAINT [FK_CMS.Post.Term_CMS.Taxonomy.Term]
GO
ALTER TABLE [dbo].[CMS.Post.Type]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type_CMS.Post.Type.Taxonomy] FOREIGN KEY([TypeID], [ForPostTypeID], [ForTaxonomyID])
REFERENCES [dbo].[CMS.Post.Type.Taxonomy] ([PostTypeID], [ForPostTypeID], [ForTaxonomyID])
GO
ALTER TABLE [dbo].[CMS.Post.Type] CHECK CONSTRAINT [FK_CMS.Post.Type_CMS.Post.Type.Taxonomy]
GO
ALTER TABLE [dbo].[CMS.Post.Type]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type_CMS.Sitemap.ChangeFrequency] FOREIGN KEY([PostSeoChangeFrequencyID])
REFERENCES [dbo].[CMS.Sitemap.ChangeFrequency] ([ID])
GO
ALTER TABLE [dbo].[CMS.Post.Type] CHECK CONSTRAINT [FK_CMS.Post.Type_CMS.Sitemap.ChangeFrequency]
GO
ALTER TABLE [dbo].[CMS.Post.Type.Attachment.Taxonomy]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_CMS.Post.Type] FOREIGN KEY([PostTypeID])
REFERENCES [dbo].[CMS.Post.Type] ([TypeID])
GO
ALTER TABLE [dbo].[CMS.Post.Type.Attachment.Taxonomy] CHECK CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_CMS.Post.Type]
GO
ALTER TABLE [dbo].[CMS.Post.Type.Attachment.Taxonomy]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_Taxonomy] FOREIGN KEY([AttachmentTaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[CMS.Post.Type.Attachment.Taxonomy] CHECK CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_Taxonomy]
GO
ALTER TABLE [dbo].[CMS.Post.Type.Field.Structure]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Field.Structure_CMS.Post.Type] FOREIGN KEY([PostTypeID])
REFERENCES [dbo].[CMS.Post.Type] ([TypeID])
GO
ALTER TABLE [dbo].[CMS.Post.Type.Field.Structure] CHECK CONSTRAINT [FK_CMS.Post.Field.Structure_CMS.Post.Type]
GO
ALTER TABLE [dbo].[CMS.Post.Type.Field.Structure]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type.Field.Structure_CMS.Field.Types] FOREIGN KEY([FieldTypeID])
REFERENCES [dbo].[CMS.Field.Type] ([FieldTypeID])
GO
ALTER TABLE [dbo].[CMS.Post.Type.Field.Structure] CHECK CONSTRAINT [FK_CMS.Post.Type.Field.Structure_CMS.Field.Types]
GO
ALTER TABLE [dbo].[CMS.Post.Type.Taxonomy]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type.Taxonomy_CMS.Taxonomy] FOREIGN KEY([ForTaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[CMS.Post.Type.Taxonomy] CHECK CONSTRAINT [FK_CMS.Post.Type.Taxonomy_CMS.Taxonomy]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Chekbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Lead.Field.Meta.Chekbox] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[Lead.Field.Structure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Chekbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Lead.Field.Meta.Chekbox]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Chekbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Chekbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Chekbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy.Term] FOREIGN KEY([TermParentID], [TaxonomyID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID], [TaxonomyID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Chekbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy.Term]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Dropdown]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Lead.Field] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[Lead.Field.Structure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Dropdown] CHECK CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Lead.Field]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Dropdown]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Dropdown] CHECK CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Dropdown]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy.Term] FOREIGN KEY([TermParentID], [TaxonomyID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID], [TaxonomyID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Dropdown] CHECK CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy.Term]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Number]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Number_Lead.FieldStructure] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[Lead.Field.Structure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Number] CHECK CONSTRAINT [FK_Lead.Field.Meta.Number_Lead.FieldStructure]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Radio]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Radio_Lead.Field] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[Lead.Field.Structure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Radio] CHECK CONSTRAINT [FK_Lead.Field.Meta.Radio_Lead.Field]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Radio]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Radio] CHECK CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Radio]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy.Term] FOREIGN KEY([TermParentID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Radio] CHECK CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy.Term]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.TermsAllowed]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.TermsAllowed_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.TermsAllowed] CHECK CONSTRAINT [FK_Lead.Field.Meta.TermsAllowed_Taxonomy.Term]
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Texbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Texbox_Lead.Field.Meta.Texbox] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[Lead.Field.Structure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[Lead.Field.Meta.Texbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Texbox_Lead.Field.Meta.Texbox]
GO
ALTER TABLE [dbo].[Lead.Field.Structure]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Structure_Lead.Field.Structure.Group] FOREIGN KEY([GroupID])
REFERENCES [dbo].[Lead.Field.Structure.Group] ([GroupID])
GO
ALTER TABLE [dbo].[Lead.Field.Structure] CHECK CONSTRAINT [FK_Lead.Field.Structure_Lead.Field.Structure.Group]
GO
ALTER TABLE [dbo].[Lead.Field.Structure]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field_Lead.Field.Type] FOREIGN KEY([FieldTypeID])
REFERENCES [dbo].[Lead.Field.Type] ([FieldTypeID])
GO
ALTER TABLE [dbo].[Lead.Field.Structure] CHECK CONSTRAINT [FK_Lead.Field_Lead.Field.Type]
GO
ALTER TABLE [dbo].[Lead.Field.Value.Scalar]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[Lead.Field.Value.Scalar] CHECK CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead]
GO
ALTER TABLE [dbo].[Lead.Field.Value.Scalar]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead.FieldStructure] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[Lead.Field.Structure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[Lead.Field.Value.Scalar] CHECK CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead.FieldStructure]
GO
ALTER TABLE [dbo].[Lead.Field.Value.Taxonomy]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[Lead.Field.Value.Taxonomy] CHECK CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Lead]
GO
ALTER TABLE [dbo].[Lead.Field.Value.Taxonomy]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Taxonomy.Term] FOREIGN KEY([TermID], [TaxonomyID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID], [TaxonomyID])
GO
ALTER TABLE [dbo].[Lead.Field.Value.Taxonomy] CHECK CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Taxonomy.Term]
GO
ALTER TABLE [dbo].[Lead.Location]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Location_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[Lead.Location] CHECK CONSTRAINT [FK_Lead.Location_Lead]
GO
ALTER TABLE [dbo].[Lead.Review]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Review_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[Lead.Review] CHECK CONSTRAINT [FK_Lead.Review_Business]
GO
ALTER TABLE [dbo].[Lead.Review]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Review_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[Lead.Review] CHECK CONSTRAINT [FK_Lead.Review_Lead]
GO
ALTER TABLE [dbo].[Lead.Review.Measure.Score]  WITH CHECK ADD  CONSTRAINT [FK_Review.Measure.Score_Lead.Review] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead.Review] ([LeadID])
GO
ALTER TABLE [dbo].[Lead.Review.Measure.Score] CHECK CONSTRAINT [FK_Review.Measure.Score_Lead.Review]
GO
ALTER TABLE [dbo].[Lead.Review.Measure.Score]  WITH CHECK ADD  CONSTRAINT [FK_Review.Measure.Score_Review.Measure] FOREIGN KEY([ReviewMeasureID])
REFERENCES [dbo].[Lead.Review.Measure] ([MeasureID])
GO
ALTER TABLE [dbo].[Lead.Review.Measure.Score] CHECK CONSTRAINT [FK_Review.Measure.Score_Review.Measure]
GO
ALTER TABLE [dbo].[LeadGen.Legal]  WITH CHECK ADD  CONSTRAINT [FK_LeadGen.Legal_Taxonomy.Term] FOREIGN KEY([LegalCountryID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID])
GO
ALTER TABLE [dbo].[LeadGen.Legal] CHECK CONSTRAINT [FK_LeadGen.Legal_Taxonomy.Term]
GO
ALTER TABLE [dbo].[System.ScheduledTask]  WITH CHECK ADD  CONSTRAINT [FK_System.Task_System.TaskPeriod] FOREIGN KEY([IntervalID])
REFERENCES [dbo].[System.ScheduledTaskInterval] ([ID])
GO
ALTER TABLE [dbo].[System.ScheduledTask] CHECK CONSTRAINT [FK_System.Task_System.TaskPeriod]
GO
ALTER TABLE [dbo].[Taxonomy.Term]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy.Term] FOREIGN KEY([TermParentID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID])
GO
ALTER TABLE [dbo].[Taxonomy.Term] CHECK CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy.Term]
GO
ALTER TABLE [dbo].[Taxonomy.Term]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy1] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[Taxonomy.Term] CHECK CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy1]
GO
ALTER TABLE [dbo].[Taxonomy.Term.Word]  WITH CHECK ADD  CONSTRAINT [FK_Taxonomy.Term.Word_System.WordCase] FOREIGN KEY([WordID])
REFERENCES [dbo].[System.WordCase] ([WordID])
GO
ALTER TABLE [dbo].[Taxonomy.Term.Word] CHECK CONSTRAINT [FK_Taxonomy.Term.Word_System.WordCase]
GO
ALTER TABLE [dbo].[Taxonomy.Term.Word]  WITH CHECK ADD  CONSTRAINT [FK_Taxonomy.Term.Word_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[Taxonomy.Term] ([TermID])
GO
ALTER TABLE [dbo].[Taxonomy.Term.Word] CHECK CONSTRAINT [FK_Taxonomy.Term.Word_Taxonomy.Term]
GO
ALTER TABLE [dbo].[User.Login]  WITH CHECK ADD  CONSTRAINT [FK_User.Login_User.Role] FOREIGN KEY([RoleID])
REFERENCES [dbo].[User.Role] ([RoleID])
GO
ALTER TABLE [dbo].[User.Login] CHECK CONSTRAINT [FK_User.Login_User.Role]
GO
ALTER TABLE [dbo].[User.Session]  WITH CHECK ADD  CONSTRAINT [FK_User.Session_User.Login] FOREIGN KEY([LoginID])
REFERENCES [dbo].[User.Login] ([LoginID])
GO
ALTER TABLE [dbo].[User.Session] CHECK CONSTRAINT [FK_User.Session_User.Login]
GO
ALTER TABLE [dbo].[Lead.Field.Value.Scalar]  WITH CHECK ADD  CONSTRAINT [CK_Lead.Field.Value.Scalar.FieldTypeID] CHECK  (([FieldTypeID]=(7) OR [FieldTypeID]=(6) OR [FieldTypeID]=(5) OR [FieldTypeID]=(1)))
GO
ALTER TABLE [dbo].[Lead.Field.Value.Scalar] CHECK CONSTRAINT [CK_Lead.Field.Value.Scalar.FieldTypeID]
GO
/****** Object:  StoredProcedure [dbo].[Admin.Business.Permission.SelectPending]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Admin.Business.Permission.SelectPending]
	-- Add the parameters for the stored procedure here
	@CountryID bigint = NULL,
	@RegionID bigint = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		B.BusinessID, B.BusinessName, B.BusinessRegistrationDate,
		COUNT (Distinct BLP.PermissionID) RequestsCount,
		Min(BLP.RequestedDateTime) as LatestRequestDateTime
	FROM 
		[dbo].[Business.Lead.Permission] BLP 
		INNER JOIN [dbo].[Business.Region.Country] B ON B.BusinessID = BLP.BusinessID
		--INNER JOIN [dbo].[Business] B ON B.BusinessID = BLP.BusinessID
		--LEFT OUTER JOIN [dbo].[Business.Lead.Permission.Term] BLPT ON BLPT.PermissionID = BLP.PermissionID
		--INNER JOIN [dbo].[Taxonomy.Term] TT ON TT.TermID = BLPT.TermID
	WHERE 
		BLP.ApprovedDateTime IS NULL 
		AND BLP.RequestedDateTime IS NOT NULL
		AND (@CountryID IS NULL OR @CountryID = B.CountryID)
		AND (@RegionID IS NULL OR @RegionID = B.RegionID)
	GROUP BY
		B.BusinessID, B.BusinessName, B.BusinessRegistrationDate
	ORDER BY Min(BLP.RequestedDateTime) DESC
END




















GO
/****** Object:  StoredProcedure [dbo].[Business.AddLogin]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.AddLogin]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@loginID bigint,
	@roleID int,
	@result bit OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	BEGIN TRY
		INSERT INTO [dbo].[Business.Login] (
			[BusinessID],
			[LoginID],
			[RoleID]
			)
		VALUES(
			@businessID,
			@loginID,
			@roleID
		)
		SET @result = 1;
		
	END TRY
	BEGIN CATCH
		-- Execute error retrieval routine.
		SET @result = NULL;
	END CATCH

	return @result

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Create]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Create]
	-- Add the parameters for the stored procedure here
	@name nvarchar(255),
	@webSite nvarchar(255),
	@countryID int,
	@businessID bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[Business](
		[Name],
		[WebSite],
		[CountryID],
		[RegistrationDate]
		)
	VALUES(
		@name,
		@webSite,
		@countryID,
		GETUTCDATE()
	)

	SET @businessID = SCOPE_IDENTITY()

	return @businessID
END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.Create]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.Create]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LegalYear smallint,
	@LegalMonth smallint,
	@CreatedDateTime datetime = null,
	@InvoiceID bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @CreatedDateTime = ISNULL(@CreatedDateTime, GETUTCDATE())

	DECLARE @LegalCountryID INT 
	SELECT @LegalCountryID = CountryID FROM [dbo].[Business] WHERE BusinessID = @BusinessID

	--@LegalNumber must grow since the beginning of each year CREATED
	DECLARE @LegalNumber INT = NULL
	SELECT @LegalNumber = MAX(ISNULL(LegalNumber,0)) + 1
	FROM [dbo].[Business.Invoice]
	WHERE [LegalCountryID] = @LegalCountryID
		AND YEAR(CreatedDateTime) = YEAR(@CreatedDateTime) 
	GROUP BY [LegalCountryID]
	SET @LegalNumber = ISNULL(@LegalNumber, 1);

	INSERT INTO [dbo].[Business.Invoice] 
	(
		[BusinessID],
		[CreatedDateTime],
		[LegalMonth],
		[LegalYear],
		[LegalNumber],
		[TotalSum],
		[LegalCountryID],
		[LegalAddress],
		[LegalName],
		[LegalCode1],
		[LegalCode2],
		[LegalBankAccount],
		[LegalBankCode1],
		[LegalBankCode2],
		[LegalBankName],
		[BillingCountryID],
		[BillingAddress],
		[BillingName],
		[BillingCode1],
		[BillingCode2]
	)
	SELECT 
		b.BusinessID,
		@CreatedDateTime as CreatedDateTime,
		@LegalMonth as LegalMonth, 
		@LegalYear as LegalYear,
		@LegalNumber as LegalNumber,
		0 as TotalSum,
		l.[LegalCountryID],
		l.[LegalAddress],
		l.[LegalName],
		l.[LegalCode1],
		l.[LegalCode2],
		l.[LegalBankAccount],
		l.[LegalBankCode1],
		l.[LegalBankCode2],
		l.[LegalBankName],
		b.[CountryID] as BillingCountryID,
		ISNULL(b.[BillingAddress], ''),
		ISNULL(b.[BillingName], ''),
		ISNULL(b.[BillingCode1], ''),
		ISNULL(b.[BillingCode2], '')
	FROM [dbo].[Business] b
	INNER JOIN [dbo].[LeadGen.Legal] l ON l.LegalCountryID = b.CountryID
	WHERE b.[BusinessID] = @BusinessID 

	SET @InvoiceID = SCOPE_IDENTITY()
END












GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.Delete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.Delete]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- IF the invoice is paid, then return 0 and do not delete the invoice
	IF EXISTS (
		SELECT 1 FROM [dbo].[Business.Invoice] WHERE InvoiceID = @InvoiceID AND (PublishedDatetime IS NOT NULL OR PaidDateTime IS NOT NULL)
	)
		RETURN 0

    DECLARE invoiceLine_cursor CURSOR FOR   
    SELECT [LineID] FROM [dbo].[Business.Invoice.Line]
	WHERE InvoiceID = @InvoiceID

	DECLARE @InvoiceLineID smallint

    OPEN invoiceLine_cursor  
    FETCH NEXT FROM invoiceLine_cursor INTO @InvoiceLineID  

    WHILE @@FETCH_STATUS = 0  
    BEGIN  

		EXEC [dbo].[Business.Invoice.Line.Delete] @InvoiceID, @InvoiceLineID

        FETCH NEXT FROM invoiceLine_cursor INTO @InvoiceLineID  
        END  
  
    CLOSE invoiceLine_cursor  
    DEALLOCATE invoiceLine_cursor 

	DELETE FROM [dbo].[Business.Invoice] WHERE InvoiceID = @InvoiceID

END
















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.Leads.SelectCompleted]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.Leads.SelectCompleted]
	-- Add the parameters for the stored procedure here
	@InoiceID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		LC.[LoginID], 
		LC.[BusinessID], 
		LC.[LeadID], 
		LC.[CompletedDateTime], 
		LC.[OrderSum], 
		LC.[SystemFeePercent], 
		LC.[LeadFee], 
		LC.[InvoiceID],
		LC.[InvoiceLineID]
	FROM [dbo].[Business.Lead.Completed] LC
	WHERE LC.InvoiceID = @InoiceID

END










GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.Line.Create]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.Line.Create]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@InvoiceLineDescription NVARCHAR(MAX),
	@UnitPrice decimal(19,4),
	@Quantity smallint,
	@Tax decimal(4,2),
	@InvoiceLineID smallint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @BusinessID BIGINT
	SELECT @BusinessID = BusinessID
	FROM [dbo].[Business.Invoice] WHERE InvoiceID = @InvoiceID

	--SELECT MAX @InvoiceLineID
	SELECT 
		@InvoiceLineID = MAX([LineID])
	FROM [dbo].[Business.Invoice.Line] 
	WHERE InvoiceID = @InvoiceID
	--Increase @InvoiceLineID for the new line
	SET @InvoiceLineID = ISNULL(@InvoiceLineID,0) + 1

	INSERT INTO [dbo].[Business.Invoice.Line] (
		[InvoiceID],
		[BusinessID],
		[LineID],
		[Description],
		[UnitPrice],
		[Quantity],
		[Tax]
	)
	VALUES
	(
		@InvoiceID,
		@BusinessID,
		@InvoiceLineID,
		ISNULL(@InvoiceLineDescription, ''),
		ISNULL(@UnitPrice,0),
		ISNULL(@Quantity,1),
		ISNULL(@Tax,0)
	)

	EXEC [dbo].[Business.Invoice.TotalSumUpdate] @InvoiceID
END
















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.Line.Custom.Create]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.Line.Custom.Create]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@InvoiceLineDescription NVARCHAR(MAX),
	@UnitPrice DECIMAL(19,4),
	@Quantity SMALLINT,
	@Tax DECIMAL(4,2),
	@InvoiceLineID smallint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @InvoiceLineID = NULL
	
	DECLARE @BusinessID BIGINT

	--@CompletedBeforeDate set to the next month because need to pay for servicies provided before or INCLUDING legal invoice date
	SELECT 
		@BusinessID = BusinessID
	FROM [dbo].[Business.Invoice] WHERE InvoiceID = @InvoiceID

	--SELECT MAX @InvoiceLineID
	SELECT 
		@InvoiceLineID = MAX(LineID)
	FROM [dbo].[Business.Invoice.Line] 
	WHERE InvoiceID = @InvoiceID
	--Increase @InvoiceLineNumber for the new line
	SET @InvoiceLineID = ISNULL(@InvoiceLineID,0) + 1

	INSERT INTO [dbo].[Business.Invoice.Line] (
		[InvoiceID],
		[BusinessID],
		[LineID],
		[Description],
		[UnitPrice],
		[Quantity],
		[Tax]
	)
	VALUES
	(
		@InvoiceID,
		@BusinessID,
		@InvoiceLineID,
		ISNULL(@InvoiceLineDescription,''),
		@UnitPrice,
		@Quantity,
		@Tax
	)

	EXEC [dbo].[Business.Invoice.TotalSumUpdate] @InvoiceID

END















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.Line.Delete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.Line.Delete]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@InvoiceLineID smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Release completed leads from invoice line
	UPDATE [dbo].[Business.Lead.Completed]
	SET [InvoiceID] = NULL,
		[InvoiceLineID] = NULL
	WHERE InvoiceID = @InvoiceID
		AND InvoiceLineID = @InvoiceLineID

	--Delete Line
	DELETE FROM [dbo].[Business.Invoice.Line]
	WHERE InvoiceID = @InvoiceID
		AND LineID = @InvoiceLineID

	DECLARE @Result BIT
	SET @Result = @@ROWCOUNT

	--Update Invoice Total Sum
	EXEC [dbo].[Business.Invoice.TotalSumUpdate] @InvoiceID

	Return @Result

END
















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.Line.Leads.Create]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.Line.Leads.Create]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@InvoiceLineDescription NVARCHAR(MAX),
	@InvoiceLineID smallint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @InvoiceLineID = NULL
	
	DECLARE @BusinessID BIGINT
	DECLARE @Year SMALLINT
	DECLARE @Month SMALLINT
	DECLARE @CompletedBeforeDate DATE

	--@CompletedBeforeDate set to the next month because need to pay for servicies till the END for the legal invoice date
	SELECT 
		@BusinessID = BusinessID,
		@CompletedBeforeDate = DateAdd(month,1,
			CAST(CAST(LegalYear AS varchar) + '-' + CAST(LegalMonth AS varchar) + '-01' AS DATETIME)
		)
	FROM [dbo].[Business.Invoice] WHERE InvoiceID = @InvoiceID

	DECLARE @LeadFeeTotalSum decimal (19,4)
	SET @LeadFeeTotalSum = [dbo].[Business.Lead.Completed.GetCompletedTotalFeeSumBeforeDateForInvoice](@BusinessID, @CompletedBeforeDate);
	
	--If @LeadFeeTotalSum <= 0 that means no leads need to be added to the invoice line, so return and do not perform further 
	IF (@LeadFeeTotalSum <= 0) 
		RETURN

	--SELECT MAX @InvoiceLineID
	SELECT 
		@InvoiceLineID = MAX([LineID])
	FROM [dbo].[Business.Invoice.Line] 
	WHERE InvoiceID = @InvoiceID
	--Increase @InvoiceLineID for the new line
	SET @InvoiceLineID = ISNULL(@InvoiceLineID,0) + 1

	INSERT INTO [dbo].[Business.Invoice.Line] (
		[InvoiceID],
		[BusinessID],
		[LineID],
		[Description],
		[UnitPrice],
		[Quantity],
		[Tax]
	)
	VALUES
	(
		@InvoiceID,
		@BusinessID,
		@InvoiceLineID,
		ISNULL(@InvoiceLineDescription,''),
		@LeadFeeTotalSum,
		1,
		0
	)

	--Mark completed leads with the created invoice line
	UPDATE [dbo].[Business.Lead.Completed]
	SET [InvoiceID] = @InvoiceID,
		[InvoiceLineID] = @InvoiceLineID
	WHERE BusinessID = @BusinessID
		AND CompletedDateTime < @CompletedBeforeDate
		AND InvoiceID IS NULL
		AND InvoiceLineID IS NULL


	EXEC [dbo].[Business.Invoice.TotalSumUpdate] @InvoiceID

END
















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.Line.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.Line.Select]
	-- Add the parameters for the stored procedure here
	@InoiceID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		l.[InvoiceID],
		l.[BusinessID],
		[LineID],
		[Description],
		[UnitPrice],
		[Quantity],
		[Tax],
		[LinePrice],
		[LineTotalPrice],
		CASE WHEN SUM(ISNULL(lc.InvoiceLineID,0)) > 0 THEN 1 ELSE 0 END AS isLeadLine
	FROM [dbo].[Business.Invoice.Line] l
	LEFT OUTER JOIN [dbo].[Business.Lead.Completed] lc ON lc.InvoiceID = l.InvoiceID AND lc.InvoiceLineID = l.LineID
	WHERE l.[InvoiceID] = @InoiceID
	GROUP BY
		l.[InvoiceID],
		l.[BusinessID],
		[LineID],
		[Description],
		[UnitPrice],
		[Quantity],
		[Tax],
		[LinePrice],
		[LineTotalPrice]
	ORDER BY [LineID]

END
















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.Line.Update]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.Line.Update]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@LineID smallint,
	@InvoiceLineDescription NVARCHAR(MAX),
	@UnitPrice decimal(19,4),
	@Quantity smallint,
	@Tax decimal(4,2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business.Invoice.Line] 
	SET [Description] = @InvoiceLineDescription,
		[UnitPrice] = @UnitPrice,
		[Quantity] = @Quantity,
		[Tax] = @Tax
	WHERE [InvoiceID] = @InvoiceID AND [LineID] = @LineID

	EXEC [dbo].[Business.Invoice.TotalSumUpdate] @InvoiceID
END
















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.Publish]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.Publish]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@PublishedDatetime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business.Invoice] 
	SET [PublishedDatetime] = ISNULL(@PublishedDatetime, GETUTCDATE())
	WHERE [InvoiceID] = @InvoiceID

END
















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.Select]
	-- Add the parameters for the stored procedure here
	@InoiceID bigint,
	@BusinessID bigint,
	@LegalYear smallint,
	@LegalNumber int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		[InvoiceID],
		[BusinessID],
		[CreatedDateTime],
		[LegalMonth],
		[LegalYear],
		[LegalNumber],
		[LegalFacturaNumber],
		[TotalSum],
		[LegalCountryID],
		[LegalAddress],
		[LegalName],
		[LegalCode1],
		[LegalCode2],
		[LegalBankName],
		[LegalBankCode1],
		[LegalBankCode2],
		[LegalBankAccount],
		[BillingCountryID],
		[BillingAddress],
		[BillingName],
		[BillingCode1],
		[BillingCode2],
		[PaidDateTime],
		[PublishedDateTime]
	FROM [dbo].[Business.Invoice] 
	WHERE (@InoiceID IS NULL OR [InvoiceID] = @InoiceID)
	AND (@BusinessID IS NULL OR [BusinessID] = @BusinessID)
	AND (@LegalYear IS NULL OR [LegalYear] = @LegalYear)
	AND (@LegalNumber IS NULL OR [LegalNumber] = @LegalNumber)

END
















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.SetPaid]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.SetPaid]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@PaidDatetime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @PaidDatetime = ISNULL(@PaidDatetime, GETUTCDATE())

	DECLARE @LegalCountryID INT 
	DECLARE @LegalYear INT 
	SELECT 
		@LegalCountryID = LegalCountryID, 
		@LegalYear = [LegalYear] 
	FROM 
		[dbo].[Business.Invoice] 
	WHERE 
		[InvoiceID] = @InvoiceID

	--@LegalFacturaNumber must grow since the beginning of year LEGAL
	DECLARE @LegalFacturaNumber INT = NULL
	SELECT @LegalFacturaNumber = MAX(ISNULL(LegalFacturaNumber,0)) + 1
	FROM [dbo].[Business.Invoice] 
	WHERE [LegalCountryID] = @LegalCountryID
		AND [LegalYear] = @LegalYear 
	GROUP BY [LegalCountryID]
	SET @LegalFacturaNumber = ISNULL(@LegalFacturaNumber, 1);

	UPDATE [dbo].[Business.Invoice] 
	SET [PaidDateTime] = @PaidDatetime,
		[LegalFacturaNumber] = ISNULL([LegalFacturaNumber], @LegalFacturaNumber) --Keep the esisting [LegalFacturaNumber] if exists 
	WHERE [InvoiceID] = @InvoiceID

END
















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.TotalSumUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.TotalSumUpdate]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Caluclate @TotalSum
	DECLARE @TotalSum DECIMAL (19,4)
	SELECT 
		@TotalSum = SUM(ISNULL([LineTotalPrice],0))
	FROM [dbo].[Business.Invoice.Line]
	WHERE [InvoiceID] = @InvoiceID
	GROUP BY [InvoiceID]
	SET @TotalSum = ISNULL(@TotalSum,0)
	
	--UPDATE Invoice TotalSum 
	UPDATE [dbo].[Business.Invoice]
	SET [TotalSum] = @TotalSum
	WHERE [InvoiceID] = @InvoiceID

END
















GO
/****** Object:  StoredProcedure [dbo].[Business.Invoice.UpdateBilling]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Invoice.UpdateBilling]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@LegalAddress nvarchar(255),
	@LegalName nvarchar(255),
	@LegalCode1 nvarchar(255),
	@LegalCode2 nvarchar(255),
	@LegalBankAccount nvarchar(255),
	@LegalBankName nvarchar(255),
	@LegalBankCode1 nvarchar(255),
	@LegalBankCode2 nvarchar(255),
	@BillingAddress nvarchar(255),
	@BillingName nvarchar(255),
	@BillingCode1 nvarchar(255),
	@BillingCode2 nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business.Invoice] 
	SET [LegalAddress] = @LegalAddress,
		[LegalName] = @LegalName,
		[LegalCode1] = @LegalCode1,
		[LegalCode2] = @LegalCode2,
		[LegalBankAccount] = @LegalBankAccount,
		[LegalBankCode1] = @LegalBankCode1,
		[LegalBankCode2] = @LegalBankCode2,
		[LegalBankName] = @LegalBankName,
		[BillingAddress] = @BillingAddress,
		[BillingName] = @BillingName,
		[BillingCode1] = @BillingCode1,
		[BillingCode2] = @BillingCode2
	WHERE [InvoiceID] = @InvoiceID

END
















GO
/****** Object:  StoredProcedure [dbo].[Business.Lead.Completed.SelectForNewInvoices]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Lead.Completed.SelectForNewInvoices]
	-- Add the parameters for the stored procedure here
	@CompletedBeforeDate DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
	[LoginID],
	[BusinessID],
	[LeadID],
	[CompletedDateTime],
	[OrderSum],
	[SystemFeePercent],
	[LeadFee]
	FROM [dbo].[Business.Lead.Completed]
	WHERE CompletedDateTime < @CompletedBeforeDate
		AND InvoiceID IS NULL
		AND InvoiceLineID IS NULL

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Lead.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Business.Lead.Select]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LeadID bigint = NULL,
	@Status nvarchar(50) = 'All',
	@DateFrom DateTime = NULL,
	@DateTo DateTime = NULL,
	@CompletedBeforeDate DATE = NULL,
	@Query NVARCHAR(50) = NULL,
	@Offset int = 0,
	@Fetch int = 2147483647,
	@TotalCount int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Leads TABLE (
		[LeadID] BIGINT,
		[DateTime] DATETIME
	)

	DECLARE @RequestedLeads TABLE (
		[LeadID] BIGINT,
		[IsApproved] BIT
	)

	INSERT INTO @RequestedLeads ([LeadID], [IsApproved])
	SELECT [LeadID], [IsApproved]
	FROM [dbo].[Business.Lead.SelectRequested](@BusinessID,@DateFrom, @DateTo, @LeadID)


	IF (@Status = 'All')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], L.[CreatedDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN @RequestedLeads R ON R.LeadID = L.LeadID
			LEFT OUTER JOIN [dbo].[Business.Lead.ContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
		WHERE (R.LeadID IS NOT NULL OR LCR.LeadID IS NOT NULL)
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'NewForBusiness')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], L.[CreatedDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN @RequestedLeads R ON R.LeadID = L.LeadID
			LEFT OUTER JOIN [dbo].[Business.Lead.NotInterested] LNR ON LNR.LeadID = L.LeadID AND LNR.BusinessID = @BusinessID
			LEFT OUTER JOIN [dbo].[Business.Lead.ContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
		WHERE R.LeadID IS NOT NULL AND LNR.NotInterestedDateTime IS NULL AND LCR.GetContactsDateTime IS NULL 
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'ContactReceived')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], LCR.[GetContactsDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN [dbo].[Business.Lead.ContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
			LEFT OUTER JOIN [dbo].[Business.Lead.Completed] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
		WHERE LCR.GetContactsDateTime IS NOT NULL AND BLC.CompletedDateTime IS NULL
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Important')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], BLI.[ImportantDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN [dbo].[Business.Lead.Important] BLI ON BLI.LeadID = L.LeadID AND BLI.BusinessID = @BusinessID
			LEFT OUTER JOIN [dbo].[Business.Lead.Completed] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
		WHERE BLI.ImportantDateTime IS NOT NULL AND BLC.CompletedDateTime IS NULL
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'NotInterested')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], LNR.[NotInterestedDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN [dbo].[Business.Lead.NotInterested] LNR ON LNR.LeadID = L.LeadID AND LNR.BusinessID = @BusinessID
		WHERE LNR.NotInterestedDateTime IS NOT NULL
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Completed')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], BLC.[CompletedDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN [dbo].[Business.Lead.Completed] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
		WHERE BLC.CompletedDateTime IS NOT NULL
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'NextInvoice')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], BLC.[CompletedDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN [dbo].[Business.Lead.Completed] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
		WHERE BLC.CompletedDateTime < @CompletedBeforeDate AND BLC.InvoiceID IS NULL AND BLC.InvoiceLineID IS NULL
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)

	IF (@Query IS NOT NULL)
	BEGIN

		DECLARE @ContainsQuery NVARCHAR(53) = '"'+ @Query + '*"'
		DECLARE @LikeQuery NVARCHAR(53) = '%'+ @Query + '%'
		--@QueryNumber would contain only numbers from the @Query
		DECLARE @QueryNumber NVARCHAR(50) = dbo.ExtractNumberFromString(@Query)
		IF(LEN(@QueryNumber) = 0 )
			SET @QueryNumber = NULL
		ELSE
			SET @QueryNumber = '%'+ @QueryNumber + '%'

		

		--Delete @LeadIDs items that were not found in search subquery
		DELETE li
		FROM @Leads li
		LEFT OUTER JOIN (
			SELECT
				t.LeadID
			FROM @Leads t
				INNER JOIN [dbo].[Lead] L ON L.LeadID = t.LeadID
				LEFT OUTER JOIN [dbo].[Business.Lead.ContactsRecieved] LCR ON LCR.LeadID = t.LeadID AND LCR.BusinessID = @BusinessID
				LEFT OUTER JOIN [dbo].[Lead.Field.Value.Scalar] s ON s.LeadID = t.LeadID
				LEFT OUTER JOIN [dbo].[Lead.Field.Structure] ls ON ls.FieldID = s.FieldID
				LEFT OUTER JOIN [dbo].[Lead.Field.Value.Taxonomy] lt ON lt.LeadID = t.LeadID
				LEFT OUTER JOIN [dbo].[Taxonomy.Term] tt ON tt.TermID = lt.TermID
				--LEFT OUTER JOIN CONTAINSTABLE([dbo].[Lead.Field.Value.Scalar], TextValue, @ContainsQuery ) ft ON ft.[Key] = s.ID
			WHERE 
				--((LCR.GetContactsDateTime IS NOT NULL OR ls.IsContact = 0) AND ft.[Key] IS NOT NULL) -OR
				((LCR.GetContactsDateTime IS NOT NULL OR ls.IsContact = 0) AND s.TextValue like @LikeQuery) OR
				(LCR.GetContactsDateTime IS NOT NULL AND L.Email like @LikeQuery) OR
				(tt.TermName like @Query) OR
				(@QueryNumber IS NOT NULL AND (
					(LCR.GetContactsDateTime IS NOT NULL AND L.NumberFromEmail like @QueryNumber)
					OR ((LCR.GetContactsDateTime IS NOT NULL OR ls.IsContact = 0) AND s.NubmerValueFromText like @QueryNumber)
					OR ((LCR.GetContactsDateTime IS NOT NULL OR ls.IsContact = 0) AND s.NumberValue like @QueryNumber)
					OR dbo.ExtractNumberFromString(tt.TermName) like @QueryNumber
					)
				)
			GROUP BY
				t.LeadID
		) s ON s.LeadID = li.[LeadID]
		WHERE s.LeadID IS NULL

	END

	-- Declare a variable that references the type.
	DECLARE @LeadIDs AS [dbo].[Sys.Bigint.TableType]; 

	-- Add data to the table variable. 
	INSERT INTO @LeadIDs (Item)
	SELECT t.[LeadID]
	FROM @Leads t
	ORDER BY t.[DateTime] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	--SET @TotalCount
	SELECT @TotalCount = COUNT(*) FROM @Leads

	
	SELECT 
		@BusinessID as BusinessID, L.[LeadID], L.[CreatedDateTime], L.[Email], L.[EmailConfirmedDateTime], L.[PublishedDateTime], L.AdminCanceledPublishDateTime, L.[UserCanceledDateTime], ISNULL(R.[IsApproved],0) as IsApproved,
		LCR.GetContactsDateTime, LNR.NotInterestedDateTime, BLI.ImportantDateTime, BLC.CompletedDateTime, BLC.OrderSum, BLC.SystemFeePercent, BLC.LeadFee
	FROM 
		@LeadIDs t 
		INNER JOIN [dbo].[Lead] L on L.LeadID = t.Item
		LEFT OUTER JOIN @RequestedLeads R ON R.LeadID = L.LeadID
		LEFT OUTER JOIN [dbo].[Business.Lead.NotInterested] LNR ON LNR.LeadID = L.LeadID AND LNR.BusinessID = @BusinessID
		LEFT OUTER JOIN [dbo].[Business.Lead.Important] BLI ON BLI.LeadID = L.LeadID AND BLI.BusinessID = @BusinessID
		LEFT OUTER JOIN [dbo].[Business.Lead.ContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
		LEFT OUTER JOIN [dbo].[Business.Lead.Completed] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID

END






GO
/****** Object:  StoredProcedure [dbo].[Business.Lead.SetCompleted]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Lead.SetCompleted]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint,
	@OrderSum decimal(19,4),
	@SystemFeePercent decimal(4,2),
	@CompletedDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [dbo].[Business.Lead.ContactsRecieved] WHERE BusinessID = @BusinessID AND LeadID = @LeadID)
		INSERT INTO [dbo].[Business.Lead.Completed]
			([LoginID], [BusinessID], [LeadID], [CompletedDateTime], [OrderSum], [SystemFeePercent])
		VALUES (@LoginID, @BusinessID, @LeadID, ISNULL(@CompletedDateTime,GETUTCDATE()), @OrderSum, @SystemFeePercent )


	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Lead.SetGetContact]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Lead.SetGetContact]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint,
	@GetContactDateTime DATETIME = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ISAproved bit = 1
	--SELECT @ISAproved = ISNULL(IsApproved,0) 
	--FROM [dbo].[Business.Lead.SelectRequested](@BusinessID, @LeadID) 

	IF (@ISAproved = 1)
		INSERT INTO [dbo].[Business.Lead.ContactsRecieved] 
			([LoginID], [BusinessID], [LeadID], [GetContactsDateTime])
		VALUES 
			(@LoginID, @BusinessID, @LeadID, ISNULL(@GetContactDateTime,GETUTCDATE()) )


	RETURN @ISAproved

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Lead.SetGetContact_PRODUCTION]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Lead.SetGetContact_PRODUCTION]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint,
	@GetContactDateTime DATETIME = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ISAproved bit = 0
	SELECT @ISAproved = ISNULL(IsApproved,0) 
	FROM [dbo].[Business.Lead.SelectRequested](@BusinessID, NULL, NULL, @LeadID) 

	IF (@ISAproved = 1)
		INSERT INTO [dbo].[Business.Lead.ContactsRecieved] 
			([LoginID], [BusinessID], [LeadID], [GetContactsDateTime])
		VALUES 
			(@LoginID, @BusinessID, @LeadID, ISNULL(@GetContactDateTime,GETUTCDATE()) )


	RETURN @ISAproved

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Lead.SetImportant]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Lead.SetImportant]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint,
	@ImportantDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[Business.Lead.Important]
		([LoginID], [BusinessID], [LeadID], [ImportantDateTime])
	VALUES (@LoginID, @BusinessID, @LeadID, ISNULL(@ImportantDateTime,GETUTCDATE()) )

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Lead.SetInterested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Lead.SetInterested]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[Business.Lead.NotInterested]
	WHERE [BusinessID] = @BusinessID AND [LeadID] = @LeadID

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Lead.SetNotified]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Lead.SetNotified]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LeadID bigint,
	@NotifiedDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM [dbo].[Business.Lead.Notified] WHERE BusinessID = @BusinessID AND LeadID = @LeadID)
		INSERT INTO [dbo].[Business.Lead.Notified]
			(BusinessID, LeadID, [NotifiedDateTime])
		VALUES (@BusinessID, @LeadID, ISNULL(@NotifiedDateTime,GETUTCDATE()))


	RETURN 1

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Lead.SetNotifiedPost]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Lead.SetNotifiedPost]
	-- Add the parameters for the stored procedure here
	@BusinessPostID bigint,
	@LeadID bigint,
	@NotifiedDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM [dbo].[Business.Lead.Notified.Post] WHERE BusinessPostID = @BusinessPostID AND LeadID = @LeadID)
		INSERT INTO [dbo].[Business.Lead.Notified.Post]
			(BusinessPostID, LeadID, [NotifiedDateTime])
		VALUES (@BusinessPostID, @LeadID, ISNULL(@NotifiedDateTime,GETUTCDATE()))


	RETURN 1

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Lead.SetNotImportant]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Lead.SetNotImportant]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[Business.Lead.Important]
	WHERE [BusinessID] = @BusinessID AND [LeadID] = @LeadID 

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Lead.SetNotInterested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Lead.SetNotInterested]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint,
	@NotInterestedDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[Business.Lead.NotInterested]
		([LoginID], [BusinessID], [LeadID], [NotInterestedDateTime])
	VALUES (@LoginID, @BusinessID, @LeadID, ISNULL(@NotInterestedDateTime,GETUTCDATE()) )

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Location.AdminApprovalSet]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Location.AdminApprovalSet]
	-- Add the parameters for the stored procedure here
	@LocationID bigint,
	@BusinessID bigint,
	@Approve bit,
	@LoginID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business.Location]
	   SET [IsAprovedByAdmin] = @Approve
	 WHERE LocationID = @LocationID AND BusinessID = @BusinessID

END












GO
/****** Object:  StoredProcedure [dbo].[Business.Location.Create]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Location.Create]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@Location geography,
	@LocationAddress nvarchar(max),
	@LocationName nvarchar(255),
	@LocationID bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[Business.Location]
           ([BusinessID]
           ,[Location]
           ,[IsAprovedByAdmin]
           ,[LocationAddress]
           ,[LocationName]
           ,[CreatedDateTime])
     VALUES
           (@BusinessID
           ,@Location
           ,0
           ,@LocationAddress
           ,@LocationName
           ,GETUTCDATE())


	SET @LocationID = SCOPE_IDENTITY()
END












GO
/****** Object:  StoredProcedure [dbo].[Business.Location.Delete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Location.Delete]
	-- Add the parameters for the stored procedure here
	@LocationID bigint,
	@BusinessID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[Business.Location]
	WHERE LocationID = @LocationID AND BusinessID = @BusinessID

END












GO
/****** Object:  StoredProcedure [dbo].[Business.Location.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Location.Select]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [LocationID]
		  ,[BusinessID]
		  ,[Location]
		  ,[IsAprovedByAdmin]
		  ,[LocationAddress]
		  ,[LocationName]
		  ,[CreatedDateTime]
	  FROM [dbo].[Business.Location]
	WHERE [BusinessID] = @BusinessID

END












GO
/****** Object:  StoredProcedure [dbo].[Business.Location.Update]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Location.Update]
	-- Add the parameters for the stored procedure here
	@LocationID bigint,
	@BusinessID bigint,
	@Location geography,
	@LocationAddress nvarchar(max),
	@LocationName nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	UPDATE [dbo].[Business.Location]
	   SET [Location] = @Location
		  ,[LocationAddress] = @LocationAddress
		  ,[LocationName] = @LocationName
	 WHERE LocationID = @LocationID AND BusinessID = @BusinessID

END












GO
/****** Object:  StoredProcedure [dbo].[Business.Notification.Email.Delete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Notification.Email.Delete]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@email nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[Business.Notification.Email] WHERE [BusinessID] = @businessID AND [Email] = @email)
	BEGIN
		DELETE FROM [dbo].[Business.Notification.Email] WHERE [BusinessID] = @businessID AND [Email] = @email
		RETURN 1
	END
	ELSE
		RETURN 0

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Notification.Email.Insert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Notification.Email.Insert]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@email nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @returnValue bit = 0

	IF NOT EXISTS (SELECT *	FROM [dbo].[Business.Notification.Email]
	WHERE [BusinessID] = @businessID AND [Email] = @email)
		BEGIN TRY
			INSERT INTO [dbo].[Business.Notification.Email] 
				([BusinessID], [Email])
			VALUES
				(@businessID, @email)
			SET @returnValue = 1
		END TRY
		BEGIN CATCH
		END CATCH

	return @returnValue

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Notification.Email.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Notification.Email.Select]
	-- Add the parameters for the stored procedure here
	@businessID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [Email] 
	FROM [Business.Notification.Email] 
	WHERE [BusinessID] = @businessID 

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Notification.Frequency.Update]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Notification.Frequency.Update]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@frequencyID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		BEGIN TRY

			UPDATE [dbo].[Business]
			SET [NotificationFrequencyID] = @frequencyID
			WHERE [BusinessID] = @businessID

			RETURN 1
		END TRY
		BEGIN CATCH
			RETURN 0
		END CATCH
END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Permission.Approve]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Permission.Approve]
	-- Add the parameters for the stored procedure here
	@LoginID bigint,
	@PermissionID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business.Lead.Permission] 
	SET ApprovedDateTime = GETUTCDATE()
	WHERE [PermissionID] = @PermissionID AND ApprovedDateTime IS NULL

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Permission.CancelApprove]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Permission.CancelApprove]
	-- Add the parameters for the stored procedure here
	@LoginID bigint,
	@PermissionID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business.Lead.Permission] 
	SET ApprovedDateTime = NULL
	WHERE [PermissionID] = @PermissionID AND ApprovedDateTime IS NOT NULL

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Permission.RemoveRequest]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Permission.RemoveRequest]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@PermissionID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business.Lead.Permission] 
	SET RequestedDateTime = NULL
	WHERE BusinessID = @BusinessID AND PermissionID = @PermissionID 

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Permission.Request]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Permission.Request]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@TermIDTable [dbo].[Sys.Bigint.TableType] READONLY,
	@PermissionID bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Try to find existing permission of this business with these termIDs 
	DECLARE @TermIDTableNumRows INT
	SELECT @TermIDTableNumRows = COUNT(*) FROM @TermIDTable

	SELECT @PermissionID = PT.PermissionID
	FROM [dbo].[Business.Lead.Permission] P
	LEFT OUTER JOIN [dbo].[Business.Lead.Permission.Term] PT ON PT.PermissionID = P.PermissionID
	LEFT OUTER JOIN @TermIDTable TT ON TT.Item = PT.TermID
	WHERE P.BusinessID = @BusinessID
	GROUP BY PT.PermissionID
	HAVING SUM (TT.Item) IS NOT NULL AND COUNT(TT.Item) = @TermIDTableNumRows

	IF @PermissionID IS NULL
	BEGIN
		-- If @PermissionID IS NULL, ALTER new Permission ID
		EXEC [dbo].[SysGetNewPrimaryKeyValueForTable] 'Business.Lead.Permission', @PermissionID OUTPUT

		INSERT INTO [dbo].[Business.Lead.Permission] 
			([PermissionID], [BusinessID], [RequestedDateTime])
		VALUES
			(@PermissionID, @BusinessID, GETUTCDATE())

		INSERT INTO [dbo].[Business.Lead.Permission.Term] 
			([PermissionID], [TermID])
		SELECT @PermissionID, Item FROM @TermIDTable	
	END
	ELSE
		-- Update Permission RequestedDateTime
		UPDATE [dbo].[Business.Lead.Permission] 
		SET [RequestedDateTime] = GETUTCDATE()
		WHERE PermissionID = @PermissionID AND BusinessID = @BusinessID AND [RequestedDateTime] IS NULL


END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Permission.Term.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Permission.Term.Select]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@RequestedOnly bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT P.[PermissionID], P.[RequestedDateTime], P.[ApprovedDateTime], 
	TT.TermID, TT.TermName, TT.TermURL, TT.TermParentID, TT.TermThumbnailURL
	FROM [dbo].[Business.Lead.Permission] P
	LEFT OUTER JOIN [dbo].[Business.Lead.Permission.Term] PT ON PT.PermissionID = P.PermissionID
	INNER JOIN [dbo].[Taxonomy.Term] TT ON TT.TermID = PT.TermID
	WHERE P.[BusinessID] = @BusinessID 
	AND (@RequestedOnly = 0 OR @RequestedOnly = 1 AND P.[RequestedDateTime] IS NOT NULL)
	

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Select]
	-- Add the parameters for the stored procedure here
	@businessID bigint = NULL,
	@registeredFrom datetime = NULL,
	@registeredTo datetime = NULL,
	@Query nvarchar(255) = null,
	@Offset int = 0,
	@Fetch int = 2147483647,
	@TotalCount int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Businesses TABLE (
		[BusinessID] BIGINT,
		[RegistrationDate] DATETIME
	)

	INSERT INTO @Businesses
	SELECT
		B.[BusinessID],
		B.[RegistrationDate]
	FROM
		[dbo].[Business] B 
	WHERE	
		(@businessID IS NULL OR B.BusinessID = @businessID)
		AND (@registeredFrom IS NULL OR B.[RegistrationDate] >= @registeredFrom)
		AND (@registeredTo IS NULL OR B.[RegistrationDate] < @registeredTo)

	IF (@Query IS NOT NULL)
	BEGIN

			--@QueryNumber would contain only numbers from the @Query
		DECLARE @QueryNumber NVARCHAR(50) = dbo.ExtractNumberFromString(@Query)
		IF(LEN(@QueryNumber) = 0 )
			SET @QueryNumber = NULL
		ELSE
			SET @QueryNumber = CONCAT('%',@QueryNumber,'%')

		SET @Query = CONCAT('%',@Query,'%')

		DELETE bi
		FROM @Businesses bi
		LEFT OUTER JOIN (
			SELECT
				B.[BusinessID]
			FROM
				[dbo].[Business] B 
				LEFT OUTER JOIN [dbo].[Business.Login] BL ON BL.BusinessID = B.BusinessID
				LEFT OUTER JOIN [dbo].[User.Login] UL ON UL.LoginID = BL.LoginID 
				LEFT OUTER JOIN @Businesses BI ON BI.BusinessID = B.BusinessID
			WHERE
				BI.BusinessID IS NULL
				OR B.[Name] like @Query
				OR B.[WebSite] like @Query
				OR B.[Address] like @Query
				OR B.[ContactName] like @Query
				OR B.[ContactEmail] like @Query
				OR dbo.ExtractNumberFromString(B.[ContactPhone]) like @QueryNumber
				OR B.[ContactSkype] like @Query
				OR B.[BillingName] like @Query
				OR B.[BillingCode1] like @Query
				OR B.[BillingCode2] like @Query
				OR B.[BillingAddress] like @Query
				OR UL.[Email] like @Query
			GROUP BY B.[BusinessID]
		) s ON s.[BusinessID] = bi.[BusinessID]
		WHERE s.[BusinessID] IS NULL

	END

	SELECT @TotalCount = COUNT(*) FROM @Businesses

	-- Declare a variable that references the type.
	DECLARE @BusinessIDs AS [dbo].[Sys.Bigint.TableType]; 

	-- Add data to the table variable. 
	INSERT INTO @BusinessIDs (Item)
	SELECT BusinessID
	FROM @Businesses
	ORDER BY [RegistrationDate] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	SELECT
		B.BusinessID,
		BL.LoginID as BusinessAdminLoginID,
		B.Name as BusinessName,
		B.RegistrationDate as BusinessRegistrationDate,
		B.WebSite,
		B.CountryID,
		T.TermID,
		T.TermName,
		T.TermParentID,
		T.TermURL,
		T.TaxonomyID,
		T.TermThumbnailURL,
		B.NotificationFrequencyID,
		B.[Address],
		B.ContactName,
		B.ContactEmail,
		B.ContactPhone,
		B.ContactSkype,
		B.[BillingName],
		B.[BillingCode1],
		B.[BillingCode2],
		B.[BillingAddress]
	FROM
		@BusinessIDs bi
		INNER JOIN [dbo].[Business] B ON B.BusinessID = bi.Item
		INNER JOIN [dbo].[Taxonomy.Term] T ON T.TermID = B.CountryID
		INNER JOIN [dbo].[Business.Login] BL ON BL.BusinessID = B.BusinessID AND BL.RoleID = 2
	ORDER BY B.[RegistrationDate] DESC

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Update.Basic]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Update.Basic]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@name nvarchar(255),
	@webSite nvarchar(255),
	@address nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business]
	SET
		[Name] = @name,
		[WebSite] = @webSite,
		[Address] = @address
	WHERE 
		[BusinessID] = @businessID

END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Update.Billing]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Update.Billing]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@name nvarchar(255),
	@code1 nvarchar(255),
	@code2 nvarchar(255),
	@address nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business]
	SET
		BillingName = @name,
		BillingCode1 = @code1,
		BillingCode2 = @code2,
		BillingAddress = @address
	WHERE 
		[BusinessID] = @businessID

	return 1
END




















GO
/****** Object:  StoredProcedure [dbo].[Business.Update.Contact]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Business.Update.Contact]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@name nvarchar(255),
	@email nvarchar(255),
	@phone nvarchar(255),
	@skype nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Business]
	SET
		ContactName = @name,
		ContactEmail = @email,
		ContactPhone = @phone,
		ContactSkype = @skype
	WHERE 
		[BusinessID] = @businessID

	return 1
END




















GO
/****** Object:  StoredProcedure [dbo].[CMS.Attachment.Delete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Attachment.Delete]
	-- Add the parameters for the stored procedure here
	@AttachmentID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @Result INT = 0;

    -- Insert statements for procedure here
	BEGIN TRAN T1  

		BEGIN TRY

				DELETE FROM [dbo].[CMS.Attachment.Term]
				WHERE [AttachmentID] = @AttachmentID

				DELETE FROM [dbo].[CMS.Attachment.Image]
				WHERE [AttachmentID] = @AttachmentID

				DELETE FROM [dbo].[CMS.Attachment]
				WHERE [AttachmentID] = @AttachmentID

				SET @Result = 1
		END TRY
		BEGIN CATCH
			--IF HAD ERRORS
			SET @Result = 0
		END CATCH 
	
	IF @Result = 1
		COMMIT TRANSACTION T1
	ELSE
		ROLLBACK TRANSACTION T1

	RETURN @Result

END


















GO
/****** Object:  StoredProcedure [dbo].[CMS.Attachment.GetByID]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Attachment.GetByID]
	-- Add the parameters for the stored procedure here
	@AttachmentID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
	A.AttachmentID,
	A.AuthorID,
	A.DateCreated,
	AT.AttachmentTypeID,
	AT.AttachmentTypeName,
	A.MIME,
	A.URL,
	A.Name,
	A.[Description],
	AIS.Code,
	AIS.CropMode,
	AIS.ImageSizeID,
	AIS.MaxHeight,
	AIS.MaxWidth,
	AI.URL as ImageURL,
	T.TaxonomyID,
	T.TaxonomyName,
	T.TaxonomyCode,
	T.IsTag,
	TT.TermID,
	TT.TermName,
	TT.TermURL,
	TT.TermParentID,
	TT.TermThumbnailURL
	FROM [dbo].[CMS.Attachment] A 
	INNER JOIN [dbo].[CMS.Attachment.Type] AT ON AT.AttachmentTypeID = A.TypeID 
	LEFT OUTER JOIN [dbo].[CMS.Attachment.Image] AI ON AI.AttachmentID = A.AttachmentID
	LEFT OUTER JOIN [dbo].[CMS.Attachment.Image.Size] AIS ON AIS.ImageSizeID = AI.ImageSizeOptionID
	LEFT OUTER JOIN [dbo].[CMS.Attachment.Term] ATT ON ATT.AttachmentID = A.AttachmentID
	LEFT OUTER JOIN [dbo].[Taxonomy.Term] TT ON TT.TermID = ATT.TermID
	LEFT OUTER JOIN [dbo].[Taxonomy] T ON T.TaxonomyID = TT.TaxonomyID
	WHERE 
		A.AttachmentID = @AttachmentID
END


















GO
/****** Object:  StoredProcedure [dbo].[CMS.Attachment.Image.Insert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Attachment.Image.Insert]
	-- Add the parameters for the stored procedure here
	@AttachmentID bigint,
	@ImageSizeOptionID int,
	@URL nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

	INSERT INTO [dbo].[CMS.Attachment.Image]
		([AttachmentID], [ImageSizeOptionID], [URL])
	VALUES
		(@AttachmentID, @ImageSizeOptionID, @URL)

END

















GO
/****** Object:  StoredProcedure [dbo].[CMS.Attachment.Image.Size.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Attachment.Image.Size.Select]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		[ImageSizeID], 
		[Code], 
		[MaxHeight], 
		[MaxWidth], 
		[CropMode]
	FROM [dbo].[CMS.Attachment.Image.Size] 
END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Attachment.ProcessNew]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Attachment.ProcessNew]
	-- Add the parameters for the stored procedure here
	@AuthorID bigint,
	@AttachmentTypeID int,
	@MIME nvarchar(50),
	@FileHash nvarchar(100),
	@FileSizeBytes int,
	@isNewAttachment BIT OUT,
	@AttachmentID bigint OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

	SELECT @AttachmentID = AttachmentID
	FROM [dbo].[CMS.Attachment] 
	WHERE [FileHash] = @FileHash 
	AND [FileSizeBytes] = @FileSizeBytes

	IF (@AttachmentID IS NULL)
		SET @isNewAttachment = 1
	ELSE
		SET @isNewAttachment = 0

	IF (@isNewAttachment = 1)
	BEGIN

		INSERT INTO [dbo].[CMS.Attachment]
			([AuthorID], [TypeID], [MIME], [URL], [DateCreated], [FileHash], [FileSizeBytes])
		VALUES 
			(@AuthorID, @AttachmentTypeID, @MIME, '', GETUTCDATE(), @FileHash, @FileSizeBytes) 

		SET @AttachmentID = SCOPE_IDENTITY() 

	END



END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Attachment.SetURL]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Attachment.SetURL]
	-- Add the parameters for the stored procedure here
	@AttachmentID bigint,
	@URL nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [dbo].[CMS.Attachment]
	SET [URL] = @URL
	WHERE [AttachmentID] = @AttachmentID

END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Attachment.Term.Add]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Attachment.Term.Add]
	@Attachment bigint,
	@TermID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		INSERT INTO [dbo].[CMS.Attachment.Term]
			([AttachmentID], [TermID])
		VALUES 
			(@Attachment, @TermID)
		RETURN 1
	END TRY
	BEGIN CATCH
		RETURN 0
	END CATCH 
END






















GO
/****** Object:  StoredProcedure [dbo].[CMS.Attachment.Term.RemoveAll]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Attachment.Term.RemoveAll]
	@AttachmentID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[CMS.Attachment.Term]
	WHERE [AttachmentID] = @AttachmentID
END






















GO
/****** Object:  StoredProcedure [dbo].[CMS.Attachment.Update]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Attachment.Update]
	-- Add the parameters for the stored procedure here
	@AttachmentID bigint,
	@Name nvarchar(100),
	@Description nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [dbo].[CMS.Attachment]
	SET [Name] = @Name,
	[Description] = @Description
	WHERE [AttachmentID] = @AttachmentID

END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Attachment.Link]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Attachment.Link]
	-- Add the parameters for the stored procedure here
	@PostID bigint,
	@AttachmentID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO [dbo].[CMS.Post.Attachment]
			([AttachmentID], [PostID], [LinkDate])
		VALUES (@AttachmentID, @PostID, GETUTCDATE()) 
		
		RETURN 1

	END TRY
	BEGIN CATCH

	  RETURN 0

	END CATCH 




END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Attachment.Unlink]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Attachment.Unlink]
	-- Add the parameters for the stored procedure here
	@PostID bigint,
	@AttachmentID bigint,
	@AttachmentUsed INT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

		UPDATE [dbo].[CMS.Post]
		SET [ThumbnailAttachmentID] = NULL
		WHERE [PostID] = @PostID AND [ThumbnailAttachmentID] = @AttachmentID

		DELETE FROM [dbo].[CMS.Post.Attachment]
		WHERE [AttachmentID] = @AttachmentID AND [PostID] = @PostID

		SELECT @AttachmentUsed = COUNT(*) 
		FROM [dbo].[CMS.Post.Attachment]
		WHERE [AttachmentID] = @AttachmentID

END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.CreateEmpty]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[CMS.Post.CreateEmpty]
	-- Add the parameters for the stored procedure here
	@AuthorID bigint,
	@PostTypeID int,
	@PostID BIGINT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


    -- Insert statements for procedure here
	INSERT INTO [dbo].[CMS.Post] 
		([TypeID], 
		[StatusID], 
		[AuthorID], 
		[DateCreated], 
		[seoPriority],
		[seoChangeFrequencyID],
		[Title], 
		[ContentMain], 
		[PostURL],
		[Order])
	VALUES (
		@PostTypeID, 
		10, 
		@AuthorID, 
		GETUTCDATE(), 
		0.5,
		4,
		'',
		'',
		'The string that nobody would ever enter',
		0) 


	SET @PostID = SCOPE_IDENTITY()

	-- Update [Title] to so it has the Post ID
	UPDATE [dbo].[CMS.Post] 
	SET [Title] = Concat('Title for Post #', @PostID)
	WHERE [PostID] = @PostID

	-- Update [PostURL] to make it unique
	Declare @URLEnding bigint = 1
	Declare @NewURL nvarchar(100)
	WHILE 1=1
	BEGIN
		IF @URLEnding = 1
			SET @NewURL = Concat('ulr-for-post-', @PostID)
		ELSE
			SET @NewURL = Concat('ulr-for-post-', @PostID, '-', @URLEnding)

		BEGIN TRY
			UPDATE [dbo].[CMS.Post] 
			SET [PostURL] = @NewURL
			WHERE [PostID] = @PostID
			BREAK
		END TRY
		BEGIN CATCH
			SET @URLEnding = @URLEnding + 1
		END CATCH 
	END


END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.CreateMultipleForTaxonomyType]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.CreateMultipleForTaxonomyType]
	-- Add the parameters for the stored procedure here
	@TaxonomyTypeID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- ALTER POSTS
	INSERT INTO [dbo].[CMS.Post] 
		([TypeID], 
		[StatusID], 
		[AuthorID], 
		[DatePublished], 
		[Title], 
		[ContentIntro], 
		[ContentPreview], 
		[ContentMain], 
		[PostURL],
		[PostForTermID],
		[PostForTaxonomyID])
	SELECT 
		ptt.PostTypeID,
		50,
		1,
		GETUTCDATE(),
		t.TermName, 
		null,
		null,
		'',
		t.TermURL, 
		t.TermID, 
		t.TaxonomyID
	FROM [dbo].[CMS.Post.Type.Taxonomy] ptt
	LEFT OUTER JOIN [dbo].[Taxonomy.Term] t on t.TaxonomyID = ptt.ForTaxonomyID
	LEFT OUTER JOIN [dbo].[CMS.Post] p on p.TypeID = ptt.PostTypeID AND p.PostForTermID = t.TermID
	WHERE ptt.PostTypeID = @TaxonomyTypeID AND p.PostID IS NULL AND t.TermID IS NOT NULL

	-- PUBLISH CREATED AND EXISTED POSTS
	UPDATE [dbo].[CMS.Post]
	SET [StatusID] = 50,
	[DatePublished] = GETUTCDATE()
	WHERE TypeID = @TaxonomyTypeID AND ([StatusID] <> 50 OR [DatePublished] IS NULL)

END


















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Delete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[CMS.Post.Delete]
	-- Add the parameters for the stored procedure here
	@PostID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION [PostDelete]

	BEGIN TRY

		DELETE FROM [dbo].[CMS.Post.Term]
		WHERE [PostID] = @PostID

		DELETE FROM [dbo].[CMS.Post.Attachment]
		WHERE [PostID] = @PostID

		DELETE FROM [dbo].[CMS.Post.Field.Value]
		WHERE [PostID] = @PostID

		DELETE FROM [dbo].[CMS.Post]
		WHERE [PostID] = @PostID

		COMMIT TRANSACTION [PostDelete]
		
		RETURN 1

	END TRY
	BEGIN CATCH

	  ROLLBACK TRANSACTION [PostDelete]
	  
	  RETURN 0

	END CATCH 

END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.DisableMultipleForTaxonomyType]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.DisableMultipleForTaxonomyType]
	-- Add the parameters for the stored procedure here
	@TaxonomyTypeID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- PUBLISH CREATED AND EXISTED POSTS
	UPDATE [dbo].[CMS.Post]
	SET [StatusID] = 10,
	[DatePublished] = NULL
	WHERE TypeID = @TaxonomyTypeID AND ([StatusID] = 50 OR [DatePublished] IS NOT NULL)

END


















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Field.Value.InsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Field.Value.InsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@PostID bigint,
	@FieldID int,
	@TextValue nvarchar(max) = NULL,
	@DatetimeValue datetime = NULL,
	@BoolValue bit = NULL,
	@NumberValue bigint = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[CMS.Post.Field.Value] WHERE PostID = @PostID AND FieldID = @FieldID)
	BEGIN

		UPDATE [dbo].[CMS.Post.Field.Value] 
		SET [TextValue] = @TextValue,
		[DatetimeValue] = @DatetimeValue,
		[BoolValue] = @BoolValue,
		[NumberValue] = @NumberValue
		WHERE [PostID] = @PostID AND [FieldID] = @FieldID
		RETURN @@ROWCOUNT

	END
	ELSE 
	BEGIN

		DECLARE @FieldTypeID int = NULL
		SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[CMS.Post.Type.Field.Structure] WHERE [FieldID] = @FieldID

		DECLARE @PostTypeID int = NULL
		SELECT @PostTypeID = [TypeID] FROM [dbo].[CMS.Post] WHERE [PostID] = @PostID

		BEGIN TRY
			INSERT INTO [dbo].[CMS.Post.Field.Value] 
				(PostID, PostTypeID, [FieldID], [TextValue], [DatetimeValue], [BoolValue], [NumberValue])
			VALUES
				(@PostID, @PostTypeID, @FieldID, @TextValue, @DatetimeValue, @BoolValue, @NumberValue)
			RETURN 1
		END TRY
		BEGIN CATCH
			RETURN 0
		END CATCH

	END




END




















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Field.Value.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Field.Value.Select]
	-- Add the parameters for the stored procedure here
	@PostID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		FS.FieldID, 
		FS.FieldCode, 
		FS.FieldLabelText, 
		FT.FieldTypeID, 
		FT.FieldTypeName, 
		FV.TextValue, 
		FV.DatetimeValue, 
		FV.BoolValue, 
		FV.NumberValue
	FROM [dbo].[CMS.Post] P 
	INNER JOIN [dbo].[CMS.Post.Type.Field.Structure] FS ON FS.PostTypeID = P.TypeID
	INNER JOIN [dbo].[CMS.Field.Type] FT ON FT.FieldTypeID = FS.FieldTypeID
	LEFT OUTER JOIN [dbo].[CMS.Post.Field.Value] FV ON FV.PostID = P.PostID AND FV.FieldID = FS.FieldID
	WHERE P.PostID = @PostID
	ORDER BY FV.FieldID

END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.GetAttachments]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.GetAttachments]
	-- Add the parameters for the stored procedure here
	@PostID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
	A.AttachmentID,
	A.AuthorID,
	A.DateCreated,
	AT.AttachmentTypeID,
	AT.AttachmentTypeName,
	A.MIME,
	A.URL,
	A.Name,
	A.[Description],
	AIS.Code,
	AIS.CropMode,
	AIS.ImageSizeID,
	AIS.MaxHeight,
	AIS.MaxWidth,
	AI.URL as ImageURL,
	T.TaxonomyID,
	T.TaxonomyName,
	T.TaxonomyCode,
	T.IsTag,
	TT.TermID,
	TT.TermName,
	TT.TermURL,
	TT.TermParentID,
	TT.TermThumbnailURL
	FROM [dbo].[CMS.Post.Attachment] PA
	INNER JOIN [dbo].[CMS.Attachment] A ON A.[AttachmentID] = PA.[AttachmentID]
	INNER JOIN [dbo].[CMS.Attachment.Type] AT ON AT.AttachmentTypeID = A.TypeID 
	LEFT OUTER JOIN [dbo].[CMS.Attachment.Image] AI ON AI.AttachmentID = A.AttachmentID
	LEFT OUTER JOIN [dbo].[CMS.Attachment.Image.Size] AIS ON AIS.ImageSizeID = AI.ImageSizeOptionID
	LEFT OUTER JOIN [dbo].[CMS.Attachment.Term] ATT ON ATT.AttachmentID = A.AttachmentID
	LEFT OUTER JOIN [dbo].[Taxonomy.Term] TT ON TT.TermID = ATT.TermID
	LEFT OUTER JOIN [dbo].[Taxonomy] T ON T.TaxonomyID = TT.TaxonomyID
	WHERE 
		PA.[PostID] = @PostID
	ORDER BY A.DateCreated Desc
END


















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.IfPostExistInOffsprings]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.IfPostExistInOffsprings] 
	-- Add the parameters for the stored procedure here
	@PostParentID INT,
	@TestPostID INT,
	@isExist BIT = 0 OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Find Term Children
	DECLARE @ChildrenPostsCursor CURSOR
	DECLARE @ChildID BIGINT
	
	
	SET @ChildrenPostsCursor = CURSOR FOR
		SELECT [PostID]
		FROM [dbo].[CMS.Post]
		WHERE [PostParentID] = @PostParentID
	
	OPEN @ChildrenPostsCursor;
	FETCH NEXT FROM @ChildrenPostsCursor INTO @ChildID

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF @ChildID = @TestPostID BEGIN
			SET @isExist = 1
			RETURN @isExist
		END
		ELSE BEGIN
			--DECLARE @RecursiveResult BIT = 0
			EXEC [dbo].[CMS.Post.IfPostExistInOffsprings] @ChildID, @TestPostID, @isExist OUT
			--SET @isExist = @RecursiveResult
			
		END

		FETCH NEXT FROM @ChildrenPostsCursor INTO @ChildID
	END
	CLOSE @ChildrenPostsCursor
	DEALLOCATE @ChildrenPostsCursor

	RETURN @isExist

END






















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.IsUniqueURL]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.IsUniqueURL]
	-- Add the parameters for the stored procedure here
	@PostURL nvarchar(50),
	@PostTypeID int,
	@PostParentID bigint,
	@ExcludePostID bigint = NULL,
	@Result bit OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @Result = CASE WHEN COUNT(*) = 0 Then 1 Else 0 End
	FROM [dbo].[CMS.Post] P
	WHERE 
		P.[PostURL] = @PostURL 
		AND P.[TypeID] = @PostTypeID
		AND (ISNULL(P.[PostParentID], 0) = ISNULL(@PostParentID, 0))
		AND (@ExcludePostID IS NULL OR P.PostID != @ExcludePostID)
END






















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Select]
	-- Add the parameters for the stored procedure here
	@PostID bigint = null,
	@PostURL nvarchar(100) = NULL,
	@PostParentID bigint = 0,
	@TypeID int = null,
	@TaxonomyID int = null,
	@TermID bigint = null,
	@ForTypeID int = null,
	@ForTermID bigint = null,
	@StatusID int = NULL,
	@ExcludeStartPage bit = 0,
	@Query NVARCHAR(50) = NULL,
	@Offset int = 0,
	@Fetch int = 2147483647,
	@TotalCount int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Posts TABLE (
		[PostID] BIGINT,
		[Order] int,
		[DatePublished] DATETIME
	)

	INSERT INTO @Posts
		SELECT 
			P.[PostID], P.[Order], P.[DatePublished]
		FROM 
			[dbo].[CMS.Post] P 
			INNER JOIN [dbo].[CMS.Post.Status] PS ON PS.[StatusID] = P.[StatusID] 
			INNER JOIN [dbo].[CMS.Post.Type] PT ON PT.[TypeID] = P.[TypeID] 
			LEFT OUTER JOIN [dbo].[CMS.Post.Term] TE ON TE.[PostID] = P.[PostID] 
			LEFT OUTER JOIN [dbo].[Taxonomy.Term] TT ON TT.[TermID] = TE.[TermID] 
		WHERE
			(@PostID IS NULL OR P.[PostID] = @PostID) 
			AND (@PostURL IS NULL OR P.[PostURL] = @PostURL)
			AND (@TypeID IS NULL OR PT.[TypeID] = @TypeID) 
			AND (@StatusID IS NULL OR P.StatusID = @StatusID)
			AND (@PostParentID = 0 OR ISNULL(P.[PostParentID], 0) = ISNULL(@PostParentID, 0))
			AND (@TaxonomyID IS NULL OR TT.[TaxonomyID] = @TaxonomyID)
			AND (@TermID IS NULL OR TT.[TermID] = @TermID)
			AND (@ForTypeID IS NULL OR PT.[ForPostTypeID] = @ForTypeID)
			AND (@ForTermID IS NULL OR P.[PostForTermID] = @ForTermID)
			AND (@ExcludeStartPage = 0 OR P.[PostURL] != '')
		GROUP BY 
			P.[PostID], P.[Order], P.[DatePublished]
	

	IF (@Query IS NOT NULL)
	BEGIN

		DECLARE @LikeQuery AS nvarchar(255) = CONCAT('%',@Query,'%')

		DELETE t
		FROM @Posts t
		LEFT OUTER JOIN (
			SELECT 
				P.[PostID]
			FROM 
				[dbo].[CMS.Post] P 
				INNER JOIN @Posts t2 ON t2.PostID = P.[PostID]
			WHERE 
				P.Title like @LikeQuery OR P.PostURL like @LikeQuery
		) s ON s.[PostID] = t.[PostID]
		WHERE s.[PostID] IS NULL

	END

	--SET @TotalCount
	SELECT @TotalCount = COUNT(*) FROM @Posts

	-- Declare a variable that references the type.
	DECLARE @PostIDs AS [dbo].[Sys.Bigint.TableType]; 

	-- Add data to the table variable. 
	INSERT INTO @PostIDs (Item)
	SELECT [PostID]
	FROM @Posts t
	ORDER BY [Order] DESC, [DatePublished] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[CMS.Post.SelectByIDs] (@PostIDs) 
	ORDER BY [Order] DESC, [DatePublished] DESC

END









GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.SelectByScalarField]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.SelectByScalarField]
	-- Add the parameters for the stored procedure here
      @FieldCode nvarchar(50),
	  @TextValue nvarchar(max),
      @DatetimeValue datetime,
      @BoolValue bit,
      @NumberValue bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Declare a variable that references the type.
	DECLARE @PostIDs AS [dbo].[Sys.Bigint.TableType];  
  
	-- Add data to the table variable. 
	INSERT INTO @PostIDs (Item)
	SELECT 
		FL.[PostID]
	FROM [dbo].[CMS.Post.Field.Value] FL
		INNER JOIN [dbo].[CMS.Post.Type.Field.Structure] FS ON FS.FieldID = FL.FieldID AND FS.FieldCode = @FieldCode
	WHERE (@TextValue IS NULL OR @TextValue = FL.TextValue) 
		AND (@DatetimeValue IS NULL OR @DatetimeValue = FL.DatetimeValue) 
		AND (@BoolValue IS NULL OR @BoolValue = FL.BoolValue) 
		AND (@NumberValue IS NULL OR @NumberValue = FL.NumberValue) 
	GROUP BY
		FL.[PostID]

	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[CMS.Post.SelectByIDs] (@PostIDs)

END








GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.SelectByUrls]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.SelectByUrls]
	-- Add the parameters for the stored procedure here
	@PostURLs nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Declare a variable that references the type.
	DECLARE @PostIDs AS [dbo].[Sys.Bigint.TableType]; 

	DECLARE @PostURL nvarchar(MAX)
    DECLARE url_cursor CURSOR FOR   
    SELECT val  
    FROM [dbo].[Sys.StringSplit] (@PostURLs, ',')
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
		FROM [dbo].[Sys.StringSplit] (@PostURL, '/')
		OPEN urlpart_cursor  
		FETCH NEXT FROM urlpart_cursor INTO @PostURLPart  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  

			IF (@isFirstUrlPart = 1)
			BEGIN

				SELECT TOP 1 @PostTypeID = [TypeID] FROM [dbo].[CMS.Post.Type] WHERE TypeURL = @PostURLPart
				IF (ISNULL(@PostTypeID,0) = 0)
				BEGIN
					SELECT TOP 1 @PostTypeID = [TypeID] FROM [dbo].[CMS.Post.Type] WHERE TypeURL = ''
					SELECT TOP 1 
						@PostID = ISNULL([PostID],0), 
						@Order = [Order], 
						@DatePublished = ISNULL([DatePublished],[DateCreated]) 
					FROM [dbo].[CMS.Post] 
					WHERE TypeID = @PostTypeID AND PostURL = @PostURLPart
				END
				ELSE
					SELECT TOP 1 --Start Post for the PostType
						@PostID = ISNULL([PostID],0), 
						@Order = [Order], 
						@DatePublished = ISNULL([DatePublished],[DateCreated]) 
					FROM [dbo].[CMS.Post] 
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
					FROM [dbo].[CMS.Post] 
					WHERE @PostTypeID = @PostTypeID AND PostURL = @PostURLPart

				END
				ELSE --Any Other Post URL (childeren of the previous PostURL)
					SELECT TOP 1
						@PostID = ISNULL([PostID],0), 
						@Order = [Order], 
						@DatePublished = ISNULL([DatePublished],[DateCreated]) 
					FROM [dbo].[CMS.Post] 
					WHERE @PostTypeID = @PostTypeID AND PostParentID = @PostID

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
	SELECT * FROM [dbo].[CMS.Post.SelectByIDs] (@PostIDs) 

END




GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Status.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Status.Select]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		[StatusID], 
		[StatusName] 
	FROM 
		[dbo].[CMS.Post.Status]
	ORDER BY [StatusID] ASC
END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Term.Add]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Term.Add]
	@PostID bigint,
	@TermID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	DECLARE @PostTypeID INT
	SELECT @PostTypeID = [TypeID] FROM [dbo].[CMS.Post] WHERE [PostID] = @PostID

	DECLARE @TaxonomyID INT
	SELECT @TaxonomyID = [TaxonomyID] FROM [dbo].[Taxonomy.Term] WHERE [TermID] = @TermID

	BEGIN TRY
		INSERT INTO [dbo].[CMS.Post.Term] 
			([PostID], [PostTypeID], [TermID], [TaxonomyID])
		VALUES 
			(@PostID, @PostTypeID, @TermID, @TaxonomyID)
		RETURN 1
	END TRY
	BEGIN CATCH
		RETURN 0
	END CATCH 
END






















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Term.RemoveAll]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Term.RemoveAll]
	@PostID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[CMS.Post.Term] 
	WHERE [PostID] = @PostID
END






















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Type.Attachment.Taxonomy.AddOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Type.Attachment.Taxonomy.AddOrUpdate]
	-- Add the parameters for the stored procedure here
	@PostTypeID int,
	@AttachmentTaxonomyID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT * FROM [dbo].[CMS.Post.Type.Attachment.Taxonomy] WHERE [PostTypeID] = @PostTypeID AND [AttachmentTaxonomyID] = @AttachmentTaxonomyID)
		BEGIN

			INSERT INTO [dbo].[CMS.Post.Type.Attachment.Taxonomy]
				([PostTypeID], [AttachmentTaxonomyID], [IsEnabled])
			VALUES
				(@PostTypeID, @AttachmentTaxonomyID, 1)

		END
	ELSE
	BEGIN

		UPDATE [dbo].[CMS.Post.Type.Attachment.Taxonomy]
		SET IsEnabled = 1
		WHERE [PostTypeID] = @PostTypeID
		AND [AttachmentTaxonomyID] = @AttachmentTaxonomyID

	END

END
















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Type.Attachment.Taxonomy.Disable]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Type.Attachment.Taxonomy.Disable]
	-- Add the parameters for the stored procedure here
	@PostTypeID int,
	@AttachmentTaxonomyID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[CMS.Post.Type.Attachment.Taxonomy]
	SET IsEnabled = 0
	WHERE [PostTypeID] = @PostTypeID
	AND [AttachmentTaxonomyID] = @AttachmentTaxonomyID

END
















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Type.Attachment.Taxonomy.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Type.Attachment.Taxonomy.Select]
	-- Add the parameters for the stored procedure here
	@PostTypeID int,
	@EnabledOnly BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		T.TaxonomyID,
		TaxonomyCode,
		TaxonomyName,
		IsTag,
		ISNULL(IsEnabled, 0) as IsEnabled,
		ISNULL(PTAT.PostTypeID, @PostTypeID) as PostTypeID
		
	FROM [dbo].[Taxonomy] T
	LEFT OUTER JOIN [dbo].[CMS.Post.Type.Attachment.Taxonomy] PTAT ON PTAT.AttachmentTaxonomyID = T.TaxonomyID AND PTAT.PostTypeID = @PostTypeID
	WHERE @EnabledOnly = 0 OR PTAT.IsEnabled = @EnabledOnly
END

















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Type.Insert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Type.Insert] 
	-- Add the parameters for the stored procedure here
	@typeCode nvarchar(50),
	@typeName nvarchar(50),
	@typeURL nvarchar(50),
	@isBrowsable bit,
	@seoTitle nvarchar(255),
	@seoMetaDescription nvarchar(500),
	@seoMetaKeywords nvarchar(500),
	@seoChangeFrequencyID int,
	@seoPriority decimal(2,1),
	@postSeoTitle nvarchar(255),
	@postSeoMetaDescription nvarchar(500),
	@postSeoMetaKeywords nvarchar(500),
	@postSeoChangeFrequencyID int,
	@postSeoPriority decimal(2,1),
	@HasContentIntro bit,
	@HasContentEnding bit,
	@typeID int OUTPUT,
	@errorText nvarchar(100) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @InsertError INT = 0

	--Check if @TermName already exist
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[CMS.Post.Type]
		WHERE [TypeName] = @typeName 
	) > 0
	BEGIN
		Set @InsertError = 1
		SET @errorText = 'FAILED Name'
	END

	--Check if @TermURL already exist in the current @TaxonomyID
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[CMS.Post.Type]
		WHERE TypeURL = @typeURL 
	) > 0
	BEGIN
		Set @InsertError = 1
		SET @errorText = 'FAILED URL'
	END

	If @InsertError = 0
	BEGIN TRY

		INSERT INTO [dbo].[CMS.Post.Type] (
			[TypeCode],
			[TypeName], 
			[TypeURL], 
			[IsBrowsable],
			[SeoTitle], 
			[SeoMetaDescription], 
			[SeoMetaKeywords], 
			[SeoPriority], 
			[SeoChangeFrequencyID], 
			[PostSeoTitle], 
			[PostSeoMetaDescription], 
			[PostSeoMetaKeywords], 
			[PostSeoPriority], 
			[PostSeoChangeFrequencyID],
			[HasContentIntro],
			[HasContentEnding])
		VALUES (
			@typeCode,
			@typeName,
			@typeURL,
			@isBrowsable,
			@seoTitle,
			@seoMetaDescription,
			@seoMetaKeywords,
			@seoPriority,
			@seoChangeFrequencyID,
			@postSeoTitle,
			@postSeoMetaDescription,
			@postSeoMetaKeywords,
			@postSeoPriority,
			@postSeoChangeFrequencyID,
			@HasContentIntro,
			@HasContentEnding
		) 

		SET @typeID = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @errorText = 'FAILED'
	END CATCH 





END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Type.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Type.Select]
	-- Add the parameters for the stored procedure here
	@TypeID int = NULL,
	@TypeCode nvarchar(50) = NULL,
	@TypeURL nvarchar(50) = NULL,
	@TypeName nvarchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		[TypeID], 
		[TypeCode],
		[TypeURL],
		[TypeName],
		[IsBrowsable],
		[seoTitle],
		[seoMetaDescription],
		[seoMetaKeywords],
		[seoPriority],
		[seoChangeFrequencyID],
		[postSeoTitle],
		[postSeoMetaDescription],
		[postSeoMetaKeywords],
		[postSeoPriority],
		[postSeoChangeFrequencyID],
		[HasContentIntro],
		[HasContentEnding],
		[ForTaxonomyID],
		[ForPostTypeID]
	FROM [dbo].[CMS.Post.Type]
	WHERE
			(@TypeID IS NULL OR [TypeID] = @TypeID) 
		AND (@TypeCode IS NULL OR [TypeCode] = @TypeCode) 
		AND (@TypeName IS NULL OR [TypeName] = @TypeName) 
		AND (@TypeURL IS NULL OR [TypeURL] = @TypeURL) 
END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Type.Select_SiteMapData]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Type.Select_SiteMapData]
	-- Add the parameters for the stored procedure here
	@PageSize int = 100
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT 
		t.TypeID, 
		t.TypeCode, 
		t.TypeURL, 
		ROW_NUMBER() OVER(PARTITION BY t.TypeID ORDER BY MAX([Order]) DESC, MAX([DatePublished]) DESC) as PageNumber,
		MAX(t.DateLastModified) as DateLastModified, 
		COUNT(t.PostNumber) as PostCount ,
		AVG(t.PostNumber)
	FROM (
		SELECT 
			--Need to use the same ordering in PostNumber as in [dbo].[CMS.Post.Select] procedure
			ROW_NUMBER() OVER(PARTITION BY pt.[TypeID] ORDER BY [Order] DESC, [DatePublished] DESC) AS PostNumber
			,pt.[TypeID]
			,pt.[TypeURL]
			,pt.[TypeCode]
			,p.[PostID]
			,p.[Order]
			,p.[DatePublished]
			,p.[DateLastModified]
		FROM [dbo].[CMS.Post.Type] pt
		INNER JOIN [dbo].[CMS.Post] p ON p.TypeID = pt.TypeID
		WHERE 
		pt.IsBrowsable = 1 
		AND p.DatePublished IS NOT NULL
	) t
	GROUP BY t.TypeID, t.TypeURL, t.TypeCode, (t.PostNumber-1)/@PageSize
	ORDER BY t.TypeID DESC--, [DatePublished] DESC
END






GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Type.Taxonomy.AddOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Type.Taxonomy.AddOrUpdate]
	-- Add the parameters for the stored procedure here
	@ForPostTypeID int,
	@ForTaxonomyID int,
	@SeoTitle nvarchar(255),
	@SeoMetaDescription nvarchar(500),
	@SeoMetaKeywords nvarchar(500),
	@SeoChangeFrequencyID int = 4,
	@SeoPriority decimal(2,1) = 0.5,
	@URL nvarchar(100),
	@Result BIT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @TaxonomyPostTypeID INT = NULL

	IF NOT EXISTS (SELECT * FROM [dbo].[CMS.Post.Type.Taxonomy] WHERE [ForPostTypeID] = @ForPostTypeID AND [ForTaxonomyID] = @ForTaxonomyID)
	BEGIN
		
		BEGIN TRAN T1  
			BEGIN TRY
			
				

				--Add new post type for the taxonomy
				INSERT INTO [dbo].[CMS.Post.Type] 
				([TypeName], [TypeURL], [SeoTitle], [SeoMetaDescription], [SeoMetaKeywords], [SeoPriority], [SeoChangeFrequencyID])
				VALUES 
				(Concat('PostTypeFor Tax:',@ForTaxonomyID,' PostType:',@ForPostTypeID), @URL, @SeoTitle, @SeoMetaDescription, @SeoMetaKeywords, @SeoPriority, @SeoChangeFrequencyID) 

				SELECT @TaxonomyPostTypeID = @@IDENTITY;  

				--Add new mapping between simple post type and taxonomy post type
				INSERT INTO [dbo].[CMS.Post.Type.Taxonomy]
				([PostTypeID], [ForPostTypeID], [ForTaxonomyID], [IsEnabled])
				VALUES
				(@TaxonomyPostTypeID, @ForPostTypeID, @ForTaxonomyID, 1)

				--Update [ForTaxonomyID] [ForPostTypeID]. Can do that only now because there is a constraint [dbo].[CMS.Post.Type.Taxonomy] table
				UPDATE [dbo].[CMS.Post.Type] 
				SET [ForTaxonomyID] = @ForTaxonomyID,
				[ForPostTypeID] = @ForPostTypeID
				WHERE [TypeID] = @TaxonomyPostTypeID

				SET @Result = 1

			END TRY		
			BEGIN CATCH
				--IF HAD ERRORS
				ROLLBACK TRAN T1
				SET @Result = 0
			END CATCH 
		
		COMMIT TRAN T1

	END

	ELSE
	BEGIN

		SELECT @TaxonomyPostTypeID = [PostTypeID]
		FROM [dbo].[CMS.Post.Type.Taxonomy]
		WHERE [ForTaxonomyID] = @ForTaxonomyID AND [ForPostTypeID] = @ForPostTypeID


		UPDATE [dbo].[CMS.Post.Type.Taxonomy] 
		SET [IsEnabled] = 1
		WHERE [ForTaxonomyID] = @ForTaxonomyID 
		AND [ForPostTypeID] = @ForPostTypeID	

		UPDATE [dbo].[CMS.Post.Type] 
		SET [TypeName] = @URL,
		[TypeURL] = @URL,
		[SeoTitle] = @SeoTitle,
		[SeoMetaDescription] = @SeoMetaDescription,
		[SeoMetaKeywords] = @SeoMetaKeywords,
		[SeoPriority] = @SeoPriority,
		[SeoChangeFrequencyID] = @SeoChangeFrequencyID
		WHERE [ForTaxonomyID] = @ForTaxonomyID AND [ForPostTypeID] = @ForPostTypeID

		SET @Result = @@ROWCOUNT

	END



	IF @Result = 1 AND @TaxonomyPostTypeID IS NOT NULL
	BEGIN
		EXEC [dbo].[CMS.Post.CreateMultipleForTaxonomyType] @TaxonomyPostTypeID
	END



END


















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Type.Taxonomy.Disable]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Type.Taxonomy.Disable]
	-- Add the parameters for the stored procedure here
	@ForPostTypeID int,
	@ForTaxonomyID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TaxonomyPostTypeID INT = NULL

	UPDATE [dbo].[CMS.Post.Type.Taxonomy] 
	SET [IsEnabled] = 0
	WHERE [ForTaxonomyID] = @ForTaxonomyID 
	AND [ForPostTypeID] = @ForPostTypeID	

	SELECT @TaxonomyPostTypeID = [PostTypeID]
	FROM [dbo].[CMS.Post.Type.Taxonomy] 
	WHERE [ForTaxonomyID] = @ForTaxonomyID 
	AND [ForPostTypeID] = @ForPostTypeID 
	AND [IsEnabled] = 0

	EXEC [dbo].[CMS.Post.DisableMultipleForTaxonomyType] @TaxonomyPostTypeID

END
















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Type.Taxonomy.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Type.Taxonomy.Select]
	-- Add the parameters for the stored procedure here
	@ForPostTypeID int = null,
	@ForTaxonomyID int = null,
	@EnabledOnly BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		[TypeID], 
		[TypeCode],
		[TypeURL],
		[TypeName],
		[IsBrowsable],
		[seoTitle],
		[seoMetaDescription],
		[seoMetaKeywords],
		[seoPriority],
		[seoChangeFrequencyID],
		[postSeoTitle],
		[postSeoMetaDescription],
		[postSeoMetaKeywords],
		[postSeoPriority],
		[postSeoChangeFrequencyID],
		[HasContentIntro],
		[HasContentEnding],
		PTT.[ForTaxonomyID],
		PTT.[ForPostTypeID],
		T.TaxonomyID,
		TaxonomyCode,
		TaxonomyName,
		IsTag,
		ISNULL(IsEnabled, 0) as IsEnabled

	FROM [dbo].[Taxonomy] T
	LEFT OUTER JOIN [dbo].[CMS.Post.Type.Taxonomy] PTT ON PTT.ForTaxonomyID = T.TaxonomyID  AND (@ForPostTypeID IS NOT NULL AND PTT.ForPostTypeID = @ForPostTypeID AND PTT.ForTaxonomyID = T.TaxonomyID)
	LEFT OUTER JOIN [dbo].[CMS.Post.Type] PT ON PT.ForPostTypeID = PTT.ForPostTypeID AND PT.ForTaxonomyID = PTT.ForTaxonomyID
	WHERE 
	(@ForTaxonomyID IS NULL OR T.TaxonomyID = @ForTaxonomyID) 
	AND (@EnabledOnly = 0 OR PTT.IsEnabled = @EnabledOnly)
END

















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Type.Update]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Type.Update]
	-- Add the parameters for the stored procedure here
	@PostTypeID int,
	@typeCode nvarchar(50),
	@typeName nvarchar(50),
	@typeURL nvarchar(50),
	@isBrowsable bit,
	@seoTitle nvarchar(255),
	@seoMetaDescription nvarchar(500),
	@seoMetaKeywords nvarchar(500),
	@seoChangeFrequencyID int,
	@seoPriority decimal(2,1),
	@postSeoTitle nvarchar(255),
	@postSeoMetaDescription nvarchar(500),
	@postSeoMetaKeywords nvarchar(500),
	@postSeoChangeFrequencyID int,
	@postSeoPriority decimal(2,1),
	@HasContentIntro bit,
	@HasContentEnding bit,
	@Result bit OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE [dbo].[CMS.Post.Type] SET 
		[TypeCode] = @TypeCode,
		[TypeName] = @TypeName,
		[TypeURL] = @TypeURL,
		[IsBrowsable] = @isBrowsable,
		[seoTitle] = @seoTitle, 
		[seoMetaDescription] = @seoMetaDescription, 
		[seoMetaKeywords] = @seoMetaKeywords,
		[seoChangeFrequencyID] = @seoChangeFrequencyID,
		[seoPriority] = @seoPriority,
		[postSeoTitle] = @postSeoTitle, 
		[postSeoMetaDescription] = @postSeoMetaDescription, 
		[postSeoMetaKeywords] = @postSeoMetaKeywords,
		[postSeoChangeFrequencyID] = @postSeoChangeFrequencyID,
		[postSeoPriority] = @postSeoPriority,
		[HasContentIntro] = @HasContentIntro,
		[HasContentEnding] = @HasContentEnding
		WHERE [TypeID] = @PostTypeID

		SET @Result = 1
	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 0
	END CATCH 

	Return @Result

END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Post.Update]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Post.Update]
	-- Add the parameters for the stored procedure here
	@PostID bigint,
	@PostParentID bigint = NULL,
	@AuthorID bigint,
	@StatusID int,
	@Title nvarchar(255),
	@ContentIntro nvarchar(MAX) = NULL,
	@ContentPreview nvarchar(MAX) = NULL,
	@ContentMain nvarchar(MAX),
	@ContentEnding nvarchar(MAX) = NULL,
	@PostURL nvarchar(100) = NULL,
	@seoTitle nvarchar(255),
	@seoMetaDescription nvarchar(500),
	@seoMetaKeywords nvarchar(500),
	@seoChangeFrequencyID int,
	@seoPriority decimal(2,1),
	@DatePublished datetime = NULL,
	@ThumbnailAttachmentID bigint,
	@Order int,
	@Result nvarchar(255) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get Current Post Type
	Declare @PostTypeID int
	SELECT @PostTypeID = [TypeID]
	FROM [dbo].[CMS.Post] 
	WHERE [PostID] = @PostID


	Declare @UpdateError bit = 0


	IF @PostParentID IS NOT NULL 
	BEGIN
		--Check if @TermParentID has the same TaxonomyID as the @TermID
		IF 0 = (SELECT COUNT(*) 
				FROM [dbo].[CMS.Post] 
				WHERE [PostID] = @PostParentID AND [TypeID] = @PostTypeID)
		BEGIN
			Set @UpdateError = 1
			SET @Result = 'FAILED PostParentID Type'
		END
		ELSE 
		BEGIN 
			--Check if @TermParentID does not exist in the @TermID offsprings
			DECLARE	@ExistInPostOffsprings bit
			EXEC	@ExistInPostOffsprings = [dbo].[CMS.Post.IfPostExistInOffsprings] @PostID, @PostParentID
			IF @PostID = @PostParentID OR @ExistInPostOffsprings = 1 BEGIN
				Set @UpdateError = 1
				SET @Result = 'FAILED PostParentID Offsprings'
			END
		END
	END

	--Check if @PostURL already exist in the current @PostTypeID and @PostParentID
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[CMS.Post]
		WHERE 
			[PostID] != @PostID
			AND [PostURL] = @PostURL 
			AND [TypeID] = @PostTypeID 
			AND ISNULL([PostParentID], 0) = ISNULL(@PostParentID, 0)
	) > 0
	BEGIN
		Set @UpdateError = 1
		SET @Result = 'FAILED URL'
	END

	If @UpdateError = 0
	BEGIN TRY

		UPDATE [dbo].[CMS.Post]
		SET [PostParentID] = @PostParentID,
			[StatusID] = @StatusID, 
			[AuthorID] = @AuthorID,
			[Title] = @Title, 
			[DateLastModified] = GETUTCDATE(),
			[ContentIntro] = @ContentIntro,
			[ContentPreview] = @ContentPreview,
			[ContentMain] = @ContentMain, 
			[ContentEnding] = @ContentEnding, 
			[PostURL] = @PostURL, 
			[seoTitle] = @seoTitle, 
			[seoMetaDescription] = @seoMetaDescription, 
			[seoMetaKeywords] = @seoMetaKeywords,
			[seoChangeFrequencyID] = @seoChangeFrequencyID,
			[seoPriority] = @seoPriority,
			[ThumbnailAttachmentID] = @ThumbnailAttachmentID,
			[Order] = @Order
		WHERE [PostID] = @PostID

		--Update Post PublishDate
		IF (@StatusID = 50) 
			IF (@DatePublished IS NULL)
				UPDATE	[dbo].[CMS.Post] 
				SET		[DatePublished] = GETUTCDATE()
				WHERE	[PostID] = @PostID AND 
						[DatePublished] IS NULL
			ELSE
				UPDATE	[dbo].[CMS.Post] 
				SET		[DatePublished] = @DatePublished
				WHERE	[PostID] = @PostID
		ELSE 
			UPDATE	[dbo].[CMS.Post] 
			SET		[DatePublished] = NULL
			WHERE	
				[PostID] = @PostID AND 
				[DatePublished] IS NOT NULL

		SET @Result = 'SUCCESS'

	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 'FAILED'
	END CATCH 
	

END





















GO
/****** Object:  StoredProcedure [dbo].[CMS.Term.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMS.Term.Select] 
	-- Add the parameters for the stored procedure here
	@TaxonomyID int = NULL,
	@PostID bigint = NULL,
	@AttachmentID bigint = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		TT.[TermID], 
		TT.[TaxonomyID], 
		TT.[TermName], 
		TT.[TermURL], 
		TT.[TermThumbnailURL],
		TT.[TermParentID]
	FROM 
		[dbo].[Taxonomy.Term] TT 
		INNER JOIN [dbo].[Taxonomy] T ON T.[TaxonomyID] = TT.[TaxonomyID] 
		LEFT OUTER JOIN [dbo].[CMS.Post.Term] PT ON PT.[PostID] = @PostID AND PT.[TermID] = TT.[TermID] 
		LEFT OUTER JOIN [dbo].[CMS.Attachment.Term] AT ON AT.[AttachmentID] = @AttachmentID AND AT.[TermID] = TT.[TermID] 
	WHERE 
		(@TaxonomyID IS NULL OR TT.[TaxonomyID] = @TaxonomyID)
		AND (@PostID IS NULL OR PT.[PostID] = @PostID)
		AND (@AttachmentID IS NULL OR AT.[AttachmentID] = @AttachmentID)
	GROUP BY 
		TT.[TermID], 
		TT.[TaxonomyID], 
		TT.[TermName], 
		TT.[TermURL], 
		TT.[TermThumbnailURL],
		TT.[TermParentID]
END


















GO
/****** Object:  StoredProcedure [dbo].[Email.Queue.Insert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Email.Queue.Insert]
	-- Add the parameters for the stored procedure here
	@EmailID uniqueidentifier,
	@CreatedDateTime datetime,
	@SendingScheduledDateTime datetime,
	@FromAddress nvarchar(255),
	@FromName nvarchar(255),
	@ToAddress nvarchar(255),
	@ReplyToAddress nvarchar(255),
	@Subject nvarchar(255),
	@Body nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[Email.Queue] (
		EmailID,
		CreatedDateTime,
		SendingScheduledDateTime,
		FromAddress,
		FromName,
		ToAddress,
		ReplyToAddress,
		[Subject],
		Body
		)
	VALUES (
		@EmailID,
		@CreatedDateTime,
		@SendingScheduledDateTime,
		@FromAddress,
		@FromName,
		@ToAddress,
		@ReplyToAddress,
		@Subject,
		@Body
	)


END




















GO
/****** Object:  StoredProcedure [dbo].[Email.Queue.SelectNextEmailToSend]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Email.Queue.SelectNextEmailToSend]
	@CurrentDateTime DateTime
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TOP 1
		EmailID,
		CreatedDateTime,
		SendingScheduledDateTime,
		SendingStartedDateTime,
		SentDateTime,
		FromAddress,
		FromName,
		ToAddress,
		ReplyToAddress,
		[Subject],
		Body
	FROM [dbo].[Email.Queue]
	WHERE SendingStartedDateTime IS NULL AND SendingScheduledDateTime <= @CurrentDateTime
	ORDER BY SendingScheduledDateTime ASC

END




















GO
/****** Object:  StoredProcedure [dbo].[Email.Queue.SetSentDateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Email.Queue.SetSentDateTime]
	-- Add the parameters for the stored procedure here
	@EmailID uniqueidentifier,
	@SentDateTime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Email.Queue]
	SET SentDateTime = @SentDateTime
	WHERE EmailID = @EmailID

END




















GO
/****** Object:  StoredProcedure [dbo].[Email.Queue.SetStartedDateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Email.Queue.SetStartedDateTime]
	-- Add the parameters for the stored procedure here
	@EmailID uniqueidentifier,
	@SendingStartedDateTime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Email.Queue]
	SET SendingStartedDateTime = @SendingStartedDateTime
	WHERE EmailID = @EmailID

END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.CancelByUser]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.CancelByUser]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@CanceledDateTime datetime = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead] 
	SET [PublishedDateTime] = NULL,
	[UserCanceledDateTime] = ISNULL(@CanceledDateTime, GETUTCDATE())
	WHERE [LeadID] = @LeadID 
	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.EmailConfirm]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.EmailConfirm]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead]
	SET [EmailConfirmedDateTime] = GETUTCDATE() 
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.Field.Meta.Term.IsAllowed]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Field.Meta.Term.IsAllowed]
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@isAllowed bit OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [dbo].[Lead.Field.Meta.TermsAllowed] WHERE [TermID] = @TermID)
		SET @isAllowed = 1;
	ELSE 
		SET @isAllowed = 0;

RETURN 0
END





















GO
/****** Object:  StoredProcedure [dbo].[Lead.Field.Meta.Term.SetAllowance]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Field.Meta.Term.SetAllowance]
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@isAllowed bit = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [dbo].[Lead.Field.Meta.TermsAllowed] WHERE [TermID] = @TermID)
	BEGIN

		IF (@isAllowed = 0)
			DELETE FROM [dbo].[Lead.Field.Meta.TermsAllowed] WHERE [TermID] = @TermID

	END
	ELSE 
	BEGIN

		IF (@isAllowed = 1)
			INSERT INTO [dbo].[Lead.Field.Meta.TermsAllowed] ([TermID]) VALUES (@TermID)

	END


RETURN 0
END





















GO
/****** Object:  StoredProcedure [dbo].[Lead.Field.Structure.Group.InsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Field.Structure.Group.InsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@GroupID int,
	@GroupCode nvarchar(100),
	@GroupTitle nvarchar(255) = NULL,
	@GroupCSSClass nvarchar(255) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[Lead.Field.Structure.Group] WHERE GroupID = @GroupID)
	BEGIN

		UPDATE [dbo].[Lead.Field.Structure.Group] 
		SET [GroupCode] = @GroupCode,
		[GroupTitle] = @GroupTitle
		WHERE GroupID = @GroupID
		RETURN @@ROWCOUNT

	END
	ELSE 
	BEGIN

		BEGIN TRY
			INSERT INTO [dbo].[Lead.Field.Structure.Group] 
				([GroupCode], [GroupTitle])
			VALUES
				(@GroupCode, @GroupTitle)
			RETURN 1
		END TRY
		BEGIN CATCH
			RETURN 0
		END CATCH

	END




END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.Field.Structure.InsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Field.Structure.InsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@FieldTypeID int,
	@FieldCode nvarchar(50),
	@GroupID int = 1,
	@FieldName nvarchar(100),
	@LabelText nvarchar(100),
	@IsRequired bit,
	@IsContact bit,
	@IsActive bit,
	@Placeholder nvarchar(100)= null,
	@RegularExpression nvarchar(100) = null,
	@MinValue bigint = null,
	@MaxValue bigint = null,
	@TaxonomyID int = null,
	@TermParentID bigint = null,
	@FieldID int OUT,
	@ErrorMessage nvarchar(255) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC [dbo].[SysGetNewPrimaryKeyValueForTable] 'Lead.Field.Structure', @FieldID OUTPUT

	INSERT INTO [dbo].[Lead.Field.Structure]
		([FieldID], [FieldCode], [FieldName], [GroupID], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive]) 
	VALUES 
		(@FieldID, @FieldCode, @FieldName, @GroupID, @FieldTypeID, @LabelText, @IsRequired, @IsContact, @IsActive)

	IF @FieldTypeID = 1
	INSERT INTO [dbo].[Lead.Field.Meta.Texbox]
		([FieldID], [Placeholder], [RegularExpression]) 
	VALUES 
		(@FieldID, @Placeholder, @RegularExpression)

	IF @FieldTypeID = 2
	INSERT INTO [dbo].[Lead.Field.Meta.Dropdown]
		([FieldID], [Placeholder], [TaxonomyID], [TermParentID]) 
	VALUES 
		(@FieldID, @Placeholder, @TaxonomyID, @TermParentID)

	IF @FieldTypeID = 3
	INSERT INTO [dbo].[Lead.Field.Meta.Chekbox]
		([FieldID], [TaxonomyID], [TermParentID]) 
	VALUES 
		(@FieldID, @TaxonomyID, @TermParentID)

	IF @FieldTypeID = 4
	INSERT INTO [dbo].[Lead.Field.Meta.Radio] 
		([FieldID], [TaxonomyID], [TermParentID]) 
	VALUES 
		(@FieldID, @TaxonomyID, @TermParentID)

	IF @FieldTypeID = 7
	INSERT INTO [dbo].[Lead.Field.Meta.Number] 
		([FieldID], [Placeholder], [MinValue], [MaxValue]) 
	VALUES 
		(@FieldID, @Placeholder, @MinValue, @MaxValue)

RETURN 0


END





















GO
/****** Object:  StoredProcedure [dbo].[Lead.Field.Structure.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Field.Structure.Select]
	-- Add the parameters for the stored procedure here
	@ActiveStatus bit = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		FS.FieldID, FS.FieldName, FS.FieldCode, FS.FieldTypeID, FT.FieldTypeName, FS.LabelText,
		FS.IsRequired, FS.IsContact, FS.IsActive, FS.[Description],
		FSG.GroupID, FSG.GroupCode, FSG.GroupTitle,
		MT.RegularExpression,
		ISNULL(ISNULL(MN.Placeholder, MD.Placeholder), MT.Placeholder) as Placeholder,
		MN.MaxValue, MN.MinValue,
		ISNULL(ISNULL(MC.TaxonomyID, MD.TaxonomyID),MR.TaxonomyID) as TaxonomyID,
		ISNULL(ISNULL(MC.TermParentID, MD.TermParentID),MR.TermParentID) as TermParentID,
		MD.TermDepthMaxLevel
	FROM [dbo].[Lead.Field.Structure.Group] FSG
	LEFT OUTER JOIN [dbo].[Lead.Field.Structure] FS ON FS.GroupID = FSG.GroupID
	LEFT OUTER JOIN [dbo].[Lead.Field.Type] FT ON FT.FieldTypeID = FS.FieldTypeID
	LEFT OUTER JOIN [dbo].[Lead.Field.Meta.Chekbox] MC ON FS.[FieldID] = MC.FieldID
	LEFT OUTER JOIN [dbo].[Lead.Field.Meta.Dropdown] MD ON FS.[FieldID] = MD.FieldID 
	LEFT OUTER JOIN [dbo].[Lead.Field.Meta.Radio] MR ON FS.[FieldID] = MR.FieldID
	LEFT OUTER JOIN [dbo].[Lead.Field.Meta.Texbox] MT ON FS.[FieldID] = MT.FieldID
	LEFT OUTER JOIN [dbo].[Lead.Field.Meta.Number] MN ON FS.[FieldID] = MN.FieldID
	WHERE @ActiveStatus IS NULL OR FS.isActive = @ActiveStatus
	ORDER BY FS.[Order] ASC
END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.Field.Value.Scalar.Delete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Field.Value.Scalar.Delete]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@FieldID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[Lead.Field.Value.Scalar] WHERE [LeadID] = @LeadID AND [FieldID] = @FieldID 

	RETURN @@ROWCOUNT

END





















GO
/****** Object:  StoredProcedure [dbo].[Lead.Field.Value.Scalar.InsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Field.Value.Scalar.InsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@FieldID int,
	@TextValue nvarchar(500) = NULL,
	@BoolValue bit = NULL,
	@DatetimeValue datetime = NULL,
	@NumberValue bigint = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FieldTypeID int = NULL
	SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[Lead.Field.Structure] WHERE [FieldID] = @FieldID


	IF EXISTS (SELECT * FROM [dbo].[Lead.Field.Value.Scalar] WHERE [LeadID] = @LeadID AND [FieldID] = @FieldID AND [FieldTypeID] = @FieldTypeID)
	BEGIN

		UPDATE [dbo].[Lead.Field.Value.Scalar]
		SET [TextValue] = @TextValue,
		[DatetimeValue] = @DatetimeValue,
		[BoolValue] = @BoolValue,
		[NumberValue] = @NumberValue
		WHERE [LeadID] = @LeadID AND [FieldID] = @FieldID
		RETURN @@ROWCOUNT

	END
	ELSE 
	BEGIN

		BEGIN TRY
			INSERT INTO [dbo].[Lead.Field.Value.Scalar]
				([LeadID], [FieldID], [FieldTypeID], [TextValue], [DatetimeValue], [BoolValue], [NumberValue])
			VALUES
				(@LeadID, @FieldID, @FieldTypeID, @TextValue, @DatetimeValue, @BoolValue, @NumberValue)
			RETURN 1
		END TRY
		BEGIN CATCH
			RETURN 0
		END CATCH

	END

RETURN 0


END





















GO
/****** Object:  StoredProcedure [dbo].[Lead.Field.Value.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Field.Value.Select]
	-- Add the parameters for the stored procedure here
	@LeadIDTable [dbo].[Sys.Bigint.TableType] READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT L.LeadID, LF.FieldID, LF.FieldCode, LF.FieldName, LF.LabelText, LF.FieldTypeID, LFT.FieldTypeName, 
	LF.IsRequired, LF.IsContact, LF.IsActive, LF.[Description],
	LFG.GroupID, LFG.GroupCode, LFG.GroupTitle,
	FVS.TextValue, FVS.DatetimeValue, FVS.BoolValue, FVS.NumberValue, 
	TT.TermID,
	TT.TermURL,
	TT.TermName,
	TT.TermThumbnailURL,
	TT.TaxonomyID
	FROM [dbo].[Lead] L
	INNER JOIN @LeadIDTable LT ON LT.Item = L.LeadID
	CROSS JOIN [dbo].[Lead.Field.Structure] LF
	INNER JOIN [dbo].[Lead.Field.Structure.Group] LFG ON LFG.GroupID = LF.GroupID 
	INNER JOIN [dbo].[Lead.Field.Type] LFT ON LFT.FieldTypeID = LF.FieldTypeID
	LEFT OUTER JOIN [dbo].[Lead.Field.Value.Scalar] FVS ON FVS.[LeadID] = L.[LeadID] AND FVS.[FieldID] = LF.[FieldID]
	LEFT OUTER JOIN [dbo].[Lead.Field.Value.Taxonomy] FVT ON FVT.[LeadID] = L.[LeadID] AND LF.[FieldID] = FVT.[FieldID]
	LEFT OUTER JOIN [dbo].[Taxonomy.Term] TT ON TT.TermID = FVT.TermID
	ORDER BY L.LeadID, LFG.GroupID, LF.[Order]

END

















GO
/****** Object:  StoredProcedure [dbo].[Lead.Field.Value.Taxonomy.Delete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Field.Value.Taxonomy.Delete]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@FieldID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FieldTypeID int = NULL
	SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[Lead.Field.Structure] WHERE [FieldID] = @FieldID

	DELETE FROM [dbo].[Lead.Field.Value.Taxonomy] 
	WHERE [LeadID] = @LeadID 
	AND [FieldID] = @FieldID 
	AND [FieldTypeID] = @FieldTypeID

	RETURN @@ROWCOUNT

END





















GO
/****** Object:  StoredProcedure [dbo].[Lead.Field.Value.Taxonomy.Insert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Field.Value.Taxonomy.Insert]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@FieldID int,
	@TermID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FieldTypeID int = NULL
	SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[Lead.Field.Structure] WHERE [FieldID] = @FieldID
	
	DECLARE @TaxonomyID int = NULL
	SELECT @TaxonomyID = [TaxonomyID] FROM [dbo].[Taxonomy.Term] WHERE [TermID] = @TermID

	BEGIN TRY
		
		INSERT INTO [Lead.Field.Value.Taxonomy]
			([LeadID], [FieldID], [FieldTypeID], [TermID], [TaxonomyID]) 
		VALUES 
			(@LeadID, @FieldID, @FieldTypeID, @TermID, @TaxonomyID)
		RETURN 1

	END TRY
	BEGIN CATCH
	END CATCH

RETURN 0


END





















GO
/****** Object:  StoredProcedure [dbo].[Lead.GetEmailConfirmationKey]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.GetEmailConfirmationKey]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TOP 1 TokenKey
	FROM [dbo].[System.Token]
	WHERE [TokenAction] = 'LeadEmailConfirmation'
	AND [TokenValue] = @LeadID
	ORDER BY [TokenDateCreated] DESC

END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.Insert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Insert]
	-- Add the parameters for the stored procedure here
	@Email nvarchar(255),
	@LeadID bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	EXEC [dbo].[SysGetNewPrimaryKeyValueForTable] 'Lead', @LeadID OUTPUT

	INSERT INTO [dbo].[Lead]
		([LeadID], [CreatedDateTime], [Email])
	VALUES
		(@LeadID, GETUTCDATE(), @Email)
END





















GO
/****** Object:  StoredProcedure [dbo].[Lead.Location.InsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Location.InsertOrUpdate]
	-- Add the parameters for the stored procedure here
           @LeadID bigint
           ,@Location geography
           ,@LocationAccuracyMeters int
           ,@LeadRadiusMeters int
           ,@StreetAddress nvarchar(255)
           ,@PostalCode nvarchar(255)
           ,@City nvarchar(255)
           ,@Region nvarchar(255)
           ,@Country nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[Lead.Location] WHERE LeadId = @LeadID
	INSERT INTO [dbo].[Lead.Location]
           ([LeadID]
           ,[Location]
           ,[LocationAccuracyMeters]
           ,[LeadRadiusMeters]
           ,[StreetAddress]
           ,[PostalCode]
           ,[City]
           ,[Region]
           ,[Country])
     VALUES
           (@LeadID
           ,@Location
           ,@LocationAccuracyMeters
           ,@LeadRadiusMeters
           ,@StreetAddress
           ,@PostalCode
           ,@City
           ,@Region
           ,@Country)
END












GO
/****** Object:  StoredProcedure [dbo].[Lead.Review.Measure.Score.DeleteAll]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Review.Measure.Score.DeleteAll]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[Lead.Review.Measure.Score]
	WHERE [LeadID] = @LeadID

END














GO
/****** Object:  StoredProcedure [dbo].[Lead.Review.Measure.Score.Insert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Review.Measure.Score.Insert]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@MeasureID smallint,
	@Score smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[Lead.Review.Measure.Score]
		([LeadID], [ReviewMeasureID], [Score])
	VALUES
		(@LeadID, @MeasureID, @Score)

END














GO
/****** Object:  StoredProcedure [dbo].[Lead.Review.Measure.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Review.Measure.Select]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		lrm.MeasureID,
		lrm.MeasureName,
		ISNULL(lrms.Score,0) as Score
	FROM
		[dbo].[Lead] l
		CROSS JOIN [dbo].[Lead.Review.Measure] lrm 
		LEFT OUTER JOIN [dbo].[Lead.Review.Measure.Score] lrms ON lrms.LeadID = l.LeadID AND lrm.MeasureID = lrms.ReviewMeasureID
	WHERE
		l.LeadID = @LeadID
	ORDER BY lrm.[Order] ASC

END














GO
/****** Object:  StoredProcedure [dbo].[Lead.Review.Publish]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Review.Publish]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@LoginID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead.Review]
	SET PublishedDateTime = GETUTCDATE()
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.Review.Save]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Review.Save]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@ReviewDateTime datetime,
	@BusinessID bigint,
	@OtherBusinessName nvarchar(255),
	@AuthorName nvarchar(255),
	@ReviewText nvarchar(max),
	@OrderPricePart1 decimal(19,4),
	@OrderPricePart2 decimal(19,4)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM [dbo].[Lead.Review] WHERE [LeadID] = @LeadID)
		INSERT INTO [dbo].[Lead.Review] ([LeadID], [ReviewDateTime]) VALUES (@LeadID, @ReviewDateTime)

	UPDATE [dbo].[Lead.Review]
	SET ReviewDateTime = @ReviewDateTime,
		BusinessID = @BusinessID,
		OtherBusinessName = @OtherBusinessName,
		AuthorName = @AuthorName,
		ReviewText = @ReviewText,
		OrderPricePart1 = @OrderPricePart1,
		OrderPricePart2 = @OrderPricePart2
	WHERE [LeadID] = @LeadID

END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.Review.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Review.Select]
	-- Add the parameters for the stored procedure here
	@LeadID bigint = NULL,
	@BusinessID bigint = NULL,
	@DateFrom DateTime = NULL,
	@DateTo DateTime = NULL,
	@Published bit = NULL,
	@Offset int = 0,
	@Fetch int = 2147483647,
	@TotalCount int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Reviews TABLE (
		[LeadID] BIGINT,
		[ReviewDateTime] DATETIME
	)

	INSERT INTO @Reviews
	SELECT
		lr.LeadID,
		lr.ReviewDateTime
	FROM
		[dbo].[Lead.Review] lr
	WHERE
	(@BusinessID IS NULL OR lr.BusinessID = @BusinessID)
	AND (@LeadID IS NULL OR lr.LeadID = @LeadID)
	AND (@DateFrom IS NULL OR @DateFrom < ReviewDateTime)
	AND (@DateTo IS NULL OR @DateTo >= ReviewDateTime)
	AND (
		@Published IS NULL  
		OR (@Published = 1 AND lr.PublishedDateTime IS NOT NULL) 
		OR (@Published = 0 AND lr.PublishedDateTime IS NULL) 
	)
  	SELECT @TotalCount = COUNT(*) FROM @Reviews


	-- Declare a variable that references the type.
	DECLARE @ReviewIDs AS [dbo].[Sys.Bigint.TableType];  
  
	-- Add data to the table variable. 
	INSERT INTO @ReviewIDs (Item)
	SELECT r.[LeadID]
	FROM @Reviews r
	ORDER BY r.[ReviewDateTime] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	-- Perform a Select
	SELECT
		lr.LeadID,
		lr.BusinessID,
		lr.ReviewDateTime,
		lr.PublishedDateTime,
		lr.AuthorName,
		lr.ReviewText,
		lr.OtherBusinessName,
		lr.OrderPricePart1,
		lr.OrderPricePart2,
		lrm.MeasureID,
		lrm.MeasureName,
		lrms.Score
	FROM
		@ReviewIDs ri
		INNER JOIN [dbo].[Lead.Review] lr ON lr.LeadID = ri.Item
		LEFT OUTER JOIN [dbo].[Lead.Review.Measure.Score] lrms ON lrms.LeadID = lr.LeadID
		LEFT OUTER JOIN [dbo].[Lead.Review.Measure] lrm ON lrm.MeasureID = lrms.ReviewMeasureID
	ORDER BY lr.[ReviewDateTime] DESC

END














GO
/****** Object:  StoredProcedure [dbo].[Lead.Review.SelectBuisnessOptions]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Review.SelectBuisnessOptions]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		B.BusinessID,
		B.Name as BusinessName,
		B.RegistrationDate as BusinessRegistrationDate,
		B.WebSite,
		B.CountryID,
		T.TermID,
		T.TermName,
		T.TermParentID,
		T.TermURL,
		T.TaxonomyID,
		T.TermThumbnailURL,
		B.NotificationFrequencyID,
		B.[Address],
		B.ContactName,
		B.ContactEmail,
		B.ContactPhone,
		B.ContactSkype,
		B.[BillingName],
		B.[BillingCode1],
		B.[BillingCode2],
		B.[BillingAddress],
		BLC.CompletedDateTime
	FROM
		[dbo].[Business] B 
		INNER JOIN [dbo].[Taxonomy.Term] T ON T.TermID = B.CountryID
		INNER JOIN [dbo].[Business.Lead.ContactsRecieved] BLCR ON BLCR.LeadID = @LeadID AND BLCR.BusinessID = B.BusinessID 
		LEFT OUTER JOIN [dbo].[Business.Lead.Completed] BLC ON BLC.LeadID = @LeadID AND BLC.BusinessID = B.BusinessID
END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.Review.UnPublish]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Review.UnPublish]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@LoginID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead.Review]
	SET PublishedDateTime = NULL
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.Select]
	-- Add the parameters for the stored procedure here
	@LeadID bigint NULL,
	@Status nvarchar(50) = 'All',
	@DateFrom DateTime = NULL,
	@DateTo DateTime = NULL,
	@Query NVARCHAR(50) = NULL,
	@Offset int = 0,
	@Fetch int = 2147483647,
	@TotalCount int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Leads TABLE (
		[LeadID] BIGINT,
		[CreatedDateTime] DATETIME
	)

	IF (@Status = 'All')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], l.[CreatedDateTime]
		FROM [dbo].[Lead] l
		WHERE @LeadID IS NULL OR l.LeadID = @LeadID
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Published')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], l.[CreatedDateTime]
		FROM [dbo].[Lead] l
		WHERE l.[PublishedDateTime] IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Canceled')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], l.[CreatedDateTime]
		FROM [dbo].[Lead] l
		WHERE l.[PublishedDateTime] IS NULL AND l.EmailConfirmedDateTime IS NOT NULL AND (l.AdminCanceledPublishDateTime IS NOT NULL OR l.UserCanceledDateTime IS NOT NULL)
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'NotConfirmed')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		WHERE l.[EmailConfirmedDateTime] IS NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'NotInWork')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM 
			[dbo].[Lead] l
		LEFT OUTER JOIN 
			[dbo].[Business.Lead.ContactsRecieved] lcr ON lcr.LeadID = l.LeadID AND lcr.GetContactsDateTime IS NOT NULL
		WHERE l.[PublishedDateTime] IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
		GROUP BY
			l.[LeadID], l.[CreatedDateTime]
		HAVING
			COUNT(lcr.LeadID) = 0
	ELSE IF (@Status = 'ReadyToPublish')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		WHERE [EmailConfirmedDateTime] IS NOT NULL AND [UserCanceledDateTime] IS NULL AND [AdminCanceledPublishDateTime] IS NULL AND [PublishedDateTime] IS NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Completed')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		INNER JOIN [dbo].[Business.Lead.Completed] lc ON lc.LeadID = l.LeadID
		WHERE lc.CompletedDateTime IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Important')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		INNER JOIN [dbo].[Business.Lead.Important] li ON li.LeadID = l.LeadID
		WHERE li.ImportantDateTime IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'InWork')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		LEFT OUTER JOIN [dbo].[Business.Lead.ContactsRecieved] lcr ON lcr.LeadID = l.LeadID
		WHERE lcr.GetContactsDateTime IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)

	IF (@Query IS NOT NULL)
	BEGIN

		--@QueryNumber would contain only numbers from the @Query
		DECLARE @QueryNumber NVARCHAR(50) = dbo.ExtractNumberFromString(@Query)
		IF(LEN(@QueryNumber) = 0 )
			SET @QueryNumber = NULL
		ELSE
			SET @QueryNumber = CONCAT('%',@QueryNumber,'%')

		SET @Query = CONCAT('%',@Query,'%')

		--Delete @LeadIDs items that were not found in search subquery
		DELETE li
		FROM @Leads li
		LEFT OUTER JOIN (
			SELECT 
				l.[LeadID]
			FROM @Leads t
				INNER JOIN [dbo].[Lead] l ON l.LeadID = t.[LeadID]
				LEFT OUTER JOIN [dbo].[Lead.Field.Value.Scalar] s ON s.LeadID = l.LeadID
				LEFT OUTER JOIN [dbo].[Lead.Field.Value.Taxonomy] lt ON lt.LeadID = l.LeadID
				LEFT OUTER JOIN [dbo].[Taxonomy.Term] tt ON tt.TermID = lt.TermID
			WHERE l.Email like @Query
				OR s.TextValue like @Query
				OR tt.TermName like @Query
				OR (@QueryNumber IS NOT NULL AND (
					l.NumberFromEmail like @QueryNumber
					OR s.NubmerValueFromText like @QueryNumber
					OR s.NumberValue like @QueryNumber
					)
				)
		) s ON s.LeadID = li.[LeadID]
		WHERE s.LeadID IS NULL

	END

	-- Declare a variable that references the type.
	DECLARE @LeadIDs AS [dbo].[Sys.Bigint.TableType];  
  
	-- Add data to the table variable. 
	INSERT INTO @LeadIDs (Item)
	SELECT t.[LeadID]
	FROM @Leads t
	ORDER BY t.[CreatedDateTime] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	--SET @TotalCount
	SELECT @TotalCount = COUNT(*) FROM @Leads

	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[Lead.SelectByIDs] (@LeadIDs)
	ORDER BY [CreatedDateTime] DESC


END














GO
/****** Object:  StoredProcedure [dbo].[Lead.Select_SiteMapData]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Lead.Select_SiteMapData]
	-- Add the parameters for the stored procedure here
	@PageSize int = 100
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT  
		ROW_NUMBER() OVER(ORDER BY MAX([CreatedDateTime]) DESC) as PageNumber,
		MAX(t.PublishedDateTime) as PublishedDateTime, 
		COUNT(t.LeadNumber) as LeadCount 
	FROM (
		SELECT 
			--Need to use the same ordering in LeadNumber as in [dbo].[Lead.Select] procedure
			ROW_NUMBER() OVER(ORDER BY [CreatedDateTime] DESC) AS LeadNumber
			,l.CreatedDateTime
			,l.PublishedDateTime
		FROM [dbo].[Lead] l
		WHERE l.PublishedDateTime IS NOT NULL
	) t
	GROUP BY (t.LeadNumber-1)/@PageSize
	ORDER BY PageNumber ASC

END





GO
/****** Object:  StoredProcedure [dbo].[Lead.SelectBusinessDetails]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.SelectBusinessDetails]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		blw.LeadID, blw.BusinessID, 
		lcr.GetContactsDateTime, lni.NotInterestedDateTime, li.ImportantDateTime, lc.CompletedDateTime, lc.OrderSum, lc.SystemFeePercent, lc.LeadFee
	FROM [dbo].[Business.Lead.Worked] blw 
		LEFT OUTER JOIN [dbo].[Business.Lead.NotInterested] lni ON lni.LeadID = blw.LeadID AND lni.BusinessID = blw.BusinessID
		LEFT OUTER JOIN [dbo].[Business.Lead.Important] li ON li.LeadID = blw.LeadID AND li.BusinessID = blw.BusinessID
		LEFT OUTER JOIN [dbo].[Business.Lead.ContactsRecieved] lcr ON lcr.LeadID = blw.LeadID AND lcr.BusinessID = blw.BusinessID
		LEFT OUTER JOIN [dbo].[Business.Lead.Completed] lc ON lc.LeadID = blw.LeadID AND lc.BusinessID = blw.BusinessID
	WHERE blw.LeadID = @LeadID
	GROUP BY 
		blw.LeadID, blw.BusinessID, 
		lcr.GetContactsDateTime, lni.NotInterestedDateTime, li.ImportantDateTime, lc.CompletedDateTime, lc.OrderSum, lc.SystemFeePercent, lc.LeadFee

END
















GO
/****** Object:  StoredProcedure [dbo].[Lead.SelectBusinessNotificationData]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.SelectBusinessNotificationData]
	-- Add the parameters for the stored procedure here
	@PublishedAfter DateTime,
	@ForFrequencyName NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		LeadID,
		BusinessID,
		IsApproved,
		NextAllowedNotificationDateTime
	 FROM (
		SELECT 
			l.[LeadID], 
			br.BusinessID,
			br.IsApproved,
			[dbo].[Business.Lead.GetNextAllowedNotificationDateTime](br.BusinessID, @ForFrequencyName) as NextAllowedNotificationDateTime
		FROM [dbo].[Lead] l
		CROSS APPLY [dbo].[Lead.Business.SelectRequested](l.LeadID) br
		LEFT OUTER JOIN [dbo].[Business.Lead.Notified] bln on bln.BusinessID = br.BusinessID AND bln.LeadID = l.LeadID
		WHERE l.PublishedDateTime >= @PublishedAfter
		AND bln.NotifiedDateTime IS NULL   
		AND l.UserCanceledDateTime IS NULL 
		AND l.AdminCanceledPublishDateTime IS NULL
	) t
	WHERE t.NextAllowedNotificationDateTime <= GETUTCDATE()

END















GO
/****** Object:  StoredProcedure [dbo].[Lead.SelectBusinessPostNotificationData]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.SelectBusinessPostNotificationData]
	-- Add the parameters for the stored procedure here
	@PublishedAfter DateTime,
	@BusinessPostTypeID int,
	@BusinessLeadRelationTaxonomyID bigint,
	@BusinessPostFieldIDDoNotSendEmails int,
	@BusinessPostFieldIDBusiness int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT T.[LeadID], T.[PostID]
	FROM (
		SELECT 
			l.[LeadID], 
			PT.[PostID]
		FROM 
			[dbo].[Lead] L
			LEFT OUTER JOIN [dbo].[Lead.Field.Value.Taxonomy] LT ON LT.LeadID = L.LeadID 
			LEFT OUTER JOIN [dbo].[CMS.Post.Term] PT ON PT.TermID = LT.TermID AND PT.PostTypeID = @BusinessPostTypeID AND LT.TaxonomyID = @BusinessLeadRelationTaxonomyID
			LEFT OUTER JOIN [dbo].[CMS.Post.Field.Value] FVS ON FVS.PostID = PT.PostID AND FVS.FieldID = @BusinessPostFieldIDDoNotSendEmails
			LEFT OUTER JOIN [dbo].[Business.Lead.Notified.Post] BLN on BLN.BusinessPostID = PT.PostID AND BLN.LeadID = L.LeadID
		WHERE 
			L.PublishedDateTime >= @PublishedAfter 
			AND L.UserCanceledDateTime IS NULL -- User Did Not RemoveEmail
			AND L.AdminCanceledPublishDateTime IS NULL -- User Did Not RemoveEmail
			AND BLN.NotifiedDateTime IS NULL -- Was Not Yet Notified
			AND ISNULL(FVS.BoolValue, 0) = 0  -- DoNotSendEmails = FALSE
			AND PT.PostID IS NOT NULL -- Has BusinessLeadRelation
		GROUP BY 
			l.[LeadID], 
			PT.[PostID]
	) T
	LEFT OUTER JOIN [dbo].[CMS.Post.Field.Value] FVB ON FVB.PostID = T.PostID AND FVB.FieldID = @BusinessPostFieldIDBusiness
	WHERE 
		FVB.NumberValue IS NULL -- Post is not assosiated with Business
	GROUP BY 
		T.[LeadID], 
		T.[PostID]
END













GO
/****** Object:  StoredProcedure [dbo].[Lead.SelectByEmail]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.SelectByEmail]
	-- Add the parameters for the stored procedure here
	@Email nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Declare a variable that references the type.
	DECLARE @LeadIDs AS [dbo].[Sys.Bigint.TableType];  
  
	-- Add data to the table variable. 
	INSERT INTO @LeadIDs (Item)
	SELECT t.[LeadID]
	FROM [dbo].[Lead] t
	WHERE t.Email = @Email
	ORDER BY t.[CreatedDateTime] DESC

	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[Lead.SelectByIDs] (@LeadIDs)
	ORDER BY [CreatedDateTime]


END














GO
/****** Object:  StoredProcedure [dbo].[Lead.SelectForReview]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.SelectForReview]
	-- Add the parameters for the stored procedure here
	@CompletedDaysBefore INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DueDateCode NVARCHAR(50)
	SELECT @DueDateCode = [dbo].[Sys.Option.Get]('LeadSettingFieldMappingDateDue')

	-- Declare a variable that references the type.
	DECLARE @LeadIDs AS [dbo].[Sys.Bigint.TableType]; 

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
		FROM [dbo].[Lead.Field.Value.Scalar] FVS
		INNER JOIN [dbo].[Lead.Field.Structure] FS ON FS.[FieldID] = FVS.[FieldID]
		INNER JOIN [dbo].[Lead] L ON L.LeadID = FVS.LeadID
		WHERE
		L.EmailConfirmedDateTime IS NOT NULL --That were confirmed
		AND L.ReviewRequestSentDateTime IS NULL --Where ReviewRequest has not yet been sent
		AND FS.[FieldCode] = @DueDateCode 
		AND FVS.[DatetimeValue] <= DateAdd(DAY, -@CompletedDaysBefore, GETUTCDATE() )

	
	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[Lead.SelectByIDs] (@LeadIDs)

END








GO
/****** Object:  StoredProcedure [dbo].[Lead.SetReviewRequestSent]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.SetReviewRequestSent]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead]
	SET ReviewRequestSentDateTime = GETUTCDATE()
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.TryPublish]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.TryPublish]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@LoginID bigint,
	@PublishDateTime datetime = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead] 
	SET [PublishedDateTime] = ISNULL(@PublishDateTime, GETUTCDATE())
	WHERE [LeadID] = @LeadID 
	AND [EmailConfirmedDateTime] IS NOT NULL 
	--AND [UserCanceledDateTime] IS NULL
	AND [PublishedDateTime] IS NULL

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.TryUnPublish]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.TryUnPublish]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@LoginID bigint,
	@AdminCanceledPublishDateTime datetime = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead] 
	SET [PublishedDateTime] = NULL,
	[AdminCanceledPublishDateTime] = ISNULL(@AdminCanceledPublishDateTime, GETUTCDATE())
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[Lead.TryUnPublishByUser]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Lead.TryUnPublishByUser]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@UserCanceledPublishDateTime datetime = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Lead] 
	SET [PublishedDateTime] = NULL,
	[UserCanceledDateTime] = ISNULL(@UserCanceledPublishDateTime, GETUTCDATE())
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[Sys.GenerateRandomString]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Sys.GenerateRandomString]
	-- Add the parameters for the stored procedure here
	@Length int,
	@RandomString nvarchar(255) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CharPool nvarchar(255) = 'abcdefghijkmnopqrstuvwxyz123456789'
	DECLARE @Upper int = Len(@CharPool)
	DECLARE @Lower int = 1
	DECLARE @LoopCount int = 0
	
	SET @RandomString = ''

	WHILE (@LoopCount < @Length) BEGIN
		SET @RandomString = @RandomString + 
			SUBSTRING(@Charpool, CONVERT(int, ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)), 1)
		SET @LoopCount = @LoopCount + 1
	END


	RETURN

END




















GO
/****** Object:  StoredProcedure [dbo].[Sys.Option.InsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sys.Option.InsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@OptionKey nvarchar(100),
	@OptionValue nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[System.Options] 
	SET OptionValue = @OptionValue
	WHERE OptionKey = @OptionKey

	IF @@ROWCOUNT = 0
		INSERT INTO [dbo].[System.Options] (OptionKey, OptionValue) VALUES (@OptionKey, @OptionValue)


END



GO
/****** Object:  StoredProcedure [dbo].[Sys.Option.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Sys.Option.Select]
	-- Add the parameters for the stored procedure here
	@OptionKey nvarchar(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT OptionKey, OptionValue
	FROM 
		[dbo].[System.Options] 
	WHERE	
		(@OptionKey IS NULL OR @OptionKey = OptionKey)

END




















GO
/****** Object:  StoredProcedure [dbo].[Sys.Token.Create]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Sys.Token.Create]
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
		EXEC dbo.[Sys.GenerateRandomString] 60, @tokenKey OUT
	ELSE
		SET @tokenKey = @tokenKeySet

	IF NOT EXISTS (SELECT 1 FROM [dbo].[System.Token] WHERE [TokenKey] = @tokenKey)
	BEGIN
		INSERT INTO [dbo].[System.Token]
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
		EXEC [dbo].[Sys.Token.Create] @tokenAction, @tokenValue, NULL, @tokenKey OUT

END




















GO
/****** Object:  StoredProcedure [dbo].[Sys.Token.Delete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Sys.Token.Delete]
	-- Add the parameters for the stored procedure here
	@tokenKey nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DELETE FROM [dbo].[System.Token] WHERE [TokenKey] = @tokenKey
END




















GO
/****** Object:  StoredProcedure [dbo].[Sys.Token.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Sys.Token.Select]
	-- Add the parameters for the stored procedure here
	@tokenKey nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [TokenKey], [TokenAction], [TokenValue], [TokenDateCreated]
	FROM [dbo].[System.Token]
	WHERE [TokenKey] = @tokenKey

END




















GO
/****** Object:  StoredProcedure [dbo].[Sys.WordCase.Insert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Sys.WordCase.Insert]
	-- Add the parameters for the stored procedure here
	@NominativeSingular nvarchar(50),
	@GenitiveSingular nvarchar(50),
	@DativeSingular nvarchar(50),
	@AccusativeSingular nvarchar(50),
	@InstrumentalSingular nvarchar(50),
	@PrepositionalSingular nvarchar(50),
	@NominativePlural nvarchar(50),
	@GenitivePlural nvarchar(50),
	@DativePlural nvarchar(50),
	@AccusativePlural nvarchar(50),
	@InstrumentalPlural nvarchar(50),
	@PrepositionalPlural nvarchar(50),
	@WordID bigint OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[System.WordCase]
		(NominativeSingular, 
		GenitiveSingular,
		DativeSingular,
		AccusativeSingular,
		InstrumentalSingular,
		PrepositionalSingular,
		NominativePlural, 
		GenitivePlural,
		DativePlural,
		AccusativePlural,
		InstrumentalPlural,
		PrepositionalPlural)
	VALUES 
		(@NominativeSingular,
		@GenitiveSingular,
		@DativeSingular,
		@AccusativeSingular,
		@InstrumentalSingular,
		@PrepositionalSingular,
		@NominativePlural,
		@GenitivePlural,
		@DativePlural,
		@AccusativePlural,
		@InstrumentalPlural,
		@PrepositionalPlural)

	SET @WordID = SCOPE_IDENTITY()


END




















GO
/****** Object:  StoredProcedure [dbo].[Sys.WordCase.Update]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Sys.WordCase.Update]
	-- Add the parameters for the stored procedure here
	@WordID bigint,
	@NominativeSingular nvarchar(50),
	@GenitiveSingular nvarchar(50),
	@DativeSingular nvarchar(50),
	@AccusativeSingular nvarchar(50),
	@InstrumentalSingular nvarchar(50),
	@PrepositionalSingular nvarchar(50),
	@NominativePlural nvarchar(50),
	@GenitivePlural nvarchar(50),
	@DativePlural nvarchar(50),
	@AccusativePlural nvarchar(50),
	@InstrumentalPlural nvarchar(50),
	@PrepositionalPlural nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[System.WordCase]
	SET NominativeSingular = @NominativeSingular,
	GenitiveSingular = @GenitiveSingular,
	DativeSingular = @DativeSingular,
	AccusativeSingular = @AccusativeSingular,
	InstrumentalSingular = @InstrumentalSingular,
	PrepositionalSingular = @PrepositionalSingular,
	NominativePlural = @NominativePlural,
	GenitivePlural = @GenitivePlural,
	DativePlural = @DativePlural,
	AccusativePlural = @AccusativePlural,
	InstrumentalPlural = @InstrumentalPlural,
	PrepositionalPlural = @PrepositionalPlural
	WHERE WordID = @WordID

END




















GO
/****** Object:  StoredProcedure [dbo].[SysGetNewPrimaryKeyValueForTable]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysGetNewPrimaryKeyValueForTable]
	-- Add the parameters for the stored procedure here
	@TableName nvarchar(100),
	@PrimaryKeyValue bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @PrimaryKeyColumnName as nvarchar(100)
	SELECT @PrimaryKeyColumnName = COL_NAME(ic.OBJECT_ID,ic.column_id)
	FROM sys.indexes AS i
	INNER JOIN sys.index_columns AS ic ON i.OBJECT_ID = ic.OBJECT_ID
	AND i.index_id = ic.index_id
	WHERE OBJECT_NAME(ic.OBJECT_ID) = @TableName AND i.is_primary_key = 1

	DECLARE @dynsql NVARCHAR(1000)
	SET @dynsql = 'select  @id =isnull(max([' + @PrimaryKeyColumnName + ']),0)+1 from [' + @TableName + '];'
	EXEC sp_executesql  @dynsql, N'@id bigint output',  @PrimaryKeyValue  OUTPUT

END


















GO
/****** Object:  StoredProcedure [dbo].[System.ScheduledTasks.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[System.ScheduledTasks.Select]
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
	FROM [dbo].[System.ScheduledTask] st
	INNER JOIN [dbo].[System.ScheduledTaskInterval] sti ON sti.ID = st.IntervalID

END




















GO
/****** Object:  StoredProcedure [dbo].[System.ScheduledTasks.SelectCurrentTasks]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[System.ScheduledTasks.SelectCurrentTasks]
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
	FROM [dbo].[System.ScheduledTask] st
	INNER JOIN [dbo].[System.ScheduledTaskInterval] ti ON ti.ID = st.IntervalID
	LEFT OUTER JOIN (
		SELECT [TaskName], MAX([StartedDateTime]) as [StartedDateTime] FROM [dbo].[System.ScheduledTaskLog]
		WHERE [CompletedDateTime] IS NOT NULL
		GROUP BY [TaskName]
	) lastRun ON lastRun.TaskName = st.[Name]
	LEFT OUTER JOIN (
		SELECT TaskName FROM [dbo].[System.ScheduledTaskLog]
		WHERE [CompletedDateTime] IS NULL
		GROUP BY [TaskName]
	) runninTask ON runninTask.TaskName = st.ID	
	WHERE runninTask.TaskName IS NULL
	AND (ti.[Name] = 'Hourly' AND DATEDIFF(hour,ISNULL(lastRun.StartedDateTime, DATEADD(hour, -st.IntervalValue, @now)),@now) >= st.IntervalValue)
	AND (ISNULL(st.StartHour, DATEPART(HOUR, @now)) >= DATEPART(HOUR, @now))

END




GO
/****** Object:  StoredProcedure [dbo].[System.ScheduledTasks.SetCompleted]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[System.ScheduledTasks.SetCompleted]
	@TaskName NVARCHAR(255),
	@Status NVARCHAR(50),
	@Message NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[System.ScheduledTaskLog]
	SET [CompletedDateTime] = GETUTCDATE(),
	[Status] = @Status,
	[Message] = @Message
	WHERE [TaskName] = @TaskName
	AND [CompletedDateTime] IS NULL	

END




GO
/****** Object:  StoredProcedure [dbo].[System.ScheduledTasks.SetStarted]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[System.ScheduledTasks.SetStarted]
	@TaskName NVARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [dbo].[System.ScheduledTaskLog] WHERE [TaskName] = @TaskName AND CompletedDateTime IS NULL)
		BEGIN
			DECLARE @ErrorMessage  NVARCHAR (255) = 'Can not start task ' + @TaskName +' because it is not completed yet (CompletedDateTime IS NULL)'
			RAISERROR(@ErrorMessage, 16,1 )
			RETURN 0;
		END
	ELSE
		INSERT INTO [dbo].[System.ScheduledTaskLog]
			([TaskName], [Status])
		VALUES
			(@TaskName, 'Started')	

END



GO
/****** Object:  StoredProcedure [dbo].[Taxonomy.Insert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Taxonomy.Insert] 
	-- Add the parameters for the stored procedure here
	@TaxonomyCode nvarchar(50),
	@TaxonomyName nvarchar(50),
	@IsTag bit,
	@Result nvarchar(100) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO [dbo].[Taxonomy] ([TaxonomyCode], [TaxonomyName], [IsTag])
		VALUES (@TaxonomyCode, @TaxonomyName, @IsTag) 

		SET @Result = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 'FAILED'
	END CATCH 





END





















GO
/****** Object:  StoredProcedure [dbo].[Taxonomy.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Taxonomy.Select]
	@TaxonomyID int = NULL,
	@TaxonomyCode nvarchar(50) = NULL,
	@TaxonomyName nvarchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		T.[TaxonomyID],
		T.[TaxonomyCode],
		T.[TaxonomyName],
		T.[IsTag]
	FROM 
		[dbo].[Taxonomy] T 
	WHERE 
		(@TaxonomyID IS NULL OR T.[TaxonomyID] = @TaxonomyID)
		AND (@TaxonomyCode IS NULL OR T.[TaxonomyCode] = @TaxonomyCode)
		AND (@TaxonomyName IS NULL OR T.[TaxonomyName] = @TaxonomyName)
END






















GO
/****** Object:  StoredProcedure [dbo].[Taxonomy.Term.Delete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Taxonomy.Term.Delete] 
	-- Add the parameters for the stored procedure here
	@TermID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	BEGIN TRANSACTION [TermDelete]

	BEGIN TRY

		-- Move current term children to the 'upper level'
		DECLARE @ParentID bigint
	
		SELECT @ParentID = [TermParentID] 
		FROM [dbo].[Taxonomy.Term] 
		WHERE [TermID] = @TermID

		UPDATE [dbo].[Taxonomy.Term] 
		SET [TermParentID] = @ParentID
		WHERE [TermParentID] = @TermID

		--Delete Posts for this term
		DECLARE @DeletePostID bigint
		DECLARE post_cursor CURSOR FOR  
		SELECT [PostID] FROM [dbo].[CMS.Post] WHERE [PostForTermID] = @TermID

		OPEN post_cursor   
		FETCH NEXT FROM post_cursor INTO @DeletePostID   

		WHILE @@FETCH_STATUS = 0   
		BEGIN

			EXEC [dbo].[CMS.Post.Delete] @DeletePostID

		FETCH NEXT FROM post_cursor INTO @DeletePostID   
		END   

		CLOSE post_cursor   
		DEALLOCATE post_cursor

		-- Delete term word assosiasion
		DELETE FROM [dbo].[Taxonomy.Term.Word] WHERE TermID = @TermID


		-- Delete the Term
		DELETE FROM [dbo].[Taxonomy.Term] 
		WHERE [TermID] = @TermID

		COMMIT TRANSACTION [TermDelete]
		
		RETURN 1

	END TRY
	BEGIN CATCH

		--IF THIS TERM IS USED SOMEWHERE
	  ROLLBACK TRANSACTION [TermDelete]
	  
	  RETURN 0

	END CATCH 

END


















GO
/****** Object:  StoredProcedure [dbo].[Taxonomy.Term.IfTermExistInOffsprings]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Taxonomy.Term.IfTermExistInOffsprings] 
	-- Add the parameters for the stored procedure here
	@ParentID BIGINT,
	@TestTermID BIGINT,
	@isExist BIT = 0 OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Find Term Children
	DECLARE @ChildrenTermsCursor CURSOR
	DECLARE @ChildID BIGINT
	
	
	SET @ChildrenTermsCursor = CURSOR FOR
		SELECT [TermID]
		FROM [dbo].[Taxonomy.Term]
		WHERE [TermParentID] = @ParentID
	
	OPEN @ChildrenTermsCursor;
	FETCH NEXT FROM @ChildrenTermsCursor INTO @ChildID

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF @ChildID = @TestTermID BEGIN
			SET @isExist = 1
			RETURN @isExist
		END
		ELSE BEGIN
			--DECLARE @RecursiveResult BIT = 0
			EXEC [dbo].[Taxonomy.Term.IfTermExistInOffsprings] @ChildID, @TestTermID, @isExist OUT
			--SET @isExist = @RecursiveResult
			
		END

		FETCH NEXT FROM @ChildrenTermsCursor INTO @ChildID
	END
	CLOSE @ChildrenTermsCursor
	DEALLOCATE @ChildrenTermsCursor

	RETURN @isExist

END






















GO
/****** Object:  StoredProcedure [dbo].[Taxonomy.Term.Insert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Taxonomy.Term.Insert] 
	-- Add the parameters for the stored procedure here
	@TaxonomyID int,
	@TermName nvarchar(255),
	@TermURL nvarchar(255),
	@TermParentID bigint = null,
	@Result nvarchar(100) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @InsertError bit = 0


	IF 
		@TermParentID IS NOT NULL 
		AND 0 = (SELECT COUNT(*) 
				FROM [dbo].[Taxonomy.Term]
				WHERE [TermID] = @TermParentID AND [TaxonomyID] = @TaxonomyID)
	BEGIN
		Set @InsertError = 1
		SET @Result = 'FAILED ParentID Taxonomy'
	END


	--Check if @TermName already exist in the current @TaxonomyID
	--IF (
	--	SELECT COUNT(*) 
	--	FROM [dbo].[Taxonomy.Term]
	--	WHERE 
	--		[TermName] = @TermName 
	--		AND [TaxonomyID] = @TaxonomyID
	--) > 0
	--BEGIN
	--	Set @InsertError = 1
	--	SET @Result = 'FAILED Name'
	--END

	--Check if @TermURL already exist in the current @TaxonomyID
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[Taxonomy.Term]
		WHERE 
			[TermURL] = @TermURL 
			AND [TaxonomyID] = @TaxonomyID
	) > 0
	BEGIN
		Set @InsertError = 1
		SET @Result = 'FAILED URL'
	END

	If @InsertError = 0
	BEGIN TRY

		INSERT INTO [dbo].[Taxonomy.Term] ([TaxonomyID], [TermName], [TermURL], [TermParentID])
		VALUES (@TaxonomyID, @TermName, @TermURL, @TermParentID) 

		SET @Result = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 'FAILED'
	END CATCH 





END





















GO
/****** Object:  StoredProcedure [dbo].[Taxonomy.Term.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Taxonomy.Term.Select] 
	-- Add the parameters for the stored procedure here
	@TermID bigint = NULL,
	@TermURL nvarchar(50) = NULL,
	@TermName nvarchar(50) = NULL,
	@TaxonomyID int = NULL,
	@TaxonomyName nvarchar(50) = NULL,
	@TaxonomyCode nvarchar(50) = NULL,
	@TermParentID bigint = 0,
	@OnlyAllowedInLeads bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		TT.[TermID], 
		TT.[TaxonomyID], 
		TT.[TermName], 
		TT.[TermURL], 
		TT.[TermThumbnailURL],
		TT.[TermParentID]
	FROM 
		[dbo].[Taxonomy.Term] TT 
		INNER JOIN [dbo].[Taxonomy] T ON T.[TaxonomyID] = TT.[TaxonomyID] 
		LEFT OUTER JOIN [dbo].[Lead.Field.Meta.TermsAllowed] LTA ON LTA.[TermID] = TT.TermID 
	WHERE 
		(@TermID IS NULL or TT.[TermID] = @TermID)
		AND (@TermURL IS NULL OR TT.[TermURL] = @TermURL)
		AND (@TermName IS NULL OR TT.[TermName] = @TermName)
		AND (@TaxonomyID IS NULL OR TT.[TaxonomyID] = @TaxonomyID)
		AND (@TaxonomyName IS NULL OR T.[TaxonomyName] = @TaxonomyName)
		AND (@TaxonomyCode IS NULL OR T.[TaxonomyCode] = @TaxonomyCode)
		AND (@TermParentID = 0 OR ISNULL(TT.[TermParentID], 0) = ISNULL(@TermParentID, 0))
		AND (ISNULL(@OnlyAllowedInLeads, 0) = 0 OR LTA.TermID IS NOT NULL)

END





















GO
/****** Object:  StoredProcedure [dbo].[Taxonomy.Term.Update]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Taxonomy.Term.Update] 
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@TermName nvarchar(255),
	@TermURL nvarchar(255),
	@TermParentID bigint,
	@Result nvarchar(255) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get Current Term Taxonomy
	Declare @TaxonomyID int
	SELECT @TaxonomyID = [TaxonomyID]
	FROM [dbo].[Taxonomy.Term] 
	WHERE [TermID] = @TermID

	Declare @UpdateError bit = 0


	IF @TermParentID IS NOT NULL 
	BEGIN

		--Check if @TermParentID has the same TaxonomyID as the @TermID
		IF 0 = (SELECT COUNT(*) 
				FROM [dbo].[Taxonomy.Term]
				WHERE [TermID] = @TermParentID AND [TaxonomyID] = @TaxonomyID)
		BEGIN
			Set @UpdateError = 1
			SET @Result = 'FAILED ParentID Taxonomy'
		END
		ELSE 
		BEGIN 
			--Check if @TermParentID does not exist in the @TermID offsprings
			DECLARE	@ExistInTermOffsprings bit
			EXEC	@ExistInTermOffsprings = [dbo].[Taxonomy.Term.IfTermExistInOffsprings] @TermID, @TermParentID
			IF @TermID = @TermParentID OR @ExistInTermOffsprings = 1 BEGIN
				Set @UpdateError = 1
				SET @Result = 'FAILED ParentID Offsprings'
			END
		END

	END


	--Check if @TermName already exist in the current @TaxonomyID
	--IF (
	--	SELECT COUNT(*) 
	--	FROM [dbo].[Taxonomy.Term]
	--	WHERE 
	--		[TermID] != @TermID
	--		AND [TermName] = @TermName 
	--		AND [TaxonomyID] = @TaxonomyID
	--) > 0
	--BEGIN
	--	Set @UpdateError = 1
	--	SET @Result = 'FAILED Name'
	--END

	--Check if @TermURL already exist in the current @TaxonomyID
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[Taxonomy.Term]
		WHERE 
			[TermID] != @TermID
			AND [TermURL] = @TermURL 
			AND [TaxonomyID] = @TaxonomyID
	) > 0
	BEGIN
		Set @UpdateError = 1
		SET @Result = 'FAILED URL'
	END

	If @UpdateError = 0
	BEGIN TRY

		UPDATE [dbo].[Taxonomy.Term] SET 
		[TermName] = @TermName,
		[TermURL] = @TermURL, 
		[TermParentID] = @TermParentID
		WHERE [TermID] = @TermID

		SET @Result = 'SUCCESS'
	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 'FAILED'
	END CATCH 

END






















GO
/****** Object:  StoredProcedure [dbo].[Taxonomy.Term.Word.Select]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Taxonomy.Term.Word.Select] 
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@WordCode nvarchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	tw.TermID, 
	tw.TermWordCode, 
	w.*
	FROM [dbo].[Taxonomy.Term.Word] tw
	INNER JOIN [dbo].[System.WordCase] w on w.WordID = tw.WordID
	WHERE @TermID = tw.TermID AND (@WordCode IS NULL OR tw.TermWordCode = @WordCode)
	
END





















GO
/****** Object:  StoredProcedure [dbo].[Taxonomy.Term.Word.SelectForMany]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Taxonomy.Term.Word.SelectForMany] 
	-- Add the parameters for the stored procedure here
	@TermIDTable [dbo].[Sys.Bigint.TableType] READONLY,
	@WordCode nvarchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	tw.TermID, 
	tw.TermWordCode, 
	w.*
	FROM [dbo].[Taxonomy.Term.Word] tw
	INNER JOIN @TermIDTable tt ON tt.Item = tw.TermID
	INNER JOIN [dbo].[System.WordCase] w on w.WordID = tw.WordID
	WHERE (@WordCode IS NULL OR tw.TermWordCode = @WordCode)
	
END





















GO
/****** Object:  StoredProcedure [dbo].[Taxonomy.Term.Word.Set]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Taxonomy.Term.Word.Set] 
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@WordID bigint,
	@WordCode nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[Taxonomy.Term.Word] 
	([TermID], [WordID], [TermWordCode]) 
	VALUES 
	(@TermID, @WordID, @WordCode)
	
END





















GO
/****** Object:  StoredProcedure [dbo].[Taxonomy.Update]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Taxonomy.Update] 
	-- Add the parameters for the stored procedure here
	@TaxonomyID int,
	@TaxonomyCode nvarchar(50),
	@TaxonomyName nvarchar(50),
	@IsTag bit,
	@Result bit OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE [dbo].[Taxonomy] 
		SET [TaxonomyCode] = @TaxonomyCode, 
		[TaxonomyName] = @TaxonomyName,
		[IsTag] = @IsTag
		WHERE [TaxonomyID] = @TaxonomyID

		SET @Result = 1

	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 0
	END CATCH 

END





















GO
/****** Object:  StoredProcedure [dbo].[User.Login.Authenticate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[User.Login.Authenticate]
	-- Add the parameters for the stored procedure here
	@email nvarchar(255),
	@passwordHash nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT	
		L.[LoginID],
		R.[RoleID],
		R.[RoleName],
		R.[RoleCode],
		L.[Email],
		L.[RegistrationDate],
		L.[EmailConfirmationDate]
	FROM	
		[dbo].[User.Login] L INNER JOIN
		[dbo].[User.Role] R ON R.[RoleID] = L.[RoleID]
	WHERE	
		[Email] = @email 
		AND [PasswordHash] = @passwordHash

END




















GO
/****** Object:  StoredProcedure [dbo].[User.Login.Create]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[User.Login.Create]
	-- Add the parameters for the stored procedure here
	@roleID int,
	@email nvarchar(100),
	@passwordHash nvarchar(255),
	@loginID bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		INSERT INTO [dbo].[User.Login] (
			[RoleID],
			[Email],
			[PasswordHash],
			[RegistrationDate]
			)
		VALUES(
			@roleID,
			@email,
			@passwordHash,
			GETUTCDATE()
		)

		SET @loginID = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
    -- Execute error retrieval routine.
		SET @loginID = NULL
	END CATCH;

	return @loginID
END




















GO
/****** Object:  StoredProcedure [dbo].[User.Login.EmailConfirm]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[User.Login.EmailConfirm]
	-- Add the parameters for the stored procedure here
	@loginID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[User.Login]
	SET [EmailConfirmationDate] = GETUTCDATE() 
	WHERE [LoginID] = @loginID

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[User.Login.PasswordHashUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[User.Login.PasswordHashUpdate]
	-- Add the parameters for the stored procedure here
	@loginID bigint,
	@sessionID nvarchar(255) = '',
	@passwordHash nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[User.Session]
	SET [SessionPasswordChangeInitialized] = 1
	WHERE [SessionID] = @SessionID AND [LoginID] = @LoginID

	UPDATE [dbo].[User.Login]
	SET [PasswordHash] = @PasswordHash 
	WHERE [LoginID] = @LoginID

	return @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[User.Login.SelectOne]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[User.Login.SelectOne]
	-- Add the parameters for the stored procedure here
	@loginID bigint,
	@email nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TOP 1	
		L.[LoginID],
		R.[RoleID],
		R.[RoleName],
		R.[RoleCode],
		L.[Email],
		L.[RegistrationDate],
		L.[EmailConfirmationDate]
	FROM	
		[dbo].[User.Login] L INNER JOIN
		[dbo].[User.Role] R ON R.[RoleID] = L.[RoleID]
	WHERE	
		(@loginID IS NOT NULL AND L.[LoginID] = @loginID)
		OR 
		(@email IS NOT NULL AND L.[Email] = @email)

END




















GO
/****** Object:  StoredProcedure [dbo].[User.Login.Session.Create]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[User.Login.Session.Create]
	-- Add the parameters for the stored procedure here
	@loginID bigint,
	@sessionID nvarchar(255) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @PasswordHash nvarchar(255)
	SELECT @PasswordHash = [PasswordHash] FROM [dbo].[User.Login] WHERE [LoginID] = @loginID

	IF ( @PasswordHash IS NOT NULL AND @PasswordHash <> '')
	BEGIN
		EXEC dbo.[Sys.GenerateRandomString] 50, @sessionID OUT
		IF (SELECT COUNT(*) FROM dbo.[User.Session] WHERE [SessionID] = @sessionID) = 0
		BEGIN
			INSERT INTO dbo.[User.Session] 
				([SessionID], 
				[LoginID], 
				[SessionPasswordHash], 
				[SessionCreationDate])
			SELECT 
				@sessionID, 
				@loginID,
				[PasswordHash],
				GETUTCDATE()
			FROM [dbo].[User.Login]
			WHERE [LoginID] = @loginID

			RETURN
		END
		ELSE
			EXEC [dbo].[User.Login.Session.Create] @loginID, @sessionID OUT
	END



	RETURN

END




















GO
/****** Object:  StoredProcedure [dbo].[User.Login.Session.Delete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[User.Login.Session.Delete]
	-- Add the parameters for the stored procedure here
	@sessionID nvarchar(255),
	@loginID bigint,
	@result bit OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DELETE FROM [dbo].[User.Session]
	WHERE [SessionID] = @sessionID AND [LoginID] = @loginID

	SET @result = @@ROWCOUNT

	RETURN @result

END




















GO
/****** Object:  StoredProcedure [dbo].[User.Login.Session.SelectLoginDetailsBySessionID]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[User.Login.Session.SelectLoginDetailsBySessionID]
	-- Add the parameters for the stored procedure here
	@sessionID nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		L.[LoginID],
		L.[Email],
		R.[RoleID],
		R.[RoleName],
		R.[RoleCode],
		L.[RegistrationDate],
		B.[BusinessID],
		B.[Name] as BusinessName,
		B.[RegistrationDate] as BusinessRegistrationDate,
		L.[EmailConfirmationDate]
	FROM 
		[dbo].[User.Session] S INNER JOIN
		[dbo].[User.Login] L ON L.[LoginID] = S.[LoginID] AND L.[EmailConfirmationDate] IS NOT NULL INNER JOIN
		[dbo].[User.Role] R ON R.[RoleID] = L.[RoleID] LEFT OUTER JOIN
		[dbo].[Business.Login] BL ON BL.[LoginID] = L.LoginID LEFT OUTER JOIN
		[dbo].[Business] B ON B.[BusinessID] = BL.[BusinessID]

	WHERE S.[SessionID] = @sessionID AND S.[SessionBlockDate] IS NULL


	RETURN

END




















GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [LocationIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE SPATIAL INDEX [LocationIndex] ON [dbo].[Business.Location]
(
	[Location]
)USING  GEOGRAPHY_AUTO_GRID 
WITH (
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [LocationWithRadiusIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE SPATIAL INDEX [LocationWithRadiusIndex] ON [dbo].[Lead.Location]
(
	[LocationWithRadius]
)USING  GEOGRAPHY_AUTO_GRID 
WITH (
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
USE [master]
GO
ALTER DATABASE [LeadGenDB] SET  READ_WRITE 
GO
