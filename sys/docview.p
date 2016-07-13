/***********************************************************************

    Program:        sys/docview.p
    
    Purpose:        View a documment
    
    Notes:
    
    
    When        Who         What
    21/03/2016  phoski      Document Link Is Encrypted 
          
 ***********************************************************************/
 
{src/web/method/wrap-cgi.i}
{lib/htmlib.i}
{lib/checkloggedin.i}

DEFINE VARIABLE lc-doc-key  AS CHARACTER    NO-UNDO. 


ASSIGN
    lc-doc-key = DYNAMIC-FUNCTION("sysec-DecodeValue",lc-global-user,TODAY,"Document",get-value("docid")).
        
FIND doch WHERE ROWID(doch) = to-rowid(lc-doc-key) NO-LOCK NO-ERROR.

IF NOT AVAILABLE doch THEN
DO:
    RUN ip-Error("Missing document").
    RETURN.
END.


CASE doch.doctype:
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
        output-content-type("application/" + lc(doch.doctype)).
    END.
END CASE.

FOR EACH docl WHERE docl.docid = doch.docid NO-LOCK:
    PUT {&WEBSTREAM} control docl.rdata.
END.

PROCEDURE ip-Error:

    DEFINE INPUT PARAMETER pc-error AS CHARACTER NO-UNDO.

    output-content-type("text/html").

    PUT {&webstream} unformatted
        '<html><head><title>Document Error</title></head>'
        '<body>'
        '<h1>This document can not be displayed</h1><br>'
        '<h2>Reference ' get-value("docid") '</h2>'
        '<h2>' pc-error '</h2></body></html>' skip.

    RETURN.

END PROCEDURE.
