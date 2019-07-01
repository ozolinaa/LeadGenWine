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