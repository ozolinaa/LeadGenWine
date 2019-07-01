﻿CREATE TABLE [dbo].[CMSAttachmentImageSize](
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