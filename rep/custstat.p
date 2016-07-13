/***********************************************************************

    Program:        rep/custstat.p
    
    Purpose:        Customer Statements - Web Page
    
    Notes:
    
    
    When        Who         What
    26/07/2006  phoski      Initial
    19/11/2014  phoski      Phase 2 changes
    02/07/2016  phoski      Admin time 
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
DEFINE VARIABLE lc-test        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pdf         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-avail       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-admin       AS CHARACTER NO-UNDO.


{lib/maillib.i}

DEFINE TEMP-TABLE tt NO-UNDO LIKE Customer.




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

&IF DEFINED(EXCLUDE-ip-CustomerTable) = 0 &THEN

PROCEDURE ip-CustomerTable :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pl-ActiveOnly        AS LOG              NO-UNDO.
    DEFINE INPUT PARAMETER pl-Selected          AS LOG              NO-UNDO.
    
    
    DEFINE BUFFER b-query FOR customer.

    DEFINE VARIABLE li-count        AS INTEGER              NO-UNDO.
    DEFINE VARIABLE li-cols         AS INTEGER INITIAL 4    NO-UNDO.
    DEFINE VARIABLE lc-default      AS CHARACTER
        INITIAL "Statement?^left" NO-UNDO.
    DEFINE VARIABLE lc-header       AS CHARACTER             NO-UNDO.
   
    DEFINE VARIABLE lc-name         AS CHARACTER             NO-UNDO.
    DEFINE VARIABLE lc-value        AS CHARACTER             NO-UNDO.
    DEFINE VARIABLE lc-allfunc      AS CHARACTER             NO-UNDO.
    DEFINE VARIABLE lc-this         AS CHARACTER             NO-UNDO.
    
    
    DO li-count = 1 TO li-cols:
        IF li-count = 1
            THEN lc-header = lc-default.
        ELSE lc-header = lc-header + "|" + lc-default.
    END.
    
    ASSIGN
        lc-this = ""
        lc-allfunc = IF pl-ActiveOnly THEN "SelAct" ELSE "SelInAct".
    

    {&out} skip
           htmlib-StartFieldSet(if pl-ActiveOnly then "Select Active Customers"
                                ELSE 'Select Inactive Customers') SKIP
           '<br/><a class="tlink" href="#" onclick="' lc-allFunc '()">Select All</a>'  SKIP
           '<a class="tlink" href="#" onclick="' lc-allFunc 'un()">UnSelect All</a>'  skip
           htmlib-StartMntTable().

    {&out}
    htmlib-TableHeading(
        lc-header
        ) skip.


    ASSIGN 
        li-count = 0
        .

    FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode   = lc-Global-Company
        AND b-query.StatementEmail <> ""
        AND b-query.IsActive = pl-ActiveOnly    
        BY b-query.name
        :

        ASSIGN
            lc-name = "tog" + string(ROWID(b-query)).
/*
        IF request_method = "get" THEN set-user-field(lc-name,IF pl-Selected THEN "on" ELSE "").
*/
        IF lc-this = ""
        THEN lc-this = lc-name.
        ELSE lc-this = lc-this + "," + lc-name.
        
        ASSIGN
            lc-value = get-value(lc-name).
        
        IF lc-avail = ""
            THEN ASSIGN lc-avail = lc-name.
        ELSE ASSIGN lc-avail = lc-avail + "|" + lc-name.

        IF li-count = 0 THEN
        DO:
            {&out} '<tr>' skip.
        END.

        {&out}
        '<td>' 

        htmlib-CheckBox(lc-name, IF lc-value = 'on'
            THEN TRUE ELSE FALSE) 

        '&nbsp;'
        TRIM(substr(b-query.name,1,30))
        '</td>' skip.

        ASSIGN 
            li-count = li-count + 1.
        IF li-count = li-cols THEN
        DO:
            ASSIGN 
                li-count = 0.
            {&out} '</tr>' skip.
        END.

    END.
    IF li-count > 0 THEN {&out} '</tr>' skip.

    {&out} skip 
           htmlib-EndTable()
           htmlib-EndFieldSet() 
           skip.

    {&out} '<script>' SKIP
           'function ' lc-allFunc '() ~{' SKIP.
           
    IF lc-this <> "" THEN
    DO li-count = 1 TO NUM-ENTRIES(lc-this):
        lc-name = ENTRY(li-count,lc-this).
        
        {&out}
            'document.getElementById("' lc-name '").checked = true;' SKIP.
            
    END.
    
    {&out} '~}' skip
           'function ' lc-allFunc 'un() ~{' SKIP.
           
    IF lc-this <> "" THEN
    DO li-count = 1 TO NUM-ENTRIES(lc-this):
        lc-name = ENTRY(li-count,lc-this).
        
        {&out}
            'document.getElementById("' lc-name '").checked = false;' SKIP.
            
    END.
    
        
    {&out} '~}' skip
            '</script>' SKIP.      
