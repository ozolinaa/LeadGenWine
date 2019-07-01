CREATE TABLE [dbo].[SystemWordCase](
	[WordID] [bigint] IDENTITY(1,1) NOT NULL,
	[NominativeSingular] [nvarchar](50) NULL,
	[GenitiveSingular] [nvarchar](50) NULL,
	[DativeSingular] [nvarchar](50) NULL,
	[AccusativeSingular] [nvarchar](50) NULL,
	[InstrumentalSingular] [nvarchar](50) NULL,
	[PrepositionalSingular] [nvarchar](50) NULL,
	[NominativePlural] [nvarchar](50) NULL,
	[GenitivePlural] [nvarchar](50) NULL,
	[DativePlural] [nvarchar](50) NULL,
	[AccusativePlural] [nvarchar](50) NULL,
	[InstrumentalPlural] [nvarchar](50) NULL,
	[PrepositionalPlural] [nvarchar](50) NULL,
 CONSTRAINT [PK_SystemWordCase] PRIMARY KEY CLUSTERED 
(
	[WordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]