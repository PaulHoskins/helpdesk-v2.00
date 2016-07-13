{src/web/method/wrap-cgi.i}

DEFINE VARIABLE lc-global-helpdesk      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-global-reportpath    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-docid                AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-doctype              AS CHARACTER NO-UNDO.
DEFINE VARIABLE lb-blob                 AS RAW  NO-UNDO.
DEFINE VARIABLE li-line                 AS INTEGER  NO-UNDO.

DEFINE TEMP-TABLE newdoc LIKE docl.

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

ASSIGN 
    lc-docid = STRING(lc-global-reportpath + "\" + lc-docid + ".xls")
    lc-doctype = "xls".


ASSIGN 
    LENGTH(lb-blob) = 16384.
INPUT from value(lc-docid) binary no-map no-convert.
REPEAT:
    IMPORT UNFORMATTED lb-blob.
    ASSIGN 
        li-line = li-line + 1.
    CREATE newdoc.
    ASSIGN 
        newdoc.DocID   = 1
        newdoc.Lineno  = li-line
        newdoc.rdata   = lb-blob.
END.
INPUT close.
ASSIGN 
    LENGTH(lb-blob) = 0.

CASE lc-doctype:
    WHEN "PDF" THEN output-content-type("application/pdf").
    WHEN "DOC" 
    OR 
    WHEN "DOT" THEN output-content-type("application/msword").
    WHEN "HTM"  
    OR 
    WHEN "HTML" THEN output-content-type("text/html").
    WHEN "XLS" 
    OR 
    WHEN "XLT" 
    OR 
    WHEN "XLTX" THEN output-content-type("application/vnd.ms-excel").
    WHEN "TXT" THEN output-content-type("text/plain~;charset=iso-8859-1").
    WHEN "INI"
    OR 
    WHEN "D"
    OR 
    WHEN "DF" THEN output-content-type("text/plain").
    WHEN "PPT" THEN output-content-type("application/ms-powerpoint").
    WHEN "PNG" THEN output-content-type("image/png").
    WHEN "GIF" THEN output-content-type("image/gif").
    WHEN "jpe"
    OR 
    WHEN "jpg"
    OR 
    WHEN "jpeg" THEN output-content-type("image/jpeg").
    WHEN "XML" THEN output-content-type("text/xml").
    WHEN "ZIP" THEN output-content-type("application/zip").
    WHEN "msg" THEN output-content-type("application/vnd.ms-outlook").
    OTHERWISE
    DO:
        RUN ip-Error("Unknown content type of " + lc-docid).
        RETURN.
    END.
END CASE.

FOR EACH newdoc WHERE newdoc.docid = 1 NO-LOCK:
    PUT {&WEBSTREAM} control newdoc.rdata.
END.



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
