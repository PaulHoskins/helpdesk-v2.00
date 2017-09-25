
/*------------------------------------------------------------------------
    File        : login.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Sat Sep 09 08:31:14 BST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* bprowsdldoc http://localhost:8080/wsa/wsa1/wsdl?targetURI=urn:tempuri-org */


DEFINE INPUT PARAMETER  pc-LoginId      AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER  pc-Passwd       AS CHARACTER    NO-UNDO.

DEFINE OUTPUT PARAMETER pl-ok           AS LOGICAL      NO-UNDO.
DEFINE OUTPUT PARAMETER pc-message      AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER pc-token        AS CHARACTER    NO-UNDO.


ASSIGN 
    pl-ok      = NO
    pc-message = "The user does not exist".
       
    