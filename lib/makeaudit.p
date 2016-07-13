/***********************************************************************

    Program:        lib/makeaudit.p
    
    Purpose:        Audit Number          
    
    Notes:
    
    
    When        Who         What
    13/04/2006  phoski      Initial
        
***********************************************************************/

DEFINE INPUT   PARAMETER pc-AuditType          AS CHARACTER NO-UNDO.
DEFINE OUTPUT  PARAMETER pf-AuditNumber        AS DECIMAL  NO-UNDO.
  

DEFINE VARIABLE li-lo AS INTEGER NO-UNDO.
DEFINE VARIABLE li-hi AS INTEGER NO-UNDO.

CASE pc-AuditType:

    WHEN 'DUMMY' THEN 
        ASSIGN 
            pf-AuditNumber = ?.
    
    OTHERWISE
    DO:
        ASSIGN 
            li-lo = NEXT-VALUE(LoAudit)
            li-hi = CURRENT-VALUE(HiAudit).
               
        IF li-lo = 1
            THEN ASSIGN li-hi = NEXT-VALUE(HiAudit).
        
        ASSIGN 
            pf-AuditNumber = dec(STRING(li-hi) + string(li-lo,"999999")).
                
    END.
END CASE.
