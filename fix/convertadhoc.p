/***********************************************************************

    Program:        fix/convertadhoc.p
    
    Purpose:        Convert blank contracts to customer default
    
    Notes:
    
    
    When        Who         What
    15/06/2015  phoski      Initial
   
***********************************************************************/

DEFINE VARIABLE lc-company   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-msg       AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-do        AS LOG       NO-UNDO.




DEFINE STREAM s.


ASSIGN
    lc-company   = "ouritdept"
    .
 
OUTPUT STREAM s TO c:\temp\convertadhoc.txt.

FOR EACH Customer NO-LOCK
    WHERE Customer.CompanyCode = lc-company 
    TRANSACTION WITH DOWN STREAM-IO WIDTH 255:
  
    FIND FIRST WebissCont WHERE
        webisscont.companyCode = Customer.CompanyCode
        AND webisscont.Customer = Customer.AccountNumber
        AND WebissCont.DefCon = TRUE
        NO-LOCK NO-ERROR.
        
    FIND FIRST Issue 
    WHERE
        Issue.companyCode = Customer.CompanyCode
        AND issue.AccountNumber = Customer.AccountNumber
        AND Issue.ContractType = ""
        NO-LOCK NO-ERROR.
    IF NOT AVAILABLE Issue THEN NEXT.     
    ASSIGN lc-msg = ""
           ll-do  = FALSE.
    IF AVAILABLE Issue
    AND NOT AVAILABLE WebissCont
    THEN lc-msg = "** No default to move to".
    ELSE
    IF AVAILABLE Issue
    THEN ASSIGN lc-msg = "Will Move"
                ll-do = TRUE.
          
    DISPLAY STREAM s
        Customer.AccountNumber
        Customer.Name
        WebissCont.ContractCode COLUMN-LABEL 'Default' WHEN AVAILABLE WebissCont
        
        AVAILABLE Issue COLUMN-LABEL 'Has AdHoc?'
        lc-msg COLUMN-LABEL 'Action' FORMAT 'x(30)'
        .
    IF ll-do THEN
    FOR EACH Issue 
        WHERE Issue.companyCode = Customer.CompanyCode
            AND issue.AccountNumber = Customer.AccountNumber
            AND Issue.ContractType = "" EXCLUSIVE-LOCK WITH DOWN FRAME f2 STREAM-IO WIDTH 255:
                
         DISPLAY STREAM s 
            Issue.IssueNumber Issue.IssueDate Issue.BriefDescription. 
                
         ASSIGN 
            Issue.Old_ContractType = "Yes,"
            Issue.ContractType = WebissCont.ContractCode.
                
    END.   
      
            
END.       

            
OUTPUT STREAM s CLOSE.
    
