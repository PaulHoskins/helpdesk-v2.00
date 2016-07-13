/***********************************************************************

    Program:        iss/ajax/overview.p
    
    Purpose:        Issue Overview - Ajax
    
    Notes:
    
    
    When        Who         What
    22/04/2006  phoski      Initial
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE li-total AS INTEGER NO-UNDO.

DEFINE TEMP-TABLE tt NO-UNDO
    FIELD AType        AS CHARACTER
    FIELD ACode        AS CHARACTER
    FIELD ADescription AS CHARACTER
    FIELD ACount       AS INTEGER
    INDEX AType
    AType
    ACount DESCENDING
    ADescription.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fnCreate) = 0 &THEN

FUNCTION fnCreate RETURNS LOGICAL
    ( pc-AType AS CHARACTER,
    pc-ACode AS CHARACTER,
    pc-ADescription AS CHARACTER )  FORWARD.


&ENDIF


/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.15
         WIDTH              = 60.57.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{lib/htmlib.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-BuildAnalysis) = 0 &THEN

PROCEDURE ip-BuildAnalysis :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Issue        FOR Issue.
    DEFINE BUFFER WebStatus    FOR WebStatus.
    DEFINE BUFFER Customer     FOR Customer.
    
    FOR EACH Issue NO-LOCK
        WHERE Issue.CompanyCode = lc-global-company
        ,
        FIRST WebStatus NO-LOCK
        WHERE WebStatus.companyCode = Issue.CompanyCode
        AND WebStatus.StatusCode  = Issue.StatusCode
        AND WebStatus.Completed   = FALSE
        :

        ASSIGN 
            li-total = li-total + 1.


        DYNAMIC-FUNCTION("fnCreate",
            "STATUS",
            Issue.StatusCode,
            WebStatus.Description
            ).

        DYNAMIC-FUNCTION("fnCreate",
            "USER",
            Issue.AssignTo,
            IF Issue.AssignTo = "" THEN "Unassigned"
            ELSE DYNAMIC-FUNCTION("com-UserName",Issue.AssignTo)
            ).

        FIND customer OF Issue NO-LOCK NO-ERROR.

        DYNAMIC-FUNCTION("fnCreate",
            "CUSTOMER",
            Issue.AccountNumber,
            Customer.name
            ).

        FIND WebIssArea OF Issue NO-LOCK NO-ERROR.

        IF AVAILABLE webIssArea THEN
            DYNAMIC-FUNCTION("fnCreate",
                "AREA",
                Issue.AreaCode,
                WebIssArea.Description
                ).
        

         

    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Graph) = 0 &THEN

PROCEDURE ip-Graph :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-AType  AS CHARACTER     NO-UNDO.

    DEFINE VARIABLE li-base         AS INTEGER        NO-UNDO.
    DEFINE VARIABLE li-perc         AS INTEGER        NO-UNDO.
    DEFINE VARIABLE lc-link         AS CHARACTER       NO-UNDO.
    DEFINE VARIABLE lc-click        AS CHARACTER       NO-UNDO.
    
    /* {&out} '<div class="bargraphcontainer" style="margin-top:10px;"><div class="bargraphcaption"><strong>'.
    */

    {&out} '<div class="bargraphcontainer" style="margin-top:10px;"><div class="loglink" style="border-left: none;text-align: center; font-weight: 900;">'.
    CASE pc-AType:
        WHEN "USER" 
        THEN {&out} 'Open Issues By Assignment'.
        WHEN "CUSTOMER" 
        THEN {&out} 'Open Issues By Customer'.
        WHEN "STATUS"
        THEN {&out} 'Open Issues By Status'.
        WHEN "AREA"
        THEN {&out} 'Open Issues By Area'.
    END CASE.

    {&out} '</div><br>'.


    FIND FIRST tt WHERE tt.AType = pc-AType NO-LOCK.


    ASSIGN 
        li-base = tt.ACount.


    FOR EACH tt WHERE tt.AType = pc-AType NO-LOCK:

        {&out}
        '<div class="bartitle">' html-encode(tt.ADescription) '</div>'.

        ASSIGN
            li-perc = ROUND( tt.ACount / ( li-Base / 100 ),0).
        IF li-perc <= 0 THEN li-perc = 1.

        /* 'iss/issue.p?frommenu=yes&status=allopen' */

        lc-link = "".
        CASE pc-AType:
            WHEN "USER" 
            THEN 
                ASSIGN 
                    lc-link = appurl + '/iss/issue.p?iclass=All&frommenu=yes&status=allopen&assign=' + IF tt.Acode = ""
                    THEN "NotAssigned" ELSE tt.ACode.
            WHEN "CUSTOMER"
            THEN 
                ASSIGN 
                    lc-link = appurl + '/iss/issue.p?iclass=All&frommenu=yes&status=allopen&account=' + tt.ACode.
            WHEN "AREA"
            THEN 
                ASSIGN 
                    lc-link = appurl + '/iss/issue.p?iclass=All&frommenu=yes&status=allopen&area=' + tt.ACode.
            WHEN "STATUS"
            THEN 
                ASSIGN 
                    lc-link = appurl + '/iss/issue.p?iclass=All&frommenu=yes&status=' + tt.ACode.
        END CASE.

        IF lc-link <> ""
            THEN lc-click = 'onclick="javascript:self.location = ~'' + lc-link + '~';"'.
        {&out} 
        '<div alt="Click to view details" ' lc-click ' onmouseover="javascript:GrowOver(this)" onmouseout="javascript:GrowOut(this)" class="bargraph" style="width:' li-perc '%;">' tt.ACount '</div>' skip.

    END.


    {&out} '</div>'.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE outputHeader :
    /*------------------------------------------------------------------------------
      Purpose:     Output the MIME header, and any "cookie" information needed 
                   by this procedure.  
      Parameters:  <none>
      Notes:       In the event that this Web object is state-aware, this is
                   a good place to set the webState and webTimeout attributes.
    ------------------------------------------------------------------------------*/

    /* To make this a state-aware Web object, pass in the timeout period 
     * (in minutes) before running outputContentType.  If you supply a timeout 
     * period greater than 0, the Web object becomes state-aware and the 
     * following happens:
     *
     *   - 4GL variables webState and webTimeout are set
     *   - a cookie is created for the broker to id the client on the return trip
     *   - a cookie is created to id the correct procedure on the return trip
     *
     * If you supply a timeout period less than 1, the following happens:
     *
     *   - 4GL variables webState and webTimeout are set to an empty string
     *   - a cookie is killed for the broker to id the client on the return trip
     *   - a cookie is killed to id the correct procedure on the return trip
     *
     * Example: Timeout period of 5 minutes for this Web object.
     *
     *   setWebState (5.0).
     */
    
    /* 
     * Output additional cookie information here before running outputContentType.
     *      For more information about the Netscape Cookie Specification, see
     *      http://home.netscape.com/newsref/std/cookie_spec.html  
     *   
     *      Name         - name of the cookie
     *      Value        - value of the cookie
     *      Expires date - Date to expire (optional). See TODAY function.
     *      Expires time - Time to expire (optional). See TIME function.
     *      Path         - Override default URL path (optional)
     *      Domain       - Override default domain (optional)
     *      Secure       - "secure" or unknown (optional)
     * 
     *      The following example sets cust-num=23 and expires tomorrow at (about) the 
     *      same time but only for secure (https) connections.
     *      
     *      RUN SetCookie IN web-utilities-hdl 
     *        ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
     */ 
    output-content-type("text/plain~; charset=iso-8859-1":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
  Purpose:     Process the web request.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  
    {lib/checkloggedin.i}
    
    RUN outputHeader.
    
    RUN ip-BuildAnalysis.

    {&out} '<div id="overview" style="display: none;">' skip.

    IF li-total = 0 
        THEN {&out} '<p class="loglink">There are no open issues.</p>'.
    else
    do:
{&out} '<div class="loglink">'.
    
{&out} '<p style="text-align: center; font-weight: 900;">There are currently ' li-Total ' open issues (' STRING(TODAY,'99/99/9999') ' - ' 
STRING(TIME,'hh:mm am') ')</p>'.
{&out} '</div>'.
    
{&out} '<table border=0 width=98% align="center">'.
    
{&out} '<tr><td valign="top">'.
    
RUN ip-Graph ( 'USER' ).
    
{&out} '</td><td valign="top">'.
    
RUN ip-Graph ( 'CUSTOMER' ).
    
{&out} '</td></tr><tr><td valign="top">'.
    
RUN ip-Graph ( 'STATUS' ).
    
{&out} '</td><td valign="top">'.
    
RUN ip-Graph ( 'AREA' ).
    
{&out} '</td></tr>'.
    
{&out} '</table>'.
END.

{&out} '</div>'.

{&out}
'<script>' skip
        'myresponse = function() ~{' skip
        /* ' Effect.SlideDown(~'overview~', ~{duration:3~});' skip */
        ' Effect.Grow(~'overview~');' skip

        '~}' skip 
        'myresponse();' skip
        '</script>'.


END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fnCreate) = 0 &THEN

FUNCTION fnCreate RETURNS LOGICAL
    ( pc-AType AS CHARACTER,
    pc-ACode AS CHARACTER,
    pc-ADescription AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    FIND tt WHERE tt.AType = pc-AType
        AND tt.ACode = pc-ACode 
        EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE tt THEN
    DO:
        CREATE tt.
        ASSIGN 
            tt.AType = pc-AType
            tt.ACode = pc-ACode
            tt.ADescription = pc-ADescription.
    END.

    ASSIGN
        tt.ACount = tt.Acount + 1.
    RETURN TRUE.

END FUNCTION.


&ENDIF

