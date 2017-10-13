
/*------------------------------------------------------------------------
    File        : getcrmlist.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Sat Sep 09 08:31:14 BST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* bprowsdldoc http://localhost:8080/wsa/wsa1/wsdl?targetURI=urn:tempuri-org
wsdl /language:VB /out:HelpDeskProxyClass.vb http://localhost:8080/wsa/wsa1/wsdl?targetURI=urn:tempuri-org

 */


DEFINE TEMP-TABLE tt_crm NO-UNDO SERIALIZE-NAME "crm" 
    FIELD opNo      AS INTEGER 
    FIELD opDesc    AS CHARACTER 
    .
    
DEFINE OUTPUT PARAMETER pc-token        AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER pl-ok           AS LOGICAL      NO-UNDO.
DEFINE OUTPUT PARAMETER pc-message      AS CHARACTER    NO-UNDO.

DEFINE OUTPUT PARAMETER TABLE FOR tt_crm.

MESSAGE "PAULH Exec".



pl-ok = TRUE.

FOR EACH op_master NO-LOCK:
    CREATE tt_crm.
    ASSIGN
        tt_crm.opNo = op_master.op_no
        tt_crm.opDesc = op_master.descr.
 END.
    