/***********************************************************************

    Program:        iss/actionupdate.p
    
    Purpose:        Issue - Action Add/Update
    
    Notes:
    
    
    When        Who         What
    09/04/2006  phoski      Initial
    24/01/2015  phoski      stop 'open' actions if the issue is closed
    09/05/2015  phoski      Complex Project
    20/10/2015  phoski      com-GetHelpDeskEmail for email sender
    12/03/2016  phoski      Customer view flag is on by default
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE lc-issue-rowid  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-error-field  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg    AS CHARACTER NO-UNDO.

DEFINE BUFFER b-table  FOR IssAction.
DEFINE BUFFER issue    FOR Issue.
DEFINE BUFFER b-user   FOR WebUser.
DEFINE BUFFER customer FOR Customer.
DEFINE BUFFER b-status  FOR WebStatus.


DEFINE VARIABLE lc-list-action  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-aname   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assign  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assname AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-actioncode   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-notes        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-assign       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-status       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-actiondate   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CustomerView AS CHARACTER NO-UNDO.


DEFINE VARIABLE lf-Audit        AS DECIMAL   NO-UNDO.
DEFINE VARIABLE lc-temp         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lr-temp         AS ROWID     NO-UNDO.
DEFINE VARIABLE ll-IsOpen       AS LOG       NO-UNDO.


{iss/issue.i}




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

&IF DEFINED(EXCLUDE-ip-Page) = 0 &THEN

PROCEDURE ip-Page :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("actiondate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Date")
        ELSE htmlib-SideLabel("Date"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("actiondate",10,lc-actiondate) 
    htmlib-CalendarLink("actiondate")
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-actiondate),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("actiontype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Action Type")
        ELSE htmlib-SideLabel("Action Type"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("actioncode",lc-list-action,lc-list-aname,
        lc-actioncode)
    '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-actioncode),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Issue Details")
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left" class="tablefield">'
           replace(Issue.LongDescription,"~n","<br>")
          '<br><input type="button" class="submitbutton" onclick="copyinfo();" value="Copy To Note">' skip
          '</TD></tr>' skip
           skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("statnote",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Note")
        ELSE htmlib-SideLabel("Note"))
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-TextArea("notes",lc-notes,6,40)
          '</TD></tr>' skip
           skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("assign",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Assigned To")
        ELSE htmlib-SideLabel("Assigned To"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("assign",lc-list-assign,lc-list-assname,
        lc-assign)
    '</TD></TR>' skip. 

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("customerview",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Customer View?")
        ELSE htmlib-SideLabel("Customer View?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("customerview", IF lc-customerview = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-customerview = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("status",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Action Status")
        ELSE htmlib-SideLabel("Action Status"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("status",lc-global-action-code,lc-global-action-display,lc-status)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(dynamic-function("com-DecodeLookup",lc-status,
                                     lc-global-action-code,
                                     lc-global-action-display
                                     ),'left')
           skip.
    {&out} '</TR>' skip.



    {&out} htmlib-EndTable() skip.

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.
    
    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' skip.
    END.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    DEFINE VARIABLE ld-date     AS DATE     NO-UNDO.
    DEFINE VARIABLE li-int      AS INTEGER      NO-UNDO.

    ASSIGN
        ld-date = DATE(lc-actiondate) no-error.

    IF ERROR-STATUS:ERROR
        OR ld-date = ? 
        THEN RUN htmlib-AddErrorMessage(
            'actiondate', 
            'The date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    IF NOT ll-isOpen AND lc-status = "OPEN" THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'status', 
            'The issue is closed, an open action is not allowed',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
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

    ASSIGN 
        lc-issue-rowid = get-value("issuerowid")
        lc-mode        = get-value("mode")
        lc-rowid       = get-value("rowid").

    
    FIND issue
        WHERE ROWID(issue) = to-rowid(lc-issue-rowid) NO-LOCK.
    FIND customer WHERE Customer.CompanyCode = Issue.CompanyCode
        AND Customer.AccountNumber = Issue.AccountNumber
        NO-LOCK NO-ERROR.

            
    IF DYNAMIC-FUNCTION("islib-StatusIsClosed",
        issue.CompanyCode,
        Issue.StatusCode) 
    THEN ll-IsOpen = FALSE.
    ELSE ll-isOpen = TRUE.
              


    RUN com-GetAction ( lc-global-company , OUTPUT lc-list-action, OUTPUT lc-list-aname ).
    RUN com-GetAssignIssue ( lc-global-company , OUTPUT lc-list-assign , OUTPUT lc-list-assname ).

    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title = 'Add'
                lc-link-label = "Cancel addition"
                lc-submit-label = "Add Action".
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Action'.
    END CASE.

    ASSIGN
        lc-title = lc-title + " Action - Issue " + string(issue.IssueNumber).


    IF request_method = "POST" THEN
    DO:
        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-actioncode   = get-value("actioncode")
                lc-notes        = get-value("notes")
                lc-assign       = get-value("assign")
                lc-status       = get-value("status")
                lc-actiondate   = get-value("actiondate")
                lc-customerview   = get-value("customerview")
                .
            
               
            RUN ip-Validate( OUTPUT lc-error-field,
                OUTPUT lc-error-msg ).

            IF lc-error-msg = "" THEN
            DO:
                
                IF lc-mode = 'update' THEN
                DO:
                    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                        EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                    IF LOCKED b-table 
                        THEN  RUN htmlib-AddErrorMessage(
                            'none', 
                            'This record is locked by another user',
                            INPUT-OUTPUT lc-error-field,
                            INPUT-OUTPUT lc-error-msg ).
                END.
                ELSE
                DO:
                    FIND WebAction
                        WHERE WebAction.CompanyCode = lc-global-company
                        AND WebAction.ActionCode  = lc-ActionCode
                        NO-LOCK NO-ERROR.
                    CREATE b-table.
                    ASSIGN 
                        b-table.actionID    = WebAction.ActionID
                        b-table.CompanyCode = lc-global-company
                        b-table.IssueNumber = issue.IssueNumber
                        b-table.CreateDate  = TODAY
                        b-table.CreateTime  = TIME
                        b-table.CreatedBy   = lc-global-user
                        b-table.customerview    = lc-customerview = "on"
                        .

                    DO WHILE TRUE:
                        RUN lib/makeaudit.p (
                            "",
                            OUTPUT lf-audit
                            ).
                        IF CAN-FIND(FIRST IssAction
                            WHERE IssAction.IssActionID = lf-audit NO-LOCK)
                            THEN NEXT.
                        ASSIGN
                            b-table.IssActionID = lf-audit.
                        LEAVE.
                    END.
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.notes            = lc-notes
                        b-table.ActionStatus     = lc-Status
                        b-table.ActionDate       = DATE(lc-ActionDate)
                        b-table.customerview    = lc-customerview = "on".

                    IF lc-mode = "ADD"
                        OR b-table.assignto <> lc-assign THEN 
                    DO:
                        IF lc-assign = ""
                            THEN ASSIGN b-table.AssignDate = ?
                                b-table.AssignTime = 0.
                        ELSE
                        DO:
                            ASSIGN 
                                b-table.AssignDate = TODAY
                                b-table.AssignTime = TIME
                                b-table.AssignBy   = lc-global-user.
                            FIND WebAction
                                WHERE WebAction.ActionID = b-table.ActionID
                                NO-LOCK NO-ERROR.
                            FIND b-user
                                WHERE b-user.LoginID = lc-assign
                                NO-LOCK NO-ERROR.
                            IF AVAILABLE webaction
                                AND webaction.emailassign
                                AND AVAILABLE b-user
                                AND b-user.email <> "" THEN
                            DO:
                                ASSIGN
                                    lc-temp = 
                                        "Customer: " + Customer.name + "~n" + 
                                        "Issue Number: " + string(Issue.IssueNumber) + '~n' + 
                                        "Issue Description: " + Issue.BriefDescription + '~n'.
                                IF Issue.LongDescription <> "" 
                                    THEN ASSIGN lc-temp = lc-temp + Issue.LongDescription + "~n".

                                ASSIGN 
                                    lc-temp = lc-temp + "~nAction Details~n" + 
                                                 webAction.description + "~n" + 
                                                 b-table.Notes + "~n~n" + 
                                                 "Assigned to you by " + 
                                                 com-UserName(lc-global-user) + 
                                                 " on " + string(b-table.AssignDate,'99/99/9999') + 
                                                 " " + string(b-table.AssignTime,"hh:mm am").
                                              
                                DYNAMIC-FUNCTION("mlib-SendEmail",
                                    lc-global-company,
                                    DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",issue.company,Issue.AccountNumber),
                                    "HelpDesk Action Assignment - Issue " + 
                                    string(Issue.IssueNumber),
                                    lc-temp,
                                    b-user.email).
                            END.

                        END.
                    END.
                    ASSIGN
                        b-table.AssignTo = lc-assign.

                    IF lc-mode = "ADD" THEN
                    DO:
                        ASSIGN 
                            lr-temp = ROWID(b-table).
                        RELEASE b-table.
                        FIND b-table WHERE ROWID(b-table) = lr-temp EXCLUSIVE-LOCK.

                        DYNAMIC-FUNCTION("islib-CreateAutoAction",
                            b-table.IssActionID).
                    END.


                END.
            END.
        END.
        ELSE
        DO:
            FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF LOCKED b-table 
                THEN RUN htmlib-AddErrorMessage(
                    'none', 
                    'This record is locked by another user',
                    INPUT-OUTPUT lc-error-field,
                    INPUT-OUTPUT lc-error-msg ).
            ELSE DELETE b-table.
        END.

        IF lc-error-field = "" THEN
        DO:
            
            RUN outputHeader.
            {&out} 
            '<html>' skip
                '<script language="javascript">' skip
                'var ParentWindow = opener' skip
                'ParentWindow.actionCreated()' skip
                
                '</script>' skip
                '<body><h1>ActionUpdated</h1></body></html>'.
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        FIND WebAction
            WHERE WebAction.ActionID = b-table.ActionID NO-LOCK NO-ERROR.
        IF AVAILABLE WebAction
        THEN ASSIGN 
                lc-actioncode = WebAction.description.

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN ASSIGN lc-notes        = b-table.notes
                lc-assign       = b-table.assignto
                lc-status       = b-table.ActionStatus
                lc-actiondate   = STRING(b-table.ActionDate,'99/99/9999')
                lc-customerview   = IF b-table.CustomerView 
                                        THEN "on" ELSE ""
                .
       
    END.
    
    IF request_method = "GET" AND lc-mode = "ADD" THEN
    DO:
        ASSIGN 
            lc-assign = lc-global-user
            lc-actiondate = STRING(TODAY,'99/99/9999')
            lc-customerview = "on".
    END.


    /** **/

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
    .

    {&out} 
    '<script>' skip
        'function copyinfo() ~{' skip
        'document.mainform.elements["notes"].value = document.mainform.elements["longdescription"].value' skip
        '~}' skip
        '</script>' skip.
    
    {&out}
    htmlib-StartForm("mainform","post", selfurl)
    htmlib-ProgramTitle(lc-title) skip.


    RUN ip-Page.

    {&out} htmlib-Hidden("issuerowid",lc-issue-rowid) skip
           htmlib-Hidden("mode",lc-mode) skip
           htmlib-Hidden("rowid",lc-rowid) skip
           htmlib-Hidden("longdescription",issue.LongDescription) skip.

    {&out} htmlib-EndForm() skip.


    IF NOT CAN-DO("view,delete",lc-mode)  THEN
    DO:
        {&out}
        htmlib-CalendarScript("actiondate") skip.
    END.
    {&out}
    htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

