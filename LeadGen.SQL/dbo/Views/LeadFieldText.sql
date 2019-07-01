CREATE VIEW [dbo].[LeadFieldText] 
AS
	select l.LeadID, 'email' as FieldCode, 1 as IsContact, l.Email as FieldValue from dbo.Lead l 
		union all
	select sv.LeadID, fs.FieldCode, fs.IsContact, sv.TextValue as FieldValue 
	FROM dbo.LeadFieldValueScalar sv
	inner join dbo.LeadFieldStructure fs ON fs.FieldID = sv.FieldID
	where fs.IsActive = 1 AND sv.TextValue IS NOT NULL
		union all
	select vt.LeadID, fs.FieldCode, fs.IsContact, tt.TermName as FieldValue 
	FROM dbo.LeadFieldValueTaxonomy vt 
	inner join dbo.TaxonomyTerm tt ON tt.TermID = vt.TermID
	inner join dbo.LeadFieldStructure fs ON fs.FieldID = vt.FieldID
	where fs.IsActive = 1