USE [master]
GO
/****** Object:  Database [LeadGenDB]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE DATABASE [LeadGenDB]
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
/****** Object:  UserDefinedTableType [dbo].[SysBigintTableType]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE TYPE [dbo].[SysBigintTableType] AS TABLE(
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
	FROM [dbo].[BusinessLeadCompleted]
	WHERE BusinessID = @BusinessID
		AND CompletedDateTime < @CompletedBeforeDate
		AND InvoiceID IS NULL
		AND InvoiceLineID IS NULL
	GROUP BY BusinessID

	-- Return the result of the function
	RETURN ISNULL(@LeadFeeTotalSum,0)

END















GO
/****** Object:  UserDefinedFunction [dbo].[BusinessLeadGetLastNotifiedDate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[BusinessLeadGetLastNotifiedDate]
(
	@BusinessID BIGINT
)
RETURNS DATETIME
AS
BEGIN
	-- Declare the return variable here
	DECLARE @NotifiedDateTime DATETIME

	SELECT TOP 1 @NotifiedDateTime = [NotifiedDateTime]
	FROM [dbo].[BusinessLeadNotified]
	WHERE BusinessID = @BusinessID
	ORDER BY [NotifiedDateTime] DESC


	-- Return the result of the function
	RETURN @NotifiedDateTime

END















GO
/****** Object:  UserDefinedFunction [dbo].[BusinessLeadGetNextAllowedNotificationDateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[BusinessLeadGetNextAllowedNotificationDateTime]
(
	@BusinessID BIGINT,
	@ForFrequencyName NVARCHAR(50)
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @AllowedDateTime DATETIME = DATEADD(year, -1, GETUTCDATE()) --Previus year

	-- Declare the return variable here
	DECLARE @LastNotifiedDateTime DATETIME = [dbo].[BusinessLeadGetLastNotifiedDate](@BusinessID)
	SET @LastNotifiedDateTime = ISNULL (@LastNotifiedDateTime, @AllowedDateTime) --Previus year (if never notified)

	DECLARE @NextAllowedNotificationDateTime DATETIME
	SELECT @NextAllowedNotificationDateTime = CASE 
		WHEN nf.[Name] = 'Immediate' THEN @AllowedDateTime
		WHEN nf.[Name] = 'Hourly' THEN DATEADD(hour, 1, @LastNotifiedDateTime )
		WHEN nf.[Name] = 'Daily' THEN DATEADD(day, 1, @LastNotifiedDateTime )
		ELSE NULL
		END
	FROM [dbo].[Business] b
	INNER JOIN [dbo].[NotificationFrequency] nf ON nf.ID = b.NotificationFrequencyID
	WHERE b.BusinessID = @BusinessID AND nf.[Name] = @ForFrequencyName

	--set to next year (means NOT NOW)
	SET @NextAllowedNotificationDateTime = ISNULL (@NextAllowedNotificationDateTime, DATEADD(year, 1, GETUTCDATE()))  

	-- Return the result of the function
	RETURN @NextAllowedNotificationDateTime

END















GO
/****** Object:  UserDefinedFunction [dbo].[BusinessLeadSelectRequested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[BusinessLeadSelectRequested]
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

	IF([dbo].[SysConvertToBit]([dbo].[SysOptionGet]('LeadApprovalPermissionEnabled')) = 1)
		MERGE @RequestedLeads rl
		USING [dbo].[BusinessPermissionGetRequestedLeadIDs](@BusinessID, @DateFrom, @DateTo, @LeadID) l
		ON l.LeadId = rl.LeadId
		WHEN MATCHED THEN
			UPDATE
			SET rl.IsApproved = Case When l.LeadId = 1 AND rl.LeadId = 1 Then 1 Else 0 END
		WHEN NOT MATCHED THEN  
			INSERT (LeadId, IsApproved)
			VALUES (l.LeadId, l.IsApproved);


	IF([dbo].[SysConvertToBit]([dbo].[SysOptionGet]('LeadApprovalLocationEnabled')) = 1)
		MERGE @RequestedLeads rl
		USING [dbo].[BusinessLocationGetNearByLeadIDs](@BusinessID, @DateFrom, @DateTo, @LeadID) l
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
/****** Object:  UserDefinedFunction [dbo].[CMSPostURLGetParentPath]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CMSPostURLGetParentPath] (@ParentID BIGINT, @ParentPath nvarchar(MAX) = '' ) returns nvarchar(MAX)
AS
BEGIN

	IF @ParentID is null
		return @ParentPath

	DECLARE @newParentID bigint

	SELECT 
		@ParentPath = CONCAT([PostURL], '/', @ParentPath),
		@newParentID = [PostParentID]
	FROM [dbo].[CMSPost] 
	WHERE [PostID] = @ParentID

	RETURN [dbo].[CMSPostURLGetParentPath] (@newParentID, @ParentPath)

END




















GO
/****** Object:  UserDefinedFunction [dbo].[LeadBusinessSelectRequested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[LeadBusinessSelectRequested]
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

	IF([dbo].[SysConvertToBit]([dbo].[SysOptionGet]('LeadApprovalPermissionEnabled')) = 1)
		MERGE @RequestedBusinesses rb
		USING [dbo].[BusienssPermissionGetBusinessesRequested](@LeadId) b
		ON b.BusinessID = rb.BusinessID
		WHEN MATCHED THEN
			UPDATE
			SET rb.IsApproved = Case When b.BusinessID = 1 AND rb.BusinessID = 1 Then 1 Else 0 END
		WHEN NOT MATCHED THEN  
			INSERT (BusinessID, IsApproved)
			VALUES (b.BusinessID, b.IsApproved);


	IF([dbo].[SysConvertToBit]([dbo].[SysOptionGet]('LeadApprovalLocationEnabled')) = 1)
		MERGE @RequestedBusinesses rb
		USING [dbo].[BusienssLocationGetBusinessesNearBy](@LeadId) b
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
/****** Object:  UserDefinedFunction [dbo].[SysConvertToBit]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[SysConvertToBit]
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
/****** Object:  UserDefinedFunction [dbo].[SysOptionGet]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[SysOptionGet]
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
		[dbo].[SystemOptions] 
	WHERE	
		@OptionKey = OptionKey


	-- Return the result of the function
	RETURN @OptionValue

END















GO
/****** Object:  UserDefinedFunction [dbo].[SysStringSplit]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SysStringSplit]
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


/****** Object:  Table [dbo].[Location]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Location](
	[LocationID] [bigint] IDENTITY(1,1) NOT NULL,
	[Location] [geography] NOT NULL,
	[AccuracyMeters] [int] NOT NULL DEFAULT 0,
	[RadiusMeters] [int] NOT NULL DEFAULT 5000,
	[LocationWithRadius]  AS ([Location].[STBuffer]([AccuracyMeters]+[RadiusMeters])) PERSISTED,
	[StreetAddress] [nvarchar](255) NULL,
	[PostalCode] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[Country] [nvarchar](255) NULL,
	[Zoom] [int]  NULL,
	[Name] [nvarchar](255) NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[UpdatedDateTime] [datetime] NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
Go


/****** Object:  Index [LeadLocationIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE SPATIAL INDEX [LocationIndex] ON [dbo].[Location]
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
CREATE SPATIAL INDEX [LocationWithRadiusIndex] ON [dbo].[Location]
(
	[LocationWithRadius]
)USING  GEOGRAPHY_AUTO_GRID 
WITH (
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[BusinessLeadPermission]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [dbo].[BusinessLeadPermissionTerm]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessLeadPermissionTerm](
	[PermissionID] [bigint] NOT NULL,
	[TermID] [bigint] NOT NULL,
 CONSTRAINT [PK_BusinessLeadPermissionTerm_1] PRIMARY KEY CLUSTERED 
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
/****** Object:  Table [dbo].[LeadFieldValueTaxonomy]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [dbo].[LeadFieldValueTaxonomy](
	[LeadID] [bigint] NOT NULL,
	[FieldID] [int] NOT NULL,
	[FieldTypeID] [int] NOT NULL,
	[TermID] [bigint] NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[UniqueIndexComputed]  AS (concat([LeadID],'_',[FieldID],'_',case when [FieldTypeID]=(3) then [TermID] else [FieldID] end)) PERSISTED NOT NULL,
 CONSTRAINT [IX_LeadFieldValueTaxonomy_Unique] UNIQUE NONCLUSTERED 
(
	[UniqueIndexComputed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [IX_LeadFieldValueTaxonomy_LeadTerm]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE CLUSTERED INDEX [IX_LeadFieldValueTaxonomy_LeadTerm] ON [dbo].[LeadFieldValueTaxonomy]
(
	[LeadID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[BusinessPermissionGetRequestedLeadIDs]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[BusinessPermissionGetRequestedLeadIDs]
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
			CASE WHEN BP.IsApprovedByAdmin IS NULL THEN 0 ELSE 1 END as IsApproved
		FROM 
			[dbo].[BusinessLeadPermission] BP
			LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] PT ON PT.PermissionID = BP.PermissionID
			CROSS JOIN [dbo].Lead L
			LEFT OUTER JOIN [dbo].[LeadFieldValueTaxonomy] VT ON VT.LeadID = L.LeadID AND VT.TermID = PT.TermID
		WHERE 
			BP.BusinessID = @BusinessID
			AND BP.RequestedDateTime IS NOT NULL
			AND (L.[PublishedDateTime] IS NOT NULL)
			AND (@LeadID IS NULL OR L.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < L.CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= L.CreatedDateTime)
		GROUP BY L.LeadID, PT.PermissionID, BP.IsApprovedByAdmin
		HAVING COUNT(VT.TermID) = COUNT(PT.TermID)
	) t
	GROUP BY t.LeadID
)








GO
/****** Object:  Table [dbo].[LeadFieldStructure]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadFieldStructure](
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
 CONSTRAINT [PK_LeadField] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_LeadFieldStructure] UNIQUE NONCLUSTERED 
(
	[FieldCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[BusienssPermissionGetBusinessesRequested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[BusienssPermissionGetBusinessesRequested]
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
			CASE WHEN BP.IsApprovedByAdmin IS NULL THEN 0 ELSE 1 END as IsApproved
		FROM 
			[dbo].[Lead] L
			CROSS JOIN [dbo].[LeadFieldStructure] LS
			INNER JOIN [dbo].[LeadFieldValueTaxonomy] LT ON LT.LeadID = L.LeadID AND LS.FieldID = LT.FieldID
			LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] BPTLead ON BPTLead.TermID = LT.TermID
			LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] BPTPermission ON BPTPermission.PermissionID = BPTLead.PermissionID
			LEFT OUTER JOIN [dbo].[BusinessLeadPermission] BP ON BP.PermissionID = BPTPermission.PermissionID AND BP.[RequestedDateTime] IS NOT NULL
		WHERE
			L.LeadID = @LeadID
			AND L.[PublishedDateTime] IS NOT NULL
			AND BP.BusinessID IS NOT NULL
		GROUP BY 
			BP.BusinessID, BP.PermissionID, BP.IsApprovedByAdmin
		HAVING 
			SUM(CASE WHEN BPTLead.TermID = BPTPermission.TermID Then 1 ELSE 0 END) = COUNT(DISTINCT BPTPermission.TermID)
	) t
	GROUP BY t.BusinessID
)

GO















GO
/****** Object:  Table [dbo].[BusinessLocation]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessLocation](
	[LocationID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[ApprovedByAdminDateTime] [DateTime] NULL,
	[IsApprovedByAdmin] AS (CASE WHEN [ApprovedByAdminDateTime] IS NULL THEN 0 ELSE 1 END) PERSISTED,
 CONSTRAINT [PK_BusinessLocation] PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadLocation](
	[LocationID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
 CONSTRAINT [PK_LeadLocation] PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_LeadLocation_Unique] UNIQUE NONCLUSTERED 
(
	[LocationID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])
GO




-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[BusinessLocationGetNearByLeadIDs]
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
			le.LeadID, 
			b.LocationID, 
			CASE WHEN b.IsApprovedByAdmin = 1 THEN 1 ELSE 0 END as IsApproved
		FROM 
			[dbo].[Lead] le
			INNER JOIN [dbo].[LeadLocation] ll ON ll.LeadID = le.LeadID
			INNER JOIN [dbo].[Location] lelo with(index([LocationWithRadiusIndex])) ON lelo.LocationID = ll.LocationID
			CROSS JOIN [dbo].[BusinessLocation] b 
			INNER JOIN [dbo].[Location] belo ON belo.LocationID = b.LocationID
			WHERE 
			b.BusinessID = @BusinessID
			AND (le.[PublishedDateTime] IS NOT NULL)
			AND (@LeadID IS NULL OR le.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < le.CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= le.CreatedDateTime)
			AND lelo.LocationWithRadius.STIntersects(belo.[LocationWithRadius]) = 1
		GROUP BY le.LeadID, b.LocationID, b.IsApprovedByAdmin
	) t
	GROUP BY t.LeadID
)








GO
/****** Object:  Table [dbo].[CMSPost]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSPost](
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
	[CustomCSS] [nvarchar](max) NULL,
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
 CONSTRAINT [PK_CMSPost] PRIMARY KEY CLUSTERED 
(
	[PostID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSPost] UNIQUE NONCLUSTERED 
(
	[PostID] ASC,
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSPost_1] UNIQUE NONCLUSTERED 
(
	[PostURL] ASC,
	[TypeID] ASC,
	[PostParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSPostStatus]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSPostStatus](
	[StatusID] [int] NOT NULL,
	[StatusName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_CMSPostStatus] PRIMARY KEY CLUSTERED 
(
	[StatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSPostType]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSPostType](
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
 CONSTRAINT [PK_CMSPostType] PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSPostType_1] UNIQUE NONCLUSTERED 
(
	[TypeURL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSPostType_2] UNIQUE NONCLUSTERED 
(
	[TypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[CMSPostSelectByIDs]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[CMSPostSelectByIDs]
(	
	-- Add the parameters for the function here
	@PostIDTable [dbo].[SysBigintTableType] READONLY
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
		P.[CustomCSS],
		CASE WHEN P.[PostParentID] IS NULL 
			THEN ''
			ELSE [dbo].[CMSPostURLGetParentPath](P.[PostParentID],DEFAULT)
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
		[dbo].[CMSPost] P
		INNER JOIN @PostIDTable T ON T.Item = P.PostID
		INNER JOIN [dbo].[CMSPostStatus] PS ON PS.[StatusID] = P.[StatusID] 
		INNER JOIN [dbo].[CMSPostType] PT ON PT.[TypeID] = P.[TypeID] 
)









GO
/****** Object:  UserDefinedFunction [dbo].[LeadSelectByIDs]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[LeadSelectByIDs]
(	
	-- Add the parameters for the function here
	@LeadIDTable [dbo].[SysBigintTableType] READONLY
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
/****** Object:  Table [dbo].[BusinessLeadCompleted]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessLeadCompleted](
	[LoginID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[CompletedDateTime] [datetime] NOT NULL,
	[OrderSum] [decimal](19, 4) NOT NULL,
	[SystemFeePercent] [decimal](4, 2) NOT NULL,
	[LeadFee]  AS (([OrderSum]*[SystemFeePercent])/(100)) PERSISTED,
	[InvoiceID] [bigint] NULL,
	[InvoiceLineID] [smallint] NULL,
 CONSTRAINT [PK_BusinessLeadCompleted] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BusinessLeadContactsRecieved]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [dbo].[BusinessLeadImportant]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessLeadImportant](
	[LoginID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[ImportantDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BusinessLeadImportant] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BusinessLeadNotInterested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessLeadNotInterested](
	[LoginID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[NotInterestedDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BusinessLeadNotInterested] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[BusinessLeadWorked]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BusinessLeadWorked]
AS
SELECT        BusinessID, LeadID
FROM            (SELECT        BusinessID, LeadID
                          FROM            dbo.[BusinessLeadNotInterested]
                          UNION ALL
                          SELECT        BusinessID, LeadID
                          FROM            dbo.[BusinessLeadImportant]
                          UNION ALL
                          SELECT        BusinessID, LeadID
                          FROM            dbo.[BusinessLeadContactsRecieved]
                          UNION ALL
                          SELECT        BusinessID, LeadID
                          FROM            dbo.[BusinessLeadCompleted]) AS t
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
 CONSTRAINT [PK_CMSTaxonomy] PRIMARY KEY CLUSTERED 
(
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TaxonomyTerm]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxonomyTerm](
	[TermID] [bigint] IDENTITY(1,1) NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermName] [nvarchar](255) NOT NULL,
	[TermURL] [nvarchar](255) NOT NULL,
	[TermThumbnailURL] [nvarchar](255) NULL,
	[TermParentID] [bigint] NULL,
 CONSTRAINT [PK_CMSTaxonomyTerm] PRIMARY KEY CLUSTERED 
(
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[BusinessRegionCountry]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BusinessRegionCountry]
AS
SELECT        B.BusinessID, B.Name AS BusinessName, B.RegistrationDate AS BusinessRegistrationDate, TT.TermID AS RegionID, TT.TermName AS RegionName, TT.TermURL AS RegionURL, TTC.TermID AS CountryID, 
                         TTC.TermName AS CountryName, TTC.TermURL AS CountryURL
FROM            dbo.Business AS B LEFT OUTER JOIN
                         dbo.[BusinessLeadPermission] AS BLP ON BLP.BusinessID = B.BusinessID INNER JOIN
                         dbo.[BusinessLeadPermissionTerm] AS BLPT ON BLPT.PermissionID = BLP.PermissionID INNER JOIN
                         dbo.[TaxonomyTerm] AS TT ON TT.TermID = BLPT.TermID INNER JOIN
                         dbo.Taxonomy AS T ON T.TaxonomyID = TT.TaxonomyID AND T.TaxonomyCode = 'city' INNER JOIN
                         dbo.[TaxonomyTerm] AS TTC ON TTC.TermID = TT.TermParentID
GROUP BY B.BusinessID, B.Name, B.RegistrationDate, TT.TermID, TT.TermName, TT.TermURL, TTC.TermID, TTC.TermName, TTC.TermURL



GO
/****** Object:  UserDefinedFunction [dbo].[BusienssLocationGetBusinessesNearBy]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[BusienssLocationGetBusinessesNearBy]
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
			CASE WHEN b.IsApprovedByAdmin = 1 THEN 1 ELSE 0 END as IsApproved
		FROM 
			[dbo].[Lead] le
			INNER JOIN [dbo].[LeadLocation] ll ON ll.LeadID = le.LeadID
			INNER JOIN [dbo].[Location] lelo with(index([LocationWithRadiusIndex])) ON lelo.LocationID = ll.LocationID
			CROSS JOIN [dbo].[BusinessLocation] b 
			INNER JOIN [dbo].[Location] belo ON belo.LocationID = b.LocationID
			WHERE 
			le.LeadID = @LeadID
			AND (le.[PublishedDateTime] IS NOT NULL)
			AND lelo.LocationWithRadius.STIntersects(belo.[LocationWithRadius]) = 1
		GROUP BY b.BusinessID, b.LocationID, b.IsApprovedByAdmin
	) t
	GROUP BY t.BusinessID
)




















GO
/****** Object:  Table [dbo].[LeadFieldValueScalar]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadFieldValueScalar](
	[ID] [uniqueidentifier] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[FieldID] [int] NOT NULL,
	[FieldTypeID] [int] NOT NULL,
	[TextValue] [nvarchar](max) NULL,
	[DatetimeValue] [datetime] NULL,
	[BoolValue] [bit] NULL,
	[NumberValue] [bigint] NULL,
	[NubmerValueFromText]  AS ([dbo].[ExtractNumberFromString]([TextValue])) PERSISTED,
 CONSTRAINT [PK_LeadFieldValueScalar] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_LeadFieldValueScalar_LeadID_FieldID] UNIQUE NONCLUSTERED 
(
	[LeadID] ASC,
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BusinessInvoice]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessInvoice](
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
 CONSTRAINT [PK_BusinessInvoice] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_BusinessInvoice] UNIQUE NONCLUSTERED 
(
	[InvoiceID] ASC,
	[BusinessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BusinessInvoiceLine]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessInvoiceLine](
	[InvoiceID] [bigint] NOT NULL,
	[BusinessID] [bigint] NOT NULL,
	[LineID] [smallint] NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[UnitPrice] [decimal](19, 4) NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Tax] [decimal](4, 2) NOT NULL,
	[LinePrice]  AS ([UnitPrice]*[Quantity]) PERSISTED,
	[LineTotalPrice]  AS ([UnitPrice]*[Quantity]+(([UnitPrice]*[Quantity])*[Tax])/(100)) PERSISTED,
 CONSTRAINT [PK_BusinessInvoiceLine] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC,
	[LineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BusinessLeadNotified]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessLeadNotified](
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
/****** Object:  Table [dbo].[BusinessLeadNotifiedPost]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessLeadNotifiedPost](
	[BusinessPostID] [bigint] NOT NULL,
	[LeadID] [bigint] NOT NULL,
	[NotifiedDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BusinessLeadNotifiedPost] PRIMARY KEY CLUSTERED 
(
	[BusinessPostID] ASC,
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BusinessLogin]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessLogin](
	[BusinessID] [bigint] NOT NULL,
	[LoginID] [bigint] NOT NULL,
	[RoleID] [int] NOT NULL,
	[LinkDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BusinessLogin_1] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BusinessNotificationEmail]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessNotificationEmail](
	[BusinessID] [bigint] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_BusinessNotificationEmail] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC,
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSAttachment]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSAttachment](
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
 CONSTRAINT [PK_CMSAttachment] PRIMARY KEY CLUSTERED 
(
	[AttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSAttachment] UNIQUE NONCLUSTERED 
(
	[FileHash] ASC,
	[FileSizeBytes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSAttachment_2] UNIQUE NONCLUSTERED 
(
	[URL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSAttachmentImage]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSAttachmentImage](
	[AttachmentID] [bigint] NOT NULL,
	[TypeID]  AS ((1)) PERSISTED NOT NULL,
	[ImageSizeOptionID] [int] NOT NULL,
	[URL] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_CMSAttachmentImage_1] PRIMARY KEY CLUSTERED 
(
	[AttachmentID] ASC,
	[ImageSizeOptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSAttachmentImageSize]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSAttachmentImageSize](
	[ImageSizeID] [int] NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[MaxHeight] [int] NOT NULL,
	[MaxWidth] [int] NOT NULL,
	[CropMode] [nvarchar](50) NULL,
 CONSTRAINT [PK_CMSAttachmentImageSize] PRIMARY KEY CLUSTERED 
(
	[ImageSizeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSAttachmentImageSize] UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSAttachmentTerm]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSAttachmentTerm](
	[AttachmentID] [bigint] NOT NULL,
	[TermID] [bigint] NOT NULL,
 CONSTRAINT [PK_CMSAttachmentTerm] PRIMARY KEY CLUSTERED 
(
	[AttachmentID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSAttachmentType]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSAttachmentType](
	[AttachmentTypeID] [int] NOT NULL,
	[AttachmentTypeName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_CMSAttachmentType] PRIMARY KEY CLUSTERED 
(
	[AttachmentTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSFieldType]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSFieldType](
	[FieldTypeID] [int] NOT NULL,
	[FieldTypeName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_CMSFieldTypes] PRIMARY KEY CLUSTERED 
(
	[FieldTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSFieldTypes] UNIQUE NONCLUSTERED 
(
	[FieldTypeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSPostAttachment]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSPostAttachment](
	[PostID] [bigint] NOT NULL,
	[AttachmentID] [bigint] NOT NULL,
	[LinkDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CMSPostAttachment] PRIMARY KEY CLUSTERED 
(
	[PostID] ASC,
	[AttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSPostFieldValue]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSPostFieldValue](
	[PostID] [bigint] NOT NULL,
	[PostTypeID] [int] NOT NULL,
	[FieldID] [int] NOT NULL,
	[TextValue] [nvarchar](max) NULL,
	[DatetimeValue] [datetime] NULL,
	[BoolValue] [bit] NULL,
	[NumberValue] [bigint] NULL,
	[LocationId] [bigint] NULL,
 CONSTRAINT [PK_CMSPostFieldValues] PRIMARY KEY CLUSTERED 
(
	[PostID] ASC,
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSPostTerm]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSPostTerm](
	[PostID] [bigint] NOT NULL,
	[TermID] [bigint] NOT NULL,
	[PostTypeID] [int] NOT NULL,
	[TaxonomyID] [int] NOT NULL,
 CONSTRAINT [PK_CMSPostTerm] PRIMARY KEY CLUSTERED 
(
	[PostID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSPostTypeAttachmentTaxonomy]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSPostTypeAttachmentTaxonomy](
	[PostTypeID] [int] NOT NULL,
	[AttachmentTaxonomyID] [int] NOT NULL,
	[IsEnabled] [bit] NOT NULL,
 CONSTRAINT [PK_CMSPostTypeAttachmentTaxonomy]]] PRIMARY KEY CLUSTERED 
(
	[PostTypeID] ASC,
	[AttachmentTaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSPostTypeFieldStructure]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSPostTypeFieldStructure](
	[FieldID] [int] IDENTITY(1,1) NOT NULL,
	[PostTypeID] [int] NOT NULL,
	[FieldTypeID] [int] NOT NULL,
	[FieldCode] [nvarchar](50) NOT NULL,
	[FieldLabelText] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_CMSPostFieldStructure] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSPostFieldStructure] UNIQUE NONCLUSTERED 
(
	[FieldCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_CMSPostTypeFieldStructure] UNIQUE NONCLUSTERED 
(
	[FieldID] ASC,
	[PostTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSPostTypeTaxonomy]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSPostTypeTaxonomy](
	[PostTypeID] [int] NOT NULL,
	[ForPostTypeID] [int] NOT NULL,
	[ForTaxonomyID] [int] NOT NULL,
	[IsEnabled] [bit] NOT NULL,
 CONSTRAINT [PK_CMSPostTypeTaxonomy] PRIMARY KEY CLUSTERED 
(
	[PostTypeID] ASC,
	[ForPostTypeID] ASC,
	[ForTaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMSSitemapChangeFrequency]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSSitemapChangeFrequency](
	[ID] [int] NOT NULL,
	[Frequency] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_SEOSitemapChangeFrequency] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EmailQueue]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmailQueue](
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
 CONSTRAINT [PK_SystemEmailQueue] PRIMARY KEY CLUSTERED 
(
	[EmailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadFieldMetaChekbox]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadFieldMetaChekbox](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((3)) PERSISTED NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermParentID] [bigint] NULL,
 CONSTRAINT [PK_LeadFieldMetaChekbox] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadFieldMetaDropdown]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadFieldMetaDropdown](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((2)) PERSISTED NOT NULL,
	[Placeholder] [nvarchar](100) NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermParentID] [bigint] NULL,
	[TermDepthMaxLevel] [int] NULL,
 CONSTRAINT [PK_LeadFieldMetaDropdown] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadFieldMetaNumber]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadFieldMetaNumber](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((7)) PERSISTED NOT NULL,
	[Placeholder] [nvarchar](100) NOT NULL,
	[MinValue] [bigint] NULL,
	[MaxValue] [bigint] NULL,
 CONSTRAINT [PK_LeadFieldMetaNumber] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadFieldMetaRadio]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadFieldMetaRadio](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((4)) PERSISTED NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermParentID] [bigint] NULL,
 CONSTRAINT [PK_LeadFieldMetaRadio] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadFieldMetaTermsAllowed]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadFieldMetaTermsAllowed](
	[TermID] [bigint] NOT NULL,
 CONSTRAINT [PK_LeadFieldMetaTermsAllowed] PRIMARY KEY CLUSTERED 
(
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadFieldMetaTextbox]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadFieldMetaTextbox](
	[FieldID] [int] NOT NULL,
	[FieldTypeID]  AS ((1)) PERSISTED NOT NULL,
	[Placeholder] [nvarchar](255) NOT NULL,
	[RegularExpression] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_LeadFieldTexboxMeta] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadFieldStructureGroup]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadFieldStructureGroup](
	[GroupID] [int] IDENTITY(1,1) NOT NULL,
	[GroupCode] [nvarchar](100) NOT NULL,
	[GroupTitle] [nvarchar](255) NULL,
	[GroupOrder] [int] NULL,
 CONSTRAINT [PK_LeadFieldStructureGroup] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_LeadFieldStructureGroup] UNIQUE NONCLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadFieldType]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadFieldType](
	[FieldTypeID] [int] NOT NULL,
	[FieldTypeName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_LeadFieldType] PRIMARY KEY CLUSTERED 
(
	[FieldTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadReview]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadReview](
	[LeadID] [bigint] NOT NULL,
	[ReviewDateTime] [datetime] NOT NULL,
	[PublishedDateTime] [datetime] NULL,
	[ReviewText] [nvarchar](max) NULL,
	[AuthorName] [nvarchar](255) NULL,
	[BusinessID] [bigint] NULL,
	[OtherBusinessName] [nvarchar](255) NULL,
	[OrderPricePart1] [decimal](19, 4) NULL,
	[OrderPricePart2] [decimal](19, 4) NULL,
 CONSTRAINT [PK_LeadReview] PRIMARY KEY CLUSTERED 
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadReviewMeasure]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadReviewMeasure](
	[MeasureID] [smallint] NOT NULL,
	[MeasureName] [nvarchar](255) NOT NULL,
	[Order] [smallint] NULL,
 CONSTRAINT [PK_ReviewMeasure] PRIMARY KEY CLUSTERED 
(
	[MeasureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_ReviewMeasure] UNIQUE NONCLUSTERED 
(
	[MeasureName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadReviewMeasureScore]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadReviewMeasureScore](
	[LeadID] [bigint] NOT NULL,
	[ReviewMeasureID] [smallint] NOT NULL,
	[Score] [smallint] NOT NULL,
 CONSTRAINT [PK_ReviewMeasureScore] PRIMARY KEY CLUSTERED 
(
	[LeadID] ASC,
	[ReviewMeasureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LeadGenLegal]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeadGenLegal](
	[LegalCountryID] [bigint] NOT NULL,
	[LegalAddress] [nvarchar](255) NOT NULL,
	[LegalName] [nvarchar](255) NOT NULL,
	[LegalCode1] [nvarchar](255) NOT NULL,
	[LegalCode2] [nvarchar](255) NOT NULL,
	[LegalBankAccount] [nvarchar](255) NOT NULL,
	[LegalBankCode1] [nvarchar](255) NOT NULL,
	[LegalBankCode2] [nvarchar](255) NOT NULL,
	[LegalBankName] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_LeadGenLegal] PRIMARY KEY CLUSTERED 
(
	[LegalCountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NotificationFrequency]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationFrequency](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_NotificationFrequency] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SystemOptions]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemOptions](
	[OptionKey] [nvarchar](100) NOT NULL,
	[OptionValue] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_SystemOptions] PRIMARY KEY CLUSTERED 
(
	[OptionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SystemScheduledTask]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [dbo].[SystemScheduledTaskInterval]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemScheduledTaskInterval](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_SystemTaskPeriod] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_SystemTaskPeriod] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SystemLog]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemLog](
	[ID] [UNIQUEIDENTIFIER] NOT NULL DEFAULT NEWID(),
	[Value] [nvarchar](MAX) NOT NULL,
	[LoggedDateTime] [datetime] NOT NULL DEFAULT GETUTCDATE())
GO
/****** Object:  Table [dbo].[SystemScheduledTaskLog]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemScheduledTaskLog](
	[ID] [uniqueidentifier] NOT NULL,
	[TaskName] [nvarchar](255) NOT NULL,
	[StartedDateTime] [datetime] NOT NULL,
	[CompletedDateTime] [datetime] NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Message] [nvarchar](max) NULL,
 CONSTRAINT [PK_SystemScheduledTaskLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SystemToken]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemToken](
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
/****** Object:  Table [dbo].[SystemWordCase]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemWordCase](
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
 CONSTRAINT [PK_SystemWordCase] PRIMARY KEY CLUSTERED 
(
	[WordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TaxonomyTermWord]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxonomyTermWord](
	[TermID] [bigint] NOT NULL,
	[WordID] [bigint] NOT NULL,
	[TermWordCode] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_TaxonomyTermWord] PRIMARY KEY CLUSTERED 
(
	[TermID] ASC,
	[WordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_TaxonomyTermWord] UNIQUE NONCLUSTERED 
(
	[TermID] ASC,
	[TermWordCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserLogin]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserLogin](
	[LoginID] [bigint] IDENTITY(1,1) NOT NULL,
	[RoleID] [int] NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[PasswordHash] [nvarchar](255) NOT NULL,
	[RegistrationDate] [datetime] NOT NULL,
	[EmailConfirmationDate] [datetime] NULL,
 CONSTRAINT [PK_UserLogin] PRIMARY KEY CLUSTERED 
(
	[LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRole](
	[RoleID] [int] NOT NULL,
	[RoleName] [nvarchar](50) NOT NULL,
	[RoleCode] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserSession]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSession](
	[SessionID] [nvarchar](255) NOT NULL,
	[LoginID] [bigint] NOT NULL,
	[SessionCreationDate] [datetime] NOT NULL,
	[SessionBlockDate] [datetime] NULL,
	[SessionPasswordHash] [nvarchar](255) NOT NULL,
	[SessionPasswordChangeInitialized] [bit] NULL,
 CONSTRAINT [PK_UserSessions] PRIMARY KEY CLUSTERED 
(
	[SessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[LeadFieldText]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[LeadFieldText] 
AS
	select l.LeadID, 'email' as FieldCode, 1 as IsContact, l.Email as FieldValue from dbo.Lead l 
		union all
	select sv.LeadID, fs.FieldCode, fs.IsContact, sv.TextValue as FieldValue 
	FROM dbo.LeadFieldValueScalar sv
	inner join dbo.LeadFieldStructure fs ON fs.FieldID = sv.FieldID
	where fs.IsActive = 1 AND sv.TextValue IS NOT NULL
		union all
	select vt.LeadID, fs.FieldCode, fs.IsContact, tt.TermName as FieldValue 
	FROM dbo.LeadFieldValueTaxonomy vt 
	inner join dbo.TaxonomyTerm tt ON tt.TermID = vt.TermID
	inner join dbo.LeadFieldStructure fs ON fs.FieldID = vt.FieldID
	where fs.IsActive = 1

GO
/****** Object:  Index [IX_Business]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Business] ON [dbo].[Business]
(
	[BusinessID] ASC,
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BusinessInvoice_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_BusinessInvoice_1] ON [dbo].[BusinessInvoice]
(
	[LegalYear] ASC,
	[LegalFacturaNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BusinessInvoice_2]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_BusinessInvoice_2] ON [dbo].[BusinessInvoice]
(
	[BusinessID] ASC,
	[LegalYear] ASC,
	[LegalMonth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [LeadIDIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [LeadIDIndex] ON [dbo].[BusinessLeadContactsRecieved]
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [LeadIDIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [LeadIDIndex] ON [dbo].[BusinessLeadNotInterested]
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [BusinessLeadPermission_RequestedDateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [BusinessLeadPermission_RequestedDateTime] ON [dbo].[BusinessLeadPermission]
(
	[BusinessID] ASC,
	[RequestedDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CMSAttachment_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CMSAttachment_1] ON [dbo].[CMSAttachment]
(
	[AttachmentID] ASC,
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CMSPost_2]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_CMSPost_2] ON [dbo].[CMSPost]
(
	[TypeID] ASC,
	[Order] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SelectIndex]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [SelectIndex] ON [dbo].[CMSPost]
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
/****** Object:  Index [IX_CMSPostType]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CMSPostType] ON [dbo].[CMSPostType]
(
	[TypeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CMSPostTypeTaxonomy]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CMSPostTypeTaxonomy] ON [dbo].[CMSPostTypeTaxonomy]
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
/****** Object:  Index [IX_LeadFieldMetaChekbox]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadFieldMetaChekbox] ON [dbo].[LeadFieldMetaChekbox]
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
/****** Object:  Index [IX_LeadFieldMetaDropdown]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadFieldMetaDropdown] ON [dbo].[LeadFieldMetaDropdown]
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
/****** Object:  Index [IX_LeadFieldMetaRadio]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadFieldMetaRadio] ON [dbo].[LeadFieldMetaRadio]
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
/****** Object:  Index [IX_LeadFieldMetaTextbox]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadFieldMetaTextbox] ON [dbo].[LeadFieldMetaTextbox]
(
	[FieldID] ASC,
	[FieldTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadField]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadField] ON [dbo].[LeadFieldStructure]
(
	[FieldID] ASC,
	[FieldTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_LeadField_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadField_1] ON [dbo].[LeadFieldStructure]
(
	[FieldName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadFieldValueScalar_DateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueScalar_DateTime] ON [dbo].[LeadFieldValueScalar]
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
/****** Object:  Index [IX_LeadFieldValueScalar_NubmerValueFromText]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueScalar_NubmerValueFromText] ON [dbo].[LeadFieldValueScalar]
(
	[NubmerValueFromText] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadFieldValueScalar_Number]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueScalar_Number] ON [dbo].[LeadFieldValueScalar]
(
	[NumberValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadFieldValueTaxonomy_LeadID]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueTaxonomy_LeadID] ON [dbo].[LeadFieldValueTaxonomy]
(
	[LeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadFieldValueTaxonomy_TermID]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueTaxonomy_TermID] ON [dbo].[LeadFieldValueTaxonomy]
(
	[TermID] ASC
)
INCLUDE ( 	[LeadID],
	[FieldID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeadFieldValueTaxonomy_TermTax]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_LeadFieldValueTaxonomy_TermTax] ON [dbo].[LeadFieldValueTaxonomy]
(
	[TaxonomyID] ASC,
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_NotificationFrequency]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_NotificationFrequency] ON [dbo].[NotificationFrequency]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_SystemScheduledTaskLog]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_SystemScheduledTaskLog] ON [dbo].[SystemScheduledTaskLog]
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
/****** Object:  Index [IX_TaxonomyTerm]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_TaxonomyTerm] ON [dbo].[TaxonomyTerm]
(
	[TermID] ASC,
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_TaxonomyTerm_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaxonomyTerm_1] ON [dbo].[TaxonomyTerm]
(
	[TermURL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_TaxonomyTerm_2]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaxonomyTerm_2] ON [dbo].[TaxonomyTerm]
(
	[TermName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_UserLogin]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserLogin] ON [dbo].[UserLogin]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserLogin_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserLogin_1] ON [dbo].[UserLogin]
(
	[LoginID] ASC,
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_UserRole]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserRole] ON [dbo].[UserRole]
(
	[RoleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_UserRole_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserRole_1] ON [dbo].[UserRole]
(
	[RoleCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Business] ADD  CONSTRAINT [DF_Business_BusinessRegistrationDate]  DEFAULT (getutcdate()) FOR [RegistrationDate]
GO
ALTER TABLE [dbo].[Business] ADD  CONSTRAINT [DF_Business_NotificationFrequencyID]  DEFAULT ((1)) FOR [NotificationFrequencyID]
GO
ALTER TABLE [dbo].[BusinessInvoice] ADD  CONSTRAINT [DF_Business.Invoice_InvoceCreatedDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[BusinessInvoiceLine] ADD  CONSTRAINT [DF_Business.Invoice.Line_Quantaty]  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[BusinessInvoiceLine] ADD  CONSTRAINT [DF_Business.Invoice.Line_Tax]  DEFAULT ((0)) FOR [Tax]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted] ADD  CONSTRAINT [DF_Business.Lead.Completed_CompletedDateTime]  DEFAULT (getutcdate()) FOR [CompletedDateTime]
GO
ALTER TABLE [dbo].[BusinessLeadContactsRecieved] ADD  CONSTRAINT [DF_Business.Lead.ContactsRecieve_GetContactsDate]  DEFAULT (getutcdate()) FOR [GetContactsDateTime]
GO
ALTER TABLE [dbo].[BusinessLeadImportant] ADD  CONSTRAINT [DF_Business.Lead.Important_ImportantDateTime]  DEFAULT (getutcdate()) FOR [ImportantDateTime]
GO
ALTER TABLE [dbo].[BusinessLeadNotified] ADD  CONSTRAINT [DF_BuinessLeadNotified_NotifiedDateTime]  DEFAULT (getutcdate()) FOR [NotifiedDateTime]
GO
ALTER TABLE [dbo].[BusinessLeadNotifiedPost] ADD  CONSTRAINT [DF_Business.Lead.Notified.Post_NotifiedDateTime]  DEFAULT (getutcdate()) FOR [NotifiedDateTime]
GO
ALTER TABLE [dbo].[BusinessLeadPermission] ADD  CONSTRAINT [DF_Business.Lead.Permission_RequestedDateTime]  DEFAULT (getutcdate()) FOR [RequestedDateTime]
GO
ALTER TABLE [dbo].[Location] ADD  CONSTRAINT [DF_Location_CreatedDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[BusinessLogin] ADD  CONSTRAINT [DF_Business.Login_LinkDate]  DEFAULT (getutcdate()) FOR [LinkDate]
GO
ALTER TABLE [dbo].[CMSAttachment] ADD  CONSTRAINT [DF_CMS.Attachment_MIME]  DEFAULT ('') FOR [MIME]
GO
ALTER TABLE [dbo].[CMSAttachment] ADD  CONSTRAINT [DF_CMS.Attachment_URL]  DEFAULT (CONVERT([varchar],sysdatetime(),(121))) FOR [URL]
GO
ALTER TABLE [dbo].[CMSAttachment] ADD  CONSTRAINT [DF_CMS.Attachment_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[CMSAttachment] ADD  CONSTRAINT [DF_CMS.Attachment_Name]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[CMSAttachment] ADD  CONSTRAINT [DF_CMS.Attachment_Description]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[CMSPost] ADD  CONSTRAINT [DF_CMS.Post_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[CMSPost] ADD  CONSTRAINT [DF_CMS.Post_DateLastModified]  DEFAULT (getutcdate()) FOR [DateLastModified]
GO
ALTER TABLE [dbo].[CMSPost] ADD  CONSTRAINT [DF_CMS.Post_Order]  DEFAULT ((0)) FOR [Order]
GO
ALTER TABLE [dbo].[CMSPostAttachment] ADD  CONSTRAINT [DF_CMS.Post.Attachment_LinkDate]  DEFAULT (getutcdate()) FOR [LinkDate]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_TypeCode]  DEFAULT ('') FOR [TypeCode]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_IsBrowsable]  DEFAULT ((0)) FOR [IsBrowsable]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_SeoPriority]  DEFAULT ((0.5)) FOR [SeoPriority]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_SeoChangeFrequencyID]  DEFAULT ((4)) FOR [SeoChangeFrequencyID]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_PostSeoPriority]  DEFAULT ((0.5)) FOR [PostSeoPriority]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_PostSeoChangeFrequencyID]  DEFAULT ((4)) FOR [PostSeoChangeFrequencyID]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_HasContentIntro]  DEFAULT ((0)) FOR [HasContentIntro]
GO
ALTER TABLE [dbo].[CMSPostType] ADD  CONSTRAINT [DF_CMS.Post.Type_HasContentEnding]  DEFAULT ((0)) FOR [HasContentEnding]
GO
ALTER TABLE [dbo].[CMSPostTypeAttachmentTaxonomy] ADD  CONSTRAINT [DF_CMS.Post.Type..Attachment.Taxonomy]]_IsEnabled]  DEFAULT ((0)) FOR [IsEnabled]
GO
ALTER TABLE [dbo].[CMSPostTypeTaxonomy] ADD  CONSTRAINT [DF_CMS.Post.Type.Taxonomy_IsDisabled]  DEFAULT ((1)) FOR [IsEnabled]
GO
ALTER TABLE [dbo].[EmailQueue] ADD  CONSTRAINT [DF_System.Email.Queue_Id]  DEFAULT (newid()) FOR [EmailID]
GO
ALTER TABLE [dbo].[EmailQueue] ADD  CONSTRAINT [DF_System.Email.Queue_CreatedDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[EmailQueue] ADD  CONSTRAINT [DF_System.Email.Queue_SendingScheduledDateTime]  DEFAULT (getutcdate()) FOR [SendingScheduledDateTime]
GO
ALTER TABLE [dbo].[Lead] ADD  CONSTRAINT [DF_Lead_LeadDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[LeadFieldMetaTextbox] ADD  CONSTRAINT [DF_Lead.Field.Meta.Textbox_Placeholder]  DEFAULT ('') FOR [Placeholder]
GO
ALTER TABLE [dbo].[LeadFieldMetaTextbox] ADD  CONSTRAINT [DF_Lead.Field.Meta.Textbox_RegularExpression]  DEFAULT ('') FOR [RegularExpression]
GO
ALTER TABLE [dbo].[LeadFieldStructure] ADD  CONSTRAINT [DF_Lead.FieldStructure_IsContact]  DEFAULT ((0)) FOR [IsContact]
GO
ALTER TABLE [dbo].[LeadFieldStructure] ADD  CONSTRAINT [DF_Lead.FieldStructure_isActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[LeadFieldValueScalar] ADD  CONSTRAINT [DF_Lead.Field.Value.Scalar_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[LeadReview] ADD  CONSTRAINT [DF_Lead.Review_ReviewDateTime]  DEFAULT (getutcdate()) FOR [ReviewDateTime]
GO
ALTER TABLE [dbo].[SystemScheduledTaskLog] ADD  CONSTRAINT [DF_System.ScheduledTaskLog_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[SystemScheduledTaskLog] ADD  CONSTRAINT [DF_System.ScheduledTaskLog_StartedDateTime]  DEFAULT (getutcdate()) FOR [StartedDateTime]
GO
ALTER TABLE [dbo].[SystemScheduledTaskLog] ADD  CONSTRAINT [DF_System.ScheduledTaskLog_Status]  DEFAULT (N'Started') FOR [Status]
GO
ALTER TABLE [dbo].[SystemToken] ADD  CONSTRAINT [DF_Token_TokenDateCreated]  DEFAULT (getutcdate()) FOR [TokenDateCreated]
GO
ALTER TABLE [dbo].[Taxonomy] ADD  CONSTRAINT [DF_Taxonomy_IsTag]  DEFAULT ((0)) FOR [IsTag]
GO
ALTER TABLE [dbo].[UserLogin] ADD  CONSTRAINT [DF_User.Login_RegistrationDate]  DEFAULT (getutcdate()) FOR [RegistrationDate]
GO
ALTER TABLE [dbo].[Business]  WITH CHECK ADD  CONSTRAINT [FK_Business_Notification.Frequency] FOREIGN KEY([NotificationFrequencyID])
REFERENCES [dbo].[NotificationFrequency] ([ID])
GO
ALTER TABLE [dbo].[Business] CHECK CONSTRAINT [FK_Business_Notification.Frequency]
GO
ALTER TABLE [dbo].[Business]  WITH CHECK ADD  CONSTRAINT [FK_Business_Taxonomy.Term] FOREIGN KEY([CountryID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO
ALTER TABLE [dbo].[Business] CHECK CONSTRAINT [FK_Business_Taxonomy.Term]
GO
ALTER TABLE [dbo].[BusinessInvoice]  WITH CHECK ADD  CONSTRAINT [FK_Business.Invoice_Business] FOREIGN KEY([BusinessID], [BillingCountryID])
REFERENCES [dbo].[Business] ([BusinessID], [CountryID])
GO
ALTER TABLE [dbo].[BusinessInvoice] CHECK CONSTRAINT [FK_Business.Invoice_Business]
GO
ALTER TABLE [dbo].[BusinessInvoiceLine]  WITH CHECK ADD  CONSTRAINT [FK_Business.Invoice.Line_Business.Invoice.Line] FOREIGN KEY([InvoiceID], [BusinessID])
REFERENCES [dbo].[BusinessInvoice] ([InvoiceID], [BusinessID])
GO
ALTER TABLE [dbo].[BusinessInvoiceLine] CHECK CONSTRAINT [FK_Business.Invoice.Line_Business.Invoice.Line]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice] FOREIGN KEY([InvoiceID], [BusinessID])
REFERENCES [dbo].[BusinessInvoice] ([InvoiceID], [BusinessID])
GO
ALTER TABLE [dbo].[BusinessLeadCompleted] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice.Line] FOREIGN KEY([InvoiceID], [InvoiceLineID])
REFERENCES [dbo].[BusinessInvoiceLine] ([InvoiceID], [LineID])
GO
ALTER TABLE [dbo].[BusinessLeadCompleted] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Invoice.Line]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Lead.ContactsRecieve] FOREIGN KEY([BusinessID], [LeadID])
REFERENCES [dbo].[BusinessLeadContactsRecieved] ([BusinessID], [LeadID])
GO
ALTER TABLE [dbo].[BusinessLeadCompleted] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Lead.ContactsRecieve]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Business.Login] FOREIGN KEY([BusinessID], [LoginID])
REFERENCES [dbo].[BusinessLogin] ([BusinessID], [LoginID])
GO
ALTER TABLE [dbo].[BusinessLeadCompleted] CHECK CONSTRAINT [FK_Business.Lead.Completed_Business.Login]
GO
ALTER TABLE [dbo].[BusinessLeadCompleted]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Completed_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[BusinessLeadCompleted] CHECK CONSTRAINT [FK_Business.Lead.Completed_Lead]
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
ALTER TABLE [dbo].[BusinessLeadImportant]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Important_Business.Login] FOREIGN KEY([BusinessID], [LoginID])
REFERENCES [dbo].[BusinessLogin] ([BusinessID], [LoginID])
GO
ALTER TABLE [dbo].[BusinessLeadImportant] CHECK CONSTRAINT [FK_Business.Lead.Important_Business.Login]
GO
ALTER TABLE [dbo].[BusinessLeadImportant]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Important_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[BusinessLeadImportant] CHECK CONSTRAINT [FK_Business.Lead.Important_Lead]
GO
ALTER TABLE [dbo].[BusinessLeadNotified]  WITH CHECK ADD  CONSTRAINT [FK_BuinessLeadNotified_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[BusinessLeadNotified] CHECK CONSTRAINT [FK_BuinessLeadNotified_Business]
GO
ALTER TABLE [dbo].[BusinessLeadNotified]  WITH CHECK ADD  CONSTRAINT [FK_BuinessLeadNotified_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[BusinessLeadNotified] CHECK CONSTRAINT [FK_BuinessLeadNotified_Lead]
GO
ALTER TABLE [dbo].[BusinessLeadNotifiedPost]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Notified.Post_CMS.Post] FOREIGN KEY([BusinessPostID])
REFERENCES [dbo].[CMSPost] ([PostID])
GO
ALTER TABLE [dbo].[BusinessLeadNotifiedPost] CHECK CONSTRAINT [FK_Business.Lead.Notified.Post_CMS.Post]
GO
ALTER TABLE [dbo].[BusinessLeadNotifiedPost]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Notified.Post_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[BusinessLeadNotifiedPost] CHECK CONSTRAINT [FK_Business.Lead.Notified.Post_Lead]
GO
ALTER TABLE [dbo].[BusinessLeadNotInterested]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.NotInterested_Business.Login] FOREIGN KEY([BusinessID], [LoginID])
REFERENCES [dbo].[BusinessLogin] ([BusinessID], [LoginID])
GO
ALTER TABLE [dbo].[BusinessLeadNotInterested] CHECK CONSTRAINT [FK_Business.Lead.NotInterested_Business.Login]
GO
ALTER TABLE [dbo].[BusinessLeadNotInterested]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.NotInterested_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[BusinessLeadNotInterested] CHECK CONSTRAINT [FK_Business.Lead.NotInterested_Lead]
GO
ALTER TABLE [dbo].[BusinessLeadPermission]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Permission_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[BusinessLeadPermission] CHECK CONSTRAINT [FK_Business.Lead.Permission_Business]
GO
ALTER TABLE [dbo].[BusinessLeadPermissionTerm]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Permission.Term_Business.Lead.Permission] FOREIGN KEY([PermissionID])
REFERENCES [dbo].[BusinessLeadPermission] ([PermissionID])
GO
ALTER TABLE [dbo].[BusinessLeadPermissionTerm] CHECK CONSTRAINT [FK_Business.Lead.Permission.Term_Business.Lead.Permission]
GO
ALTER TABLE [dbo].[BusinessLeadPermissionTerm]  WITH CHECK ADD  CONSTRAINT [FK_Business.Lead.Permission.Term_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO
ALTER TABLE [dbo].[BusinessLeadPermissionTerm] CHECK CONSTRAINT [FK_Business.Lead.Permission.Term_Taxonomy.Term]
GO
ALTER TABLE [dbo].[BusinessLocation]  WITH CHECK ADD  CONSTRAINT [FK_Business.Location_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[BusinessLocation] CHECK CONSTRAINT [FK_Business.Location_Business]
GO
ALTER TABLE [dbo].[BusinessLogin]  WITH CHECK ADD  CONSTRAINT [FK_Business.Login_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[BusinessLogin] CHECK CONSTRAINT [FK_Business.Login_Business]
GO
ALTER TABLE [dbo].[BusinessLogin]  WITH CHECK ADD  CONSTRAINT [FK_Business.Login_User.Login1] FOREIGN KEY([LoginID], [RoleID])
REFERENCES [dbo].[UserLogin] ([LoginID], [RoleID])
GO
ALTER TABLE [dbo].[BusinessLogin] CHECK CONSTRAINT [FK_Business.Login_User.Login1]
GO
ALTER TABLE [dbo].[BusinessNotificationEmail]  WITH CHECK ADD  CONSTRAINT [FK_Business.Notification.Email_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[BusinessNotificationEmail] CHECK CONSTRAINT [FK_Business.Notification.Email_Business]
GO
ALTER TABLE [dbo].[CMSAttachment]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment_CMS.Attachment.Type] FOREIGN KEY([TypeID])
REFERENCES [dbo].[CMSAttachmentType] ([AttachmentTypeID])
GO
ALTER TABLE [dbo].[CMSAttachment] CHECK CONSTRAINT [FK_CMS.Attachment_CMS.Attachment.Type]
GO
ALTER TABLE [dbo].[CMSAttachmentImage]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment.Image_CMS.Attachment] FOREIGN KEY([AttachmentID], [TypeID])
REFERENCES [dbo].[CMSAttachment] ([AttachmentID], [TypeID])
GO
ALTER TABLE [dbo].[CMSAttachmentImage] CHECK CONSTRAINT [FK_CMS.Attachment.Image_CMS.Attachment]
GO
ALTER TABLE [dbo].[CMSAttachmentTerm]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment.Term_CMS.Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].[CMSAttachment] ([AttachmentID])
GO
ALTER TABLE [dbo].[CMSAttachmentTerm] CHECK CONSTRAINT [FK_CMS.Attachment.Term_CMS.Attachment]
GO
ALTER TABLE [dbo].[CMSAttachmentTerm]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment.Term_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO
ALTER TABLE [dbo].[CMSAttachmentTerm] CHECK CONSTRAINT [FK_CMS.Attachment.Term_Taxonomy.Term]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post] FOREIGN KEY([PostParentID])
REFERENCES [dbo].[CMSPost] ([PostID])
GO
ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post.Status] FOREIGN KEY([StatusID])
REFERENCES [dbo].[CMSPostStatus] ([StatusID])
GO
ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post.Status]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post.Type] FOREIGN KEY([TypeID])
REFERENCES [dbo].[CMSPostType] ([TypeID])
GO
ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post.Type]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_CMS.Post.Type.Taxonomy] FOREIGN KEY([TypeID], [PostForTaxonomyID])
REFERENCES [dbo].[CMSPostTypeTaxonomy] ([PostTypeID], [ForTaxonomyID])
GO
ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_CMS.Post.Type.Taxonomy]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_SEO.Sitemap.ChangeFrequency] FOREIGN KEY([SeoChangeFrequencyID])
REFERENCES [dbo].[CMSSitemapChangeFrequency] ([ID])
GO
ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_SEO.Sitemap.ChangeFrequency]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_Taxonomy.Term] FOREIGN KEY([PostForTermID], [PostForTaxonomyID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID])
GO
ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_Taxonomy.Term]
GO
ALTER TABLE [dbo].[CMSPost]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post_User.Login] FOREIGN KEY([AuthorID])
REFERENCES [dbo].[UserLogin] ([LoginID])
GO
ALTER TABLE [dbo].[CMSPost] CHECK CONSTRAINT [FK_CMS.Post_User.Login]
GO
ALTER TABLE [dbo].[CMSPostAttachment]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post] FOREIGN KEY([PostID])
REFERENCES [dbo].[CMSPost] ([PostID])
GO
ALTER TABLE [dbo].[CMSPostAttachment] CHECK CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post]
GO
ALTER TABLE [dbo].[CMSPostAttachment]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post.Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].[CMSAttachment] ([AttachmentID])
GO
ALTER TABLE [dbo].[CMSPostAttachment] CHECK CONSTRAINT [FK_CMS.Post.Attachment_CMS.Post.Attachment]
GO
ALTER TABLE [dbo].[CMSPostFieldValue]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Field.Values_CMS.Post.Field.Values] FOREIGN KEY([PostID], [PostTypeID])
REFERENCES [dbo].[CMSPost] ([PostID], [TypeID])
GO
ALTER TABLE [dbo].[CMSPostFieldValue] CHECK CONSTRAINT [FK_CMS.Post.Field.Values_CMS.Post.Field.Values]
GO
ALTER TABLE [dbo].[CMSPostFieldValue]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Field.Values_CMS.Post.Field.Values1] FOREIGN KEY([FieldID], [PostTypeID])
REFERENCES [dbo].[CMSPostTypeFieldStructure] ([FieldID], [PostTypeID])
GO
ALTER TABLE [dbo].[CMSPostFieldValue] CHECK CONSTRAINT [FK_CMS.Post.Field.Values_CMS.Post.Field.Values1]
GO
ALTER TABLE [dbo].[CMSPostTerm]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Term_CMS.Post] FOREIGN KEY([PostID], [PostTypeID])
REFERENCES [dbo].[CMSPost] ([PostID], [TypeID])
GO
ALTER TABLE [dbo].[CMSPostTerm] CHECK CONSTRAINT [FK_CMS.Post.Term_CMS.Post]
GO
ALTER TABLE [dbo].[CMSPostTerm]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Term_CMS.Taxonomy.Term] FOREIGN KEY([TermID], [TaxonomyID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID])
GO
ALTER TABLE [dbo].[CMSPostTerm] CHECK CONSTRAINT [FK_CMS.Post.Term_CMS.Taxonomy.Term]
GO
ALTER TABLE [dbo].[CMSPostType]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type_CMS.Post.Type.Taxonomy] FOREIGN KEY([TypeID], [ForPostTypeID], [ForTaxonomyID])
REFERENCES [dbo].[CMSPostTypeTaxonomy] ([PostTypeID], [ForPostTypeID], [ForTaxonomyID])
GO
ALTER TABLE [dbo].[CMSPostType] CHECK CONSTRAINT [FK_CMS.Post.Type_CMS.Post.Type.Taxonomy]
GO
ALTER TABLE [dbo].[CMSPostType]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type_CMS.Sitemap.ChangeFrequency] FOREIGN KEY([PostSeoChangeFrequencyID])
REFERENCES [dbo].[CMSSitemapChangeFrequency] ([ID])
GO
ALTER TABLE [dbo].[CMSPostType] CHECK CONSTRAINT [FK_CMS.Post.Type_CMS.Sitemap.ChangeFrequency]
GO
ALTER TABLE [dbo].[CMSPostTypeAttachmentTaxonomy]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_CMS.Post.Type] FOREIGN KEY([PostTypeID])
REFERENCES [dbo].[CMSPostType] ([TypeID])
GO
ALTER TABLE [dbo].[CMSPostTypeAttachmentTaxonomy] CHECK CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_CMS.Post.Type]
GO
ALTER TABLE [dbo].[CMSPostTypeAttachmentTaxonomy]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_Taxonomy] FOREIGN KEY([AttachmentTaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[CMSPostTypeAttachmentTaxonomy] CHECK CONSTRAINT [FK_CMS.Post.Type..Attachment.Taxonomy]]_Taxonomy]
GO
ALTER TABLE [dbo].[CMSPostTypeFieldStructure]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Field.Structure_CMS.Post.Type] FOREIGN KEY([PostTypeID])
REFERENCES [dbo].[CMSPostType] ([TypeID])
GO
ALTER TABLE [dbo].[CMSPostTypeFieldStructure] CHECK CONSTRAINT [FK_CMS.Post.Field.Structure_CMS.Post.Type]
GO
ALTER TABLE [dbo].[CMSPostTypeFieldStructure]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type.Field.Structure_CMS.Field.Types] FOREIGN KEY([FieldTypeID])
REFERENCES [dbo].[CMSFieldType] ([FieldTypeID])
GO
ALTER TABLE [dbo].[CMSPostTypeFieldStructure] CHECK CONSTRAINT [FK_CMS.Post.Type.Field.Structure_CMS.Field.Types]
GO
ALTER TABLE [dbo].[CMSPostTypeTaxonomy]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Post.Type.Taxonomy_CMS.Taxonomy] FOREIGN KEY([ForTaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[CMSPostTypeTaxonomy] CHECK CONSTRAINT [FK_CMS.Post.Type.Taxonomy_CMS.Taxonomy]
GO
ALTER TABLE [dbo].[LeadFieldMetaChekbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Lead.Field.Meta.Chekbox] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[LeadFieldMetaChekbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Lead.Field.Meta.Chekbox]
GO
ALTER TABLE [dbo].[LeadFieldMetaChekbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[LeadFieldMetaChekbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy]
GO
ALTER TABLE [dbo].[LeadFieldMetaChekbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy.Term] FOREIGN KEY([TermParentID], [TaxonomyID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID])
GO
ALTER TABLE [dbo].[LeadFieldMetaChekbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Chekbox_Taxonomy.Term]
GO
ALTER TABLE [dbo].[LeadFieldMetaDropdown]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Lead.Field] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[LeadFieldMetaDropdown] CHECK CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Lead.Field]
GO
ALTER TABLE [dbo].[LeadFieldMetaDropdown]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[LeadFieldMetaDropdown] CHECK CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy]
GO
ALTER TABLE [dbo].[LeadFieldMetaDropdown]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy.Term] FOREIGN KEY([TermParentID], [TaxonomyID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID])
GO
ALTER TABLE [dbo].[LeadFieldMetaDropdown] CHECK CONSTRAINT [FK_Lead.Field.Meta.Dropdown_Taxonomy.Term]
GO
ALTER TABLE [dbo].[LeadFieldMetaNumber]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Number_Lead.FieldStructure] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[LeadFieldMetaNumber] CHECK CONSTRAINT [FK_Lead.Field.Meta.Number_Lead.FieldStructure]
GO
ALTER TABLE [dbo].[LeadFieldMetaRadio]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Radio_Lead.Field] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[LeadFieldMetaRadio] CHECK CONSTRAINT [FK_Lead.Field.Meta.Radio_Lead.Field]
GO
ALTER TABLE [dbo].[LeadFieldMetaRadio]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[LeadFieldMetaRadio] CHECK CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy]
GO
ALTER TABLE [dbo].[LeadFieldMetaRadio]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy.Term] FOREIGN KEY([TermParentID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO
ALTER TABLE [dbo].[LeadFieldMetaRadio] CHECK CONSTRAINT [FK_Lead.Field.Meta.Radio_Taxonomy.Term]
GO
ALTER TABLE [dbo].[LeadFieldMetaTermsAllowed]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.TermsAllowed_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO
ALTER TABLE [dbo].[LeadFieldMetaTermsAllowed] CHECK CONSTRAINT [FK_Lead.Field.Meta.TermsAllowed_Taxonomy.Term]
GO
ALTER TABLE [dbo].[LeadFieldMetaTextbox]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Meta.Textbox_Lead.Field.Meta.Textbox] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[LeadFieldMetaTextbox] CHECK CONSTRAINT [FK_Lead.Field.Meta.Textbox_Lead.Field.Meta.Textbox]
GO
ALTER TABLE [dbo].[LeadFieldStructure]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Structure_Lead.Field.Structure.Group] FOREIGN KEY([GroupID])
REFERENCES [dbo].[LeadFieldStructureGroup] ([GroupID])
GO
ALTER TABLE [dbo].[LeadFieldStructure] CHECK CONSTRAINT [FK_Lead.Field.Structure_Lead.Field.Structure.Group]
GO
ALTER TABLE [dbo].[LeadFieldStructure]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field_Lead.Field.Type] FOREIGN KEY([FieldTypeID])
REFERENCES [dbo].[LeadFieldType] ([FieldTypeID])
GO
ALTER TABLE [dbo].[LeadFieldStructure] CHECK CONSTRAINT [FK_Lead.Field_Lead.Field.Type]
GO
ALTER TABLE [dbo].[LeadFieldValueScalar]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[LeadFieldValueScalar] CHECK CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead]
GO
ALTER TABLE [dbo].[LeadFieldValueScalar]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead.FieldStructure] FOREIGN KEY([FieldID], [FieldTypeID])
REFERENCES [dbo].[LeadFieldStructure] ([FieldID], [FieldTypeID])
GO
ALTER TABLE [dbo].[LeadFieldValueScalar] CHECK CONSTRAINT [FK_Lead.Field.Value.Scalar_Lead.FieldStructure]
GO
ALTER TABLE [dbo].[LeadFieldValueTaxonomy]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[LeadFieldValueTaxonomy] CHECK CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Lead]
GO
ALTER TABLE [dbo].[LeadFieldValueTaxonomy]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Taxonomy.Term] FOREIGN KEY([TermID], [TaxonomyID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID], [TaxonomyID])
GO
ALTER TABLE [dbo].[LeadFieldValueTaxonomy] CHECK CONSTRAINT [FK_Lead.Field.Value.Taxonomy_Taxonomy.Term]
GO
ALTER TABLE [dbo].[LeadLocation]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Location_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[LeadLocation] CHECK CONSTRAINT [FK_Lead.Location_Lead]
GO
ALTER TABLE [dbo].[LeadReview]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Review_Business] FOREIGN KEY([BusinessID])
REFERENCES [dbo].[Business] ([BusinessID])
GO
ALTER TABLE [dbo].[LeadReview] CHECK CONSTRAINT [FK_Lead.Review_Business]
GO
ALTER TABLE [dbo].[LeadReview]  WITH CHECK ADD  CONSTRAINT [FK_Lead.Review_Lead] FOREIGN KEY([LeadID])
REFERENCES [dbo].[Lead] ([LeadID])
GO
ALTER TABLE [dbo].[LeadReview] CHECK CONSTRAINT [FK_Lead.Review_Lead]
GO
ALTER TABLE [dbo].[LeadReviewMeasureScore]  WITH CHECK ADD  CONSTRAINT [FK_Review.Measure.Score_Lead.Review] FOREIGN KEY([LeadID])
REFERENCES [dbo].[LeadReview] ([LeadID])
GO
ALTER TABLE [dbo].[LeadReviewMeasureScore] CHECK CONSTRAINT [FK_Review.Measure.Score_Lead.Review]
GO
ALTER TABLE [dbo].[LeadReviewMeasureScore]  WITH CHECK ADD  CONSTRAINT [FK_Review.Measure.Score_Review.Measure] FOREIGN KEY([ReviewMeasureID])
REFERENCES [dbo].[LeadReviewMeasure] ([MeasureID])
GO
ALTER TABLE [dbo].[LeadReviewMeasureScore] CHECK CONSTRAINT [FK_Review.Measure.Score_Review.Measure]
GO
ALTER TABLE [dbo].[LeadGenLegal]  WITH CHECK ADD  CONSTRAINT [FK_LeadGen.Legal_Taxonomy.Term] FOREIGN KEY([LegalCountryID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO
ALTER TABLE [dbo].[LeadGenLegal] CHECK CONSTRAINT [FK_LeadGen.Legal_Taxonomy.Term]
GO
ALTER TABLE [dbo].[SystemScheduledTask]  WITH CHECK ADD  CONSTRAINT [FK_System.Task_System.TaskPeriod] FOREIGN KEY([IntervalID])
REFERENCES [dbo].[SystemScheduledTaskInterval] ([ID])
GO
ALTER TABLE [dbo].[SystemScheduledTask] CHECK CONSTRAINT [FK_System.Task_System.TaskPeriod]
GO
ALTER TABLE [dbo].[TaxonomyTerm]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy.Term] FOREIGN KEY([TermParentID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO
ALTER TABLE [dbo].[TaxonomyTerm] CHECK CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy.Term]
GO
ALTER TABLE [dbo].[TaxonomyTerm]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy1] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO
ALTER TABLE [dbo].[TaxonomyTerm] CHECK CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy1]
GO
ALTER TABLE [dbo].[TaxonomyTermWord]  WITH CHECK ADD  CONSTRAINT [FK_Taxonomy.Term.Word_System.WordCase] FOREIGN KEY([WordID])
REFERENCES [dbo].[SystemWordCase] ([WordID])
GO
ALTER TABLE [dbo].[TaxonomyTermWord] CHECK CONSTRAINT [FK_Taxonomy.Term.Word_System.WordCase]
GO
ALTER TABLE [dbo].[TaxonomyTermWord]  WITH CHECK ADD  CONSTRAINT [FK_Taxonomy.Term.Word_Taxonomy.Term] FOREIGN KEY([TermID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO
ALTER TABLE [dbo].[TaxonomyTermWord] CHECK CONSTRAINT [FK_Taxonomy.Term.Word_Taxonomy.Term]
GO
ALTER TABLE [dbo].[UserLogin]  WITH CHECK ADD  CONSTRAINT [FK_User.Login_User.Role] FOREIGN KEY([RoleID])
REFERENCES [dbo].[UserRole] ([RoleID])
GO
ALTER TABLE [dbo].[UserLogin] CHECK CONSTRAINT [FK_User.Login_User.Role]
GO
ALTER TABLE [dbo].[UserSession]  WITH CHECK ADD  CONSTRAINT [FK_User.Session_User.Login] FOREIGN KEY([LoginID])
REFERENCES [dbo].[UserLogin] ([LoginID])
GO
ALTER TABLE [dbo].[UserSession] CHECK CONSTRAINT [FK_User.Session_User.Login]
GO
ALTER TABLE [dbo].[LeadFieldValueScalar]  WITH CHECK ADD  CONSTRAINT [CK_Lead.Field.Value.Scalar.FieldTypeID] CHECK  (([FieldTypeID]=(7) OR [FieldTypeID]=(6) OR [FieldTypeID]=(5) OR [FieldTypeID]=(1)))
GO
ALTER TABLE [dbo].[LeadFieldValueScalar] CHECK CONSTRAINT [CK_Lead.Field.Value.Scalar.FieldTypeID]
GO
ALTER TABLE [dbo].[BusinessLocation]  WITH CHECK ADD  CONSTRAINT [FK_BusinessLocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([LocationId])
GO
ALTER TABLE [dbo].[LeadLocation]  WITH CHECK ADD  CONSTRAINT [FK_LeadLocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([LocationId])
GO
ALTER TABLE [dbo].[CMSPostFieldValue]  WITH CHECK ADD  CONSTRAINT [FK_CMSPostFieldLocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([LocationId])
GO

/****** Object:  StoredProcedure [dbo].[AdminBusinessPermissionSelectPending]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AdminBusinessPermissionSelectPending]
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
		[dbo].[BusinessLeadPermission] BLP 
		INNER JOIN [dbo].[BusinessRegionCountry] B ON B.BusinessID = BLP.BusinessID
		--INNER JOIN [dbo].[Business] B ON B.BusinessID = BLP.BusinessID
		--LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] BLPT ON BLPT.PermissionID = BLP.PermissionID
		--INNER JOIN [dbo].[TaxonomyTerm] TT ON TT.TermID = BLPT.TermID
	WHERE 
		BLP.ApprovedByAdminDateTime IS NULL 
		AND BLP.RequestedDateTime IS NOT NULL
		AND (@CountryID IS NULL OR @CountryID = B.CountryID)
		AND (@RegionID IS NULL OR @RegionID = B.RegionID)
	GROUP BY
		B.BusinessID, B.BusinessName, B.BusinessRegistrationDate
	ORDER BY Min(BLP.RequestedDateTime) DESC
END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessLoginAdd]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLoginAdd]
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
		INSERT INTO [dbo].[BusinessLogin] (
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
/****** Object:  StoredProcedure [dbo].[BusinessCreate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessCreate]
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
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceCreate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceCreate]
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
	FROM [dbo].[BusinessInvoice]
	WHERE [LegalCountryID] = @LegalCountryID
		AND YEAR(CreatedDateTime) = YEAR(@CreatedDateTime) 
	GROUP BY [LegalCountryID]
	SET @LegalNumber = ISNULL(@LegalNumber, 1);

	INSERT INTO [dbo].[BusinessInvoice] 
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
	INNER JOIN [dbo].[LeadGenLegal] l ON l.LegalCountryID = b.CountryID
	WHERE b.[BusinessID] = @BusinessID 

	SET @InvoiceID = SCOPE_IDENTITY()
END












GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceDelete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceDelete]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- IF the invoice is paid, then return 0 and do not delete the invoice
	IF EXISTS (
		SELECT 1 FROM [dbo].[BusinessInvoice] WHERE InvoiceID = @InvoiceID AND (PublishedDatetime IS NOT NULL OR PaidDateTime IS NOT NULL)
	)
		RETURN 0

    DECLARE invoiceLine_cursor CURSOR FOR   
    SELECT [LineID] FROM [dbo].[BusinessInvoiceLine]
	WHERE InvoiceID = @InvoiceID

	DECLARE @InvoiceLineID smallint

    OPEN invoiceLine_cursor  
    FETCH NEXT FROM invoiceLine_cursor INTO @InvoiceLineID  

    WHILE @@FETCH_STATUS = 0  
    BEGIN  

		EXEC [dbo].[BusinessInvoiceLineDelete] @InvoiceID, @InvoiceLineID

        FETCH NEXT FROM invoiceLine_cursor INTO @InvoiceLineID  
        END  
  
    CLOSE invoiceLine_cursor  
    DEALLOCATE invoiceLine_cursor 

	DELETE FROM [dbo].[BusinessInvoice] WHERE InvoiceID = @InvoiceID

END
















GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceLeadsSelectCompleted]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLeadsSelectCompleted]
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
	FROM [dbo].[BusinessLeadCompleted] LC
	WHERE LC.InvoiceID = @InoiceID

END










GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceLineCreate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineCreate]
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
	FROM [dbo].[BusinessInvoice] WHERE InvoiceID = @InvoiceID

	--SELECT MAX @InvoiceLineID
	SELECT 
		@InvoiceLineID = MAX([LineID])
	FROM [dbo].[BusinessInvoiceLine] 
	WHERE InvoiceID = @InvoiceID
	--Increase @InvoiceLineID for the new line
	SET @InvoiceLineID = ISNULL(@InvoiceLineID,0) + 1

	INSERT INTO [dbo].[BusinessInvoiceLine] (
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

	EXEC [dbo].[BusinessInvoiceTotalSumUpdate] @InvoiceID
END
















GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceLineCustomCreate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineCustomCreate]
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
	FROM [dbo].[BusinessInvoice] WHERE InvoiceID = @InvoiceID

	--SELECT MAX @InvoiceLineID
	SELECT 
		@InvoiceLineID = MAX(LineID)
	FROM [dbo].[BusinessInvoiceLine] 
	WHERE InvoiceID = @InvoiceID
	--Increase @InvoiceLineNumber for the new line
	SET @InvoiceLineID = ISNULL(@InvoiceLineID,0) + 1

	INSERT INTO [dbo].[BusinessInvoiceLine] (
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

	EXEC [dbo].[BusinessInvoiceTotalSumUpdate] @InvoiceID

END















GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceLineDelete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineDelete]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@InvoiceLineID smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Release completed leads from invoice line
	UPDATE [dbo].[BusinessLeadCompleted]
	SET [InvoiceID] = NULL,
		[InvoiceLineID] = NULL
	WHERE InvoiceID = @InvoiceID
		AND InvoiceLineID = @InvoiceLineID

	--Delete Line
	DELETE FROM [dbo].[BusinessInvoiceLine]
	WHERE InvoiceID = @InvoiceID
		AND LineID = @InvoiceLineID

	DECLARE @Result BIT
	SET @Result = @@ROWCOUNT

	--Update Invoice Total Sum
	EXEC [dbo].[BusinessInvoiceTotalSumUpdate] @InvoiceID

	Return @Result

END
















GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceLineLeadsCreate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineLeadsCreate]
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
	FROM [dbo].[BusinessInvoice] WHERE InvoiceID = @InvoiceID

	DECLARE @LeadFeeTotalSum decimal (19,4)
	SET @LeadFeeTotalSum = [dbo].[Business.Lead.Completed.GetCompletedTotalFeeSumBeforeDateForInvoice](@BusinessID, @CompletedBeforeDate);
	
	--If @LeadFeeTotalSum <= 0 that means no leads need to be added to the invoice line, so return and do not perform further 
	IF (@LeadFeeTotalSum <= 0) 
		RETURN

	--SELECT MAX @InvoiceLineID
	SELECT 
		@InvoiceLineID = MAX([LineID])
	FROM [dbo].[BusinessInvoiceLine] 
	WHERE InvoiceID = @InvoiceID
	--Increase @InvoiceLineID for the new line
	SET @InvoiceLineID = ISNULL(@InvoiceLineID,0) + 1

	INSERT INTO [dbo].[BusinessInvoiceLine] (
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
	UPDATE [dbo].[BusinessLeadCompleted]
	SET [InvoiceID] = @InvoiceID,
		[InvoiceLineID] = @InvoiceLineID
	WHERE BusinessID = @BusinessID
		AND CompletedDateTime < @CompletedBeforeDate
		AND InvoiceID IS NULL
		AND InvoiceLineID IS NULL


	EXEC [dbo].[BusinessInvoiceTotalSumUpdate] @InvoiceID

END
















GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceLineSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineSelect]
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
	FROM [dbo].[BusinessInvoiceLine] l
	LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] lc ON lc.InvoiceID = l.InvoiceID AND lc.InvoiceLineID = l.LineID
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
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceLineUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceLineUpdate]
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

	UPDATE [dbo].[BusinessInvoiceLine] 
	SET [Description] = @InvoiceLineDescription,
		[UnitPrice] = @UnitPrice,
		[Quantity] = @Quantity,
		[Tax] = @Tax
	WHERE [InvoiceID] = @InvoiceID AND [LineID] = @LineID

	EXEC [dbo].[BusinessInvoiceTotalSumUpdate] @InvoiceID
END
















GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoicePublish]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoicePublish]
	-- Add the parameters for the stored procedure here
	@InvoiceID bigint,
	@PublishedDatetime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BusinessInvoice] 
	SET [PublishedDatetime] = ISNULL(@PublishedDatetime, GETUTCDATE())
	WHERE [InvoiceID] = @InvoiceID

END
















GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceSelect]
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
	FROM [dbo].[BusinessInvoice] 
	WHERE (@InoiceID IS NULL OR [InvoiceID] = @InoiceID)
	AND (@BusinessID IS NULL OR [BusinessID] = @BusinessID)
	AND (@LegalYear IS NULL OR [LegalYear] = @LegalYear)
	AND (@LegalNumber IS NULL OR [LegalNumber] = @LegalNumber)

END
















GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceSetPaid]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceSetPaid]
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
		[dbo].[BusinessInvoice] 
	WHERE 
		[InvoiceID] = @InvoiceID

	--@LegalFacturaNumber must grow since the beginning of year LEGAL
	DECLARE @LegalFacturaNumber INT = NULL
	SELECT @LegalFacturaNumber = MAX(ISNULL(LegalFacturaNumber,0)) + 1
	FROM [dbo].[BusinessInvoice] 
	WHERE [LegalCountryID] = @LegalCountryID
		AND [LegalYear] = @LegalYear 
	GROUP BY [LegalCountryID]
	SET @LegalFacturaNumber = ISNULL(@LegalFacturaNumber, 1);

	UPDATE [dbo].[BusinessInvoice] 
	SET [PaidDateTime] = @PaidDatetime,
		[LegalFacturaNumber] = ISNULL([LegalFacturaNumber], @LegalFacturaNumber) --Keep the esisting [LegalFacturaNumber] if exists 
	WHERE [InvoiceID] = @InvoiceID

END
















GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceTotalSumUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceTotalSumUpdate]
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
	FROM [dbo].[BusinessInvoiceLine]
	WHERE [InvoiceID] = @InvoiceID
	GROUP BY [InvoiceID]
	SET @TotalSum = ISNULL(@TotalSum,0)
	
	--UPDATE Invoice TotalSum 
	UPDATE [dbo].[BusinessInvoice]
	SET [TotalSum] = @TotalSum
	WHERE [InvoiceID] = @InvoiceID

END
















GO
/****** Object:  StoredProcedure [dbo].[BusinessInvoiceUpdateBilling]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessInvoiceUpdateBilling]
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

	UPDATE [dbo].[BusinessInvoice] 
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
/****** Object:  StoredProcedure [dbo].[BusinessLeadCompletedSelectForNewInvoices]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadCompletedSelectForNewInvoices]
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
	FROM [dbo].[BusinessLeadCompleted]
	WHERE CompletedDateTime < @CompletedBeforeDate
		AND InvoiceID IS NULL
		AND InvoiceLineID IS NULL

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessLeadSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BusinessLeadSelect]
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
	FROM [dbo].[BusinessLeadSelectRequested](@BusinessID,@DateFrom, @DateTo, @LeadID)


	IF (@Status = 'All')
		INSERT INTO @Leads
		SELECT 
			L.[LeadID], L.[CreatedDateTime]
		FROM 
			[dbo].[Lead] L 
			LEFT OUTER JOIN @RequestedLeads R ON R.LeadID = L.LeadID
			LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
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
			LEFT OUTER JOIN [dbo].[BusinessLeadNotInterested] LNR ON LNR.LeadID = L.LeadID AND LNR.BusinessID = @BusinessID
			LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
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
			LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
			LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
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
			LEFT OUTER JOIN [dbo].[BusinessLeadImportant] BLI ON BLI.LeadID = L.LeadID AND BLI.BusinessID = @BusinessID
			LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
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
			LEFT OUTER JOIN [dbo].[BusinessLeadNotInterested] LNR ON LNR.LeadID = L.LeadID AND LNR.BusinessID = @BusinessID
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
			LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
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
			LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID
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
				LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] LCR ON LCR.LeadID = t.LeadID AND LCR.BusinessID = @BusinessID
				LEFT OUTER JOIN [dbo].[LeadFieldValueScalar] s ON s.LeadID = t.LeadID
				LEFT OUTER JOIN [dbo].[LeadFieldStructure] ls ON ls.FieldID = s.FieldID
				LEFT OUTER JOIN [dbo].[LeadFieldValueTaxonomy] lt ON lt.LeadID = t.LeadID
				LEFT OUTER JOIN [dbo].[TaxonomyTerm] tt ON tt.TermID = lt.TermID
				--LEFT OUTER JOIN CONTAINSTABLE([dbo].[LeadFieldValueScalar], TextValue, @ContainsQuery ) ft ON ft.[Key] = s.ID
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
	DECLARE @LeadIDs AS [dbo].[SysBigintTableType]; 

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
		LEFT OUTER JOIN [dbo].[BusinessLeadNotInterested] LNR ON LNR.LeadID = L.LeadID AND LNR.BusinessID = @BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadImportant] BLI ON BLI.LeadID = L.LeadID AND BLI.BusinessID = @BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] LCR ON LCR.LeadID = L.LeadID AND LCR.BusinessID = @BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] BLC ON BLC.LeadID = L.LeadID AND BLC.BusinessID = @BusinessID

END






GO
/****** Object:  StoredProcedure [dbo].[BusinessLeadSetCompleted]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetCompleted]
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

	IF EXISTS (SELECT 1 FROM [dbo].[BusinessLeadContactsRecieved] WHERE BusinessID = @BusinessID AND LeadID = @LeadID)
		INSERT INTO [dbo].[BusinessLeadCompleted]
			([LoginID], [BusinessID], [LeadID], [CompletedDateTime], [OrderSum], [SystemFeePercent])
		VALUES (@LoginID, @BusinessID, @LeadID, ISNULL(@CompletedDateTime,GETUTCDATE()), @OrderSum, @SystemFeePercent )


	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessLeadSetGetContact]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetGetContact]
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
	--FROM [dbo].[BusinessLeadSelectRequested](@BusinessID, @LeadID) 

	IF (@ISAproved = 1)
		INSERT INTO [dbo].[BusinessLeadContactsRecieved] 
			([LoginID], [BusinessID], [LeadID], [GetContactsDateTime])
		VALUES 
			(@LoginID, @BusinessID, @LeadID, ISNULL(@GetContactDateTime,GETUTCDATE()) )


	RETURN @ISAproved

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessLeadSetGetContact_PRODUCTION]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetGetContact_PRODUCTION]
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
	FROM [dbo].[BusinessLeadSelectRequested](@BusinessID, NULL, NULL, @LeadID) 

	IF (@ISAproved = 1)
		INSERT INTO [dbo].[BusinessLeadContactsRecieved] 
			([LoginID], [BusinessID], [LeadID], [GetContactsDateTime])
		VALUES 
			(@LoginID, @BusinessID, @LeadID, ISNULL(@GetContactDateTime,GETUTCDATE()) )


	RETURN @ISAproved

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessLeadSetImportant]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetImportant]
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

	INSERT INTO [dbo].[BusinessLeadImportant]
		([LoginID], [BusinessID], [LeadID], [ImportantDateTime])
	VALUES (@LoginID, @BusinessID, @LeadID, ISNULL(@ImportantDateTime,GETUTCDATE()) )

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessLeadSetInterested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetInterested]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[BusinessLeadNotInterested]
	WHERE [BusinessID] = @BusinessID AND [LeadID] = @LeadID

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessLeadSetNotified]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetNotified]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LeadID bigint,
	@NotifiedDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM [dbo].[BusinessLeadNotified] WHERE BusinessID = @BusinessID AND LeadID = @LeadID)
		INSERT INTO [dbo].[BusinessLeadNotified]
			(BusinessID, LeadID, [NotifiedDateTime])
		VALUES (@BusinessID, @LeadID, ISNULL(@NotifiedDateTime,GETUTCDATE()))


	RETURN 1

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessLeadSetNotifiedPost]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetNotifiedPost]
	-- Add the parameters for the stored procedure here
	@BusinessPostID bigint,
	@LeadID bigint,
	@NotifiedDateTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM [dbo].[BusinessLeadNotifiedPost] WHERE BusinessPostID = @BusinessPostID AND LeadID = @LeadID)
		INSERT INTO [dbo].[BusinessLeadNotifiedPost]
			(BusinessPostID, LeadID, [NotifiedDateTime])
		VALUES (@BusinessPostID, @LeadID, ISNULL(@NotifiedDateTime,GETUTCDATE()))


	RETURN 1

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessLeadSetNotImportant]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetNotImportant]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LoginID bigint,
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[BusinessLeadImportant]
	WHERE [BusinessID] = @BusinessID AND [LeadID] = @LeadID 

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessLeadSetNotInterested]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLeadSetNotInterested]
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

	INSERT INTO [dbo].[BusinessLeadNotInterested]
		([LoginID], [BusinessID], [LeadID], [NotInterestedDateTime])
	VALUES (@LoginID, @BusinessID, @LeadID, ISNULL(@NotInterestedDateTime,GETUTCDATE()) )

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessLocationAdminApprovalSet]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLocationAdminApprovalSet]
	-- Add the parameters for the stored procedure here
	@LocationID bigint,
	@BusinessID bigint,
	@ApprovedByAdminDateTime [datetime],
	@LoginID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BusinessLocation]
	   SET [ApprovedByAdminDateTime] = @ApprovedByAdminDateTime
	 WHERE LocationID = @LocationID AND BusinessID = @BusinessID

END












GO
/****** Object:  StoredProcedure [dbo].[BusinessLocationCreate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLocationCreate]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@LocationID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	INSERT INTO [dbo].[BusinessLocation]
           ([LocationID]
		   ,[BusinessID]
           ,[ApprovedByAdminDateTime])
     VALUES
           (@LocationID
		   ,@BusinessID
           ,NULL)

END












GO
/****** Object:  StoredProcedure [dbo].[BusinessLocationDelete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLocationDelete]
	-- Add the parameters for the stored procedure here
	@LocationID bigint,
	@BusinessID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[BusinessLocation]
	WHERE LocationID = @LocationID AND BusinessID = @BusinessID

	DELETE FROM [dbo].[Location]
	WHERE LocationID = @LocationID

END












GO
/****** Object:  StoredProcedure [dbo].[BusinessLocationSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessLocationSelect]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT BL.[BusinessID]
		  ,BL.[ApprovedByAdminDateTime]
		  ,L.[LocationID]
		  ,L.[Location]
		  ,L.[AccuracyMeters]
		  ,L.[RadiusMeters]
		  ,L.[LocationWithRadius]
		  ,L.[StreetAddress]
		  ,L.[PostalCode]
		  ,L.[City]
		  ,L.[Region]
		  ,L.[Country]
		  ,L.[Zoom]
		  ,L.[Name]
		  ,L.[CreatedDateTime]
		  ,L.[UpdatedDateTime]
	  FROM [dbo].[BusinessLocation] BL
	  INNER JOIN [dbo].[Location] L ON L.LocationID = BL.LocationID
	WHERE [BusinessID] = @BusinessID

END













GO
/****** Object:  StoredProcedure [dbo].[BusinessNotificationEmailDelete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessNotificationEmailDelete]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@email nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[BusinessNotificationEmail] WHERE [BusinessID] = @businessID AND [Email] = @email)
	BEGIN
		DELETE FROM [dbo].[BusinessNotificationEmail] WHERE [BusinessID] = @businessID AND [Email] = @email
		RETURN 1
	END
	ELSE
		RETURN 0

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessNotificationEmailInsert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessNotificationEmailInsert]
	-- Add the parameters for the stored procedure here
	@businessID bigint,
	@email nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @returnValue bit = 0

	IF NOT EXISTS (SELECT *	FROM [dbo].[BusinessNotificationEmail]
	WHERE [BusinessID] = @businessID AND [Email] = @email)
		BEGIN TRY
			INSERT INTO [dbo].[BusinessNotificationEmail] 
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
/****** Object:  StoredProcedure [dbo].[BusinessNotificationEmailSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessNotificationEmailSelect]
	-- Add the parameters for the stored procedure here
	@businessID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [Email] 
	FROM [BusinessNotificationEmail] 
	WHERE [BusinessID] = @businessID 

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessNotificationFrequencyUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessNotificationFrequencyUpdate]
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
/****** Object:  StoredProcedure [dbo].[BusinessPermissionApprove]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessPermissionApprove]
	-- Add the parameters for the stored procedure here
	@LoginID bigint,
	@PermissionID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BusinessLeadPermission] 
	SET ApprovedByAdminDateTime = GETUTCDATE()
	WHERE [PermissionID] = @PermissionID AND ApprovedByAdminDateTime IS NULL

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessPermissionCancelApprove]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessPermissionCancelApprove]
	-- Add the parameters for the stored procedure here
	@LoginID bigint,
	@PermissionID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BusinessLeadPermission] 
	SET ApprovedByAdminDateTime = NULL
	WHERE [PermissionID] = @PermissionID AND ApprovedByAdminDateTime IS NOT NULL

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessPermissionRemoveRequest]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessPermissionRemoveRequest]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@PermissionID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BusinessLeadPermission] 
	SET RequestedDateTime = NULL
	WHERE BusinessID = @BusinessID AND PermissionID = @PermissionID 

	RETURN @@ROWCOUNT

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessPermissionRequest]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessPermissionRequest]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@TermIDTable [dbo].[SysBigintTableType] READONLY,
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
	FROM [dbo].[BusinessLeadPermission] P
	LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] PT ON PT.PermissionID = P.PermissionID
	LEFT OUTER JOIN @TermIDTable TT ON TT.Item = PT.TermID
	WHERE P.BusinessID = @BusinessID
	GROUP BY PT.PermissionID
	HAVING SUM (TT.Item) IS NOT NULL AND COUNT(TT.Item) = @TermIDTableNumRows

	IF @PermissionID IS NULL
	BEGIN
		-- If @PermissionID IS NULL, ALTER new Permission ID
		EXEC [dbo].[SysGetNewPrimaryKeyValueForTable] 'Business.Lead.Permission', @PermissionID OUTPUT

		INSERT INTO [dbo].[BusinessLeadPermission] 
			([PermissionID], [BusinessID], [RequestedDateTime])
		VALUES
			(@PermissionID, @BusinessID, GETUTCDATE())

		INSERT INTO [dbo].[BusinessLeadPermissionTerm] 
			([PermissionID], [TermID])
		SELECT @PermissionID, Item FROM @TermIDTable	
	END
	ELSE
		-- Update Permission RequestedDateTime
		UPDATE [dbo].[BusinessLeadPermission] 
		SET [RequestedDateTime] = GETUTCDATE()
		WHERE PermissionID = @PermissionID AND BusinessID = @BusinessID AND [RequestedDateTime] IS NULL


END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessPermissionTermSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessPermissionTermSelect]
	-- Add the parameters for the stored procedure here
	@BusinessID bigint,
	@RequestedOnly bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT P.[PermissionID], P.[RequestedDateTime], P.[ApprovedByAdminDateTime], 
	TT.TermID, TT.TermName, TT.TermURL, TT.TermParentID, TT.TermThumbnailURL
	FROM [dbo].[BusinessLeadPermission] P
	LEFT OUTER JOIN [dbo].[BusinessLeadPermissionTerm] PT ON PT.PermissionID = P.PermissionID
	INNER JOIN [dbo].[TaxonomyTerm] TT ON TT.TermID = PT.TermID
	WHERE P.[BusinessID] = @BusinessID 
	AND (@RequestedOnly = 0 OR @RequestedOnly = 1 AND P.[RequestedDateTime] IS NOT NULL)
	

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessSelect]
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
				LEFT OUTER JOIN [dbo].[BusinessLogin] BL ON BL.BusinessID = B.BusinessID
				LEFT OUTER JOIN [dbo].[UserLogin] UL ON UL.LoginID = BL.LoginID 
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
	DECLARE @BusinessIDs AS [dbo].[SysBigintTableType]; 

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
		INNER JOIN [dbo].[TaxonomyTerm] T ON T.TermID = B.CountryID
		INNER JOIN [dbo].[BusinessLogin] BL ON BL.BusinessID = B.BusinessID AND BL.RoleID = 2
	ORDER BY B.[RegistrationDate] DESC

END




















GO
/****** Object:  StoredProcedure [dbo].[BusinessUpdateBasic]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessUpdateBasic]
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
/****** Object:  StoredProcedure [dbo].[BusinessUpdateBilling]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessUpdateBilling]
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
/****** Object:  StoredProcedure [dbo].[BusinessUpdateContact]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessUpdateContact]
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
/****** Object:  StoredProcedure [dbo].[CMSAttachmentDelete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentDelete]
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

				DELETE FROM [dbo].[CMSAttachmentTerm]
				WHERE [AttachmentID] = @AttachmentID

				DELETE FROM [dbo].[CMSAttachmentImage]
				WHERE [AttachmentID] = @AttachmentID

				DELETE FROM [dbo].[CMSAttachment]
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
/****** Object:  StoredProcedure [dbo].[CMSAttachmentGetByID]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentGetByID]
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
	FROM [dbo].[CMSAttachment] A 
	INNER JOIN [dbo].[CMSAttachmentType] AT ON AT.AttachmentTypeID = A.TypeID 
	LEFT OUTER JOIN [dbo].[CMSAttachmentImage] AI ON AI.AttachmentID = A.AttachmentID
	LEFT OUTER JOIN [dbo].[CMSAttachmentImageSize] AIS ON AIS.ImageSizeID = AI.ImageSizeOptionID
	LEFT OUTER JOIN [dbo].[CMSAttachmentTerm] ATT ON ATT.AttachmentID = A.AttachmentID
	LEFT OUTER JOIN [dbo].[TaxonomyTerm] TT ON TT.TermID = ATT.TermID
	LEFT OUTER JOIN [dbo].[Taxonomy] T ON T.TaxonomyID = TT.TaxonomyID
	WHERE 
		A.AttachmentID = @AttachmentID
END


















GO
/****** Object:  StoredProcedure [dbo].[CMSAttachmentImageInsert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentImageInsert]
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

	INSERT INTO [dbo].[CMSAttachmentImage]
		([AttachmentID], [ImageSizeOptionID], [URL])
	VALUES
		(@AttachmentID, @ImageSizeOptionID, @URL)

END

















GO
/****** Object:  StoredProcedure [dbo].[CMSAttachmentImageSizeSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentImageSizeSelect]
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
	FROM [dbo].[CMSAttachmentImageSize] 
END





















GO
/****** Object:  StoredProcedure [dbo].[CMSAttachmentProcessNew]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentProcessNew]
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
	FROM [dbo].[CMSAttachment] 
	WHERE [FileHash] = @FileHash 
	AND [FileSizeBytes] = @FileSizeBytes

	IF (@AttachmentID IS NULL)
		SET @isNewAttachment = 1
	ELSE
		SET @isNewAttachment = 0

	IF (@isNewAttachment = 1)
	BEGIN

		INSERT INTO [dbo].[CMSAttachment]
			([AuthorID], [TypeID], [MIME], [URL], [DateCreated], [FileHash], [FileSizeBytes])
		VALUES 
			(@AuthorID, @AttachmentTypeID, @MIME, '', GETUTCDATE(), @FileHash, @FileSizeBytes) 

		SET @AttachmentID = SCOPE_IDENTITY() 

	END



END





















GO
/****** Object:  StoredProcedure [dbo].[CMSAttachmentSetURL]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentSetURL]
	-- Add the parameters for the stored procedure here
	@AttachmentID bigint,
	@URL nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [dbo].[CMSAttachment]
	SET [URL] = @URL
	WHERE [AttachmentID] = @AttachmentID

END





















GO
/****** Object:  StoredProcedure [dbo].[CMSAttachmentTermAdd]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentTermAdd]
	@Attachment bigint,
	@TermID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		INSERT INTO [dbo].[CMSAttachmentTerm]
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
/****** Object:  StoredProcedure [dbo].[CMSAttachmentTermRemoveAll]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentTermRemoveAll]
	@AttachmentID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[CMSAttachmentTerm]
	WHERE [AttachmentID] = @AttachmentID
END






















GO
/****** Object:  StoredProcedure [dbo].[CMSAttachmentUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSAttachmentUpdate]
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
	UPDATE [dbo].[CMSAttachment]
	SET [Name] = @Name,
	[Description] = @Description
	WHERE [AttachmentID] = @AttachmentID

END





















GO
/****** Object:  StoredProcedure [dbo].[CMSPostAttachmentLink]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostAttachmentLink]
	-- Add the parameters for the stored procedure here
	@PostID bigint,
	@AttachmentID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO [dbo].[CMSPostAttachment]
			([AttachmentID], [PostID], [LinkDate])
		VALUES (@AttachmentID, @PostID, GETUTCDATE()) 
		
		RETURN 1

	END TRY
	BEGIN CATCH

	  RETURN 0

	END CATCH 




END





















GO
/****** Object:  StoredProcedure [dbo].[CMSPostAttachmentUnlink]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostAttachmentUnlink]
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

		UPDATE [dbo].[CMSPost]
		SET [ThumbnailAttachmentID] = NULL
		WHERE [PostID] = @PostID AND [ThumbnailAttachmentID] = @AttachmentID

		DELETE FROM [dbo].[CMSPostAttachment]
		WHERE [AttachmentID] = @AttachmentID AND [PostID] = @PostID

		SELECT @AttachmentUsed = COUNT(*) 
		FROM [dbo].[CMSPostAttachment]
		WHERE [AttachmentID] = @AttachmentID

END





















GO
/****** Object:  StoredProcedure [dbo].[CMSPostCreateEmpty]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[CMSPostCreateEmpty]
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
	INSERT INTO [dbo].[CMSPost] 
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
	UPDATE [dbo].[CMSPost] 
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
			UPDATE [dbo].[CMSPost] 
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
/****** Object:  StoredProcedure [dbo].[CMSPostCreateMultipleForTaxonomyType]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostCreateMultipleForTaxonomyType]
	-- Add the parameters for the stored procedure here
	@TaxonomyTypeID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- ALTER POSTS
	INSERT INTO [dbo].[CMSPost] 
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
	FROM [dbo].[CMSPostTypeTaxonomy] ptt
	LEFT OUTER JOIN [dbo].[TaxonomyTerm] t on t.TaxonomyID = ptt.ForTaxonomyID
	LEFT OUTER JOIN [dbo].[CMSPost] p on p.TypeID = ptt.PostTypeID AND p.PostForTermID = t.TermID
	WHERE ptt.PostTypeID = @TaxonomyTypeID AND p.PostID IS NULL AND t.TermID IS NOT NULL

	-- PUBLISH CREATED AND EXISTED POSTS
	UPDATE [dbo].[CMSPost]
	SET [StatusID] = 50,
	[DatePublished] = GETUTCDATE()
	WHERE TypeID = @TaxonomyTypeID AND ([StatusID] <> 50 OR [DatePublished] IS NULL)

END


















GO
/****** Object:  StoredProcedure [dbo].[CMSPostDelete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[CMSPostDelete]
	-- Add the parameters for the stored procedure here
	@PostID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION [PostDelete]

	BEGIN TRY

		DELETE FROM [dbo].[CMSPostTerm]
		WHERE [PostID] = @PostID

		DELETE FROM [dbo].[CMSPostAttachment]
		WHERE [PostID] = @PostID

		DELETE FROM [dbo].[CMSPostFieldValue]
		WHERE [PostID] = @PostID

		DELETE FROM [dbo].[CMSPost]
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
/****** Object:  StoredProcedure [dbo].[CMSPostDisableMultipleForTaxonomyType]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostDisableMultipleForTaxonomyType]
	-- Add the parameters for the stored procedure here
	@TaxonomyTypeID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- PUBLISH CREATED AND EXISTED POSTS
	UPDATE [dbo].[CMSPost]
	SET [StatusID] = 10,
	[DatePublished] = NULL
	WHERE TypeID = @TaxonomyTypeID AND ([StatusID] = 50 OR [DatePublished] IS NOT NULL)

END


















GO
/****** Object:  StoredProcedure [dbo].[CMSPostFieldValueInsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostFieldValueInsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@PostID bigint,
	@FieldID int,
	@TextValue nvarchar(max) = NULL,
	@DatetimeValue datetime = NULL,
	@BoolValue bit = NULL,
	@NumberValue bigint = NULL,
	@LocationID bigint = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[CMSPostFieldValue] WHERE PostID = @PostID AND FieldID = @FieldID)
	BEGIN

		DECLARE @OldLocationID BIGINT
		SELECT  @OldLocationID = [LocationID] 
		FROM [dbo].[CMSPostFieldValue] 
		WHERE [PostID] = @PostID AND [FieldID] = @FieldID

		UPDATE [dbo].[CMSPostFieldValue] 
		SET [TextValue] = @TextValue,
		[DatetimeValue] = @DatetimeValue,
		[BoolValue] = @BoolValue,
		[NumberValue] = @NumberValue,
		[LocationID] = @LocationID
		WHERE [PostID] = @PostID AND [FieldID] = @FieldID

		EXEC [dbo].[LocationDelete] @OldLocationID

		RETURN @@ROWCOUNT

	END
	ELSE 
	BEGIN

		DECLARE @FieldTypeID int = NULL
		SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[CMSPostTypeFieldStructure] WHERE [FieldID] = @FieldID

		DECLARE @PostTypeID int = NULL
		SELECT @PostTypeID = [TypeID] FROM [dbo].[CMSPost] WHERE [PostID] = @PostID

		BEGIN TRY
			INSERT INTO [dbo].[CMSPostFieldValue] 
				(PostID, PostTypeID, [FieldID], [TextValue], [DatetimeValue], [BoolValue], [NumberValue], [LocationID])
			VALUES
				(@PostID, @PostTypeID, @FieldID, @TextValue, @DatetimeValue, @BoolValue, @NumberValue, @LocationID)
			RETURN 1
		END TRY
		BEGIN CATCH
			RETURN 0
		END CATCH

	END




END




















GO
/****** Object:  StoredProcedure [dbo].[CMSPostFieldValueSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostFieldValueSelect]
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
		FV.NumberValue,
		FV.LocationID
	FROM [dbo].[CMSPost] P 
	INNER JOIN [dbo].[CMSPostTypeFieldStructure] FS ON FS.PostTypeID = P.TypeID
	INNER JOIN [dbo].[CMSFieldType] FT ON FT.FieldTypeID = FS.FieldTypeID
	LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FV ON FV.PostID = P.PostID AND FV.FieldID = FS.FieldID
	WHERE P.PostID = @PostID
	ORDER BY FV.FieldID

END





















GO
/****** Object:  StoredProcedure [dbo].[CMSPostGetAttachments]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostGetAttachments]
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
	FROM [dbo].[CMSPostAttachment] PA
	INNER JOIN [dbo].[CMSAttachment] A ON A.[AttachmentID] = PA.[AttachmentID]
	INNER JOIN [dbo].[CMSAttachmentType] AT ON AT.AttachmentTypeID = A.TypeID 
	LEFT OUTER JOIN [dbo].[CMSAttachmentImage] AI ON AI.AttachmentID = A.AttachmentID
	LEFT OUTER JOIN [dbo].[CMSAttachmentImageSize] AIS ON AIS.ImageSizeID = AI.ImageSizeOptionID
	LEFT OUTER JOIN [dbo].[CMSAttachmentTerm] ATT ON ATT.AttachmentID = A.AttachmentID
	LEFT OUTER JOIN [dbo].[TaxonomyTerm] TT ON TT.TermID = ATT.TermID
	LEFT OUTER JOIN [dbo].[Taxonomy] T ON T.TaxonomyID = TT.TaxonomyID
	WHERE 
		PA.[PostID] = @PostID
	ORDER BY A.DateCreated Desc
END


















GO
/****** Object:  StoredProcedure [dbo].[CMSPostIfPostExistInOffsprings]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostIfPostExistInOffsprings] 
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
		FROM [dbo].[CMSPost]
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
			EXEC [dbo].[CMSPostIfPostExistInOffsprings] @ChildID, @TestPostID, @isExist OUT
			--SET @isExist = @RecursiveResult
			
		END

		FETCH NEXT FROM @ChildrenPostsCursor INTO @ChildID
	END
	CLOSE @ChildrenPostsCursor
	DEALLOCATE @ChildrenPostsCursor

	RETURN @isExist

END






















GO
/****** Object:  StoredProcedure [dbo].[CMSPostIsUniqueURL]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostIsUniqueURL]
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
	FROM [dbo].[CMSPost] P
	WHERE 
		P.[PostURL] = @PostURL 
		AND P.[TypeID] = @PostTypeID
		AND (ISNULL(P.[PostParentID], 0) = ISNULL(@PostParentID, 0))
		AND (@ExcludePostID IS NULL OR P.PostID != @ExcludePostID)
END






















GO
/****** Object:  StoredProcedure [dbo].[CMSPostSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostSelect]
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
			[dbo].[CMSPost] P 
			INNER JOIN [dbo].[CMSPostStatus] PS ON PS.[StatusID] = P.[StatusID] 
			INNER JOIN [dbo].[CMSPostType] PT ON PT.[TypeID] = P.[TypeID] 
			LEFT OUTER JOIN [dbo].[CMSPostTerm] TE ON TE.[PostID] = P.[PostID] 
			LEFT OUTER JOIN [dbo].[TaxonomyTerm] TT ON TT.[TermID] = TE.[TermID] 
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
				[dbo].[CMSPost] P 
				INNER JOIN @Posts t2 ON t2.PostID = P.[PostID]
			WHERE 
				P.Title like @LikeQuery OR P.PostURL like @LikeQuery
		) s ON s.[PostID] = t.[PostID]
		WHERE s.[PostID] IS NULL

	END

	--SET @TotalCount
	SELECT @TotalCount = COUNT(*) FROM @Posts

	-- Declare a variable that references the type.
	DECLARE @PostIDs AS [dbo].[SysBigintTableType]; 

	-- Add data to the table variable. 
	INSERT INTO @PostIDs (Item)
	SELECT [PostID]
	FROM @Posts t
	ORDER BY [Order] DESC, [DatePublished] DESC
	OFFSET @Offset ROWS
	FETCH NEXT @Fetch ROWS ONLY

	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[CMSPostSelectByIDs] (@PostIDs) 
	ORDER BY [Order] DESC, [DatePublished] DESC

END









GO
/****** Object:  StoredProcedure [dbo].[CMSPostSelectByScalarField]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostSelectByScalarField]
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
	DECLARE @PostIDs AS [dbo].[SysBigintTableType];  
  
	-- Add data to the table variable. 
	INSERT INTO @PostIDs (Item)
	SELECT 
		FL.[PostID]
	FROM [dbo].[CMSPostFieldValue] FL
		INNER JOIN [dbo].[CMSPostTypeFieldStructure] FS ON FS.FieldID = FL.FieldID AND FS.FieldCode = @FieldCode
	WHERE (@TextValue IS NULL OR @TextValue = FL.TextValue) 
		AND (@DatetimeValue IS NULL OR @DatetimeValue = FL.DatetimeValue) 
		AND (@BoolValue IS NULL OR @BoolValue = FL.BoolValue) 
		AND (@NumberValue IS NULL OR @NumberValue = FL.NumberValue) 
	GROUP BY
		FL.[PostID]

	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[CMSPostSelectByIDs] (@PostIDs)

END








GO
/****** Object:  StoredProcedure [dbo].[CMSPostSelectByUrls]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
	SELECT * FROM [dbo].[CMSPostSelectByIDs] (@PostIDs) 

END




GO
/****** Object:  StoredProcedure [dbo].[CMSPostStatusSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostStatusSelect]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		[StatusID], 
		[StatusName] 
	FROM 
		[dbo].[CMSPostStatus]
	ORDER BY [StatusID] ASC
END





















GO
/****** Object:  StoredProcedure [dbo].[CMSPostTermAdd]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTermAdd]
	@PostID bigint,
	@TermID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	DECLARE @PostTypeID INT
	SELECT @PostTypeID = [TypeID] FROM [dbo].[CMSPost] WHERE [PostID] = @PostID

	DECLARE @TaxonomyID INT
	SELECT @TaxonomyID = [TaxonomyID] FROM [dbo].[TaxonomyTerm] WHERE [TermID] = @TermID

	BEGIN TRY
		INSERT INTO [dbo].[CMSPostTerm] 
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
/****** Object:  StoredProcedure [dbo].[CMSPostTermRemoveAll]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTermRemoveAll]
	@PostID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[CMSPostTerm] 
	WHERE [PostID] = @PostID
END






















GO
/****** Object:  StoredProcedure [dbo].[CMSPostTypeAttachmentTaxonomyAddOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeAttachmentTaxonomyAddOrUpdate]
	-- Add the parameters for the stored procedure here
	@PostTypeID int,
	@AttachmentTaxonomyID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT * FROM [dbo].[CMSPostTypeAttachmentTaxonomy] WHERE [PostTypeID] = @PostTypeID AND [AttachmentTaxonomyID] = @AttachmentTaxonomyID)
		BEGIN

			INSERT INTO [dbo].[CMSPostTypeAttachmentTaxonomy]
				([PostTypeID], [AttachmentTaxonomyID], [IsEnabled])
			VALUES
				(@PostTypeID, @AttachmentTaxonomyID, 1)

		END
	ELSE
	BEGIN

		UPDATE [dbo].[CMSPostTypeAttachmentTaxonomy]
		SET IsEnabled = 1
		WHERE [PostTypeID] = @PostTypeID
		AND [AttachmentTaxonomyID] = @AttachmentTaxonomyID

	END

END
















GO
/****** Object:  StoredProcedure [dbo].[CMSPostTypeAttachmentTaxonomyDisable]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeAttachmentTaxonomyDisable]
	-- Add the parameters for the stored procedure here
	@PostTypeID int,
	@AttachmentTaxonomyID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[CMSPostTypeAttachmentTaxonomy]
	SET IsEnabled = 0
	WHERE [PostTypeID] = @PostTypeID
	AND [AttachmentTaxonomyID] = @AttachmentTaxonomyID

END
















GO
/****** Object:  StoredProcedure [dbo].[CMSPostTypeAttachmentTaxonomySelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeAttachmentTaxonomySelect]
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
	LEFT OUTER JOIN [dbo].[CMSPostTypeAttachmentTaxonomy] PTAT ON PTAT.AttachmentTaxonomyID = T.TaxonomyID AND PTAT.PostTypeID = @PostTypeID
	WHERE @EnabledOnly = 0 OR PTAT.IsEnabled = @EnabledOnly
END

















GO
/****** Object:  StoredProcedure [dbo].[CMSPostTypeInsert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeInsert] 
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
		FROM [dbo].[CMSPostType]
		WHERE [TypeName] = @typeName 
	) > 0
	BEGIN
		Set @InsertError = 1
		SET @errorText = 'FAILED Name'
	END

	--Check if @TermURL already exist in the current @TaxonomyID
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[CMSPostType]
		WHERE TypeURL = @typeURL 
	) > 0
	BEGIN
		Set @InsertError = 1
		SET @errorText = 'FAILED URL'
	END

	If @InsertError = 0
	BEGIN TRY

		INSERT INTO [dbo].[CMSPostType] (
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
/****** Object:  StoredProcedure [dbo].[CMSPostTypeSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeSelect]
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
	FROM [dbo].[CMSPostType]
	WHERE
			(@TypeID IS NULL OR [TypeID] = @TypeID) 
		AND (@TypeCode IS NULL OR [TypeCode] = @TypeCode) 
		AND (@TypeName IS NULL OR [TypeName] = @TypeName) 
		AND (@TypeURL IS NULL OR [TypeURL] = @TypeURL) 
END





















GO
/****** Object:  StoredProcedure [dbo].[CMSPostTypeSelect_SiteMapData]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeSelect_SiteMapData]
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
			--Need to use the same ordering in PostNumber as in [dbo].[CMSPostSelect] procedure
			ROW_NUMBER() OVER(PARTITION BY pt.[TypeID] ORDER BY [Order] DESC, [DatePublished] DESC) AS PostNumber
			,pt.[TypeID]
			,pt.[TypeURL]
			,pt.[TypeCode]
			,p.[PostID]
			,p.[Order]
			,p.[DatePublished]
			,p.[DateLastModified]
		FROM [dbo].[CMSPostType] pt
		INNER JOIN [dbo].[CMSPost] p ON p.TypeID = pt.TypeID
		WHERE 
		pt.IsBrowsable = 1 
		AND p.DatePublished IS NOT NULL
	) t
	GROUP BY t.TypeID, t.TypeURL, t.TypeCode, (t.PostNumber-1)/@PageSize
	ORDER BY t.TypeID DESC--, [DatePublished] DESC
END






GO
/****** Object:  StoredProcedure [dbo].[CMSPostTypeTaxonomyAddOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeTaxonomyAddOrUpdate]
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

	IF NOT EXISTS (SELECT * FROM [dbo].[CMSPostTypeTaxonomy] WHERE [ForPostTypeID] = @ForPostTypeID AND [ForTaxonomyID] = @ForTaxonomyID)
	BEGIN
		
		BEGIN TRAN T1  
			BEGIN TRY
			
				declare @PostTypeName nvarchar(255) = Concat('PostTypeFor Tax:',@ForTaxonomyID,' PostType:',@ForPostTypeID)
				declare @TypeCode nvarchar(255) = Concat('tax_',@ForTaxonomyID,'__posttype_',@ForPostTypeID)

				--Add new post type for the taxonomy
				INSERT INTO [dbo].[CMSPostType] 
				([TypeCode], [TypeName], [TypeURL], [SeoTitle], [SeoMetaDescription], [SeoMetaKeywords], [SeoPriority], [SeoChangeFrequencyID])
				VALUES 
				(@TypeCode, @PostTypeName, @URL, @SeoTitle, @SeoMetaDescription, @SeoMetaKeywords, @SeoPriority, @SeoChangeFrequencyID) 

				SELECT @TaxonomyPostTypeID = @@IDENTITY;  

				--Add new mapping between simple post type and taxonomy post type
				INSERT INTO [dbo].[CMSPostTypeTaxonomy]
				([PostTypeID], [ForPostTypeID], [ForTaxonomyID], [IsEnabled])
				VALUES
				(@TaxonomyPostTypeID, @ForPostTypeID, @ForTaxonomyID, 1)

				--Update [ForTaxonomyID] [ForPostTypeID]. Can do that only now because there is a constraint [dbo].[CMSPostTypeTaxonomy] table
				UPDATE [dbo].[CMSPostType] 
				SET [ForTaxonomyID] = @ForTaxonomyID,
				[ForPostTypeID] = @ForPostTypeID
				WHERE [TypeID] = @TaxonomyPostTypeID

				SET @Result = 1
				COMMIT TRAN T1
			END TRY		
			BEGIN CATCH
				--IF HAD ERRORS
				ROLLBACK TRAN T1
				SET @Result = 0

				DECLARE @msg nvarchar(2048) = error_message()  
			    RAISERROR (@msg, 16, 1)
			END CATCH 
		
		

	END

	ELSE
	BEGIN

		SELECT @TaxonomyPostTypeID = [PostTypeID]
		FROM [dbo].[CMSPostTypeTaxonomy]
		WHERE [ForTaxonomyID] = @ForTaxonomyID AND [ForPostTypeID] = @ForPostTypeID


		UPDATE [dbo].[CMSPostTypeTaxonomy] 
		SET [IsEnabled] = 1
		WHERE [ForTaxonomyID] = @ForTaxonomyID 
		AND [ForPostTypeID] = @ForPostTypeID	

		UPDATE [dbo].[CMSPostType] 
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
		EXEC [dbo].[CMSPostCreateMultipleForTaxonomyType] @TaxonomyPostTypeID
	END



END
GO
/****** Object:  StoredProcedure [dbo].[CMSPostTypeTaxonomyDisable]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeTaxonomyDisable]
	-- Add the parameters for the stored procedure here
	@ForPostTypeID int,
	@ForTaxonomyID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TaxonomyPostTypeID INT = NULL

	UPDATE [dbo].[CMSPostTypeTaxonomy] 
	SET [IsEnabled] = 0
	WHERE [ForTaxonomyID] = @ForTaxonomyID 
	AND [ForPostTypeID] = @ForPostTypeID	

	SELECT @TaxonomyPostTypeID = [PostTypeID]
	FROM [dbo].[CMSPostTypeTaxonomy] 
	WHERE [ForTaxonomyID] = @ForTaxonomyID 
	AND [ForPostTypeID] = @ForPostTypeID 
	AND [IsEnabled] = 0

	EXEC [dbo].[CMSPostDisableMultipleForTaxonomyType] @TaxonomyPostTypeID

END
















GO
/****** Object:  StoredProcedure [dbo].[CMSPostTypeTaxonomySelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeTaxonomySelect]
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
	LEFT OUTER JOIN [dbo].[CMSPostTypeTaxonomy] PTT ON PTT.ForTaxonomyID = T.TaxonomyID  AND (@ForPostTypeID IS NOT NULL AND PTT.ForPostTypeID = @ForPostTypeID AND PTT.ForTaxonomyID = T.TaxonomyID)
	LEFT OUTER JOIN [dbo].[CMSPostType] PT ON PT.ForPostTypeID = PTT.ForPostTypeID AND PT.ForTaxonomyID = PTT.ForTaxonomyID
	WHERE 
	(@ForTaxonomyID IS NULL OR T.TaxonomyID = @ForTaxonomyID) 
	AND (@EnabledOnly = 0 OR PTT.IsEnabled = @EnabledOnly)
END

















GO
/****** Object:  StoredProcedure [dbo].[CMSPostTypeUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostTypeUpdate]
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

		UPDATE [dbo].[CMSPostType] SET 
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
/****** Object:  StoredProcedure [dbo].[CMSPostUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSPostUpdate]
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
	@CustomCSS nvarchar(MAX) = NULL,
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
	FROM [dbo].[CMSPost] 
	WHERE [PostID] = @PostID


	Declare @UpdateError bit = 0


	IF @PostParentID IS NOT NULL 
	BEGIN
		--Check if @TermParentID has the same TaxonomyID as the @TermID
		IF 0 = (SELECT COUNT(*) 
				FROM [dbo].[CMSPost] 
				WHERE [PostID] = @PostParentID AND [TypeID] = @PostTypeID)
		BEGIN
			Set @UpdateError = 1
			SET @Result = 'FAILED PostParentID Type'
		END
		ELSE 
		BEGIN 
			--Check if @TermParentID does not exist in the @TermID offsprings
			DECLARE	@ExistInPostOffsprings bit
			EXEC	@ExistInPostOffsprings = [dbo].[CMSPostIfPostExistInOffsprings] @PostID, @PostParentID
			IF @PostID = @PostParentID OR @ExistInPostOffsprings = 1 BEGIN
				Set @UpdateError = 1
				SET @Result = 'FAILED PostParentID Offsprings'
			END
		END
	END

	--Check if @PostURL already exist in the current @PostTypeID and @PostParentID
	IF (
		SELECT COUNT(*) 
		FROM [dbo].[CMSPost]
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

		UPDATE [dbo].[CMSPost]
		SET [PostParentID] = @PostParentID,
			[StatusID] = @StatusID, 
			[AuthorID] = @AuthorID,
			[Title] = @Title, 
			[DateLastModified] = GETUTCDATE(),
			[ContentIntro] = @ContentIntro,
			[ContentPreview] = @ContentPreview,
			[ContentMain] = @ContentMain, 
			[ContentEnding] = @ContentEnding, 
			[CustomCSS] = @CustomCSS,
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
				UPDATE	[dbo].[CMSPost] 
				SET		[DatePublished] = GETUTCDATE()
				WHERE	[PostID] = @PostID AND 
						[DatePublished] IS NULL
			ELSE
				UPDATE	[dbo].[CMSPost] 
				SET		[DatePublished] = @DatePublished
				WHERE	[PostID] = @PostID
		ELSE 
			UPDATE	[dbo].[CMSPost] 
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
/****** Object:  StoredProcedure [dbo].[CMSTermSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CMSTermSelect] 
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
		[dbo].[TaxonomyTerm] TT 
		INNER JOIN [dbo].[Taxonomy] T ON T.[TaxonomyID] = TT.[TaxonomyID] 
		LEFT OUTER JOIN [dbo].[CMSPostTerm] PT ON PT.[PostID] = @PostID AND PT.[TermID] = TT.[TermID] 
		LEFT OUTER JOIN [dbo].[CMSAttachmentTerm] AT ON AT.[AttachmentID] = @AttachmentID AND AT.[TermID] = TT.[TermID] 
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
/****** Object:  StoredProcedure [dbo].[EmailQueueInsert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EmailQueueInsert]
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

	INSERT INTO [dbo].[EmailQueue] (
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
/****** Object:  StoredProcedure [dbo].[EmailQueueSelectNextEmailToSend]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EmailQueueSelectNextEmailToSend]
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
	FROM [dbo].[EmailQueue]
	WHERE SendingStartedDateTime IS NULL AND SendingScheduledDateTime <= @CurrentDateTime
	ORDER BY SendingScheduledDateTime ASC

END




















GO
/****** Object:  StoredProcedure [dbo].[EmailQueueSetSentDateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EmailQueueSetSentDateTime]
	-- Add the parameters for the stored procedure here
	@EmailID uniqueidentifier,
	@SentDateTime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[EmailQueue]
	SET SentDateTime = @SentDateTime
	WHERE EmailID = @EmailID

END




















GO
/****** Object:  StoredProcedure [dbo].[EmailQueueSetStartedDateTime]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EmailQueueSetStartedDateTime]
	-- Add the parameters for the stored procedure here
	@EmailID uniqueidentifier,
	@SendingStartedDateTime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[EmailQueue]
	SET SendingStartedDateTime = @SendingStartedDateTime
	WHERE EmailID = @EmailID

END




















GO
/****** Object:  StoredProcedure [dbo].[LeadCancelByUser]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadCancelByUser]
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
/****** Object:  StoredProcedure [dbo].[LeadEmailConfirm]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadEmailConfirm]
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
/****** Object:  StoredProcedure [dbo].[LeadFieldMetaTermIsAllowed]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldMetaTermIsAllowed]
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@isAllowed bit OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [dbo].[LeadFieldMetaTermsAllowed] WHERE [TermID] = @TermID)
		SET @isAllowed = 1;
	ELSE 
		SET @isAllowed = 0;

RETURN 0
END





















GO
/****** Object:  StoredProcedure [dbo].[LeadFieldMetaTermSetAllowance]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldMetaTermSetAllowance]
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@isAllowed bit = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [dbo].[LeadFieldMetaTermsAllowed] WHERE [TermID] = @TermID)
	BEGIN

		IF (@isAllowed = 0)
			DELETE FROM [dbo].[LeadFieldMetaTermsAllowed] WHERE [TermID] = @TermID

	END
	ELSE 
	BEGIN

		IF (@isAllowed = 1)
			INSERT INTO [dbo].[LeadFieldMetaTermsAllowed] ([TermID]) VALUES (@TermID)

	END


RETURN 0
END





















GO
/****** Object:  StoredProcedure [dbo].[LeadFieldStructureGroupInsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldStructureGroupInsertOrUpdate]
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

	IF EXISTS (SELECT * FROM [dbo].[LeadFieldStructureGroup] WHERE GroupID = @GroupID)
	BEGIN

		UPDATE [dbo].[LeadFieldStructureGroup] 
		SET [GroupCode] = @GroupCode,
		[GroupTitle] = @GroupTitle
		WHERE GroupID = @GroupID
		RETURN @@ROWCOUNT

	END
	ELSE 
	BEGIN

		BEGIN TRY
			INSERT INTO [dbo].[LeadFieldStructureGroup] 
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
/****** Object:  StoredProcedure [dbo].[LeadFieldStructureInsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldStructureInsertOrUpdate]
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

	INSERT INTO [dbo].[LeadFieldStructure]
		([FieldID], [FieldCode], [FieldName], [GroupID], [FieldTypeID], [LabelText], [IsRequired], [IsContact], [IsActive]) 
	VALUES 
		(@FieldID, @FieldCode, @FieldName, @GroupID, @FieldTypeID, @LabelText, @IsRequired, @IsContact, @IsActive)

	IF @FieldTypeID = 1
	INSERT INTO [dbo].[LeadFieldMetaTextbox]
		([FieldID], [Placeholder], [RegularExpression]) 
	VALUES 
		(@FieldID, @Placeholder, @RegularExpression)

	IF @FieldTypeID = 2
	INSERT INTO [dbo].[LeadFieldMetaDropdown]
		([FieldID], [Placeholder], [TaxonomyID], [TermParentID]) 
	VALUES 
		(@FieldID, @Placeholder, @TaxonomyID, @TermParentID)

	IF @FieldTypeID = 3
	INSERT INTO [dbo].[LeadFieldMetaChekbox]
		([FieldID], [TaxonomyID], [TermParentID]) 
	VALUES 
		(@FieldID, @TaxonomyID, @TermParentID)

	IF @FieldTypeID = 4
	INSERT INTO [dbo].[LeadFieldMetaRadio] 
		([FieldID], [TaxonomyID], [TermParentID]) 
	VALUES 
		(@FieldID, @TaxonomyID, @TermParentID)

	IF @FieldTypeID = 7
	INSERT INTO [dbo].[LeadFieldMetaNumber] 
		([FieldID], [Placeholder], [MinValue], [MaxValue]) 
	VALUES 
		(@FieldID, @Placeholder, @MinValue, @MaxValue)

RETURN 0


END





















GO
/****** Object:  StoredProcedure [dbo].[LeadFieldStructureSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldStructureSelect]
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
	FROM [dbo].[LeadFieldStructureGroup] FSG
	LEFT OUTER JOIN [dbo].[LeadFieldStructure] FS ON FS.GroupID = FSG.GroupID
	LEFT OUTER JOIN [dbo].[LeadFieldType] FT ON FT.FieldTypeID = FS.FieldTypeID
	LEFT OUTER JOIN [dbo].[LeadFieldMetaChekbox] MC ON FS.[FieldID] = MC.FieldID
	LEFT OUTER JOIN [dbo].[LeadFieldMetaDropdown] MD ON FS.[FieldID] = MD.FieldID 
	LEFT OUTER JOIN [dbo].[LeadFieldMetaRadio] MR ON FS.[FieldID] = MR.FieldID
	LEFT OUTER JOIN [dbo].[LeadFieldMetaTextbox] MT ON FS.[FieldID] = MT.FieldID
	LEFT OUTER JOIN [dbo].[LeadFieldMetaNumber] MN ON FS.[FieldID] = MN.FieldID
	WHERE @ActiveStatus IS NULL OR FS.isActive = @ActiveStatus
	ORDER BY FS.[Order] ASC
END




















GO
/****** Object:  StoredProcedure [dbo].[LeadFieldValueScalarDelete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldValueScalarDelete]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@FieldID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[LeadFieldValueScalar] WHERE [LeadID] = @LeadID AND [FieldID] = @FieldID 

	RETURN @@ROWCOUNT

END





















GO
/****** Object:  StoredProcedure [dbo].[LeadFieldValueScalarInsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldValueScalarInsertOrUpdate]
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
	SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[LeadFieldStructure] WHERE [FieldID] = @FieldID


	IF EXISTS (SELECT * FROM [dbo].[LeadFieldValueScalar] WHERE [LeadID] = @LeadID AND [FieldID] = @FieldID AND [FieldTypeID] = @FieldTypeID)
	BEGIN

		UPDATE [dbo].[LeadFieldValueScalar]
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
			INSERT INTO [dbo].[LeadFieldValueScalar]
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
/****** Object:  StoredProcedure [dbo].[LeadFieldValueSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldValueSelect]
	-- Add the parameters for the stored procedure here
	@LeadIDTable [dbo].[SysBigintTableType] READONLY
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
	CROSS JOIN [dbo].[LeadFieldStructure] LF
	INNER JOIN [dbo].[LeadFieldStructureGroup] LFG ON LFG.GroupID = LF.GroupID 
	INNER JOIN [dbo].[LeadFieldType] LFT ON LFT.FieldTypeID = LF.FieldTypeID
	LEFT OUTER JOIN [dbo].[LeadFieldValueScalar] FVS ON FVS.[LeadID] = L.[LeadID] AND FVS.[FieldID] = LF.[FieldID]
	LEFT OUTER JOIN [dbo].[LeadFieldValueTaxonomy] FVT ON FVT.[LeadID] = L.[LeadID] AND LF.[FieldID] = FVT.[FieldID]
	LEFT OUTER JOIN [dbo].[TaxonomyTerm] TT ON TT.TermID = FVT.TermID
	ORDER BY L.LeadID, LFG.GroupID, LF.[Order]

END

















GO
/****** Object:  StoredProcedure [dbo].[LeadFieldValueTaxonomyDelete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldValueTaxonomyDelete]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@FieldID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FieldTypeID int = NULL
	SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[LeadFieldStructure] WHERE [FieldID] = @FieldID

	DELETE FROM [dbo].[LeadFieldValueTaxonomy] 
	WHERE [LeadID] = @LeadID 
	AND [FieldID] = @FieldID 
	AND [FieldTypeID] = @FieldTypeID

	RETURN @@ROWCOUNT

END





















GO
/****** Object:  StoredProcedure [dbo].[LeadFieldValueTaxonomyInsert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadFieldValueTaxonomyInsert]
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
	SELECT @FieldTypeID = [FieldTypeID] FROM [dbo].[LeadFieldStructure] WHERE [FieldID] = @FieldID
	
	DECLARE @TaxonomyID int = NULL
	SELECT @TaxonomyID = [TaxonomyID] FROM [dbo].[TaxonomyTerm] WHERE [TermID] = @TermID

	BEGIN TRY
		
		INSERT INTO [LeadFieldValueTaxonomy]
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
/****** Object:  StoredProcedure [dbo].[LeadGetEmailConfirmationKey]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadGetEmailConfirmationKey]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TOP 1 TokenKey
	FROM [dbo].[SystemToken]
	WHERE [TokenAction] = 'LeadEmailConfirmation'
	AND [TokenValue] = @LeadID
	ORDER BY [TokenDateCreated] DESC

END




















GO
/****** Object:  StoredProcedure [dbo].[LeadInsert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadInsert]
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
/****** Object:  StoredProcedure [dbo].[LocationSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LocationSelect]
-- Add the parameters for the stored procedure here
	@LocationID BIGINT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  
		[LocationID]
		,[Location]
        ,[AccuracyMeters]
        ,[RadiusMeters]
        ,[StreetAddress]
        ,[PostalCode]
        ,[City]
        ,[Region]
        ,[Country]
		,[Zoom]
        ,[Name]
		,[CreatedDateTime]
		,[UpdatedDateTime]
		FROM [dbo].[Location]
		WHERE [LocationID] = @LocationID
END




GO
/****** Object:  StoredProcedure [dbo].[LocationCreate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LocationCreate]
-- Add the parameters for the stored procedure here
	@Location geography
	,@AccuracyMeters int
	,@RadiusMeters int
	,@StreetAddress nvarchar(255)
	,@PostalCode nvarchar(255)
	,@City nvarchar(255)
	,@Region nvarchar(255)
	,@Country nvarchar(255)
	,@Zoom int
	,@Name nvarchar(255)
	,@LocationID BIGINT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[Location]
           ([Location]
           ,[AccuracyMeters]
           ,[RadiusMeters]
           ,[StreetAddress]
           ,[PostalCode]
           ,[City]
           ,[Region]
           ,[Country]
		   ,[Zoom]
           ,[Name])
     VALUES
           (@Location
           ,@AccuracyMeters
           ,@RadiusMeters
           ,@StreetAddress
           ,@PostalCode
           ,@City
           ,@Region
           ,@Country
		   ,@Zoom
		   ,@Name)

	SET @LocationID = SCOPE_IDENTITY()
END


GO
/****** Object:  StoredProcedure [dbo].[LocationUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LocationUpdate]
-- Add the parameters for the stored procedure here
	@LocationID BIGINT
	,@Location geography
	,@AccuracyMeters int
	,@RadiusMeters int
	,@StreetAddress nvarchar(255)
	,@PostalCode nvarchar(255)
	,@City nvarchar(255)
	,@Region nvarchar(255)
	,@Country nvarchar(255)
	,@Zoom int
	,@Name nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Location]
	SET [Location] = @Location,
    [AccuracyMeters] = @AccuracyMeters,
    [RadiusMeters] = @RadiusMeters,
	[StreetAddress] = @StreetAddress,
    [PostalCode] = @PostalCode,
    [City] = @City,
    [Region] = @Region,
	[Country] = @Country,
	[Zoom] = @Zoom,
	[Name] = @Name
	WHERE [LocationId] = @LocationID
END

GO
/****** Object:  StoredProcedure [dbo].[LocationUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LocationDelete]
-- Add the parameters for the stored procedure here
	@LocationID BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[Location]
	WHERE [LocationId] = @LocationID
END





GO
/****** Object:  StoredProcedure [dbo].[LeadLocationInsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadLocationInsertOrUpdate]
	-- Add the parameters for the stored procedure here
           @LeadID bigint,
		   @LocationId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @OldLocationId bigint
	SELECT @OldLocationId = LocationId FROM [dbo].[LeadLocation] WHERE LeadId = @LeadID

	IF @OldLocationId IS NOT NULL
	BEGIN
		--Delete OLD Location
		DELETE FROM [dbo].[LeadLocation] WHERE LocationId = @OldLocationId
		EXEC [dbo].[LocationDelete] @OldLocationId
	END


	INSERT INTO [dbo].[LeadLocation]
           ([LocationID]
		   ,[LeadID])
     VALUES
           (@LocationId
		   ,@LeadID)
END












GO
/****** Object:  StoredProcedure [dbo].[LeadReviewMeasureScoreDeleteAll]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewMeasureScoreDeleteAll]
	-- Add the parameters for the stored procedure here
	@LeadID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM [dbo].[LeadReviewMeasureScore]
	WHERE [LeadID] = @LeadID

END














GO
/****** Object:  StoredProcedure [dbo].[LeadReviewMeasureScoreInsert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewMeasureScoreInsert]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@MeasureID smallint,
	@Score smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[LeadReviewMeasureScore]
		([LeadID], [ReviewMeasureID], [Score])
	VALUES
		(@LeadID, @MeasureID, @Score)

END














GO
/****** Object:  StoredProcedure [dbo].[LeadReviewMeasureSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewMeasureSelect]
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
		CROSS JOIN [dbo].[LeadReviewMeasure] lrm 
		LEFT OUTER JOIN [dbo].[LeadReviewMeasureScore] lrms ON lrms.LeadID = l.LeadID AND lrm.MeasureID = lrms.ReviewMeasureID
	WHERE
		l.LeadID = @LeadID
	ORDER BY lrm.[Order] ASC

END














GO
/****** Object:  StoredProcedure [dbo].[LeadReviewPublish]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewPublish]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@LoginID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[LeadReview]
	SET PublishedDateTime = GETUTCDATE()
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[LeadReviewSave]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewSave]
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

	IF NOT EXISTS (SELECT 1 FROM [dbo].[LeadReview] WHERE [LeadID] = @LeadID)
		INSERT INTO [dbo].[LeadReview] ([LeadID], [ReviewDateTime]) VALUES (@LeadID, @ReviewDateTime)

	UPDATE [dbo].[LeadReview]
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
/****** Object:  StoredProcedure [dbo].[LeadReviewSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewSelect]
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
		[dbo].[LeadReview] lr
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
	DECLARE @ReviewIDs AS [dbo].[SysBigintTableType];  
  
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
		INNER JOIN [dbo].[LeadReview] lr ON lr.LeadID = ri.Item
		LEFT OUTER JOIN [dbo].[LeadReviewMeasureScore] lrms ON lrms.LeadID = lr.LeadID
		LEFT OUTER JOIN [dbo].[LeadReviewMeasure] lrm ON lrm.MeasureID = lrms.ReviewMeasureID
	ORDER BY lr.[ReviewDateTime] DESC

END














GO
/****** Object:  StoredProcedure [dbo].[LeadReviewSelectBuisnessOptions]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewSelectBuisnessOptions]
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
		INNER JOIN [dbo].[TaxonomyTerm] T ON T.TermID = B.CountryID
		INNER JOIN [dbo].[BusinessLeadContactsRecieved] BLCR ON BLCR.LeadID = @LeadID AND BLCR.BusinessID = B.BusinessID 
		LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] BLC ON BLC.LeadID = @LeadID AND BLC.BusinessID = B.BusinessID
END




















GO
/****** Object:  StoredProcedure [dbo].[LeadReviewUnPublish]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadReviewUnPublish]
	-- Add the parameters for the stored procedure here
	@LeadID bigint,
	@LoginID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[LeadReview]
	SET PublishedDateTime = NULL
	WHERE [LeadID] = @LeadID

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[LeadSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSelect]
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
			[dbo].[BusinessLeadContactsRecieved] lcr ON lcr.LeadID = l.LeadID AND lcr.GetContactsDateTime IS NOT NULL
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
		INNER JOIN [dbo].[BusinessLeadCompleted] lc ON lc.LeadID = l.LeadID
		WHERE lc.CompletedDateTime IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'Important')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		INNER JOIN [dbo].[BusinessLeadImportant] li ON li.LeadID = l.LeadID
		WHERE li.ImportantDateTime IS NOT NULL
			AND (@LeadID IS NULL OR l.LeadID = @LeadID)
			AND (@DateFrom IS NULL OR @DateFrom < CreatedDateTime)
			AND (@DateTo IS NULL OR @DateTo >= CreatedDateTime)
	ELSE IF (@Status = 'InWork')
		INSERT INTO @Leads
		SELECT 
			l.[LeadID], [CreatedDateTime]
		FROM [dbo].[Lead] l
		LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] lcr ON lcr.LeadID = l.LeadID
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
				LEFT OUTER JOIN [dbo].[LeadFieldValueScalar] s ON s.LeadID = l.LeadID
				LEFT OUTER JOIN [dbo].[LeadFieldValueTaxonomy] lt ON lt.LeadID = l.LeadID
				LEFT OUTER JOIN [dbo].[TaxonomyTerm] tt ON tt.TermID = lt.TermID
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
	DECLARE @LeadIDs AS [dbo].[SysBigintTableType];  
  
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
	SELECT * FROM [dbo].[LeadSelectByIDs] (@LeadIDs)
	ORDER BY [CreatedDateTime] DESC


END














GO
/****** Object:  StoredProcedure [dbo].[LeadSelect_SiteMapData]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LeadSelect_SiteMapData]
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
			--Need to use the same ordering in LeadNumber as in [dbo].[LeadSelect] procedure
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
/****** Object:  StoredProcedure [dbo].[LeadSelectBusinessDetails]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSelectBusinessDetails]
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
	FROM [dbo].[BusinessLeadWorked] blw 
		LEFT OUTER JOIN [dbo].[BusinessLeadNotInterested] lni ON lni.LeadID = blw.LeadID AND lni.BusinessID = blw.BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadImportant] li ON li.LeadID = blw.LeadID AND li.BusinessID = blw.BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadContactsRecieved] lcr ON lcr.LeadID = blw.LeadID AND lcr.BusinessID = blw.BusinessID
		LEFT OUTER JOIN [dbo].[BusinessLeadCompleted] lc ON lc.LeadID = blw.LeadID AND lc.BusinessID = blw.BusinessID
	WHERE blw.LeadID = @LeadID
	GROUP BY 
		blw.LeadID, blw.BusinessID, 
		lcr.GetContactsDateTime, lni.NotInterestedDateTime, li.ImportantDateTime, lc.CompletedDateTime, lc.OrderSum, lc.SystemFeePercent, lc.LeadFee

END
















GO
/****** Object:  StoredProcedure [dbo].[LeadSelectBusinessNotificationData]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSelectBusinessNotificationData]
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
			[dbo].[BusinessLeadGetNextAllowedNotificationDateTime](br.BusinessID, @ForFrequencyName) as NextAllowedNotificationDateTime
		FROM [dbo].[Lead] l
		CROSS APPLY [dbo].[LeadBusinessSelectRequested](l.LeadID) br
		LEFT OUTER JOIN [dbo].[BusinessLeadNotified] bln on bln.BusinessID = br.BusinessID AND bln.LeadID = l.LeadID
		WHERE l.PublishedDateTime >= @PublishedAfter
		AND bln.NotifiedDateTime IS NULL   
		AND l.UserCanceledDateTime IS NULL 
		AND l.AdminCanceledPublishDateTime IS NULL
	) t
	WHERE t.NextAllowedNotificationDateTime <= GETUTCDATE()

END








GO
/****** Object:  StoredProcedure [dbo].[LeadSelectBusinessPostNotificationData]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSelectBusinessPostNotificationData]
	-- Add the parameters for the stored procedure here
	@PublishedAfter DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @BusinessPostTypeID int = 3

	DECLARE @BusinessLeadRelationTaxonomyID bigint = 0

	DECLARE @BusinessPostFieldIDDoNotSendEmails int = 8
	DECLARE @BusinessPostFieldIDBusiness int = 9
	DECLARE @BusinessPostFieldIDLocation int = 7

	DECLARE @TaxonomyMatches TABLE
	(
		LeadID BIGINT NOT NULL,
		PostID BIGINT NOT NULL
	)
	DECLARE @LocationMatches TABLE
	(
		LeadID BIGINT NOT NULL,
		PostID BIGINT NOT NULL
	)
	DECLARE @ResultMatches TABLE
	(
		LeadID BIGINT NOT NULL,
		PostID BIGINT NOT NULL
	)

	IF @BusinessLeadRelationTaxonomyID > 0 BEGIN
		INSERT INTO @TaxonomyMatches (LeadID, PostID)
		SELECT T.[LeadID], T.[PostID]
		FROM (
			SELECT 
				LE.[LeadID], 
				PT.[PostID]
			FROM 
				[dbo].[Lead] LE
				INNER JOIN [dbo].[LeadFieldValueTaxonomy] LT ON LT.LeadID = LE.LeadID 
				INNER JOIN [dbo].[CMSPostTerm] PT ON PT.TermID = LT.TermID AND PT.PostTypeID = @BusinessPostTypeID AND LT.TaxonomyID = @BusinessLeadRelationTaxonomyID
				LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVS ON FVS.PostID = PT.PostID AND FVS.FieldID = @BusinessPostFieldIDDoNotSendEmails
				LEFT OUTER JOIN [dbo].[BusinessLeadNotifiedPost] BLN on BLN.BusinessPostID = PT.PostID AND BLN.LeadID = LE.LeadID
				LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVB ON FVB.PostID = PT.PostID AND FVB.FieldID = @BusinessPostFieldIDBusiness

			WHERE 
				LE.PublishedDateTime >= @PublishedAfter 
				AND LE.UserCanceledDateTime IS NULL -- User Did Not RemoveEmail
				AND LE.PublishedDateTime IS NOT NULL -- IsPublished
				AND BLN.NotifiedDateTime IS NULL -- Was Not Yet Notified
				AND ISNULL(FVS.BoolValue, 0) = 0  -- DoNotSendEmails = FALSE
				AND ISNULL(FVB.NumberValue, 0) = 0  -- Has no link to Business
			GROUP BY 
				LE.[LeadID], 
				PT.[PostID]
		) T
		LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVB ON FVB.PostID = T.PostID AND FVB.FieldID = @BusinessPostFieldIDBusiness
		WHERE 
			FVB.NumberValue IS NULL -- Post is not assosiated with Business
		GROUP BY 
			T.[LeadID], 
			T.[PostID]
	END

	IF @BusinessPostFieldIDLocation > 0 BEGIN
		INSERT INTO @LocationMatches (LeadID, PostID)
		SELECT LE.[LeadID], FVL.PostID 
		FROM [dbo].[Lead] LE 
		INNER JOIN [dbo].[LeadLocation] LL ON LL.LeadID = LE.LeadID
		INNER JOIN [dbo].[Location] L1 with(index([LocationWithRadiusIndex])) ON L1.LocationID = LL.LocationID
		INNER JOIN [dbo].[Location] L2 ON L2.LocationWithRadius.STIntersects(L1.[LocationWithRadius]) = 1
		INNER JOIN [dbo].[CMSPostFieldValue] FVL ON FVL.PostTypeID = @BusinessPostTypeID AND FVL.LocationID = L2.LocationID
		LEFT OUTER JOIN [dbo].[BusinessLeadNotifiedPost] BLN on BLN.BusinessPostID = FVL.PostID AND BLN.LeadID = LE.LeadID
		LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVS ON FVS.PostID = FVL.PostID AND FVS.FieldID = @BusinessPostFieldIDDoNotSendEmails
		LEFT OUTER JOIN [dbo].[CMSPostFieldValue] FVB ON FVB.PostID = FVL.PostID AND FVB.FieldID = @BusinessPostFieldIDBusiness
		WHERE 
			LE.PublishedDateTime >= @PublishedAfter 
			AND LE.UserCanceledDateTime IS NULL -- User Did Not RemoveEmail
			AND LE.PublishedDateTime IS NOT NULL -- IsPublished
			AND BLN.NotifiedDateTime IS NULL -- Was Not Yet Notified
			AND ISNULL(FVS.BoolValue, 0) = 0  -- DoNotSendEmails = FALSE
			AND ISNULL(FVB.NumberValue, 0) = 0  -- Has no link to Business
		GROUP BY 
			LE.[LeadID], 
			FVL.[PostID]
	END

	INSERT INTO @ResultMatches (LeadID, PostID)
	SELECT LeadID, PostID
	FROM @LocationMatches

	SELECT LeadID, PostID
	FROM @ResultMatches
END













GO
/****** Object:  StoredProcedure [dbo].[LeadSelectByEmail]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSelectByEmail]
	-- Add the parameters for the stored procedure here
	@Email nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Declare a variable that references the type.
	DECLARE @LeadIDs AS [dbo].[SysBigintTableType];  
  
	-- Add data to the table variable. 
	INSERT INTO @LeadIDs (Item)
	SELECT t.[LeadID]
	FROM [dbo].[Lead] t
	WHERE t.Email = @Email
	ORDER BY t.[CreatedDateTime] DESC

	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[LeadSelectByIDs] (@LeadIDs)
	ORDER BY [CreatedDateTime]


END














GO
/****** Object:  StoredProcedure [dbo].[LeadSelectForReview]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSelectForReview]
	-- Add the parameters for the stored procedure here
	@CompletedDaysBefore INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DueDateCode NVARCHAR(50)
	SELECT @DueDateCode = [dbo].[SysOptionGet]('LeadSettingFieldMappingDateDue')

	-- Declare a variable that references the type.
	DECLARE @LeadIDs AS [dbo].[SysBigintTableType]; 

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
		FROM [dbo].[LeadFieldValueScalar] FVS
		INNER JOIN [dbo].[LeadFieldStructure] FS ON FS.[FieldID] = FVS.[FieldID]
		INNER JOIN [dbo].[Lead] L ON L.LeadID = FVS.LeadID
		WHERE
		L.EmailConfirmedDateTime IS NOT NULL --That were confirmed
		AND L.ReviewRequestSentDateTime IS NULL --Where ReviewRequest has not yet been sent
		AND FS.[FieldCode] = @DueDateCode 
		AND FVS.[DatetimeValue] <= DateAdd(DAY, -@CompletedDaysBefore, GETUTCDATE() )

	
	-- Call the function and pass the table variable
	SELECT * FROM [dbo].[LeadSelectByIDs] (@LeadIDs)

END








GO
/****** Object:  StoredProcedure [dbo].[LeadSetReviewRequestSent]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadSetReviewRequestSent]
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
/****** Object:  StoredProcedure [dbo].[LeadTryPublish]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadTryPublish]
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
/****** Object:  StoredProcedure [dbo].[LeadTryUnPublish]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadTryUnPublish]
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
/****** Object:  StoredProcedure [dbo].[LeadTryUnPublishByUser]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LeadTryUnPublishByUser]
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
/****** Object:  StoredProcedure [dbo].[SysGenerateRandomString]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysGenerateRandomString]
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
/****** Object:  StoredProcedure [dbo].[SysOptionInsertOrUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SysOptionInsertOrUpdate]
	-- Add the parameters for the stored procedure here
	@OptionKey nvarchar(100),
	@OptionValue nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[SystemOptions] 
	SET OptionValue = @OptionValue
	WHERE OptionKey = @OptionKey

	IF @@ROWCOUNT = 0
		INSERT INTO [dbo].[SystemOptions] (OptionKey, OptionValue) VALUES (@OptionKey, @OptionValue)


END



GO
/****** Object:  StoredProcedure [dbo].[SysOptionSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysOptionSelect]
	-- Add the parameters for the stored procedure here
	@OptionKey nvarchar(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT OptionKey, OptionValue
	FROM 
		[dbo].[SystemOptions] 
	WHERE	
		(@OptionKey IS NULL OR @OptionKey = OptionKey)

END




















GO
/****** Object:  StoredProcedure [dbo].[SysTokenCreate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
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




















GO
/****** Object:  StoredProcedure [dbo].[SysTokenDelete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysTokenDelete]
	-- Add the parameters for the stored procedure here
	@tokenKey nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DELETE FROM [dbo].[SystemToken] WHERE [TokenKey] = @tokenKey
END




















GO
/****** Object:  StoredProcedure [dbo].[SysTokenSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysTokenSelect]
	-- Add the parameters for the stored procedure here
	@tokenKey nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [TokenKey], [TokenAction], [TokenValue], [TokenDateCreated]
	FROM [dbo].[SystemToken]
	WHERE [TokenKey] = @tokenKey

END




















GO
/****** Object:  StoredProcedure [dbo].[SysWordCaseInsert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysWordCaseInsert]
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

	INSERT INTO [dbo].[SystemWordCase]
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
/****** Object:  StoredProcedure [dbo].[SysWordCaseUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SysWordCaseUpdate]
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

	UPDATE [dbo].[SystemWordCase]
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
/****** Object:  StoredProcedure [dbo].[SystemScheduledTasksSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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




















GO
/****** Object:  StoredProcedure [dbo].[SystemScheduledTasksSelectCurrentTasks]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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




GO
/****** Object:  StoredProcedure [dbo].[SystemScheduledTasksSetCompleted]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SystemScheduledTasksSetCompleted]
	@TaskName NVARCHAR(255),
	@Status NVARCHAR(50),
	@Message NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[SystemScheduledTaskLog]
	SET [CompletedDateTime] = GETUTCDATE(),
	[Status] = @Status,
	[Message] = @Message
	WHERE [TaskName] = @TaskName
	AND [CompletedDateTime] IS NULL	

END




GO
/****** Object:  StoredProcedure [dbo].[SystemScheduledTasksSetStarted]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SystemScheduledTasksSetStarted]
	@TaskName NVARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [dbo].[SystemScheduledTaskLog] WHERE [TaskName] = @TaskName AND CompletedDateTime IS NULL)
		BEGIN
			DECLARE @ErrorMessage  NVARCHAR (255) = 'Can not start task ' + @TaskName +' because it is not completed yet (CompletedDateTime IS NULL)'
			RAISERROR(@ErrorMessage, 16,1 )
			RETURN 0;
		END
	ELSE
		INSERT INTO [dbo].[SystemScheduledTaskLog]
			([TaskName], [Status])
		VALUES
			(@TaskName, 'Started')	

END



GO
/****** Object:  StoredProcedure [dbo].[SystemLogInsert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SystemLogInsert]
	@Value NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO SystemLog ([Value]) VALUES (@Value)

END



GO
/****** Object:  StoredProcedure [dbo].[TaxonomyInsert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyInsert] 
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
/****** Object:  StoredProcedure [dbo].[TaxonomySelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomySelect]
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
/****** Object:  StoredProcedure [dbo].[TaxonomyTermDelete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermDelete] 
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
		FROM [dbo].[TaxonomyTerm] 
		WHERE [TermID] = @TermID

		UPDATE [dbo].[TaxonomyTerm] 
		SET [TermParentID] = @ParentID
		WHERE [TermParentID] = @TermID

		--Delete Posts for this term
		DECLARE @DeletePostID bigint
		DECLARE post_cursor CURSOR FOR  
		SELECT [PostID] FROM [dbo].[CMSPost] WHERE [PostForTermID] = @TermID

		OPEN post_cursor   
		FETCH NEXT FROM post_cursor INTO @DeletePostID   

		WHILE @@FETCH_STATUS = 0   
		BEGIN

			EXEC [dbo].[CMSPostDelete] @DeletePostID

		FETCH NEXT FROM post_cursor INTO @DeletePostID   
		END   

		CLOSE post_cursor   
		DEALLOCATE post_cursor

		-- Delete term word assosiasion
		DELETE FROM [dbo].[TaxonomyTermWord] WHERE TermID = @TermID


		-- Delete the Term
		DELETE FROM [dbo].[TaxonomyTerm] 
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
/****** Object:  StoredProcedure [dbo].[TaxonomyTermIfTermExistInOffsprings]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermIfTermExistInOffsprings] 
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
		FROM [dbo].[TaxonomyTerm]
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
			EXEC [dbo].[TaxonomyTermIfTermExistInOffsprings] @ChildID, @TestTermID, @isExist OUT
			--SET @isExist = @RecursiveResult
			
		END

		FETCH NEXT FROM @ChildrenTermsCursor INTO @ChildID
	END
	CLOSE @ChildrenTermsCursor
	DEALLOCATE @ChildrenTermsCursor

	RETURN @isExist

END






















GO
/****** Object:  StoredProcedure [dbo].[TaxonomyTermInsert]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermInsert] 
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
				FROM [dbo].[TaxonomyTerm]
				WHERE [TermID] = @TermParentID AND [TaxonomyID] = @TaxonomyID)
	BEGIN
		Set @InsertError = 1
		SET @Result = 'FAILED ParentID Taxonomy'
	END


	--Check if @TermName already exist in the current @TaxonomyID
	--IF (
	--	SELECT COUNT(*) 
	--	FROM [dbo].[TaxonomyTerm]
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
		FROM [dbo].[TaxonomyTerm]
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

		INSERT INTO [dbo].[TaxonomyTerm] ([TaxonomyID], [TermName], [TermURL], [TermParentID])
		VALUES (@TaxonomyID, @TermName, @TermURL, @TermParentID) 

		SET @Result = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		--IF HAD ERRORS
		SET @Result = 'FAILED'
	END CATCH 





END





















GO
/****** Object:  StoredProcedure [dbo].[TaxonomyTermSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermSelect] 
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
		[dbo].[TaxonomyTerm] TT 
		INNER JOIN [dbo].[Taxonomy] T ON T.[TaxonomyID] = TT.[TaxonomyID] 
		LEFT OUTER JOIN [dbo].[LeadFieldMetaTermsAllowed] LTA ON LTA.[TermID] = TT.TermID 
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
/****** Object:  StoredProcedure [dbo].[TaxonomyTermUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermUpdate] 
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
	FROM [dbo].[TaxonomyTerm] 
	WHERE [TermID] = @TermID

	Declare @UpdateError bit = 0


	IF @TermParentID IS NOT NULL 
	BEGIN

		--Check if @TermParentID has the same TaxonomyID as the @TermID
		IF 0 = (SELECT COUNT(*) 
				FROM [dbo].[TaxonomyTerm]
				WHERE [TermID] = @TermParentID AND [TaxonomyID] = @TaxonomyID)
		BEGIN
			Set @UpdateError = 1
			SET @Result = 'FAILED ParentID Taxonomy'
		END
		ELSE 
		BEGIN 
			--Check if @TermParentID does not exist in the @TermID offsprings
			DECLARE	@ExistInTermOffsprings bit
			EXEC	@ExistInTermOffsprings = [dbo].[TaxonomyTermIfTermExistInOffsprings] @TermID, @TermParentID
			IF @TermID = @TermParentID OR @ExistInTermOffsprings = 1 BEGIN
				Set @UpdateError = 1
				SET @Result = 'FAILED ParentID Offsprings'
			END
		END

	END


	--Check if @TermName already exist in the current @TaxonomyID
	--IF (
	--	SELECT COUNT(*) 
	--	FROM [dbo].[TaxonomyTerm]
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
		FROM [dbo].[TaxonomyTerm]
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

		UPDATE [dbo].[TaxonomyTerm] SET 
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
/****** Object:  StoredProcedure [dbo].[TaxonomyTermWordSelect]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermWordSelect] 
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
	FROM [dbo].[TaxonomyTermWord] tw
	INNER JOIN [dbo].[SystemWordCase] w on w.WordID = tw.WordID
	WHERE @TermID = tw.TermID AND (@WordCode IS NULL OR tw.TermWordCode = @WordCode)
	
END





















GO
/****** Object:  StoredProcedure [dbo].[TaxonomyTermWordSelectForMany]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TaxonomyTermWordSelectForMany] 
	-- Add the parameters for the stored procedure here
	@TermIDTable [dbo].[SysBigintTableType] READONLY,
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
	FROM [dbo].[TaxonomyTermWord] tw
	INNER JOIN @TermIDTable tt ON tt.Item = tw.TermID
	INNER JOIN [dbo].[SystemWordCase] w on w.WordID = tw.WordID
	WHERE (@WordCode IS NULL OR tw.TermWordCode = @WordCode)
	
END





















GO
/****** Object:  StoredProcedure [dbo].[TaxonomyTermWordSet]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyTermWordSet] 
	-- Add the parameters for the stored procedure here
	@TermID bigint,
	@WordID bigint,
	@WordCode nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[TaxonomyTermWord] 
	([TermID], [WordID], [TermWordCode]) 
	VALUES 
	(@TermID, @WordID, @WordCode)
	
END





















GO
/****** Object:  StoredProcedure [dbo].[TaxonomyUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaxonomyUpdate] 
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
/****** Object:  StoredProcedure [dbo].[UserLoginAuthenticate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginAuthenticate]
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
		[dbo].[UserLogin] L INNER JOIN
		[dbo].[UserRole] R ON R.[RoleID] = L.[RoleID]
	WHERE	
		[Email] = @email 
		AND [PasswordHash] = @passwordHash

END




















GO
/****** Object:  StoredProcedure [dbo].[UserLoginCreate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginCreate]
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
		INSERT INTO [dbo].[UserLogin] (
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
/****** Object:  StoredProcedure [dbo].[UserLoginEmailConfirm]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginEmailConfirm]
	-- Add the parameters for the stored procedure here
	@loginID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[UserLogin]
	SET [EmailConfirmationDate] = GETUTCDATE() 
	WHERE [LoginID] = @loginID

	RETURN @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[UserLoginPasswordHashUpdate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginPasswordHashUpdate]
	-- Add the parameters for the stored procedure here
	@loginID bigint,
	@sessionID nvarchar(255) = '',
	@passwordHash nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[UserSession]
	SET [SessionPasswordChangeInitialized] = 1
	WHERE [SessionID] = @SessionID AND [LoginID] = @LoginID

	UPDATE [dbo].[UserLogin]
	SET [PasswordHash] = @PasswordHash 
	WHERE [LoginID] = @LoginID

	return @@ROWCOUNT
END




















GO
/****** Object:  StoredProcedure [dbo].[UserLoginSelectOne]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginSelectOne]
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
		[dbo].[UserLogin] L INNER JOIN
		[dbo].[UserRole] R ON R.[RoleID] = L.[RoleID]
	WHERE	
		(@loginID IS NOT NULL AND L.[LoginID] = @loginID)
		OR 
		(@email IS NOT NULL AND L.[Email] = @email)

END




















GO
/****** Object:  StoredProcedure [dbo].[UserLoginSessionCreate]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginSessionCreate]
	-- Add the parameters for the stored procedure here
	@loginID bigint,
	@sessionID nvarchar(255) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @PasswordHash nvarchar(255)
	SELECT @PasswordHash = [PasswordHash] FROM [dbo].[UserLogin] WHERE [LoginID] = @loginID

	IF ( @PasswordHash IS NOT NULL AND @PasswordHash <> '')
	BEGIN
		EXEC dbo.[SysGenerateRandomString] 50, @sessionID OUT
		IF (SELECT COUNT(*) FROM dbo.[UserSession] WHERE [SessionID] = @sessionID) = 0
		BEGIN
			INSERT INTO dbo.[UserSession] 
				([SessionID], 
				[LoginID], 
				[SessionPasswordHash], 
				[SessionCreationDate])
			SELECT 
				@sessionID, 
				@loginID,
				[PasswordHash],
				GETUTCDATE()
			FROM [dbo].[UserLogin]
			WHERE [LoginID] = @loginID

			RETURN
		END
		ELSE
			EXEC [dbo].[UserLoginSessionCreate] @loginID, @sessionID OUT
	END



	RETURN

END




















GO
/****** Object:  StoredProcedure [dbo].[UserLoginSessionDelete]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginSessionDelete]
	-- Add the parameters for the stored procedure here
	@sessionID nvarchar(255),
	@loginID bigint,
	@result bit OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DELETE FROM [dbo].[UserSession]
	WHERE [SessionID] = @sessionID AND [LoginID] = @loginID

	SET @result = @@ROWCOUNT

	RETURN @result

END




















GO
/****** Object:  StoredProcedure [dbo].[UserLoginSessionSelectLoginDetailsBySessionID]    Script Date: 5/9/2017 10:43:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserLoginSessionSelectLoginDetailsBySessionID]
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
		[dbo].[UserSession] S INNER JOIN
		[dbo].[UserLogin] L ON L.[LoginID] = S.[LoginID] AND L.[EmailConfirmationDate] IS NOT NULL INNER JOIN
		[dbo].[UserRole] R ON R.[RoleID] = L.[RoleID] LEFT OUTER JOIN
		[dbo].[BusinessLogin] BL ON BL.[LoginID] = L.LoginID LEFT OUTER JOIN
		[dbo].[Business] B ON B.[BusinessID] = BL.[BusinessID]

	WHERE S.[SessionID] = @sessionID AND S.[SessionBlockDate] IS NULL


	RETURN

END












GO
/****** Object:  Trigger [dbo].[ManagePostsOnTermInsert]    Script Date: 5/12/2017 11:30:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[ManagePostsOnTermInsert]
ON [dbo].[TaxonomyTerm]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;

	DECLARE @TaxonomyPostTypeID int;  

	DECLARE postType_cursor CURSOR FOR
		SELECT ptt.[PostTypeID]
		FROM [dbo].[CMSPostTypeTaxonomy] ptt
		INNER JOIN inserted i ON i.TaxonomyID = ptt.ForTaxonomyID
		WHERE ptt.IsEnabled = 1
	
	OPEN postType_cursor  
  
	FETCH NEXT FROM postType_cursor   
	INTO @TaxonomyPostTypeID  
  
	WHILE @@FETCH_STATUS = 0  
	BEGIN 
		EXEC [dbo].[CMSPostCreateMultipleForTaxonomyType] @TaxonomyPostTypeID

		FETCH NEXT FROM postType_cursor   
		INTO @TaxonomyPostTypeID
	END

	CLOSE postType_cursor;  
	DEALLOCATE postType_cursor; 

END










GO
ALTER TABLE [dbo].[TaxonomyTerm] ENABLE TRIGGER [ManagePostsOnTermInsert]
GO
/****** Object:  Trigger [dbo].[ManagePostsOnTermUpdate]    Script Date: 5/12/2017 11:30:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[ManagePostsOnTermUpdate]
ON [dbo].[TaxonomyTerm]
FOR UPDATE
AS 
BEGIN
    SET NOCOUNT ON;

    IF UPDATE ([TermURL]) 
    BEGIN
		UPDATE [dbo].[CMSPost]
		SET [PostURL] = [TermURL] FROM inserted
		WHERE [PostForTermID] = [TermID]		
	END

    IF UPDATE ([TermName]) 
    BEGIN
		DECLARE @OldTermName nvarchar(50)
		SELECT @OldTermName = [TermName] FROM deleted

		UPDATE [dbo].[CMSPost]
		SET [Title] = [TermName] FROM inserted
		WHERE [PostForTermID] = [TermID] AND [Title] = @OldTermName
	END


END


GO
ALTER TABLE [dbo].[TaxonomyTerm] ENABLE TRIGGER [ManagePostsOnTermUpdate]
GO
/****** Object:  Trigger [dbo].[ManageSessionsOnPasswordHashUpdate]    Script Date: 5/12/2017 11:30:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
GO




SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF


ALTER DATABASE [LeadGenDB] SET  READ_WRITE 
GO