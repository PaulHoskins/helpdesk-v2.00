/***********************************************************************

    Program:        batch/checkSystem.p
    
    Purpose:        Check System for problems
    
    Notes:
    
    
    When        Who         What
    28/10/2015  phoski      Initial
   
***********************************************************************/

{lib/common.i}

DEFINE VARIABLE lc-CompList AS CHARACTER FORMAT 'x(80)' LABEL 'Comp List' NO-UNDO.
DEFINE VARIABLE lc-report   AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-count    AS INTEGER  LABEL '#' NO-UNDO.
DEFINE VARIABLE ll-Steam AS LOG       NO-UNDO.

DEFINE VARIABLE lc-prob     AS CHARACTER LABEL 'Problem' FORMAT 'x(40)' NO-UNDO.

FUNCTION prob RETURNS LOG ( pc-msg AS CHAR):
    IF lc-prob = ""
    THEN lc-prob = "** " + pc-msg.
    ELSE lc-prob = lc-prob + ", " + pc-msg.
    RETURN TRUE.
    
END FUNCTION.


ASSIGN
    lc-report = "c:\temp\checkSystem.txt".

OUTPUT TO value(lc-report) PAGED.
   

FOR EACH Company NO-LOCK WITH FRAME fcompany SIDE-LABELS STREAM-IO WIDTH 255:
    
    IF Company.CompanyCode <> "OURITDEPT"
    THEN NEXT. 
    
    ASSIGN
        lc-global-company = Company.CompanyCode
        lc-CompList = "".
        
    FOR EACH WebStatus 
        WHERE WebStatus.Completed = TRUE 
        AND WebStatus.CompanyCode = lc-global-company
        NO-LOCK:
        ASSIGN 
            lc-CompList = WebStatus.StatusCode + "," + lc-CompList.
    END.
    DISPLAY Company.CompanyCode Company.Name lc-CompList.
    

    FOR EACH WebUser NO-LOCK
        WHERE WebUser.companyCode = lc-global-company,
     
        EACH Issue NO-LOCK
        WHERE Issue.CompanyCode = lc-global-company
        AND Issue.AssignTo    = WebUser.LoginID
        AND INDEX(lc-CompList,Issue.StatusCode)  = 0
        BREAK BY WebUser.LoginID
        WITH FRAME fissue STREAM-IO DOWN WIDTH 255:
            
        IF FIRST-OF(WebUser.LoginID) THEN
        DO:
            ASSIGN
                li-count = 0.
             ll-Steam = DYNAMIC-FUNCTION("com-isTeamMember", lc-global-company,webuser.loginid,?).
        END.
        ASSIGN li-count = li-count + 1.
        ASSIGN lc-prob = "".
        
        FIND WebStatus OF Issue NO-LOCK NO-ERROR.
        
        IF NOT AVAILABLE WebStatus 
        THEN prob("Status").
        
        FIND Customer OF Issue NO-LOCK NO-ERROR.
        IF NOT AVAILABLE Customer THEN
        DO:
            prob("Customer").
        END.
        ELSE
        IF ll-steam AND Issue.AccountNumber <> '84' THEN
        DO:
            IF NOT CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = Issue.assignTo
                AND webusteam.st-num = customer.st-num NO-LOCK) 
             THEN prob("Team").
            
        END.
     
        DISPLAY WebUser.LoginID ll-steam li-count Issue.IssueNumber Issue.IssueDate Issue.StatusCode FORMAT 'x(20)' 
            Issue.AccountNumber Customer.Name WHEN AVAILABLE Customer lc-prob.
        
        DOWN.
                
    END.

END.

            
    