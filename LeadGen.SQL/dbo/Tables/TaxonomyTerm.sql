CREATE TABLE [dbo].[TaxonomyTerm](
	[TermID] [bigint] IDENTITY(1,1) NOT NULL,
	[TaxonomyID] [int] NOT NULL,
	[TermName] [nvarchar](255) NOT NULL,
	[TermURL] [nvarchar](255) NOT NULL,
	[TermThumbnailURL] [nvarchar](255) NULL,
	[TermParentID] [bigint] NULL,
 CONSTRAINT [PK_CMSTaxonomyTerm] PRIMARY KEY CLUSTERED 
(
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TaxonomyTerm]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy.Term] FOREIGN KEY([TermParentID])
REFERENCES [dbo].[TaxonomyTerm] ([TermID])
GO

ALTER TABLE [dbo].[TaxonomyTerm] CHECK CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy.Term]
GO
ALTER TABLE [dbo].[TaxonomyTerm]  WITH CHECK ADD  CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy1] FOREIGN KEY([TaxonomyID])
REFERENCES [dbo].[Taxonomy] ([TaxonomyID])
GO

ALTER TABLE [dbo].[TaxonomyTerm] CHECK CONSTRAINT [FK_CMS.Taxonomy.Term_CMS.Taxonomy1]
GO
/****** Object:  Index [IX_TaxonomyTerm]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_TaxonomyTerm] ON [dbo].[TaxonomyTerm]
(
	[TermID] ASC,
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TaxonomyTerm_1]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaxonomyTerm_1] ON [dbo].[TaxonomyTerm]
(
	[TermURL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TaxonomyTerm_2]    Script Date: 5/9/2017 10:43:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaxonomyTerm_2] ON [dbo].[TaxonomyTerm]
(
	[TermName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[ManagePostsOnTermInsert]
ON [dbo].[TaxonomyTerm]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;

	DECLARE @TaxonomyPostTypeID int;  

	DECLARE postType_cursor CURSOR FOR
		SELECT ptt.[PostTypeID]
		FROM [dbo].[CMSPostTypeTaxonomy] ptt
		INNER JOIN inserted i ON i.TaxonomyID = ptt.ForTaxonomyID
		WHERE ptt.IsEnabled = 1
	
	OPEN postType_cursor  
  
	FETCH NEXT FROM postType_cursor   
	INTO @TaxonomyPostTypeID  
  
	WHILE @@FETCH_STATUS = 0  
	BEGIN 
		EXEC [dbo].[CMSPostCreateMultipleForTaxonomyType] @TaxonomyPostTypeID

		FETCH NEXT FROM postType_cursor   
		INTO @TaxonomyPostTypeID
	END

	CLOSE postType_cursor;  
	DEALLOCATE postType_cursor; 

END
GO

ALTER TABLE [dbo].[TaxonomyTerm] ENABLE TRIGGER [ManagePostsOnTermInsert]
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[ManagePostsOnTermUpdate]
ON [dbo].[TaxonomyTerm]
FOR UPDATE
AS 
BEGIN
    SET NOCOUNT ON;

    IF UPDATE ([TermURL]) 
    BEGIN
		UPDATE [dbo].[CMSPost]
		SET [PostURL] = [TermURL] FROM inserted
		WHERE [PostForTermID] = [TermID]		
	END

    IF UPDATE ([TermName]) 
    BEGIN
		DECLARE @OldTermName nvarchar(50)
		SELECT @OldTermName = [TermName] FROM deleted

		UPDATE [dbo].[CMSPost]
		SET [Title] = [TermName] FROM inserted
		WHERE [PostForTermID] = [TermID] AND [Title] = @OldTermName
	END


END
GO

ALTER TABLE [dbo].[TaxonomyTerm] ENABLE TRIGGER [ManagePostsOnTermUpdate]