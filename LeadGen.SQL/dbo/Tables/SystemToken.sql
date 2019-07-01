CREATE TABLE [dbo].[SystemToken](
	[TokenKey] [nvarchar](255) NOT NULL,
	[TokenAction] [nvarchar](255) NOT NULL,
	[TokenValue] [nvarchar](255) NOT NULL,
	[TokenDateCreated] [datetime] NOT NULL,
 CONSTRAINT [PK_Token] PRIMARY KEY CLUSTERED 
(
	[TokenKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SystemToken] ADD  CONSTRAINT [DF_Token_TokenDateCreated]  DEFAULT (getutcdate()) FOR [TokenDateCreated]