/***********************************************************************

    Program:        lib/princexml.i
    
    Purpose:             
    
    Notes:
    
    
    When        Who         What
    11/04/2006  phoski      Initial
    
    03/08/2010  DJS         3665 - Changed to putput only the html file
                            for the email
    20/06/2011  DJS         Changed to output as complete HTML email
    
***********************************************************************/

&if defined(princexml-library-defined) = 0 &then

&glob princexml-library-defined yes

&global-define prince put stream s-prince unformatted 

DEFINE STREAM s-prince.
DEFINE VARIABLE lc-prince-exec AS CHARACTER INITIAL
    '"C:\Program Files (x86)\Prince\engine\bin\prince.exe"' NO-UNDO.

DEFINE TEMP-TABLE tt-pxml NO-UNDO
    FIELD PageOrientation AS CHARACTER
    . 




FUNCTION pxml-Convert       RETURNS LOG ( pc-html AS CHARACTER , pc-pdf AS CHARACTER):

    OS-COMMAND SILENT VALUE(lc-prince-exec + " " + pc-html + " " + pc-pdf ).

    RETURN SEARCH(pc-pdf) <> ?.

END FUNCTION.



FUNCTION pxml-Initialise    RETURNS LOG ():
    EMPTY TEMP-TABLE tt-pxml.

END FUNCTION.



