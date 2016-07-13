/***********************************************************************

    Program:        sys/webacsmnt.p
    
    Purpose:        Account Survey Maintenance 
    
    Notes:
    
    
    When        Who         What
    18/06/2016  phoski      Initial
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


DEFINE BUFFER b-valid FOR acs_head.
DEFINE BUFFER b-table FOR acs_head.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-field        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-code         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-description  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-em-subject   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-em-begin     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-em-end       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-wp-subject   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-wp-begin     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-wp-end       AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop         AS INTEGER   NO-UNDO.



{src/web2/wrap-cgi.i}
{lib/htmlib.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Details:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/
/* PH
    DEFINE BUFFER b-phase FOR ptp_phase.
    DEFINE BUFFER b-task  FOR ptp_task.
    DEFINE VARIABLE li-last  LIKE ptp_phase.PhaseID NO-UNDO.
    
    
    
    {&out}
           skip
           htmlib-StartMntTable()
            htmlib-TableHeading(
            "Phase^left|Action^left|Start Day^right|Estimated Duration^right|Ignore Weekend|Action Group^right|Responsibility|Billable"
            ) skip.
        
     
    FOR EACH b-phase NO-LOCK
        WHERE b-phase.acs_code = lc-code
        ,
        EACH b-task NO-LOCK 
            WHERE b-task.acs_code = b-phase.acs_code
              AND b-task.PhaseID = b-phase.PhaseID
        BY b-phase.DisplayOrder
        BY b-task.displayOrder
         :
    
        {&out}
            skip
            tbar-tr(rowid(b-phase))
            skip
            htmlib-MntTableField(html-encode(IF li-last = b-phase.phaseid THEN "" ELSE b-phase.descr),'left')
            htmlib-MntTableField(html-encode(b-task.descr),'left')
            htmlib-MntTableField(string(b-task.StartDay),'right')
              htmlib-MntTableField(com-TimeToString(b-task.EstDuration),'right') 
            htmlib-MntTableField(IF b-task.IgnoreWeekend THEN "Yes" ELSE "No",'left')
            htmlib-MntTableField(string(b-task.ActionGroup),'right') 
            htmlib-MntTableField(html-encode(
            com-DecodeLookup(b-task.Responsibility,lc-global-taskResp-code,lc-global-taskResp-desc)
            ),'left')
            htmlib-MntTableField(IF b-task.Billable THEN "Yes" ELSE "No",'left')
                    
            '</tr>' SKIP.
         ASSIGN
            li-last = b-phase.phaseid.
            
     END.         
    {&out} 
    skip 
           htmlib-EndTable()
           skip.
                
*/

END PROCEDURE.

