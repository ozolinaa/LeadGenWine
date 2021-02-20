CREATE VIEW [dbo].[LeadScalarTextView]
   WITH SCHEMABINDING
   AS  
	SELECT
			CONCAT(s.LeadID, '_scalarField_', s.FieldID) as ID, 
			s.LeadID, ls.FieldCode, ls.IsContact, ISNULL(s.TextValue,s.NumberValue) as FieldText
		FROM [dbo].[LeadFieldValueScalar] s
		INNER JOIN [dbo].[LeadFieldStructure] ls ON ls.FieldID = s.FieldID
		WHERE TextValue IS NOT NULL OR NumberValue IS NOT NULL
GO
CREATE UNIQUE CLUSTERED INDEX [PK_ID] ON [dbo].[LeadScalarTextView]
(  
    [ID] ASC  
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]  
GO  
CREATE FULLTEXT INDEX ON [dbo].[LeadScalarTextView]
    ([FieldText] LANGUAGE 1033)  
    KEY INDEX [PK_ID]  
    ON [LeadFieldTextCatalog];  
GO