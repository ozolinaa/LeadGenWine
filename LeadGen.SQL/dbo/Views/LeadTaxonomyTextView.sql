CREATE VIEW [dbo].[LeadTaxonomyTextView]
   WITH SCHEMABINDING
   AS  
		SELECT
			CONCAT(lt.LeadID, '_taxField_', lt.FieldID, '_', lt.TermID) as ID, 
			lt.LeadID, ls.FieldCode, ls.IsContact, tt.TermName as FieldText
		FROM [dbo].[LeadFieldValueTaxonomy] lt
		INNER JOIN [dbo].[LeadFieldStructure] ls ON ls.FieldID = lt.FieldID
		INNER JOIN [dbo].[TaxonomyTerm] tt ON tt.TermID = lt.TermID
GO
CREATE UNIQUE CLUSTERED INDEX [PK_ID] ON [dbo].[LeadTaxonomyTextView]
(  
    [ID] ASC  
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]  
GO  
CREATE FULLTEXT INDEX ON [dbo].[LeadTaxonomyTextView]
    ([FieldText] LANGUAGE 1033)  
    KEY INDEX [PK_ID]  
    ON [LeadFieldTextCatalog];  
GO 