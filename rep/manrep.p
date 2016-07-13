/***********************************************************************

    Program:        rep/manrep.p
    
    Purpose:        Management Report - Web Page
    
    Notes:
    
    
    When        Who         What
    10/07/2006  phoski      Initial
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-date        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-days        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pdf         AS CHARACTER NO-UNDO.
{rep/manreptt.i}
{lib/maillib.i}




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






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
{lib/maillib.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-HeaderInclude-Calendar) = 0 &THEN

PROCEDURE ip-HeaderInclude-Calendar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ProcessReport) = 0 &THEN

PROCEDURE ip-ProcessReport :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    

    RUN rep/manrepbuild.p 
        ( lc-global-company,
        DATE(lc-date),
        int(lc-days),
        OUTPUT table tt-mrep ).

    RUN prince/manrep.p 
        ( lc-global-user,
        lc-global-company,
        DATE(lc-date),
        int(lc-days),
        INPUT table tt-mrep,
        OUTPUT lc-pdf ).
    
      
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    DEFINE VARIABLE li-int      AS INTEGER      NO-UNDO.
    DEFINE VARIABLE ld-date     AS DATE     NO-UNDO.


    ASSIGN
        ld-date = DATE(lc-date) no-error.
    IF ERROR-STATUS:ERROR 
        THEN RUN htmlib-AddErrorMessage(
            'date', 
            'The date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    

    ASSIGN 
        li-int = int(lc-days) no-error.
    IF ERROR-STATUS:ERROR 
        OR li-int < 1 THEN RUN htmlib-AddErrorMessage(
            'days', 
            'The number of days must be over zero',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE outputHeader :
    /*------------------------------------------------------------------------------
      Purpose:     Output the MIME header, and any "cookie" information needed 
                   by this procedure.  
      Parameters:  <none>
      emails:       In the event that this Web object is state-aware, this is
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
    output-content-type ("text/html":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
  Purpose:     Process the web request.
  Parameters:  <none>
  emails:       
------------------------------------------------------------------------------*/
    
    {lib/checkloggedin.i} 


    
    FIND webuser WHERE webuser.loginid = lc-user NO-LOCK NO-ERROR.

   

    IF request_method = "POST" THEN
    DO:
        
        ASSIGN
            lc-date = get-value("date")
            lc-days = get-value("days").
        
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            RUN ip-ProcessReport.
            
        END.
    END.

  
    IF request_method <> "post"
        THEN ASSIGN lc-date = STRING(TODAY,"99/99/9999")
            lc-days = "7".
        .

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle("Management Report") skip.


    
    {&out} htmlib-StartInputTable() skip.

   
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("date",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Report Date")
        ELSE htmlib-SideLabel("Report Date"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("date",10,lc-date) 
    htmlib-CalendarLink("date")
    '</td></tr>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("recordperpage",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Period (Days)")
        ELSE htmlib-SideLabel("Period (Days)"))
    '</TD><td>'
    htmlib-InputField("days",3,lc-days) 
    '</TD></TR>' skip.


    {&out} htmlib-EndTable() skip.


    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.
    
    {&out} '<center>' htmlib-SubmitButton("submitform","Report") 
    '</center>' skip.
    
         
    {&out} htmlib-Hidden("pdf",lc-pdf).

    {&out} htmlib-EndForm() skip
          htmlib-CalendarScript("date") skip.


    IF lc-pdf <> "" THEN
    DO:
        {&out} '<script>' skip
            "OpenNewWindow('"
                    appurl "/rep/viewpdf3.p?PDF=" 
                    url-encode(lc-pdf,"query") "')" skip
            '</script>' skip.
    END.
    {&out} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

