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
ALTER TABLE [dbo].[CMSAttachmentImage]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Attachment.Image_CMS.Attachment] FOREIGN KEY([AttachmentID], [TypeID])
REFERENCES [dbo].[CMSAttachment] ([AttachmentID], [TypeID])
GO

ALTER TABLE [dbo].[CMSAttachmentImage] CHECK CONSTRAINT [FK_CMS.Attachment.Image_CMS.Attachment]