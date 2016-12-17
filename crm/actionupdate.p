/***********************************************************************

    Program:        crm/actionupdate.p
    
    Purpose:        CRM - Action Add/Update
    
    Notes:
    
    
    When        Who         What
    22/08/2016  phoski      Initial
    17/12/2016  phoski      call process-event for add.Action

***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE lc-op-rowid     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-error-field  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg    AS CHARACTER NO-UNDO.

DEFINE BUFFER b-table   FOR op_Action.
DEFINE BUFFER op_master FOR op_master.
DEFINE BUFFER b-user    FOR WebUser.
DEFINE BUFFER customer  FOR Customer.
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


DEFINE VARIABLE lf-Audit        AS DECIMAL   NO-UNDO.
DEFINE VARIABLE lc-temp         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lr-temp         AS ROWID     NO-UNDO.
DEFINE VARIABLE ll-IsOpen       AS LOG       NO-UNDO.

DEFINE VARIABLE lc-Data            AS CHARACTER EXTENT 10 NO-UNDO.
DEFINE TEMP-TABLE tt-old-table NO-UNDO LIKE op_master.


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

    {&out} htmlib-StartInputTable() SKIP.


    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("actiondate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Date")
        ELSE htmlib-SideLabel("Date"))
        '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("actiondate",10,lc-actiondate) 
            htmlib-CalendarLink("actiondate")
            '</TD>' SKIP.
    ELSE 
        {&out} htmlib-TableField(html-encode(lc-actiondate),'left')
            SKIP.
    {&out} 
        '</TR>' SKIP.

    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("actiontype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Action Type")
        ELSE htmlib-SideLabel("Action Type"))
        '</TD>' SKIP
        .

    IF lc-mode = "ADD" OR lc-mode = "UPDATE" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-Select("actioncode",lc-list-action,lc-list-aname,
            lc-actioncode)
            '</TD>'.
    ELSE
        {&out} htmlib-TableField(html-encode(lc-actioncode),'left')
            SKIP.
    {&out} 
        '</TR>' SKIP.

    
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("statnote",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Note")
        ELSE htmlib-SideLabel("Note"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-TextArea("notes",lc-notes,6,40)
        '</TD></tr>' SKIP
        SKIP.

    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("assign",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Assigned To")
        ELSE htmlib-SideLabel("Assigned To"))
        '</TD>' 
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-Select("assign",lc-list-assign,lc-list-assname,
        lc-assign)
        '</TD></TR>' SKIP. 


    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("status",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Action Status")
        ELSE htmlib-SideLabel("Action Status"))
        '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-Select("status",lc-global-action-code,lc-global-action-display,lc-status)
            '</TD>' SKIP.
    ELSE 
        {&out} htmlib-TableField(DYNAMIC-FUNCTION("com-DecodeLookup",lc-status,
            lc-global-action-code,
            lc-global-action-display
            ),'left')
            SKIP.
    {&out} 
        '</TR>' SKIP.



    {&out} htmlib-EndTable() SKIP.

    IF lc-error-msg <> "" THEN
    DO:
        {&out} 
            '<BR><BR><CENTER>' 
            htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' SKIP.
    END.
    
    IF lc-submit-label <> "" THEN
    DO:
        {&out} 
            '<center>' htmlib-SubmitButton("submitform",lc-submit-label) 
            '</center>' SKIP.
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


    DEFINE VARIABLE ld-date AS DATE    NO-UNDO.
    DEFINE VARIABLE li-int  AS INTEGER NO-UNDO.

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
        lc-op-rowid = get-value("oprowid")
        lc-mode     = get-value("mode")
        lc-rowid    = get-value("rowid").

    
    FIND op_master
        WHERE ROWID(op_master) = to-rowid(lc-op-rowid) NO-LOCK.
    EMPTY TEMP-TABLE tt-old-table.
    CREATE tt-old-table.
    BUFFER-COPY op_master TO tt-old-table.
                    
    
    FIND customer WHERE Customer.CompanyCode = op_master.CompanyCode
        AND Customer.AccountNumber = op_master.AccountNumber
        NO-LOCK NO-ERROR.

            
    ASSIGN
        ll-isOpen = TRUE.   
              


    RUN com-GetAction ( lc-global-company , OUTPUT lc-list-action, OUTPUT lc-list-aname ).
    RUN com-GetAssignIssue ( lc-global-company , OUTPUT lc-list-assign , OUTPUT lc-list-assname ).

    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title        = 'Add'
                lc-link-label   = "Cancel addition"
                lc-submit-label = "Add Action".
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title        = 'Update'
                lc-link-label   = 'Cancel update'
                lc-submit-label = 'Update Action'.
    END CASE.

    ASSIGN
        lc-title = lc-title + " Action - Opportunity  " + string(op_master.descr).


    IF request_method = "POST" THEN
    DO:
        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-actioncode = get-value("actioncode")
                lc-notes      = get-value("notes")
                lc-assign     = get-value("assign")
                lc-status     = get-value("status")
                lc-actiondate = get-value("actiondate")
                .                .
            
               
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
                        b-table.CompanyCode = lc-global-company
                        b-table.op_id       = op_master.op_id
                        b-table.CreateDt    = NOW
                        b-table.CreatedBy   = lc-global-user
                        
                        .

                    DO WHILE TRUE:
                        RUN lib/makeaudit.p (
                            "",
                            OUTPUT lf-audit
                            ).
                        IF CAN-FIND(FIRST op_action
                            WHERE op_Action.opActionID = int(lf-audit) NO-LOCK)
                            THEN NEXT.
                        ASSIGN
                            b-table.opActionID = lf-audit.
                        LEAVE.
                    END.
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.notes        = lc-notes
                        b-table.ActionStatus = lc-Status
                        b-table.ActionCode   = lc-ActionCode
                        b-table.ActionDate   = DATE(lc-ActionDate)
                        .

                    IF lc-mode = "ADD"
                        OR b-table.assignto <> lc-assign THEN 
                    DO:
                        IF lc-assign = ""
                            THEN ASSIGN b-table.AssignDt = ?.
                                
                        ELSE
                        DO:
                            ASSIGN 
                                b-table.AssignDt = NOW
                                b-table.AssignBy = lc-global-user.
                            
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
                        ASSIGN
                            lc-data = "".
                        ASSIGN lc-data[1] = STRING(lr-temp).    
                    
                        RUN crm/lib/process-event.p (
                            ROWID(op_master),
                            lc-global-user,
                            "ADD.ACTION",
                            lc-data,
                            INPUT TABLE tt-old-table
                            ).
                                
                        

                        
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
                '<html>' SKIP
                '<script language="javascript">' SKIP
                'var ParentWindow = opener' SKIP
                'ParentWindow.actionCreated()' SKIP
                
                '</script>' SKIP
                '<body><h1>ActionUpdated</h1></body></html>'.
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        FIND WebAction
            WHERE WebAction.CompanyCode = b-table.CompanyCode
            AND WebAction.ActionCode = b-table.ActionCode NO-LOCK NO-ERROR.
        IF AVAILABLE WebAction
            THEN ASSIGN 
                lc-actioncode = WebAction.ActionCode.

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN ASSIGN lc-notes      = b-table.notes
                lc-actionCode = b-table.ActionCode
                lc-assign     = b-table.assignto
                lc-status     = b-table.ActionStatus
                lc-actiondate = STRING(b-table.ActionDate,'99/99/9999')
                .
       
    END.
    
    IF request_method = "GET" AND lc-mode = "ADD" THEN
    DO:
        ASSIGN 
            lc-assign     = lc-global-user
            lc-actiondate = STRING(TODAY,'99/99/9999')
            .
    END.



    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) SKIP
        .

    {&out}
        htmlib-StartForm("mainform","post", selfurl)
        htmlib-ProgramTitle(lc-title) SKIP.


    RUN ip-Page.

    {&out} htmlib-Hidden("oprowid",lc-op-rowid) SKIP
        htmlib-Hidden("mode",lc-mode) SKIP
        htmlib-Hidden("rowid",lc-rowid) SKIP
        .

    {&out} htmlib-EndForm() SKIP.


    IF NOT CAN-DO("view,delete",lc-mode)  THEN
    DO:
        {&out}
            htmlib-CalendarScript("actiondate") SKIP.
    END.
    {&out}
        htmlib-Footer() SKIP.
    
  
END PROCEDURE.


&ENDIF

