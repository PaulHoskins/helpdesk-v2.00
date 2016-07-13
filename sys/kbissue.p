/***********************************************************************

    Program:        sys/kbissue.p
    
    Purpose:        Select Issue For KB Addition
    
    Notes:
    
    
    When        Who         What
    20/08/2006  phoski      initial
   
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-print    AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-max-lines     AS INTEGER   INITIAL 12 NO-UNDO.
DEFINE VARIABLE lr-first-row     AS ROWID     NO-UNDO.
DEFINE VARIABLE lr-last-row      AS ROWID     NO-UNDO.
DEFINE VARIABLE li-count         AS INTEGER   NO-UNDO.
DEFINE VARIABLE ll-prev          AS LOG       NO-UNDO.
DEFINE VARIABLE ll-next          AS LOG       NO-UNDO.
DEFINE VARIABLE lc-search        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-smessage      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-otherp   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-char          AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-sel-account   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sel-status    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sel-assign    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sel-area      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-status        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-customer      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-issdate       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-raised        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-assigned      AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-open-status   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-closed-status AS CHARACTER NO-UNDO.

DEFINE BUFFER b-query  FOR issue.
DEFINE BUFFER b-search FOR issue.
DEFINE BUFFER b-cust   FOR customer.
DEFINE BUFFER b-status FOR WebStatus.
DEFINE BUFFER b-user   FOR WebUser.
DEFINE BUFFER b-Area   FOR WebIssArea.
  
DEFINE QUERY q FOR b-query SCROLLING.

DEFINE VARIABLE lc-area         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-acc     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-aname   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-acc-lo       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-acc-hi       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ass-lo       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ass-hi       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-area-lo      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-area-hi      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-srch-status  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-srch-desc    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-status  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-sname   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-assign  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assname AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-list-area    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-arname  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-info         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-object       AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-tag-end      AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-dummy-return AS CHARACTER INITIAL "MYXXX111PPP2222" NO-UNDO.
DEFINE VARIABLE ll-customer     AS LOG       NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-Format-Select-Account) = 0 &THEN

FUNCTION Format-Select-Account RETURNS CHARACTER
    ( pc-htm AS CHARACTER )  FORWARD.


&ENDIF


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

&IF DEFINED(EXCLUDE-ip-ExportJScript) = 0 &THEN

PROCEDURE ip-ExportJScript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out} skip
            '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' skip.

    {&out} skip 
          '<script language="JavaScript">' skip.

    {&out} skip
        'function ChangeAccount() ~{' skip
        '   SubmitThePage("AccountChange")' skip
        '~}' skip

        'function ChangeStatus() ~{' skip
        '   SubmitThePage("StatusChange")' skip
        '~}' skip.

    {&out} skip
           '</script>' skip.
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
  
    DEFINE BUFFER this-user        FOR WebUser.

    {lib/checkloggedin.i}


    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.

    ASSIGN
        ll-customer = this-user.UserClass = "CUSTOMER".

    IF ll-customer THEN
    DO:
        ASSIGN 
            lc-sel-account = this-user.AccountNumber
            lc-sel-assign  = htmlib-Null().
        set-user-field("account",this-user.AccountNumber).
    END.

    ASSIGN 
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation")
        lc-sel-account = get-value("account")
        lc-sel-status  = get-value("status")
        lc-sel-assign  = get-value("assign")
        lc-sel-area    = get-value("area").
    
    IF lc-sel-account = ""
        THEN ASSIGN lc-sel-account = htmlib-Null().

    IF lc-sel-status = ""
        THEN ASSIGN lc-sel-status = htmlib-Null().

    IF lc-sel-assign = ""
        THEN ASSIGN lc-sel-assign = htmlib-Null().

    IF lc-sel-area = ""
        THEN ASSIGN lc-sel-area = htmlib-Null().

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    
    
    ASSIGN 
        lc-char = htmlib-GetAttr('system','MNTNoLinesDown').
    
    ASSIGN 
        li-max-lines = int(lc-char) no-error.
    IF ERROR-STATUS:ERROR
        OR li-max-lines < 1
        OR li-max-lines = ? THEN li-max-lines = 12.

    RUN com-GetCustomer ( lc-global-company , lc-global-user, OUTPUT lc-list-acc, OUTPUT lc-list-aname ).

    RUN com-GetStatus ( lc-global-company , OUTPUT lc-list-status, OUTPUT lc-list-sname ).

    RUN com-StatusType ( lc-global-company , OUTPUT lc-open-status , OUTPUT lc-closed-status ).

    RUN com-GetAssign ( lc-global-company , OUTPUT lc-list-assign , OUTPUT lc-list-assname ).

    RUN com-GetArea ( lc-global-company , OUTPUT lc-list-area , OUTPUT lc-list-arname ).

    RUN outputHeader.
    
    {&out} htmlib-Header("Create KB Item") skip.

    RUN ip-ExportJScript.

    {&out} htmlib-JScript-Maintenance() skip.

    {&out} htmlib-StartForm("mainform","post", appurl + '/sys/kbissue.p' ) skip.

    {&out} htmlib-ProgramTitle("Create KB Item From Issue") 
    htmlib-hidden("submitsource","") skip.
    
    {&out} htmlib-TextLink("Back",
        appurl + '/sys/webkbitem.p' + 
        '?search='  + 
        '&firstrow=' + 
        '&lastrow='  + 
        '&navigation=refresh' +
        '&time=' + string(TIME)
        ) '<BR><BR>' skip.

    {&out} htmlib-BeginCriteria("Search Issues").

    {&out} '<table xxwidth="100%" align=center><tr>' skip.

    IF NOT ll-customer
        THEN {&out}
    '<td align=right valign=top>' htmlib-SideLabel("Customer") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("account",lc-list-acc,lc-list-aname,lc-sel-account)) '</td>'
        .
    {&out}
    '<td align=right valign=top>' htmlib-SideLabel("Status") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("status",lc-list-status,lc-list-sname,lc-sel-status)) '</td>' skip.

    IF NOT ll-customer
        THEN {&out} '<td align=right valign=top>' htmlib-SideLabel("Assigned") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("assign",lc-list-assign,lc-list-assname,lc-sel-assign)) '</td>' skip.

    {&out} 
    '<td align=right valign=top>' htmlib-SideLabel("Area") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("area",lc-list-area,lc-list-arname,lc-sel-area)) '</td>'
    '</tr></table>' skip.
    {&out} htmlib-EndCriteria().


    ASSIGN 
        lc-link-print = appurl + '/iss/issueprint.p?account=' 
                         + html-encode(lc-sel-account) 
                         + '&area=' + lc-sel-area 
                         + '&assign=' + lc-sel-assign 
                         + '&status=' + lc-sel-status.

    
    {&out}
    tbar-Begin(
        tbar-Find(appurl + "/sys/kbissue.p")
        )
    tbar-BeginOption()
    tbar-Link("view",?,"off",lc-link-otherp).

    {&out}
    tbar-EndOption()
    tbar-End().

    IF NOT ll-customer
        THEN {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="97%"') skip
           htmlib-TableHeading(
            "Issue Number^right|Date^right|Brief Description^left|Status^left|Area|Assigned To|Customer^left"
            ) skip.
    else {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="97%"') skip
           htmlib-TableHeading(
            "Issue Number^right|Date^right|Brief Description^left|Status^left|Area"
            ) skip.


    IF ll-customer THEN
    DO:
        ASSIGN 
            lc-sel-account = this-user.AccountNumber
            lc-sel-assign  = htmlib-Null().
    END.

    IF lc-sel-account = htmlib-Null()
        THEN ASSIGN lc-acc-lo = ""
            lc-acc-hi = "ZZZZZZZZZZZZZZZZZZZZZZZZ".
    ELSE ASSIGN lc-acc-lo = lc-sel-account
            lc-acc-hi = lc-sel-account.

    IF lc-sel-status = htmlib-Null() 
        THEN ASSIGN lc-srch-status = "*".
    ELSE
        IF lc-sel-status = "AllOpen" 
            THEN ASSIGN lc-srch-status = lc-open-status.
        ELSE 
            IF lc-sel-status = "AllClosed"
                THEN ASSIGN lc-srch-status = lc-closed-status.
            ELSE ASSIGN lc-srch-status = lc-sel-status.

    
    IF lc-sel-assign = htmlib-null() 
        THEN ASSIGN lc-ass-lo = ""
            lc-ass-hi = "ZZZZZZZZZZZZZZZZ".
    ELSE
        IF lc-sel-assign = "NotAssigned" 
            THEN ASSIGN lc-ass-lo = ""
                lc-ass-hi = "".
        ELSE ASSIGN lc-ass-lo = lc-sel-assign
                lc-ass-hi = lc-sel-assign.

    IF lc-sel-area = htmlib-null() 
        THEN ASSIGN lc-area-lo = ""
            lc-area-hi = "ZZZZZZZZZZZZZZZZ".
    ELSE
        IF lc-sel-area = "NotAssigned" 
            THEN ASSIGN lc-area-lo = ""
                lc-area-hi = "".
        ELSE ASSIGN lc-area-lo = lc-sel-area
                lc-area-hi = lc-sel-area.


    IF lc-search > "" THEN
        OPEN QUERY q FOR EACH b-query NO-LOCK
            WHERE b-query.CompanyCode = lc-global-company
            AND b-query.AccountNumber >= lc-acc-lo
            AND b-query.AccountNumber <= lc-acc-hi
            AND b-query.AssignTo >= lc-ass-lo
            AND b-query.AssignTo <= lc-ass-hi
            AND b-query.AreaCode >= lc-area-lo
            AND b-query.AreaCode <= lc-area-hi
            AND can-do(lc-srch-status,b-query.StatusCode)
            AND b-query.SearchField CONTAINS lc-search
            BY b-query.IssueNumber DESCENDING.
    ELSE
        OPEN QUERY q FOR EACH b-query NO-LOCK
            WHERE b-query.CompanyCode = lc-global-company
            AND b-query.AccountNumber >= lc-acc-lo
            AND b-query.AccountNumber <= lc-acc-hi
            AND b-query.AssignTo >= lc-ass-lo
            AND b-query.AssignTo <= lc-ass-hi
            AND b-query.AreaCode >= lc-area-lo
            AND b-query.AreaCode <= lc-area-hi
            AND can-do(lc-srch-status,b-query.StatusCode)
            BY b-query.IssueNumber DESCENDING.

    GET FIRST q NO-LOCK.

    IF lc-navigation = "nextpage" THEN
    DO:
        REPOSITION q TO ROWID TO-ROWID(lc-lastrow) NO-ERROR.
        IF ERROR-STATUS:ERROR = FALSE THEN
        DO:
            GET NEXT q NO-LOCK.
            GET NEXT q NO-LOCK.
            IF NOT AVAILABLE b-query THEN GET FIRST q.
        END.
    END.
    ELSE
        IF lc-navigation = "prevpage" THEN
        DO:
            REPOSITION q TO ROWID TO-ROWID(lc-firstrow) NO-ERROR.
            IF ERROR-STATUS:ERROR = FALSE THEN
            DO:
                GET NEXT q NO-LOCK.
                REPOSITION q BACKWARDS li-max-lines + 1.
                GET NEXT q NO-LOCK.
                IF NOT AVAILABLE b-query THEN GET FIRST q.
            END.
        END.
        ELSE
            IF lc-navigation = "refresh" THEN
            DO:
                REPOSITION q TO ROWID TO-ROWID(lc-firstrow) NO-ERROR.
                IF ERROR-STATUS:ERROR = FALSE THEN
                DO:
                    GET NEXT q NO-LOCK.
                    IF NOT AVAILABLE b-query THEN GET FIRST q.
                END.  
                ELSE GET FIRST q.
            END.

    ASSIGN 
        li-count = 0
        lr-first-row = ?
        lr-last-row  = ?.

    REPEAT WHILE AVAILABLE b-query:
   
        
        ASSIGN 
            lc-rowid = STRING(ROWID(b-query))
            lc-issdate = IF b-query.issuedate = ? THEN "" ELSE STRING(b-query.issuedate,'99/99/9999').
        
        ASSIGN 
            li-count = li-count + 1.
        IF lr-first-row = ?
            THEN ASSIGN lr-first-row = ROWID(b-query).
        ASSIGN 
            lr-last-row = ROWID(b-query).
        
        ASSIGN 
            lc-link-otherp = 'search=' + lc-search +
                                '&firstrow=' + string(lr-first-row) +
                                '&account=' + lc-sel-account + 
                                '&status=' + lc-sel-status + 
                                '&assign=' + lc-sel-assign + 
                                '&area=' + lc-sel-area.

        FIND b-cust OF b-query
            NO-LOCK NO-ERROR.
        ASSIGN 
            lc-customer = IF AVAILABLE b-cust THEN b-cust.name ELSE "".

        FIND b-status OF b-query NO-LOCK NO-ERROR.
        IF AVAILABLE b-status THEN
        DO:
            ASSIGN 
                lc-status = b-status.Description.
            IF b-status.CompletedStatus
                THEN lc-status = lc-status + ' (closed)'.
            ELSE lc-status = lc-status + ' (open)'.
        END.
        ELSE lc-status = "".

        FIND b-user WHERE b-user.LoginID = b-query.RaisedLogin NO-LOCK NO-ERROR.
        ASSIGN 
            lc-raised = IF AVAILABLE b-user THEN b-user.name ELSE "".

        FIND b-user WHERE b-user.LoginID = b-query.AssignTo NO-LOCK NO-ERROR.
        ASSIGN 
            lc-assigned = IF AVAILABLE b-user THEN b-user.name ELSE "".

        FIND b-area OF b-query NO-LOCK NO-ERROR.
        ASSIGN 
            lc-area = IF AVAILABLE b-area THEN b-area.description ELSE "".

        {&out}
            skip
            tbar-tr(rowid(b-query))
            skip
            htmlib-MntTableField(
                '<a class="tlink" style="border: none;" href="' + appurl + "/sys/webkbitemmnt.p?mode=add&copyissue=" +
                        string(rowid(b-query)) +
                        '" title="Copy to KB item">' +
                        string(b-query.IssueNumber) +
                '</a>'
                
                ,'right').


        {&out}
        htmlib-MntTableField(html-encode(lc-issdate),'right').

        IF b-query.LongDescription <> ""
            AND b-query.LongDescription <> b-query.briefdescription THEN
        DO:
        
            ASSIGN 
                lc-info = 
                REPLACE(htmlib-MntTableField(html-encode(b-query.briefdescription),'left'),'</td>','')
                lc-object = "hdobj" + string(b-query.issuenumber).
    
            ASSIGN 
                li-tag-end = INDEX(lc-info,">").

            {&out} substr(lc-info,1,li-tag-end).

            ASSIGN 
                substr(lc-info,1,li-tag-end) = "".
            
            {&out} 
            '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
            lc-object '~')">':U skip.
            {&out} lc-info.
    
            {&out} htmlib-ExpandBox(lc-object,b-query.LongDescription).

            {&out} '</td>' skip.
        END.
        ELSE {&out} htmlib-MntTableField(html-encode(b-query.briefdescription),"left").



        {&out}
        htmlib-MntTableField(html-encode(lc-status),'left')
        htmlib-MntTableField(html-encode(lc-area),'left').

        IF NOT ll-customer THEN
        DO:

            {&out}
            htmlib-MntTableField(html-encode(lc-assigned),'left')
                .
            IF lc-raised = ""
                THEN {&out} htmlib-MntTableField(html-encode(lc-customer),'left').
            else
            do:
        ASSIGN 
            lc-info = 
                    REPLACE(htmlib-MntTableField(html-encode(lc-customer),'left'),'</td>','')
            lc-object = "hdobjcust" + string(b-query.issuenumber).
        
        ASSIGN 
            li-tag-end = INDEX(lc-info,">").
    
        {&out} substr(lc-info,1,li-tag-end).
    
        ASSIGN 
            substr(lc-info,1,li-tag-end) = "".
    
        {&out} 
        '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
        lc-object '~')">':U skip.
        {&out} lc-info.
        
        {&out} htmlib-SimpleExpandBox(lc-object,lc-raised).
                
        {&out} '</td>' skip.
    END.

END.


{&out} skip
                tbar-BeginHidden(rowid(b-query))
                tbar-Link("view",rowid(b-query),
                          'javascript:HelpWindow('
                          + '~'' + appurl 
                          + '/iss/issueview.p?rowid=' + string(rowid(b-query))
                          + '~'' 
                          + ');'
                          ,lc-link-otherp).

{&out}
                
tbar-EndHidden()
            skip
           '</tr>' skip.

       

IF li-count = li-max-lines THEN LEAVE.

GET NEXT q NO-LOCK.
            
END.

IF li-count < li-max-lines THEN
DO:
    {&out} skip htmlib-BlankTableLines(li-max-lines - li-count) skip.
END.

{&out} skip 
           htmlib-EndTable()
           skip.

   
    {lib/issnavpanel.i "sys/kbissue.p"}

{&out} skip
           htmlib-Hidden("firstrow", string(lr-first-row)) skip
           htmlib-Hidden("lastrow", string(lr-last-row)) skip
           skip.

IF ll-customer THEN
DO:
    {&out} 
            skip
            '<div style="display: none;">'
                format-Select-Account(htmlib-Select("account",lc-sel-account,lc-sel-account,lc-sel-account)) 
                format-Select-Account(htmlib-Select("assign",htmlib-Null(),htmlib-Null(),htmlib-Null())) 
                
            '</div>'
            skip.
/*
assign lc-sel-account = this-user.AccountNumber
       lc-sel-assign  = htmlib-Null().
*/

END.
{&out} htmlib-EndForm().

    
{&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-Format-Select-Account) = 0 &THEN

FUNCTION Format-Select-Account RETURNS CHARACTER
    ( pc-htm AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<select',
        '<select onChange="ChangeAccount()"')
        . 


    RETURN lc-htm.


END FUNCTION.


&ENDIF

