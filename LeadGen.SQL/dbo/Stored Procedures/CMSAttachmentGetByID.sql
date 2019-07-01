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