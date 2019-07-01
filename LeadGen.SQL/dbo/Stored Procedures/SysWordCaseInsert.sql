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