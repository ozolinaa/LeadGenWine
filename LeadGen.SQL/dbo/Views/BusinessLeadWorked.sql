CREATE VIEW [dbo].[BusinessLeadWorked]
AS
SELECT        BusinessID, LeadID
FROM            (SELECT        BusinessID, LeadID
                          FROM            dbo.[BusinessLeadNotInterested]
                          UNION ALL
                          SELECT        BusinessID, LeadID
                          FROM            dbo.[BusinessLeadImportant]
                          UNION ALL
                          SELECT        BusinessID, LeadID
                          FROM            dbo.[BusinessLeadContactsRecieved]
                          UNION ALL
                          SELECT        BusinessID, LeadID
                          FROM            dbo.[BusinessLeadCompleted]) AS t
GROUP BY BusinessID, LeadID