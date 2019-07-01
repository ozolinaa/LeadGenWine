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