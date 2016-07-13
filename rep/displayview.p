/***********************************************************************

    Program:        rep/displayview.p
    
    Purpose:        Management Report -  Display Report detail
    
    Notes:
    
    
    When        Who         What
    10/11/2010  DJS         Initial
    
***********************************************************************/

{src/web/method/wrap-cgi.i}

DEFINE VARIABLE lc-global-helpdesk      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-global-reportpath    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-docid                AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-doctype              AS CHARACTER NO-UNDO.
DEFINE VARIABLE lb-blob                 AS RAW  NO-UNDO.
DEFINE VARIABLE li-line                 AS INTEGER  NO-UNDO.
DEFINE VARIABLE TYPEOF                  AS CHARACTER INITIAL "Detail,Summary_Detail,Summary" NO-UNDO.
DEFINE VARIABLE ISSUE                   AS CHARACTER INITIAL "Customer,Engineer,Issues"  NO-UNDO.
DEFINE VARIABLE CAL                     AS CHARACTER INITIAL "Week,Month" NO-UNDO.
 

FIND WebAttr WHERE WebAttr.SystemID = "BATCHWORK"
    AND   WebAttr.AttrID   = "BATCHPATH"
    NO-LOCK NO-ERROR.
ASSIGN 
    lc-global-helpdesk =  WebAttr.AttrValue .

FIND WebAttr WHERE WebAttr.SystemID = "BATCHWORK"
    AND   WebAttr.AttrID   = "REPORTPATH"
    NO-LOCK NO-ERROR.
ASSIGN 
    lc-global-reportpath =  WebAttr.AttrValue .

ASSIGN 
    lc-docid = get-value("docid").

FIND FIRST BatchWork WHERE ROWID(BatchWork) = to-rowid(lc-docid) NO-LOCK NO-ERROR.

output-content-type("text/html").
PUT {&webstream} unformatted
      '<html><head><title>Document Details</title></head>' skip
      '<body>' skip
      '<h2> Details for batch ' string(BatchWork.BatchID) ' </h2><br /> ' skip
      ' Run date: ' string(BatchWork.BatchDate,"99/99/9999")  ' Time: ' string(BatchWork.BatchTime,"HH:MM")  '<br /> ' skip
      ' <br /> ' skip
      ' Description : ' BatchWork.Description ' <br /> ' skip
      ' View : '        entry(integer(BatchWork.BatchParams[2]),TYPEOF) ' <br /> ' skip
      ' For :  '        entry(integer(BatchWork.BatchParams[3]),ISSUE) ' <br /> ' skip
      ' By : '          entry(integer(BatchWork.BatchParams[4]),CAL) ' <br /> ' skip.

IF BatchWork.BatchParams[3] = "2" THEN  PUT {&webstream} unformatted ' Engineers : '   BatchWork.BatchParams[5] ' <br /> ' skip.
ELSE  PUT {&webstream} unformatted ' Customers : '   BatchWork.BatchParams[6] ' <br /> ' skip.
PUT {&webstream} unformatted
      ' Period : '      BatchWork.BatchParams[7] ' <br /> <br />' skip
      '<input   type="button" id=closebutton value="Close"    name="ButtonClose" onclick="javascript:window.close()"  class="button">'  skip
      ' </body></html>' skip.


 
 


PROCEDURE ip-Error:
    DEFINE INPUT PARAMETER pc-error AS CHARACTER NO-UNDO.
    output-content-type("text/html").
    PUT {&webstream} unformatted
        '<html><head><title>Document Error</title></head>'
        '<body>'
        '<h1>This document can not be displayed</h1><br>'
        '<h2>Document ID =' lc-docid '</h2><br>'
        '<h2>' pc-error '</h2></body></html>' skip.
    RETURN.
END PROCEDURE.
