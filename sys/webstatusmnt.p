/***********************************************************************

    Program:        sys/webstatusmnt.p
    
    Purpose:        Status Maintenance           
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      CompanyCode  
    11/04/2006  phoski      DefaultCode & CustomerTrack & DisplayOrder   
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


DEFINE BUFFER b-valid FOR webstatus.
DEFINE BUFFER b-table FOR webstatus.


DEFINE VARIABLE lc-search          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters      AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url        AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-defaultcode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-customertrack   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-displayorder    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-statuscode      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-description     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-notecode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-completedstatus AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ignoreemail     AS CHARACTER NO-UNDO.




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

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE li-int  AS INTEGER NO-UNDO.
    
    IF lc-mode = "ADD":U THEN
    DO:
        IF lc-statuscode = ""
            OR lc-statuscode = ?
            THEN RUN htmlib-AddErrorMessage(
                'statuscode', 
                'You must enter the status code',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.statuscode = lc-statuscode
            AND b-valid.CompanyCode = lc-global-company
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'statuscode', 
                'This status code already exists',
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

    IF lc-notecode <> "" THEN
    DO:
        IF CAN-FIND(WebNote WHERE WebNote.NoteCode = lc-notecode NO-LOCK)
            = FALSE THEN
        DO:
            RUN htmlib-AddErrorMessage(
                'notecode', 
                'The note does not exist',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        END.
    END.

    ASSIGN 
        li-int = int(lc-displayorder) no-error.

    IF ERROR-STATUS:ERROR 
        THEN RUN htmlib-AddErrorMessage(
            'displayorder', 
            'The display order must be an integer',
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
                lc-submit-label = "Add Status".
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
                lc-submit-label = 'Delete Status'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Status'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Status'
        lc-link-url = appurl + '/sys/webstatus.p' + 
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
            set-user-field("nexturl",appurl + "/sys/webstatus.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-statuscode        = get-value("statuscode")
                lc-description       = get-value("description")
                lc-completedstatus   = get-value("completedstatus")
                lc-notecode          = get-value("notecode")
                lc-defaultcode       = get-value("defaultcode")
                lc-customertrack     = get-value("customertrack")
                lc-displayorder      = get-value("displayorder")
                lc-ignoreemail       = get-value("ignoreemail")
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
                        b-table.statuscode = CAPS(lc-statuscode)
                        b-table.CompanyCode = lc-global-company
                        lc-firstrow      = STRING(ROWID(b-table))
                        .
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    IF lc-defaultcode = "on"
                        THEN RUN com-ResetDefaultStatus ( lc-global-company ).

                    ASSIGN 
                        b-table.description     = lc-description
                        b-table.completedstatus = lc-completedstatus = 'on'
                        b-table.defaultcode     = lc-defaultcode = 'on'
                        b-table.CustomerTrack   = lc-customertrack = 'on'
                        b-table.IgnoreEmail     = lc-IgnoreEmail = 'on'
                        b-table.DisplayOrder    = int(lc-displayOrder)
                        b-table.notecode        = CAPS(lc-notecode)
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
            RUN run-web-object IN web-utilities-hdl ("sys/webstatus.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-statuscode = b-table.statuscode.

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN ASSIGN lc-description       = b-table.description
                lc-completedstatus   = IF b-table.completedstatus THEN 'on' ELSE ''
                lc-notecode          = b-table.notecode
                lc-displayorder      = STRING(b-table.displayorder)
                lc-defaultcode       = IF b-table.defaultcode THEN 'on' ELSE ''
                lc-customertrack     = IF b-table.customertrack THEN 'on' ELSE ''
                lc-IgnoreEmail       = IF b-table.IgnoreEmail THEN 'on' ELSE ''

                .
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/webstatusmnt.p' )
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("statuscode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Status Code")
        ELSE htmlib-SideLabel("Status Code"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("statuscode",20,lc-statuscode) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-statuscode),'left')
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
        (IF LOOKUP("completedstatus",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Completed?")
        ELSE htmlib-SideLabel("Completed?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("completedstatus", IF lc-completedstatus = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-completedstatus = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("defaultcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Default Status?")
        ELSE htmlib-SideLabel("Default Status?"))
    '</TD>'.
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("defaultcode", IF lc-defaultcode = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-defaultcode = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("customertrack",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Customer Track?")
        ELSE htmlib-SideLabel("Customer Track?"))
    '</TD>'.
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("customertrack", IF lc-customertrack = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-customertrack = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("ignoreemail",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Ignore Epulse Issues?")
        ELSE htmlib-SideLabel("Ignore Epulse Issues?"))
    '</TD>'.
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("ignoreemail", IF lc-ignoreemail = 'on'
        THEN TRUE ELSE FALSE) 
    '<div class="infobox" style="font-size: 10px">If ticked then no alerts will be sent to the customer.</div>'
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-ignoreemail = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("displayorder",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Display Order")
        ELSE htmlib-SideLabel("Display Order"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("displayorder",4,lc-displayorder) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-displayorder),'left')
           skip.
    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("notecode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Default Note")
        ELSE htmlib-SideLabel("Default Note"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("notecode",20,lc-notecode) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-notecode),'left')
           skip.
    IF CAN-DO("add,update",lc-mode) THEN
    DO:
        {&out} skip
               '<td>'
               htmlib-Lookup("Lookup Note",
                             "notecode",
                             "nullfield",
                             appurl + '/lookup/note.p')
               '</TD>'
               skip.
    END.
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
         
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