FUNCTION pxml-Safe RETURNS CHARACTER ( p_in AS CHARACTER ):
    ASSIGN
        p_in = REPLACE(p_in, "&":U, "&amp~;":U)       /* ampersand */
        p_in = REPLACE(p_in, "~"":U, "&quot~;":U)     /* quote */
        p_in = REPLACE(p_in, "<":U, "&lt~;":U)        /* < */
        p_in = REPLACE(p_in, ">":U, "&gt~;":U).       /* > */

    RETURN p_in.

END FUNCTION.



FUNCTION pxml-StandardHTMLBegin RETURNS LOG ():

    {&prince}
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' skip
        '<html>' skip
        '<head>' skip
    .
    RETURN TRUE.

END FUNCTION.

FUNCTION pxml-StandardBody RETURNS LOG ():

    {&prince}
    '</head>' skip
        '<body>' skip.

    RETURN TRUE.


END FUNCTION.



FUNCTION pxml-Header        RETURNS LOG (pc-companyCode AS CHARACTER):


    DEFINE BUFFER b-company FOR Company.


    DYNAMIC-FUNCTION("pxml-StandardHTMLBegin").

    DYNAMIC-FUNCTION("pxml-StyleSheet",pc-companyCode).
    
    FIND company WHERE company.Companycode = pc-companyCode NO-LOCK NO-ERROR.

    DYNAMIC-FUNCTION("pxml-StandardBody").

    
    IF NOT AVAILABLE Company THEN
        {&prince}
    '<div class="heading">' skip
        '   Micar Computer Systems Limited - HelpDesk' skip.
    else
    {&prince}
        '<div class="heading">' skip
        '   ' dynamic-function("pxml-Safe",Company.Name) ' - HelpDesk' skip.
    
    DYNAMIC-FUNCTION("pxml-Logo",pc-companyCode).
        
    {&prince}
    '   <span style="float: right">' STRING(TODAY,"99/99/9999") '</span>' skip
        '</div>' skip
        '<div id="content">' skip.


    RETURN TRUE.

END FUNCTION.


/* ADDED June 2011 - DJS */
FUNCTION pxml-Email-Header        RETURNS CHARACTER (pc-companyCode AS CHARACTER):
    DEFINE VARIABLE lc-output AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-use    AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-company FOR Company.




    lc-output =  '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' +
        '<html>' +
        '<head>'
        .

    FIND company WHERE company.Companycode = pc-companyCode NO-LOCK NO-ERROR.

    lc-output = lc-output +
        '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">' +
        '<title>' + company.Name + '</title>'  .



    lc-output = lc-output +
        '</head>' +
        '<body>' +
        '<div >' +
        '<table style="position:relative;flow:static(header);width:100%;font-size:15px; ">' +
        '<tr>' +
        '</tr>' +
        '<td>' .



    IF pc-companyCode = "micar" THEN
    DO:
        lc-use = "http://micar.com/resources/template/header_logo.gif".
        lc-output = lc-output + '<img src="' + lc-use + '" height=113px width=160px style="float: left; padding-right: 10px;">' .
    END.
    ELSE
    DO:
        lc-use = "http://www.ouritdept.co.uk/files/main_logo.jpg".
        lc-output = lc-output + '<img src="' + lc-use + '" height=70px width=160px style="float: left; padding-right: 10px;">' .
    END.



    lc-output = lc-output +
        '</td>' +
        '<td>' +
        '</td>' +
        '<tr>' +
        '<td align="left">' .

    IF NOT AVAILABLE Company THEN
        lc-output = lc-output +
            '<div class="heading">' +
            '   Micar Computer Systems Limited - HelpDesk' .
    ELSE
        lc-output = lc-output +
            '<div class="heading">' +
            dynamic-function("pxml-Safe",Company.Name) + ' - HelpDesk' .

    lc-output = lc-output +
        '</td>' +
        '<td align="right">' + string(TODAY,"99/99/9999") + '</td>' +
        '</tr>' +
        '</table>' +
        '</div>' .



    RETURN lc-output.

END FUNCTION.

/* ------------------------------------------------------------- */

FUNCTION pxml-PrePrintFooter RETURNS LOG ( pc-companyCode AS CHARACTER ):

    DEFINE BUFFER b-Company FOR Company.

    FIND Company 
        WHERE Company.CompanyCode = pc-CompanyCode NO-LOCK NO-ERROR.

    IF NOT AVAILABLE Company THEN RETURN TRUE.

    {&prince}
    '<style>' skip
        '@page ~{' skip
        '@bottom ~{' skip
        'font-size: 8px;' skip
        'content: "' Company.name '";' skip
        'border-top: 1px solid black;' skip
        '~}' skip
        '~}' skip
        '</style>' skip.

    RETURN TRUE.
END FUNCTION.


FUNCTION pxml-Footer RETURNS LOG ( pc-companycode AS CHARACTER ):

    {&prince}
    '</div>' skip
        '</body>' skip
        '</html>' skip.

    RETURN TRUE.

END FUNCTION.


FUNCTION pxml-FileNameLogo RETURNS CHARACTER ( pc-CompanyCode AS CHARACTER ):

    DEFINE VARIABLE lc-style AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE li-loop  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-use   AS CHARACTER NO-UNDO.

    ASSIGN
        lc-style[1] = "prince/" + lc(pc-companyCode) + "/logo.gif"
        lc-style[2] = "prince/default/logo.gif".

    DO li-loop = 1 TO 2:
        ASSIGN 
            lc-style[li-loop] = SEARCH((lc-style[li-loop])).
        IF lc-style[li-loop] = ? THEN NEXT.
        ASSIGN
            lc-use = lc-style[li-loop].
        LEAVE.
    END.

    IF lc-use <> ? THEN
    DO:
        FILE-INFO:FILE-NAME = lc-use.
        ASSIGN 
            lc-use = FILE-INFO:FULL-PATHNAME.
    END.

    RETURN lc-use.

END FUNCTION.


FUNCTION pxml-Logo    RETURNS LOG ( pc-companyCode AS CHARACTER ):

    DEFINE VARIABLE lc-use AS CHARACTER NO-UNDO.

    IF pc-companyCode = "micar" THEN 
    DO:
      
        lc-use = "http://micar.com/resources/template/header_logo.gif".

        {&prince} 
        '<img src="' lc-use '" height=113px width=160px style="float: left; padding-right: 10px;">' skip. 
    END.
    ELSE
    DO:
      
        lc-use = "http://www.ouritdept.co.uk/files/main_logo.jpg".

        {&prince} 
        '<img src="' lc-use '" height=70px width=160px style="float: left; padding-right: 10px;">' skip. 
    END.

    RETURN TRUE.

END FUNCTION.


FUNCTION pxml-StyleSheet    RETURNS LOG ( pc-companyCode AS CHARACTER ):

    DEFINE BUFFER b-tt-pxml FOR tt-pxml.
    DEFINE VARIABLE lc-style  AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE li-loop   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-use    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-css    AS CHARACTER INITIAL "prince.css".
    DEFINE VARIABLE cTextLine AS CHARACTER NO-UNDO.

    FIND FIRST tt-pxml NO-LOCK NO-ERROR.
    IF AVAILABLE tt-pxml
        AND tt-pxml.PageOrientation = "LANDSCAPE"
        THEN ASSIGN lc-css = "landscape" + lc-css.

    ASSIGN
        lc-style[1] = "prince/" + lc(pc-companyCode) + "/" + lc-css
        lc-style[2] = "prince/default/" + lc-css.

    DO li-loop = 1 TO 2:
        ASSIGN 
            lc-style[li-loop] = SEARCH((lc-style[li-loop])).
        IF lc-style[li-loop] = ? THEN NEXT.
        ASSIGN
            lc-use = lc-style[li-loop].
        LEAVE.
    END.

    IF lc-use <> ? THEN
    DO:
        FILE-INFO:FILE-NAME = lc-use.
        ASSIGN 
            lc-use = FILE-INFO:FULL-PATHNAME.
        {&prince} 
        '<style type="text/css"> ' skip.
        INPUT from value( lc-use ) no-echo. /* read in the stylesheet */
        REPEAT:
            IMPORT UNFORMATTED cTextLine.      /* read the whole text line... */
            {&prince} cTextLine skip.
        END.
        {&prince} 
        '</style> ' skip.
    END.

    RETURN TRUE.

END FUNCTION.


FUNCTION pxml-DocumentStyleSheet    RETURNS LOG ( pc-Document AS CHARACTER ,
    pc-companyCode AS CHARACTER ):

    DEFINE BUFFER b-tt-pxml FOR tt-pxml.
    DEFINE VARIABLE lc-style AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE li-loop  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-use   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-css   AS CHARACTER INITIAL "prince.css".

    ASSIGN 
        lc-css = LC(pc-document) + ".css".

    FIND FIRST tt-pxml NO-LOCK NO-ERROR.
    IF AVAILABLE tt-pxml
        AND tt-pxml.PageOrientation = "LANDSCAPE"
        THEN ASSIGN lc-css = "landscape" + lc-css.

    ASSIGN
        lc-style[1] = "prince/" + lc(pc-companyCode) + "/" + lc-css
        lc-style[2] = "prince/default/" + lc-css.

    DO li-loop = 1 TO 2:
        ASSIGN 
            lc-style[li-loop] = SEARCH((lc-style[li-loop])).
        IF lc-style[li-loop] = ? THEN NEXT.
        ASSIGN
            lc-use = lc-style[li-loop].
        LEAVE.
    END.

    IF lc-use <> ? THEN
    DO:
        FILE-INFO:FILE-NAME = lc-use.
        ASSIGN 
            lc-use = FILE-INFO:FULL-PATHNAME.
        {&prince} 
        '<link rel="stylesheet" href="' lc-use '" type="text/css">' skip.

    END.

    RETURN TRUE.

END FUNCTION.


FUNCTION pxml-OpenStream    RETURNS LOG ( pc-filename AS CHARACTER ):

    OUTPUT stream s-prince to value(pc-filename).
    
END FUNCTION.


FUNCTION pxml-CloseStream   RETURNS LOG ():

    OUTPUT stream s-prince close.

END FUNCTION.

&endif
