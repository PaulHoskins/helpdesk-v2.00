/***********************************************************************

    Program:        cust/custticket.p
    
    Purpose:        Customer Maintenance - Ticket Creation       
    
    Notes:
    
    
    When        Who         What
    13/07/2006  phoski      CompanyCode  
    20/02/2016  phoski      Allow negative tickets amounts
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.


DEFINE BUFFER b-valid FOR customer.
DEFINE BUFFER b-table FOR customer.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-date         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-reference    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-amount       AS CHARACTER NO-UNDO.

{lib/ticket.i}




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

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      objtargets:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE ld-date     AS DATE     NO-UNDO.
    DEFINE VARIABLE lf-amount   AS DECIMAL      NO-UNDO.

    ASSIGN
        ld-date = DATE(lc-date) no-error.

    IF ERROR-STATUS:ERROR
        OR ld-date = ? 
        THEN RUN htmlib-AddErrorMessage(
            'date', 
            'The date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-reference = ""
        THEN RUN htmlib-AddErrorMessage(
            'reference', 
            'You must enter the ticket reference',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    ASSIGN
        lf-amount = dec(lc-amount) no-error.

    IF ERROR-STATUS:ERROR
        OR lf-amount = ?
        OR lf-amount = 0
        OR lf-amount <> truncate(lf-amount,0)
        THEN RUN htmlib-AddErrorMessage(
            'amount', 
            'The ticket hours are invalid',
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
      objtargets:       In the event that this Web object is state-aware, this is
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
  objtargets:       
------------------------------------------------------------------------------*/
    
    {lib/checkloggedin.i} 

    ASSIGN 
        lc-mode = "ADD"
        lc-rowid = get-value("rowid")
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = "refresh".

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.

    ASSIGN 
        lc-title = 'Add'
        lc-link-label = "Cancel ticket"
        lc-submit-label = "Add Ticket".
        

    ASSIGN 
        lc-title = lc-title + ' Ticket - ' + 
                                  html-encode(b-table.name)
        lc-link-url = appurl + '/cust/cust.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME)
        .

    


    IF request_method = "POST" THEN
    DO:


        ASSIGN
            lc-date      = get-value("date")
            lc-reference = get-value("reference")
            lc-amount    = get-value("amount").

            
        .
            
            
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            EMPTY TEMP-TABLE tt-ticket.
            CREATE tt-ticket.
            ASSIGN
                tt-ticket.AccountNumber     = b-table.AccountNumber
                tt-ticket.CompanyCode       = b-table.CompanyCode
                tt-ticket.CreateBy          = lc-user
                tt-ticket.CreateDate        = TODAY
                tt-ticket.CreateTime        = TIME
                /*
                ***
                *** All times are stored in seconds
                ***
                */
                tt-ticket.Amount            = ( dec(lc-amount) * 60 ) * 60
                tt-ticket.Reference         = lc-Reference
                tt-ticket.TxnDate           = DATE(lc-date)
                tt-ticket.TxnTime           = TIME
                tt-ticket.TxnType           = "TCK"
                .
            RUN tlib-PostTicket.

            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            ASSIGN 
                request_method = "GET".
            RUN run-web-object IN web-utilities-hdl ("cust/cust.p").
            RETURN.
           
        END.

    END.

    
    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
    
    IF request_method <> "post" THEN 
    DO:
        ASSIGN 
            lc-date      = STRING(TODAY,"99/99/9999").
    END.
    

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("date",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Ticket Date")
        ELSE htmlib-SideLabel("Ticket Date"))
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-InputField("date",10,lc-date) skip
           htmlib-CalendarLink("date")
           '</TD></TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("reference",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Reference")
        ELSE htmlib-SideLabel("Reference"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("reference",40,lc-reference) 
    '</TD>' skip
            '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("amount",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Hours")
        ELSE htmlib-SideLabel("Hours"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("amount",3,lc-amount) 
    '</TD>' skip
            '</TR>' skip.

    

    {&out} htmlib-EndTable() skip.


    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

   
    {&out}
    htmlib-Hidden("rowid",lc-rowid) skip
        htmlib-Hidden("search",lc-search)
        htmlib-Hidden("firstrow",lc-firstrow)
        htmlib-Hidden("lastrow",lc-lastrow)
        htmlib-Hidden("navigation",lc-navigation).

    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' skip.
    END.
         
    {&out} htmlib-EndForm() skip
           htmlib-CalendarScript("date") skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

