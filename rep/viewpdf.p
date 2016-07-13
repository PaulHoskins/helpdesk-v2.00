/* Do not use a CGI variable for the file name */
{src/web/method/wrap-cgi.i}
DEFINE VARIABLE lc-pdf AS CHARACTER NO-UNDO.
ASSIGN 
    lc-pdf = get-value("PDF").
DEFINE STREAM infile.
DEFINE VARIABLE vdata AS RAW NO-UNDO.


output-content-type("application/pdf").
INPUT stream infile from value(lc-pdf) binary.
LENGTH(vdata) = 512.
REPEAT:
    IMPORT STREAM infile UNFORMATTED vdata.
    PUT {&WEBSTREAM} control vdata.
END.
LENGTH(vdata) = 0.
INPUT stream infile close.
OS-DELETE value(lc-pdf) no-error.




