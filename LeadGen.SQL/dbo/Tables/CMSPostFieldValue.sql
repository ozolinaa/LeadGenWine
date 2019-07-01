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
ALTER TABLE [dbo].[CMSPostFieldValue]  WITH CHECK ADD  CONSTRAINT [FK_CMSPostFieldLocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([LocationId])