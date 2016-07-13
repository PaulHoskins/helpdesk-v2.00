/***********************************************************************

    Program:        iss/actionprojectupdate.p
    
    Purpose:        Issue - Action Add/Update (Complex Project)
    
    Notes:
    
    
    When        Who         What
    06/05/2015  phoski      Initial
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE BUFFER b-table  FOR IssAction.
DEFINE BUFFER issue    FOR Issue.
DEFINE BUFFER b-user   FOR WebUser.
DEFINE BUFFER customer FOR Customer.
DEFINE BUFFER b-status FOR WebStatus.
DEFINE BUFFER esched   FOR eSched.

DEFINE VARIABLE lc-issue-rowid  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-error-field  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg    AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-list-assign  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assname AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-notes        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-assign       AS CHARACTER 
    EXTENT 5 NO-UNDO.
DEFINE VARIABLE lc-status       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-actiondate   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CustomerView AS CHARACTER NO-UNDO.


DEFINE VARIABLE lf-Audit        AS DECIMAL   NO-UNDO.
DEFINE VARIABLE lc-temp         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lr-temp         AS ROWID     NO-UNDO.
DEFINE VARIABLE ll-IsOpen       AS LOG       NO-UNDO.
DEFINE VARIABLE li-loop         AS INTEGER   NO-UNDO.


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
    htmlib-SideLabel("Issue Details")
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left" class="tablefield">'
           replace(Issue.LongDescription,"~n","<br>")
          '</TD></tr>' skip
           skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("notes",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Action")
        ELSE htmlib-SideLabel("Action"))
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-InputField("notes",40,lc-notes) 
          '</TD></tr>' skip
           skip.

    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("assign",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Other Engineers")
        ELSE htmlib-SideLabel("Other Engineers"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">' SKIP.
    DO li-loop = 1 TO EXTENT(lc-assign):
        {&out} 
        htmlib-Select("assign" + string(li-loop),lc-list-assign,lc-list-assname,
            lc-assign[li-loop]).
        IF li-loop <> EXTENT(lc-assign) 
            THEN {&out} '<br />' SKIP.
    END.    
    {&out} '</TD></TR>' skip. 
    

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
    ELSE
    IF ld-date < Issue.prj-Start 
    THEN RUN htmlib-AddErrorMessage(
            'actiondate', 
            'The date is before the project start of ' + string(Issue.prj-start,"99/99/9999"),
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
    
    IF lc-notes = ?
        OR lc-notes = ""
        THEN RUN htmlib-AddErrorMessage(
            'notes', 
            'The action must be entered',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).   
        
    ASSIGNCHK:
    DO li-loop = 1 TO EXTENT(lc-assign):
        IF lc-assign[li-loop] = "" THEN NEXT.
         
        IF lc-assign[li-loop] = b-table.assignto THEN
        DO:
            RUN htmlib-AddErrorMessage(
                'assign', 
                'The Senior Engineer can not be selected',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
            LEAVE.   
        END. 
        DO li-int = 1 TO   EXTENT(lc-assign):
            IF li-int = li-loop THEN NEXT.
            IF lc-assign[li-loop] = lc-assign[li-int] THEN
            DO:
                RUN htmlib-AddErrorMessage(
                    'assign', 
                    'You can only select an engineer once',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).
                LEAVE ASSIGNCHK.   
            END. 
        
            
        END.        
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
        
        ASSIGN 
            lc-notes        = get-value("notes")
            lc-status       = get-value("status")
            lc-actiondate   = get-value("actiondate")
            lc-customerview   = get-value("customerview")
            .
                
        DO li-loop = 1 TO EXTENT(lc-assign):
            ASSIGN
                lc-assign[li-loop] = get-value("assign" + string(li-loop)).   
        END.
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
                        
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
                
            IF lc-error-msg = "" THEN
            DO:
                /*
                ***
                *** Trash all schedules apart from the main user and recreate them if required
                ***
                */
                FOR EACH eSched EXCLUSIVE-LOCK
                    WHERE eSched.IssActionID = b-table.IssActionID:
                    IF eSched.AssignTo <> b-table.assignTo
                    THEN DELETE eSched.
                END.
                
                DO li-loop = 1 TO EXTENT(lc-assign):
                    IF lc-assign[li-loop] = "" THEN NEXT.
                        CREATE eSched.
                        ASSIGN 
                            eSched.eSchedID = NEXT-VALUE(esched).
                        BUFFER-COPY b-table EXCEPT b-table.assignto 
                            TO eSched
                            ASSIGN
                               eSched.AssignTo = lc-assign[li-loop].    
                END.
                
                
                ASSIGN 
                    b-table.ActDescription   = lc-notes
                    b-table.ActionStatus     = lc-Status
                    b-table.ActionDate       = DATE(lc-ActionDate)
                    b-table.customerview     = lc-customerview = "on"
                    b-table.StartDay         = ( Issue.prj-Start - b-table.ActionDate ) + 1.

                FOR EACH eSched EXCLUSIVE-LOCK
                    WHERE eSched.IssActionID = b-table.IssActionID:
                    
                    ASSIGN
                        eSched.ActionDate = b-table.ActionDate.
                END.
                
                  


            END.
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
  

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN 
        DO:
            ASSIGN 
                lc-notes = b-table.ActDescription
                lc-status       = b-table.ActionStatus
                lc-actiondate   = STRING(b-table.ActionDate,'99/99/9999')
                lc-customerview   = IF b-table.CustomerView 
                                        THEN "on" ELSE ""
                li-loop            = 0.
        
            /* Other Engineers */
            FOR EACH eSched NO-LOCK
                WHERE eSched.IssActionID = b-table.IssActionID:
                IF eSched.AssignTo = b-table.AssignTo THEN NEXT.
                li-loop = li-loop + 1.
                IF li-loop <= extent(lc-assign)
                    THEN lc-assign[li-loop] = eSched.AssignTo.
                     
            END.             
        END.  
    END.
    
    
    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip.

  
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