PROCEDURE ip-Page:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("tablecode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Survey Code")
        ELSE htmlib-SideLabel("Survey Code"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("tablecode",20,lc-code) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-code),'left')
           skip.


    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("description",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("description",40,lc-description) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-description),'left')
           skip.
    {&out} '</TR>' skip.
    

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("em-subject",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Email Subject")
        ELSE htmlib-SideLabel("Email Subject"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("em-subject",60,lc-em-subject) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-em-subject),'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("em-begin",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Email Top")
        ELSE htmlib-SideLabel("Email Top"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("em-begin",lc-em-begin,10,60) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(replace(lc-em-begin,'~n','<br />'),'left')
           skip.
    {&out} '</TR>' skip.
    
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("em-end",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Email Bottom")
        ELSE htmlib-SideLabel("Email Bottom"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("em-end",lc-em-end,10,60) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(replace(lc-em-end,'~n','<br />'),'left')
           skip.
    {&out} '</TR>' skip.
    /** */
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("wp-subject",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Web Page Title")
        ELSE htmlib-SideLabel("Web Page Title"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("wp-subject",60,lc-wp-subject) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-wp-subject),'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("wp-begin",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Web Page Top")
        ELSE htmlib-SideLabel("Web Page Top"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("wp-begin",lc-wp-begin,10,60) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(replace(lc-wp-begin,'~n','<br />'),'left')
           skip.
    {&out} '</TR>' skip.
    
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("wp-end",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Web Page Bottom")
        ELSE htmlib-SideLabel("Web Page Bottom"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("wp-end",lc-wp-end,10,60) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(replace(lc-wp-end,'~n','<br />'),'left')
           skip.
    {&out} '</TR>' skip.
    IF lc-mode <> "DELETE" THEN
    DO:
        
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
               
        htmlib-SideLabel("Available Merge Fields")
        '</TD>'
        '<td>' SKIP.
    
        RUN ipShowMergeFields ('issue','Issue','Issue Merge Fields').
        RUN ipShowMergeFields ('customer','Customer','Customer Merge Fields').
        RUN ipShowMergeFields ('webstatus','IStatus','Issue Status Merge Fields').
        RUN ipShowMergeFields ('webIssArea','IArea','Issue Area Merge Fields').
        RUN ipShowMergeFields ('webUser','Assigned','Issue Assigned To Merge Fields').
        RUN ipShowMergeFields ('webUser','Raised','Issue Raised By Merge Fields').


        {&out} '</TD></TR>' skip.

    END.
    
    
    {&out} htmlib-EndTable() skip.
    

END PROCEDURE.

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    IF lc-mode = "ADD":U THEN
    DO:
        IF lc-code = ""
            OR lc-code = ?
            THEN RUN htmlib-AddErrorMessage(
                'tablecode', 
                'You must enter the survey code',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.acs_code = lc-code
            AND b-valid.companycode = lc-global-company
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'tablecode', 
                'This survey already exists',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    END.

    IF lc-description = ""
        OR lc-description = ?
        THEN RUN htmlib-AddErrorMessage(
            'description', 
            'You must enter the description',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE ipShowMergeFields:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-table        AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-buffer       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-label        AS CHARACTER NO-UNDO.


    {&out} skip
           htmlib-StartMntTable().

    {&out} '<tr><th colspan=2>' pc-label '</th></tr>' SKIP.
    {&out}
    htmlib-TableHeading(
        "Code|Description"
        ) skip.

    FOR EACH _file NO-LOCK WHERE _file._file-name = pc-table,
        EACH _field NO-LOCK OF _file
        WHERE _field._extent <= 1:

        {&out} '<tr>'
        htmlib-MntTableField('<%' + pc-buffer + '.' + _field-name  + '%>','left')
        htmlib-MntTableField(IF _label = ? THEN '' ELSE _label,'left')
        '</tr>' SKIP.
    END.
    {&out} skip 
           htmlib-EndTable()
           skip.




END PROCEDURE.

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
        lc-mode = get-value("mode")
        lc-rowid = get-value("rowid")
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation").

    IF lc-mode = "" 
        THEN ASSIGN lc-mode = get-field("savemode")
            lc-rowid = get-field("saverowid")
            lc-search = get-value("savesearch")
            lc-firstrow = get-value("savefirstrow")
            lc-lastrow  = get-value("savelastrow")
            lc-navigation = get-value("savenavigation").

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title = 'Add'
                lc-link-label = "Cancel addition"
                lc-submit-label = "Add Survey".
        WHEN 'view'
        THEN 
            ASSIGN 
                lc-title = 'View'
                lc-link-label = "Back"
                lc-submit-label = "".
        WHEN 'delete'
        THEN 
            ASSIGN 
                lc-title = 'Delete'
                lc-link-label = 'Cancel deletion'
                lc-submit-label = 'Delete Survey'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Survey'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Account Survey'
        lc-link-url = appurl + '/sys/webacs.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME)
        .

    
    IF CAN-DO("view,update,delete",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/sys/webacs.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-code   = get-value("tablecode")
                lc-description  = get-value("description")
                lc-em-subject   = get-value("em-subject")
                lc-em-begin     = get-value("em-begin")
                lc-em-end       = get-value("em-end")
                lc-wp-subject   = get-value("wp-subject")
                lc-wp-begin     = get-value("wp-begin")
                lc-wp-end       = get-value("wp-end")
                
                
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
                    CREATE b-table.
                    ASSIGN 
                        b-table.acs_code = CAPS(lc-code)
                        b-table.companycode = lc-global-company
                        lc-firstrow      = STRING(ROWID(b-table))
                        .
                    
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.Descr       = lc-description
                        b-table.em_subject  = lc-em-subject
                        b-table.em_begin    = lc-em-begin
                        b-table.em_end      = lc-em-end
                        b-table.wp_subject  = lc-wp-subject
                        b-table.wp_begin    = lc-wp-begin
                        b-table.wp_end      = lc-wp-end
                        .
                    
                END.
            END.
        END.
        ELSE
        DO:
            FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF LOCKED b-table 
                THEN  RUN htmlib-AddErrorMessage(
                    'none', 
                    'This record is locked by another user',
                    INPUT-OUTPUT lc-error-field,
                    INPUT-OUTPUT lc-error-msg ).
            ELSE DELETE b-table.
        END.

        IF lc-error-field = "" THEN
        DO:
            RUN outputHeader.
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            RUN run-web-object IN web-utilities-hdl ("sys/webacs.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-code = b-table.acs_code.

        IF CAN-DO("view,delete",lc-mode) OR request_method <> "post"
            THEN 
        DO:
            ASSIGN 
                lc-description  = b-table.descr
                lc-em-subject   = b-table.em_subject
                lc-em-begin     = b-table.em_begin
                lc-em-end       = b-table.em_end
                lc-wp-subject   = b-table.wp_subject
                lc-wp-begin     = b-table.wp_begin
                lc-wp-end       = b-table.wp_end
               .
           
        END.
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/webacsmnt.p' )
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    RUN ip-Page.
    
    IF lc-mode = "VIEW" THEN
    RUN ip-Details.
    

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<br/ ><center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' skip.
    END.
         
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

