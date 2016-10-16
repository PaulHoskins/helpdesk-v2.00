/***********************************************************************

    Program:        crm/lib/getRepList.p
   
    Purpose:        CRM Get List of Reps for user
    
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
DEFINE BUFFER salRep  FOR webuser.


FIND WebUser WHERE WebUser.LoginID = pc-LoginID NO-LOCK.

FOR EACH salRep NO-LOCK
    WHERE salRep.CompanyCode = pc-companyCode
      AND salrep.engType BEGINS "SAL"
    BY salRep.Name:
        
        
    IF WebUser.engType = "SAL" AND salRep.Loginid <> WebUser.LoginID THEN NEXT.
    
    IF pc-account = ""
    THEN ASSIGN pc-account = salRep.LoginID
                pc-name = salRep.Name.
    ELSE ASSIGN pc-account = pc-account + "|"  + salRep.LoginID  
                 pc-name = pc-name + "|" + salRep.Name.     
    
        
END.




