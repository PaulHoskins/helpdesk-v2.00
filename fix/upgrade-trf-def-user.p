
/*------------------------------------------------------------------------
    File        : upgrade-trf-def-user.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : paul.hoskins
    Created     : Sat Aug 15 08:13:01 BST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


FOR EACH WebUser NO-LOCK WHERE defaultuser :
    
    DISPLAY WebUser.LoginID WebUser.AccountNumber WebUser.CompanyCode.
    FIND Customer WHERE Customer.CompanyCode =  WebUser.CompanyCode
                    AND Customer.AccountNumber = WebUser.AccountNumber EXCLUSIVE-LOCK NO-ERROR.
    IF AVAILABLE Customer
    THEN Customer.def-iss-loginid = WebUser.LoginID.
     
                    
    
END.
