
/*------------------------------------------------------------------------
    File        : reset-pass.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : paul
    Created     : Thu Nov 06 09:07:24 GMT 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

FOR EACH webuser EXCLUSIVE-LOCK.

ASSIGN
    passwd = ENCODE("12345678")
    WebUser.LastPasswordChange = TODAY.
    WebUser.Email = "paulanhoskins@outlook.com".
    
END.
    