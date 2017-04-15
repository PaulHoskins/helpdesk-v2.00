/***********************************************************************

    Program:        crm/lib/process-event.p
    
    Purpose:        Do Some action for an opportunity
    
    Notes:
    
    
    When        Who         What
    06/08/2016  phoski      Initial
    09/04/2017  phoski      Note on Unqual Lead email
   
***********************************************************************/
{lib/common.i}
{lib/maillib.i}


DEFINE TEMP-TABLE tt-old-table NO-UNDO LIKE op_master.

DEFINE INPUT PARAMETER pr-Rowid     AS ROWID    NO-UNDO.
DEFINE INPUT PARAMETER pc-loginid   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-Event     AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-Data      AS CHARACTER EXTENT 10  NO-UNDO.
DEFINE INPUT PARAMETER TABLE FOR tt-old-table.


DEFINE BUFFER op_master FOR op_master.
DEFINE BUFFER company   FOR Company.
DEFINE BUFFER customer  FOR Customer.
DEFINE BUFFER b-login   FOR WebUser.
DEFINE BUFFER op_Action FOR op_Action.



FIND op_master WHERE ROWID(op_master) = pr-Rowid EXCLUSIVE-LOCK.


FIND FIRST tt-old-table NO-LOCK NO-ERROR.

FIND company WHERE Company.CompanyCode = op_master.CompanyCode NO-LOCK NO-ERROR.

ASSIGN
    lc-global-company = Company.CompanyCode.
        
FIND Customer WHERE Customer.CompanyCode = op_master.CompanyCode
    AND Customer.AccountNumber = op_master.AccountNumber NO-LOCK NO-ERROR.
         
                
FIND b-login WHERE b-login.loginid = op_master.salesContact NO-LOCK NO-ERROR.              

CASE pc-event:
    WHEN "ADD" THEN
        DO:
            IF op_master.OpType = "ULEAD" AND Company.unqualOppEmail <> ""
                THEN RUN SendUnqualLeadEmail.
     
            CREATE op_Status.
            ASSIGN
                op_status.companyCode  = op_master.CompanyCode
                op_status.op_id        = op_master.op_id
                op_status.loginid      = pc-loginid 
                op_status.ChangeDate   = NOW
                op_status.FromOPStatus = ""
                op_status.ToOpStatus   = op_master.OpStatus.
  
        END.

    WHEN "UPDATE" THEN
        DO:
            IF op_master.OpStatus <> tt-old-table.OpStatus THEN
            DO:
                CREATE op_Status.
                ASSIGN
                    op_status.companyCode  = op_master.CompanyCode
                    op_status.op_id        = op_master.op_id
                    op_status.loginid      = pc-loginid 
                    op_status.ChangeDate   = NOW
                    op_status.FromOPStatus = tt-old-table.OpStatus
                    op_status.ToOpStatus   = op_master.OpStatus.
            END.
          
        END.
    WHEN "ADD.ACTION" THEN
        DO:
            
            FIND op_Action WHERE ROWID(op_action) = to-rowid(pc-data[1]) NO-LOCK.
            
            RUN SendActionAssignEmail.
            
        END.
        
END CASE.




/* **********************  Internal Procedures  *********************** */

PROCEDURE SendActionAssignEmail:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-subject AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-text    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-link    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-descr   AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER WebAction FOR WebAction.
    DEFINE BUFFER b-user    FOR WebUser.
    
    
    FIND WebAction 
        WHERE WebAction.CompanyCode = op_Action.CompanyCode
        AND WebAction.ActionCode = op_Action.ActionCode
        NO-LOCK NO-ERROR.
         
    FIND b-user
        WHERE b-user.LoginID = op_Action.AssignTo 
        NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-user THEN RETURN.
                                          
            
    ASSIGN 
        lc-descr = IF AVAILABLE WebAction THEN WebAction.Description ELSE op_Action.ActionCode.
              
    

    ASSIGN
        lc-subject = "CRM Opportunity Assignment - Opportunity " + string(op_master.op_no) .
    

        
    ASSIGN 
        lc-text = "~nCompany Name: " + Customer.Name 
                    + "~n~nOpportunity: " + string(op_master.op_no) 
                    + " - " + op_master.descr 
                    + "~n~nAction Details".
                    
    
    
    ASSIGN 
        lc-text = lc-text + "~nAction Type: " + lc-descr
                        + "~nNote:~n " + op_Action.notes.
    
    ASSIGN 
        lc-text = lc-text + "~n~nAssign to you by " + com-userName(pc-loginid) + " on " + string(NOW,"99/99/9999 HH:MM AM").
        
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
            
         
    DYNAMIC-FUNCTION("mlib-SendEmail",
        op_master.CompanyCode,
        DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",op_master.companyCode,op_master.AccountNumber),
        lc-Subject,
        lc-text,
        b-user.Email).
                
                


END PROCEDURE.

PROCEDURE SendUnqualLeadEmail:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-subject AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-text    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-link    AS CHARACTER NO-UNDO.
      
    

    ASSIGN
        lc-subject = "Unqualified Lead Created - " + string(op_master.op_no) + " @ " + string(NOW,"99/99/9999 hh:mm").
    
    ASSIGN 
        lc-text = "Dear Sales,~n~nA new Unqualified Lead has been added to the CRM Opportunities. The details are as below:-~n".
        
    ASSIGN 
        lc-text = lc-text + "~nCompany Name: " + Customer.Name.
    IF AVAILABLE b-login THEN
    DO:    
        ASSIGN 
            lc-text = lc-text + "~n~nSales Contact: " + b-login.Name.
        
        ASSIGN 
            lc-text = lc-text + "~n~nTelephone No: " + b-login.Telephone.
            
        ASSIGN 
            lc-text = lc-text + "~n~nMobile No: " + b-login.Mobile.
            
        ASSIGN 
            lc-text = lc-text + "~n~nEmail: " + b-login.Email.
       
        
    END.
    ASSIGN 
        lc-text = lc-text + "~n~nPost Code: " + Customer.Postcode.
        
     ASSIGN 
            lc-text = lc-text + "~n~nDescription: " + op_master.descr.
       
    ASSIGN 
            lc-text = lc-text + "~n~nNote:~n~n " + op_master.OpNote.
               
        
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
            
         
    DYNAMIC-FUNCTION("mlib-SendEmail",
        op_master.CompanyCode,
        DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",op_master.companyCode,op_master.AccountNumber),
        lc-Subject,
        lc-text,
        Company.unqualOppEmail).
                

END PROCEDURE.
