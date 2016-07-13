/***********************************************************************

    Program:        rep/custstat.p
    
    Purpose:        Customer Statements - Web Page
    
    Notes:
    
    
    When        Who         What
    26/07/2006  phoski      Initial
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
{lib/maillib.i}

DEFINE VARIABLE lc-error-field   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lodate        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-hidate        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pdf           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-view          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AccountNumber AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-label    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Enc-Key       AS CHARACTER NO-UNDO.




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


    RUN prince/custstat.p 
        ( lc-global-user,
        lc-global-company,
        lc-AccountNumber,
        DATE(lc-lodate),
        DATE(lc-hidate),
        OUTPUT lc-pdf ).
    
    lc-pdf = SEARCH(lc-pdf).

    IF lc-view = "on" THEN RETURN.

    IF lc-pdf <> "" 
        THEN mlib-SendAttEmail 
            ( lc-global-company,
            "",
            "HelpDesk Statement for " + customer.name,
            "Please find attached your statement covering the period "
            + string(DATE(lc-lodate),"99/99/9999") + " to " +
            string(DATE(lc-hidate),'99/99/9999'),
            webuser.email,
            "",
            "",
            lc-pdf ).
                


      
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


        
    DEFINE VARIABLE ld-date     AS DATE     NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-rowid    AS CHARACTER     NO-UNDO.

    ASSIGN
        ld-date = DATE(lc-lodate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-date = ?
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    ASSIGN
        ld-date = DATE(lc-hidate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-date = ?
        THEN RUN htmlib-AddErrorMessage(
            'hidate', 
            'The date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF pc-error-field <> "" THEN RETURN.

    IF DATE(lc-lodate) > date(lc-hidate) THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'hidate', 
            'The date range is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
        RETURN.
    END.
   

   

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

    ASSIGN
        lc-AccountNumber = get-value("accountnumber").

    FIND customer
        WHERE customer.companyCode = lc-global-company
        AND customer.AccountNumber = lc-AccountNumber NO-LOCK NO-ERROR.
    
    ASSIGN 
        lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(customer))).
                 
    IF request_method = "POST" THEN
    DO:
        
        ASSIGN
            lc-hidate = get-value("hidate")
            lc-lodate = get-value("lodate")
            lc-view   = get-value("view")
            .
        
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            RUN ip-ProcessReport.

            
            
            IF lc-view <> "on"
                THEN set-user-field("statementsent","yes").
            ELSE set-user-field("showpdf",lc-pdf).
                
            ASSIGN
                request_method = "GET".
            IF Webuser.UserClass = "CUSTOMER" THEN
            DO:
                RUN run-web-object IN web-utilities-hdl ("iss/issue.p").
                RETURN.
            END.
            set-user-field("source","menu").
            set-user-field("rowid",lc-enc-key).
            
            RUN run-web-object IN web-utilities-hdl ("cust/custview.p").
            RETURN.

            
        END.
    END.

    ASSIGN
        lc-link-label = "Cancel"
        lc-link-url = appurl + '/cust/custview.p' + 
                                  '?source=menu&rowid=' + url-encode(lc-enc-key,"Query")
                                   +
                                  '&time=' + string(TIME)
        .
    IF Webuser.UserClass = "CUSTOMER" THEN
        ASSIGN lc-link-url = appurl + '/iss/issue.p'.
    IF request_method <> "post"
        THEN ASSIGN lc-hidate = STRING(TODAY,"99/99/9999")
            lc-lodate = STRING(TODAY - day(TODAY) + 1,"99/99/9999")
               
            .

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle(
               
               if webuser.UserClass = "CUSTOMER"
               then "Produce Statement" else "Customer Statement - " + customer.Name) skip.


    
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.

   
    {&out} '<TR>'
    '<TD VALIGN="TOP" ALIGN="right">' 

            
        (IF LOOKUP("lodate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Statement From")
        ELSE htmlib-SideLabel("Statement From"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("lodate",10,lc-lodate) 
    htmlib-CalendarLink("lodate")
    '</td>' skip
        
            '<TD VALIGN="TOP" ALIGN="right">' 

            
            (if lookup("hidate",lc-error-field,'|') > 0 
            then htmlib-SideLabelError("To")
            else htmlib-SideLabel("To"))
            '</TD>'
            '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("hidate",10,lc-hidate) 
            htmlib-CalendarLink("hidate")
            '</td>' skip
            '<TD VALIGN="TOP" ALIGN="right">' 
               '&nbsp;'
            htmlib-SideLabel("View Statement?")
            '<br><span style="font-size: 10px;">Statement will be emailed<br>to you if not ticked</span>'
            '</td>'
            '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-CheckBox("view", if lc-view = 'on'
                                        then true else false) 
               
            '</TD>'
            
            '</tr>' skip.

    {&out} htmlib-EndTable() skip.

   
    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.
    
    {&out} '<center><br>' htmlib-SubmitButton("submitform","Create Statement") 
    '</center>' skip.
    
         
    {&out} htmlib-Hidden("accountnumber",lc-accountnumber) skip.

    {&out} htmlib-EndForm() skip
          htmlib-CalendarScript("hidate")
          htmlib-CalendarScript("lodate") skip.


   
    {&out} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

