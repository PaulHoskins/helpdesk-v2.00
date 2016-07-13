/***********************************************************************

    Program:        iss/moveissue.p
    
    Purpose:        Issue Maintenance - Move Customer
    
    Notes:
    
    
    When        Who         What
    07/04/2007  phoski      Initial
    
    09/08/2010  DJS         3667 - view only active co's & users
    02/07/2016  phoski      Ticket balance on account and issue removed

***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE BUFFER b-valid  FOR issue.
DEFINE BUFFER b-table  FOR issue.
DEFINE BUFFER b-cust   FOR Customer.
DEFINE BUFFER b-status FOR webstatus.
DEFINE BUFFER b-area   FOR webIssarea.


DEFINE VARIABLE lc-mode         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-area         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-account      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-status       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-assign       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-category     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-submitsource AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-otherp  AS CHARACTER NO-UNDO.




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
{iss/issue.i}
{lib/ticket.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-BackToIssue) = 0 &THEN

PROCEDURE ip-BackToIssue :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

    RUN outputHeader.
    {&out} htmlib-Header(lc-title) skip.
   
    ASSIGN 
        request_method = "get".

    ASSIGN 
        lc-link-url = '"' + 
                         appurl + '/iss/issue.p' + 
                        '?search=' + lc-search + 
                        '&firstrow=' + lc-firstrow + 
                        '&lastrow=' + lc-lastrow + 
                        '&navigation=refresh' +
                        '&time=' + string(TIME) + 
                        '&account=' + lc-account + 
                        '&status=' + lc-status +
                        '&assign=' + lc-assign + 
                        '&area=' + lc-area + 
                        '&category=' + lc-category +
                        '"'.
    
   

    {&out} '<script language="javascript">' skip.

           
    {&out} 'NewURL = ' lc-link-url  skip
           'self.location = NewURL' skip
            '</script>' skip.

    {&OUT} htmlib-Footer() skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-BuildPage) = 0 &THEN

PROCEDURE ip-BuildPage :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE BUFFER b-cust   FOR customer.
    DEFINE BUFFER b-user   FOR WebUser.
    DEFINE BUFFER b-cat    FOR WebIssCat.

    DEFINE VARIABLE lc-icustname AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-raised    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-assign    AS CHARACTER NO-UNDO.
    
    FIND b-cust OF b-table NO-LOCK NO-ERROR.
    FIND b-cat  OF b-table NO-LOCK NO-ERROR.
    
    IF AVAILABLE b-cust
        THEN ASSIGN lc-icustname = b-cust.AccountNumber + 
                               ' ' + b-cust.Name.
    ELSE ASSIGN lc-icustname = 'N/A'.

    ASSIGN
        lc-raised = com-UserName(b-table.RaisedLogin).

    
    ASSIGN
        lc-assign = com-UserName(b-table.AssignTo).

    {&out} htmlib-StartInputTable() skip.

    FIND b-area OF b-table NO-LOCK NO-ERROR.
    FIND b-status OF b-table NO-LOCK NO-ERROR.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Customer")
    '</TD>' skip
           htmlib-TableField(html-encode(lc-icustname),'left') skip
           '<TR><TD VALIGN="TOP" ALIGN="right">' 
           htmlib-SideLabel("Date")
           '</TD>' skip
           htmlib-TableField(if b-table.IssueDate = ? then "" else 
               string(b-table.IssueDate,'99/99/9999') + " " + 
               string(b-table.IssueTime,'hh:mm am'),'left') skip
           '<TR><TD VALIGN="TOP" ALIGN="right">' 
           htmlib-SideLabel("Raised By")
           '</TD>' skip
           htmlib-TableField(html-encode(lc-raised),'left') skip

    .

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Description")
    '</TD>'
    htmlib-TableField(b-table.briefdescription,"") 
    '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Notes")
    '</TD>'
    htmlib-TableField(REPLACE(b-table.longdescription,'~n','<BR>'),"") 
    '</TR>' skip.


    IF AVAILABLE b-area THEN
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Area")
    '</TD>'
    htmlib-TableField(b-area.description,"") 
    '</TR>' skip.
    
    IF AVAILABLE b-status THEN
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Status")
    '</TD>'
    htmlib-TableField(b-status.description,"") 
    '</TR>' skip.

    IF AVAILABLE b-cat THEN
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Category")
    '</TD>'
    htmlib-TableField(b-cat.description,"") 
    '</TR>' skip.

    
    IF lc-assign <> "" THEN
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Assigned To")
    '</TD>'
    htmlib-TableField(lc-assign,"") 
    '</TR>' skip.

    
    IF b-table.PlannedCompletion <> ?  THEN
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Planned Completion")
    '</TD>'
    htmlib-TableField(STRING(b-table.PlannedCompletion,'99/99/9999'),"") 
    '</TR>' skip.

    

    {&out} '<tr><td valign=top align=right">'
    htmlib-SideLabel("Select Account")
    '</td>'
    '<td>' skip.
                
   
    {&out} '<select name="newaccount" class="inputfield">' skip.

    FOR EACH customer NO-LOCK
        WHERE customer.companyCode = b-table.Company
        AND   customer.isActive = TRUE                            /* 3667 */  
        BY customer.name:

        IF customer.AccountNumber = b-table.AccountNumber THEN NEXT.

        {&out}
        '<option value="' customer.AccountNumber '">'
        html-encode(customer.Name) '</option>' skip.
    END.

    {&out} '</select></td></tr>' skip.
    
    {&out} htmlib-EndTable() skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-MoveAccount) = 0 &THEN

