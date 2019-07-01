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