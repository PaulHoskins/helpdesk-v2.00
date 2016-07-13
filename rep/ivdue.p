/***********************************************************************

    Program:        rep/ivdue.p
    
    Purpose:        Inventory Due - Web Page
    
    Notes:
    
    
    When        Who         What
    26/07/2006  phoski      Initial
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-lodate      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-hidate      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pdf         AS CHARACTER NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.14
         WIDTH              = 60.6.
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
    
    RUN prince/ivdue.p 
        ( lc-global-user,
        lc-global-company,
        DATE(lc-lodate),
        DATE(lc-hidate),
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


    
        
    DEFINE VARIABLE ld-lodate   AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-hidate   AS DATE     NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-rowid    AS CHARACTER     NO-UNDO.

    
    ASSIGN
        ld-lodate = DATE(lc-lodate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-lodate = ?
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The from date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    ASSIGN
        ld-hidate = DATE(lc-hidate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-hidate = ?
        THEN RUN htmlib-AddErrorMessage(
            'hidate', 
            'The to date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF ld-lodate > ld-hidate 
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The date range is invalid',
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
            lc-lodate = get-value("lodate")
            lc-hidate = get-value("hidate")
            
            .
        
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            RUN ip-ProcessReport.
            
        END.
    END.

  
    IF request_method <> "post"
        THEN ASSIGN lc-lodate = STRING(DYNAMIC-FUNCTION("com-MonthBegin",TODAY),"99/99/9999")
            lc-hidate = STRING(DYNAMIC-FUNCTION("com-MonthEnd",TODAY),"99/99/9999")
            .

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle("Customer Inventory Renewals") skip.


    
    {&out} htmlib-StartInputTable() skip.

   
    {&out} '<TR>' skip
            '<TD VALIGN="TOP" ALIGN="right">' 
            (if lookup("lodate",lc-error-field,'|') > 0 
            then htmlib-SideLabelError("From Date")
            else htmlib-SideLabel("From Date"))
            '</TD>'
            '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("lodate",10,lc-lodate) 
            htmlib-CalendarLink("lodate")
            '</td>' skip
            '<td>&nbsp;</td>'
            '<TD VALIGN="TOP" ALIGN="right">' 
            (if lookup("hidate",lc-error-field,'|') > 0 
            then htmlib-SideLabelError("To Date")
            else htmlib-SideLabel("To Date"))
            '</TD>'
            '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("hidate",10,lc-hidate) 
            htmlib-CalendarLink("hidate")
            '</td>' skip
            
            
            '</tr>' skip.

    {&out} htmlib-EndTable() skip.

    
    IF request_method = "post" AND lc-error-msg = "" THEN
    DO:
        
    END.

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.
    
    {&out} '<center>' htmlib-SubmitButton("submitform","Report") 
    '</center>' skip.
    
    {&out} htmlib-EndForm() skip
          htmlib-CalendarScript("lodate") skip
          htmlib-CalendarScript("hidate") skip.


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

