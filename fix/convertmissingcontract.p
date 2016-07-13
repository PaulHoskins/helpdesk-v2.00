/***********************************************************************

    Program:        fix/convertmissingcontrac.p
    
    Purpose:        Convert missing contracts to customer default
    
    Notes:
    
    
    When        Who         What
    15/06/2015  phoski      Initial
   
***********************************************************************/

DEFINE VARIABLE lc-company AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-msg     AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-do      AS LOG       NO-UNDO.
DEFINE VARIABLE ll-found   AS LOG       NO-UNDO.
DEFINE VARIABLE lc-default AS CHAR      NO-UNDO.





DEFINE STREAM s.


ASSIGN
    lc-company = "ouritdept"
    .
 
OUTPUT STREAM s TO c:\temp\convertmissing.txt.

FOR EACH Issue EXCLUSIVE-LOCK:
    IF NUM-ENTRIES(Issue.ContractType,'|') > 1
    THEN  Issue.ContractType = ENTRY(1,Issue.ContractType,"|").  
END.    
FOR EACH Customer NO-LOCK
    WHERE Customer.CompanyCode = lc-company 
    TRANSACTION WITH DOWN STREAM-IO WIDTH 255:
  
    FIND FIRST WebissCont WHERE
        webisscont.companyCode = Customer.CompanyCode
        AND webisscont.Customer = Customer.AccountNumber
        AND WebissCont.DefCon = TRUE
        NO-LOCK NO-ERROR.
    IF NOT AVAILABLE WebissCont THEN NEXT.

    lc-default = WebissCont.ContractCode.
    ll-found  = NO.
            
    FOR EACH Issue 
        WHERE
        Issue.companyCode = Customer.CompanyCode
        AND issue.AccountNumber = Customer.AccountNumber
        NO-LOCK :
        
        FIND FIRST WebissCont WHERE
            webisscont.companyCode = Customer.CompanyCode
            AND webisscont.Customer = Customer.AccountNumber
            AND WebissCont.ContractCode = Issue.ContractType
            NO-LOCK NO-ERROR.
        IF AVAILABLE WebissCont THEN NEXT.
        ll-found = TRUE.
        LEAVE.
             
    END.
    IF NOT ll-found THEN NEXT.
    
     
    ASSIGN 
        lc-msg = ""
        ll-do  = FALSE.
    
          
    DISPLAY STREAM s
        Customer.AccountNumber
        Customer.Name
        lc-default COLUMN-LABEL 'Default' 
     
        .
    
    FOR EACH Issue 
        WHERE Issue.companyCode = Customer.CompanyCode
        AND issue.AccountNumber = Customer.AccountNumber
        EXCLUSIVE-LOCK WITH DOWN FRAME f2 STREAM-IO WIDTH 255:
           
        FIND FIRST WebissCont WHERE
            webisscont.companyCode = Customer.CompanyCode
            AND webisscont.Customer = Customer.AccountNumber
            AND WebissCont.ContractCode = Issue.ContractType
            NO-LOCK NO-ERROR.
        IF AVAILABLE WebissCont THEN NEXT.
                
        DISPLAY STREAM s 
            Issue.IssueNumber Issue.IssueDate Issue.ContractType FORMAT 'x(40)'. 
           
            
     ASSIGN 
        Issue.Old_ContractType = "Yes," + Issue.ContractType
        Issue.ContractType = lc-default.
            
    END.   
      
            
END.       

            
OUTPUT STREAM s CLOSE.
    
