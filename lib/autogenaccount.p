/***********************************************************************

    Program:        autogenaccount.p
    
    Purpose:        Allocates an Account Number     
    
    Notes:
    
    
    When        Who         What
    15/10/2016  phoski      Initial - CRM Phase 2
    
 ***********************************************************************/
 
DEFINE INPUT PARAMETER pc-companyCode   AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER pc-Account      AS CHARACTER NO-UNDO.

DEFINE BUFFER Company  FOR Company LABEL "AutoGenCompany".
DEFINE BUFFER Customer FOR Customer.


DO WHILE TRUE:
    
    FIND Company WHERE Company.CompanyCode = pc-companyCode EXCLUSIVE-LOCK.
    
    ASSIGN 
        pc-account = STRING(Company.nextAccount)
        Company.nextAccount =  Company.nextAccount + 1.
    IF Company.lengthAccount > 0 THEN      
    DO WHILE LENGTH(pc-account) < Company.lengthAccount:
        ASSIGN
            pc-account = "0" + pc-account.
          
    END.
    
    IF CAN-FIND(Customer WHERE Customer.CompanyCode = pc-companyCode
                           AND Customer.AccountNumber = pc-account NO-LOCK) THEN NEXT.
                           
    RELEASE Company.
                           
    LEAVE.  
END.    