END PROCEDURE.


&ENDIF

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

    FOR EACH tt NO-LOCK:

        RUN prince/custstat.p 
            ( lc-global-user,
            tt.CompanyCode,
            tt.AccountNumber,
            lc-admin = "on",
            DATE(lc-lodate),
            DATE(lc-hidate),
            OUTPUT lc-pdf ).
    
        lc-pdf = SEARCH(lc-pdf).

        IF lc-pdf <> "" 
            THEN mlib-SendAttEmail 
                ( lc-global-company,
                "",
                "HelpDesk Statement for " + tt.name,
                "Please find attached your statement covering the period "
                + '<b>' + string(DATE(lc-lodate),"99/99/9999") + "</b> to "
                + '<b>' +
                string(DATE(lc-hidate),'99/99/9999') + '</b>',
                ( IF lc-test = "on" THEN webuser.email ELSE tt.StatementEmail),
                "",
                "",
                lc-pdf ).
                


    END.
       

      
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


    DEFINE BUFFER Customer FOR Customer.
        
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
    EMPTY TEMP-TABLE tt.

    DO li-loop = 1 TO NUM-ENTRIES(lc-avail,"|"):

        IF get-value(ENTRY(li-loop,lc-avail,"|")) <> "on" THEN NEXT.

        ASSIGN
            lc-rowid = substr(ENTRY(li-loop,lc-avail,"|"),4).

        FIND customer
            WHERE ROWID(customer) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.
        IF NOT AVAILABLE customer THEN NEXT.

        FIND tt WHERE tt.CompanyCode = customer.CompanyCode
            AND tt.AccountNumber = customer.AccountNumber NO-LOCK NO-ERROR.
        IF AVAILABLE tt THEN
        DO:
            MESSAGE "duplicate = " lc-rowid li-loop lc-avail.
            NEXT.
        END.
        CREATE tt.
        BUFFER-COPY customer TO tt.
    END.

    FIND FIRST tt NO-LOCK NO-ERROR.

    IF NOT AVAILABLE tt THEN RUN htmlib-AddErrorMessage(
            'dummy', 
            'You must select one or more customers',
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

    EMPTY TEMP-TABLE tt.

    IF request_method = "POST" THEN
    DO:
        
        ASSIGN
            lc-hidate = get-value("hidate")
            lc-lodate = get-value("lodate")
            lc-test = get-value("test")
            lc-avail = get-value("avail")
            lc-admin = get-value("admin")
            .
        
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            RUN ip-ProcessReport.
        END.
    END.

  
    IF request_method <> "post"
        THEN ASSIGN lc-hidate = STRING(TODAY,"99/99/9999")
            lc-lodate = STRING(TODAY - day(TODAY) + 1,"99/99/9999")
            lc-test = "on"
            .

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle("Customer Statements") skip.


    
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
            '</td>' SKIP
            '</tr><tr><TD VALIGN="TOP" ALIGN="right">&nbsp;' 
            (if lookup("admin",lc-error-field,'|') > 0 
            then htmlib-SideLabelError("Include Administration Time?")
            else htmlib-SideLabel("Include Administration Time?"))
            '</TD>'
            '<TD VALIGN="TOP" ALIGN="left">'
                htmlib-CheckBox("admin", if lc-admin = 'on'
                                        then true else false) 
            '</TD>'
            
            '</tr><tr><TD VALIGN="TOP" ALIGN="right">&nbsp;' 
            (if lookup("test",lc-error-field,'|') > 0 
            then htmlib-SideLabelError("Test Statements To " + webuser.email + "?")
            else htmlib-SideLabel("Test Statements To " + webuser.email + "?"))
            '</TD>'
            '<TD VALIGN="TOP" ALIGN="left">'
                htmlib-CheckBox("test", if lc-test = 'on'
                                        then true else false) 
            '</TD>'
        
            '</tr>' skip.

    {&out} htmlib-EndTable() skip.

    ASSIGN 
        lc-avail = "".
    RUN ip-CustomerTable ( TRUE, FALSE ).
    RUN ip-CustomerTable ( FALSE, FALSE ).    
    

    IF request_method = "post" AND lc-error-msg = "" THEN
    DO:
        {&out} '<div class="infobox" style="font-size: 10px;">Statements have been emailed to ' 
            (IF lc-test = "on" THEN webuser.email ELSE " the customers" )
        '</div>'.
    END.

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.
    
    {&out} '<center>' htmlib-SubmitButton("submitform","Create Statements") 
    '</center>' skip.
    
         
    {&out} htmlib-Hidden("avail",lc-avail) skip.

    {&out} htmlib-EndForm() skip
          htmlib-CalendarScript("hidate")
          htmlib-CalendarScript("lodate") skip.


   
    {&out} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

