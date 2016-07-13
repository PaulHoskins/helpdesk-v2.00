/***********************************************************************

    Program:        rep/deleteview.p
    
    Purpose:        Management Report -  - Delete Reports
    
    Notes:
    
    
    When        Who         What
    10/11/2010  DJS         Initial
    
***********************************************************************/


{src/web/method/wrap-cgi.i}

DEFINE VARIABLE lc-global-helpdesk   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-global-reportpath AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-docid             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-doctype           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lb-blob              AS RAW  NO-UNDO.
DEFINE VARIABLE li-line              AS INTEGER  NO-UNDO.
DEFINE VARIABLE lc-webuser           AS CHARACTER NO-UNDO.

DEFINE TEMP-TABLE newdoc LIKE docl.

OUTPUT to "C:\temp\djs.txt" append.
PUT UNFORMATTED 
    "lc-docid                "  lc-docid SKIP
    "lc-global-helpdesk      "  lc-global-helpdesk SKIP
    "lc-global-reportpath    "  lc-global-reportpath SKIP(2).
OUTPUT close.




FIND WebAttr WHERE WebAttr.SystemID = "BATCHWORK"
    AND   WebAttr.AttrID   = "BATCHPATH"
    NO-LOCK NO-ERROR.
ASSIGN 
    lc-global-helpdesk = WebAttr.AttrValue .

FIND WebAttr WHERE WebAttr.SystemID = "BATCHWORK"
    AND   WebAttr.AttrID   = "REPORTPATH"
    NO-LOCK NO-ERROR.
ASSIGN 
    lc-global-reportpath = WebAttr.AttrValue .

ASSIGN 
    lc-docid = get-value("rowid").

FIND FIRST BatchWork WHERE ROWID(BatchWork) = to-rowid(lc-docid) NO-ERROR. 

IF AVAILABLE BatchWork THEN 
DO: 
    ASSIGN 
        BatchWork.BatchDelete = TRUE
        lc-webuser            = BatchWork.BatchUser
        lc-docid              = STRING(lc-global-reportpath + "\" + string(BatchWork.batchID) + "_" + BatchWork.Description + ".xls").

    OS-DELETE value(lc-docid) no-error.
    DELETE BatchWork.
    RUN run-web-object IN web-utilities-hdl ("rep/engrep01.p").
    RETURN .
END.
ELSE
DO:
    output-content-type("text/html").
    PUT {&webstream} unformatted
      '<html><head><title>Document Error</title></head>'
      '<body>'
      '<h1>This document can not be deleted</h1><br>'
      '<h2>Document ID = ' lc-docid '</h2><br>'
      '<h2> Please contact your system administrator. </h2></body></html>' skip.
    RETURN .
END.

