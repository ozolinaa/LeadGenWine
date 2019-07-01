﻿CREATE TABLE [dbo].[CMSFieldType](
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