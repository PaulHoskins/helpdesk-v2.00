/***********************************************************************

    Program:        crm/proc/crmloaddatasetok.p
    
    Purpose:        CRM Data Set Load into DB
    
    Notes:
    
    
    When        Who         What
    03/09/2016  phoski      Initial
    
***********************************************************************/

DEFINE INPUT PARAMETER pc-companyCode   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-loginid       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-file          AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pr-rowid         AS ROWID     NO-UNDO.

