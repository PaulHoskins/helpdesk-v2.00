
/*------------------------------------------------------------------------
    File        : c-ops.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Fri Dec 02 17:09:49 GMT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


DEFINE VARIABLE li-op   AS INTEGER INITIAL 16 NO-UNDO.
DEFINE VARIABLE li-from AS INTEGER NO-UNDO.
DEFINE VARIABLE li-next AS INTEGER NO-UNDO.
DEFINE VARIABLE li-count AS INTEGER INITIAL 100 NO-UNDO.
DEFINE VARIABLE li-loop AS INTEGER NO-UNDO.




DEFINE BUFFER b FOR op_master.
DEFINE BUFFER c FOR op_master.
DEFINE BUFFER n FOR op_master.



FOR EACH b:
        descr = "op " + string(b.op_no).
END.

