CREATE VIEW [dbo].[LeadLocationTextView]
   WITH SCHEMABINDING
   AS  
	SELECT 
		CONCAT(ll.LeadID, '_system_location_', ll.LocationID) as ID,
		ll.LeadID, '_system_location_address' as FieldCode, 0 as IsContact, LOC.StreetAddress as FieldText
	FROM [dbo].[LeadLocation] LL 
	INNER JOIN [dbo].[Location] LOC ON LOC.LocationID = LL.LocationID
GO
CREATE UNIQUE CLUSTERED INDEX [PK_ID] ON [dbo].[LeadLocationTextView]
(  
    [ID] ASC  
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]  
GO  
CREATE FULLTEXT INDEX ON [dbo].[LeadLocationTextView]
    ([FieldText] LANGUAGE 1033)  
    KEY INDEX [PK_ID]  
    ON [LeadFieldTextCatalog];  
GO 