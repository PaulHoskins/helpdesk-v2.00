/***********************************************************************

    Program:        batch/projaction.p
    
    Purpose:        Project Actions Report
    
    Notes:
    
    
    When        Who         What
    15/05/2015  phoski      Initial
    20/10/2015  phoski      com-GetHelpDeskEmail for email sender

***********************************************************************/

{lib/common.i}
{iss/issue.i}
{lib/maillib.i}





DEFINE VARIABLE ld-lo-Date   AS DATE      NO-UNDO.
DEFINE VARIABLE ld-hi-Date   AS DATE      NO-UNDO.
DEFINE VARIABLE lc-EmailList AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-text      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-subject   AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop      AS INTEGER NO-UNDO.

DEFINE BUFFER Issue     FOR Issue.
DEFINE BUFFER IssAction FOR IssAction.
DEFINE BUFFER esched    FOR eSched.
DEFINE BUFFER Company   FOR Company.
DEFINE BUFFER WebUser   FOR WebUser.
DEFINE BUFFER customer  FOR Customer.


DEFINE STREAM s-log.
DEFINE STREAM s-file.

ASSIGN 
    ld-lo-date = TODAY
    ld-hi-date = TODAY + 3.
       
/*       
OUTPUT stream s-log to value(SESSION:TEMP-DIR + "/projaction.log") UNBUFFERED.
*/
OUTPUT stream s-log to value("c:/temp/projaction.log") UNBUFFERED.
FOR EACH Company NO-LOCK,
    EACH Issue NO-LOCK
    WHERE Issue.CompanyCode = Company.CompanyCode
    AND Issue.iClass = lc-global-iclass-complex,
    EACH issAction NO-LOCK
    WHERE issAction.CompanyCode = Issue.CompanyCode
    AND issAction.IssueNumber = Issue.IssueNumber
    AND issAction.ActionDate >= ld-lo-date
    AND issAction.ActionDate <= ld-hi-date
    AND issAction.ActionStatus = "OPEN"
    BY Issue.IssueNumber
    BY IssAction.ActionDate
    WITH FRAME f-rep DOWN STREAM-IO WIDTH 255:
    FIND Customer OF Issue NO-LOCK NO-ERROR.
    IF NOT AVAILABLE Customer THEN NEXT.

    /*
    ***
    *** Project Engineer and anyone else assigned to this project
    ***
    */
    lc-emailList = Issue.prj-eng.
    FOR EACH eSched NO-LOCK
        WHERE eSched.IssActionID = IssAction.IssActionID:
        IF LOOKUP(eSched.AssignTo,lc-emailList) = 0
            THEN lc-emailList = lc-EmailList + "," + eSched.AssignTo.
    END.

               
    DISPLAY STREAM s-log
        Issue.IssueNumber
        Issue.BriefDescription
        Customer.Name
        IssAction.ActionDate
        IssAction.ActDescription
        lc-emailList FORMAT 'x(20)' COLUMN-LABEL 'Email List'.
        
    DOWN STREAM s-log.
    ASSIGN
        lc-Subject = "Action due on " + string(IssAction.ActionDate,"99/99/9999") + " " + IssAction.ActDescription
        lc-text = "<b>Issue:</b> " + string(Issue.IssueNumber) 
                                + ' ' + Issue.BriefDescription + " " + 
                                "~n<b>Customer:</b> " + Customer.Name + 
                  "~n<b>Action:</b> " + string(IssAction.ActionDate,"99/99/9999") + " " + IssAction.ActDescription.
    DO li-loop = 1 TO NUM-ENTRIES(lc-emailList):
        FIND WebUser WHERE WebUser.LoginID = ENTRY(li-loop,lc-EmailList) NO-LOCK NO-ERROR.
        IF NOT AVAILABLE WebUser
        OR WebUser.Email = "" THEN NEXT.
        
        DYNAMIC-FUNCTION("mlib-SendEmail",
                Issue.Company,
                DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",issue.company,Issue.AccountNumber),
                lc-Subject,
                lc-text,
                WebUser.email).
            
    END.
                  
    
            
END.
OUTPUT STREAM s-log CLOSE.

 
        