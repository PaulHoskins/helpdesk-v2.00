
/*------------------------------------------------------------------------
    File        : fix-seq.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : paul
    Created     : Sun Aug 17 11:28:33 BST 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

DEFINE VARIABLE li-docid AS INTEGER NO-UNDO.

REPEAT:
  
    
    FIND LAST doch NO-LOCK.
    CURRENT-VALUE(docid) = doch.DocID + 1.
    DISPLAY doch.DocID CURRENT-VALUE(docid).
    
    LEAVE.
END.
        