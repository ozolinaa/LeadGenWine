CREATE VIEW [dbo].[BusinessRegionCountry]
AS
SELECT        B.BusinessID, B.Name AS BusinessName, B.RegistrationDate AS BusinessRegistrationDate, TT.TermID AS RegionID, TT.TermName AS RegionName, TT.TermURL AS RegionURL, TTC.TermID AS CountryID, 
                         TTC.TermName AS CountryName, TTC.TermURL AS CountryURL
FROM            dbo.Business AS B LEFT OUTER JOIN
                         dbo.[BusinessLeadPermission] AS BLP ON BLP.BusinessID = B.BusinessID INNER JOIN
                         dbo.[BusinessLeadPermissionTerm] AS BLPT ON BLPT.PermissionID = BLP.PermissionID INNER JOIN
                         dbo.[TaxonomyTerm] AS TT ON TT.TermID = BLPT.TermID INNER JOIN
                         dbo.Taxonomy AS T ON T.TaxonomyID = TT.TaxonomyID AND T.TaxonomyCode = 'city' INNER JOIN
                         dbo.[TaxonomyTerm] AS TTC ON TTC.TermID = TT.TermParentID
GROUP BY B.BusinessID, B.Name, B.RegistrationDate, TT.TermID, TT.TermName, TT.TermURL, TTC.TermID, TTC.TermName, TTC.TermURL