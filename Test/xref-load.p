
/*------------------------------------------------------------------------
    File        : xref-load.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Sat Jul 22 07:52:21 BST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

DEFINE TEMP-TABLE tt NO-UNDO
    FIELD cRecord AS CHARACTER FORMAT 'x(250)' 
    .
    
DEFINE VARIABLE c AS CHARACTER NO-UNDO.
    
INPUT FROM c:\temp\xref.txt.
REPEAT:
    IMPORT UNFORMATTED c.
    CREATE tt.
    ASSIGN tt.cRecord = c.
END.
INPUT CLOSE.
    
OUTPUT TO c:\temp\report.txt.

FOR EACH tt NO-LOCK WITH DOWN STREAM-IO WIDTH 255:
    IF cRecord MATCHES "*SEARCH*" THEN
    DO: /*
        IF cRecord MATCHES "*WHOLE-INDEX*" 
        AND NOT cRecord MATCHES "*webuSteam*" 
         AND NOT cRecord MATCHES "*TempTable*" 
        THEN DISPLAY cRecord.  */
        IF cRecord MATCHES "*helpdesk.IssStatus NewStatusCode*"
        THEN DISPLAY cRecord.
    END.
END.