PROCEDURE ip-MoveAccount :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pr-rowid        AS ROWID        NO-UNDO.
    DEFINE INPUT PARAMETER pc-account      AS CHARACTER         NO-UNDO.


    FIND issue
        WHERE ROWID(issue) = pr-rowid EXCLUSIVE-LOCK.

    FOR EACH issAlert OF Issue EXCLUSIVE-LOCK:
        DELETE issAlert.
    END.

    /*
    ***
    *** Reverse any tickets on this issue
    ***
    */
    IF issue.Ticket THEN
    DO:
        FIND customer
            WHERE customer.CompanyCode = issue.CompanyCode
            AND customer.AccountNumber = issue.AccountNumber EXCLUSIVE-LOCK.
        FOR EACH Ticket EXCLUSIVE-LOCK
            WHERE ticket.CompanyCode = issue.CompanyCode
            AND ticket.IssueNumber = issue.IssueNumber:

            DELETE ticket.
        END.
    
    END.

    RUN islib-CreateNote(
        lc-global-company,
        issue.IssueNumber,
        lc-global-user,
        "SYS.ACCOUNT",
        "Issue moved from customer " + 
        dynamic-function("com-CustomerName",Issue.CompanyCode,Issue.AccountNumber)
        ).
    ASSIGN
        Issue.AccountNumber = pc-account
        Issue.link-SLAID    = 0
        Issue.SLADate       = ?
        Issue.SLALevel      = ?
        Issue.SLAStatus     = "OFF"
        Issue.SLATime       = 0
        Issue.Ticket        = FALSE
        .

    IF com-IsCustomer(Issue.CompanyCode,Issue.CreateBy) 
        THEN issue.CreateBy = "".

    IF com-IsCustomer(Issue.CompanyCode,Issue.RaisedLoginId) 
        THEN issue.RaisedLoginId = "".

    FIND customer
        WHERE customer.CompanyCode = issue.CompanyCode
        AND customer.AccountNumber = issue.AccountNumber EXCLUSIVE-LOCK.

    IF customer.SupportTicket = "YES" THEN
    DO:
        ASSIGN
            Issue.Ticket = TRUE.
        EMPTY TEMP-TABLE tt-ticket.
        FOR EACH issActivity
            WHERE issActivity.CompanyCode = Issue.CompanyCode
            AND issActivity.IssueNumber = Issue.IssueNumber NO-LOCK:
            CREATE tt-ticket.
            ASSIGN
                tt-ticket.CompanyCode       =   issue.CompanyCode
                tt-ticket.AccountNumber     =   issue.AccountNumber
                tt-ticket.Amount            =   issActivity.Duration * -1
                tt-ticket.CreateBy          =   lc-global-user
                tt-ticket.CreateDate        =   TODAY
                tt-ticket.CreateTime        =   TIME
                tt-ticket.IssueNumber       =   Issue.IssueNumber
                tt-ticket.Reference         =   issActivity.description
                tt-ticket.TickID            =   ?
                tt-ticket.TxnDate           =   issActivity.ActDate
                tt-ticket.TxnTime           =   TIME
                tt-ticket.TxnType           =   "ACT"
                tt-ticket.IssActivityID     =   issActivity.IssActivityID.
        END.
        RELEASE issue.
        RUN tlib-PostTicket.
    END.

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
    output-content-type ("text/html":U).
  
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

    ASSIGN 
        lc-mode = get-value("mode")
        lc-rowid = get-value("rowid")
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation")
        lc-account = get-value("account")
        lc-status  = get-value("status")
        lc-assign  = get-value("assign")
        lc-area    = get-value("area")
        lc-category = get-value("category")
        lc-submitsource = get-value("submitsource").


    IF lc-mode = "" 
        THEN ASSIGN lc-mode = get-field("savemode")
            lc-rowid = get-field("saverowid")
            lc-search = get-value("savesearch")
            lc-firstrow = get-value("savefirstrow")
            lc-lastrow  = get-value("savelastrow")
            lc-navigation = get-value("savenavigation")
            lc-account = get-value("saveaccount")
            lc-status  = get-value("savestatus")
            lc-assign  = get-value("saveassign")
            lc-area    = get-value("savearea")
            lc-category = get-value("savecategory").

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                               "&firstrow=" + lc-firstrow + 
                               "&lastrow=" + lc-lastrow.


    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.

    ASSIGN 
        lc-title = "Move Issue - " + string(b-table.IssueNumber)
        lc-link-url = appurl + '/iss/issue.p' + 
                        '?search=' + lc-search + 
                        '&firstrow=' + lc-firstrow + 
                        '&lastrow=' + lc-lastrow + 
                        '&navigation=refresh' +
                        '&time=' + string(TIME) + 
                        '&account=' + lc-account + 
                        '&status=' + lc-status +
                        '&assign=' + lc-assign + 
                        '&area=' + lc-area + 
                        '&category=' + lc-category
                        
        lc-link-label = "Cancel".

    

    IF request_method = "POST" THEN
    DO:

        RUN ip-MoveAccount ( TO-ROWID(lc-rowid),
            get-value("newaccount")
            ).
        RUN ip-BackToIssue.
        RETURN.
    END.

    RUN outputHeader.

    {&out}
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' skip 
         '<HTML>' skip
         '<HEAD>' skip

         '<meta http-equiv="Cache-Control" content="No-Cache">' skip
         '<meta http-equiv="Pragma"        content="No-Cache">' skip
         '<meta http-equiv="Expires"       content="0">' skip
         '<TITLE>' lc-title '</TITLE>' skip
         DYNAMIC-FUNCTION('htmlib-StyleSheet':U) skip
         '<script language="JavaScript" src="/scripts/js/standard.js"></script>' skip
         DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.


    
    {&out}
    '</HEAD>' skip
         '<body class="normaltext" onUnload="ClosePage()">' skip
    .

    {&out}
    htmlib-StartForm("mainform","post", appurl + '/iss/moveissue.p' )
    htmlib-ProgramTitle(lc-title).


    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("saveaccount", lc-account) skip
           htmlib-Hidden ("savestatus", lc-status) skip
           htmlib-Hidden ("saveassign", lc-assign) skip
           htmlib-Hidden ("savearea", lc-area) skip
           htmlib-Hidden ("savecategory", lc-category ) skip.
    
    {&out} htmlib-Hidden("submitsource","null").

    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.


    RUN ip-BuildPage.

    {&out} '<br><br><center>' htmlib-SubmitButton("submitform","Update Account").

    {&OUT} htmlib-EndForm() skip.

    
    
    {&out} htmlib-Footer() skip.


END PROCEDURE.


&ENDIF

