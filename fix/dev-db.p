
/*------------------------------------------------------------------------
    File        : dev-db.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : paul.hoskins
    Created     : Tue Jun 09 07:21:52 BST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


FOR EACH Customer EXCLUSIVE-LOCK:
     statementemail = "paulanhoskins@outlook.com".
END.

FOR EACH WebUser EXCLUSIVE-LOCK:
    WebUser.Email = "paulanhoskins@outlook.com".
    WebUser.LastPasswordChange = TODAY.
    
END. 