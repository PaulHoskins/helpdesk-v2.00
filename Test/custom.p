

/*------------------------------------------------------------------------
    File        : custom.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pauldd
    Created     : Sun Jul 20 10:48:19 BST 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */
DEF VAR xx AS INT NO-UNDO.


/* ***************************  Main Block  *************************** */

DEFINE VARIABLE ld-basedate AS DATETIME NO-UNDO.
DEFINE VARIABLE ld-amber    AS DATETIME NO-UNDO.
DEFINE VARIABLE li-min      AS INT      NO-UNDO.

/*
FOR EACH WebUser:
    ASSIGN
       WebUser.Email = 'paulanhoskins@outlook.com'
       WebUser.Passwd = ENCODE("12345678")
       WebUser.LastPasswordChange = TODAY.
    
   
END.
*/

    