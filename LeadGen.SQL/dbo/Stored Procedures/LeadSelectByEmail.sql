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