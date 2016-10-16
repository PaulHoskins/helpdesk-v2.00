/***********************************************************************

    Program:        crm/lib/getCustomerList.p
   
    Purpose:        CRM Get List of Customers for user
    
    Notes:
    
    
    When        Who         What
    16/10/2016  phoski      Initial
   
***********************************************************************/

DEFINE INPUT PARAMETER pc-companyCode   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-LoginID       AS CHARACTER NO-UNDO.

DEFINE OUTPUT PARAMETER pc-Account      AS LONGCHAR NO-UNDO.
DEFINE OUTPUT PARAMETER pc-Name         AS LONGCHAR NO-UNDO.

{lib/common.i}

DEFINE BUFFER webuser   FOR WebUser.
DEFINE BUFFER customer  FOR Customer.


FIND WebUser WHERE WebUser.LoginID = pc-LoginID NO-LOCK.

FOR EACH Customer NO-LOCK
    WHERE Customer.CompanyCode = pc-companyCode
    BY Customer.Name:
        
    IF Customer.accStatus =  lc-global-accStatus-HelpDesk-InActive THEN NEXT.
    
    IF WebUser.engType = "SAL" AND Customer.SalesManager <> WebUser.LoginID THEN NEXT.
    
    IF pc-account = ""
    THEN ASSIGN pc-account = Customer.AccountNumber
                pc-name = Customer.Name.
    ELSE ASSIGN pc-account = pc-account + "|"  + Customer.AccountNumber   
                 pc-name = pc-name + "|" + Customer.Name.     
    
        
END.




