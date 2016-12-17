/***********************************************************************

    Program:        batch/opactwarn.p
    
    Purpose:        Last Activity Warning Emails
    
    Notes:
    
    
    When        Who         What
    01/03/2016  phoski      Initial
    
   
***********************************************************************/
{lib/common.i}
{lib/maillib.i}

DEFINE VARIABLE ld-date    AS DATE      NO-UNDO.
DEFINE VARIABLE lc-LastAct AS CHARACTER NO-UNDO.
DEFINE VARIABLE ld-LastAct AS DATE      NO-UNDO.
DEFINE VARIABLE lr-LastAct AS ROWID     NO-UNDO.

DEFINE VARIABLE lc-subject AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-text    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-descr   AS CHARACTER NO-UNDO.
    

DEFINE BUFFER op_master   FOR op_master.
DEFINE BUFFER company     FOR Company.
DEFINE BUFFER customer    FOR Customer.
DEFINE BUFFER b-login     FOR WebUser.
DEFINE BUFFER op_Action   FOR op_Action.
DEFINE BUFFER op_Activity FOR op_Activity.



DEFINE STREAM rp.



ASSIGN
    ld-date = TODAY.
   
OUTPUT STREAM rp TO c:\temp\opactwarn.log.
    

FOR EACH Company NO-LOCK
    WHERE Company.opactwarnDays > 0 WITH FRAME flog DOWN STREAM-IO WIDTH 255:

    ASSIGN
        lc-global-company = Company.CompanyCode.
    
    FOR EACH op_master NO-LOCK
        WHERE op_master.CompanyCode = lc-global-company
        AND op_master.OpStatus = "OP"   WITH FRAME flog:
       
        ASSIGN
            lr-lastAct = ?
            ld-LastAct = ?
            lc-LastAct = "".
       
        FOR EACH op_activity NO-LOCK
            WHERE op_activity.CompanyCode = op_master.CompanyCode
            AND op_activity.op_id = op_master.op_id
            BY op_activity.startDate 
            BY op_activity.startTime:
   
            ASSIGN 
                lc-LastAct = STRING(op_activity.StartDate,"99/99/9999") + 
                    " " +
                   string(op_activity.StartTime,"hh:mm")
                ld-LastAct = op_activity.StartDate
                lr-LastAct = ROWID(op_activity).
                   
            IF op_activity.activityType <> ""
                THEN ASSIGN lc-LastAct = lc-LastAct + " : " + op_activity.activityType + " - " + op_activity.Description.
                
                  
        END.
        
        IF ld-lastAct = ?
            OR ld-lastAct > ld-date - Company.opactwarnDays THEN NEXT.
        
        FIND op_Activity WHERE ROWID( op_activity) = lr-LastAct NO-LOCK.
        
        FIND Customer WHERE Customer.CompanyCode = op_master.CompanyCode
            AND Customer.AccountNumber = op_master.AccountNumber NO-LOCK NO-ERROR.
         
                
        FIND b-login WHERE b-login.loginid = Customer.SalesManager NO-LOCK NO-ERROR.  

        ASSIGN
            lc-subject = "CRM Opportunity Activity - Opportunity " + string(op_master.op_no) +
                        " None After " + string(ld-date - Company.opactwarnDays,"99/99/9999").
    

        
        ASSIGN 
            lc-text = "~nCompany Name: " + Customer.Name 
                    + "~n~nOpportunity: " + string(op_master.op_no) 
                    + " - " + op_master.descr 
                    + "~n~nLast Activity: " + lc-LastAct.
        IF Company.helpdesklink <> ""  THEN 
        DO:
            ASSIGN 
                lc-link = Company.helpdesklink + "/mn/login.p?company=" + Company.CompanyCode
                                                + "&mode=passthru&passtype=opportunity&passref=" + string(op_master.op_no).
                                                
            ASSIGN 
                lc-text = lc-text + "~n~nBy selecting the following link you will access the Opportunity~n~n" +
                  substitute('<a href="&2">&1</a>',
                          "Opportunity - " + string(op_master.op_no),
                          lc-Link ).
                          
        END.   
           
        DISPLAY STREAM rp
            b-login.Email
            op_master.op_no op_master.descr ld-date - Company.opactwarnDays FORMAT '99/99/9999' COLUMN-LABEL 'Trigger!Date'
                    lc-lastAct FORMAT 'x(40)'.
        DOWN STREAM rp.
        
             
        
        
        DYNAMIC-FUNCTION("mlib-SendEmail",
            op_master.CompanyCode,
            DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",op_master.companyCode,op_master.AccountNumber),
            lc-Subject,
            lc-text,
            b-login.Email + "," + Company.opactwarnEmail).
    
    END.
     
    
END.

OUTPUT STREAM rp CLOSE.



/* **********************  Internal Procedures  *********************** */

