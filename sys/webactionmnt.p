/***********************************************************************

    Program:        sys/webactionmnt.p
    
    Purpose:        Action Maintenance       
    
    Notes:
    
    
    When        Who         What
    30/04/2006  phoski      Initial
    25/06/2016  phoski      ActionClass
          
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


DEFINE BUFFER b-valid FOR webaction.
DEFINE BUFFER b-table FOR webaction.

DEFINE VARIABLE lc-search         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters     AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url       AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-actioncode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-autoactioncode AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-description    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Notes          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-EmailAssign    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lf-Audit          AS DECIMAL   NO-UNDO.
DEFINE VARIABLE lc-actionClass          AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-action    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-aname     AS CHARACTER NO-UNDO.






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


    IF lc-mode = "ADD":U THEN
    DO:
        IF lc-actioncode = ""
            OR lc-actioncode = ?
            THEN RUN htmlib-AddErrorMessage(
                'actioncode', 
                'You must enter the action code',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.actioncode = lc-actioncode
            AND b-valid.companycode = lc-global-company
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'actioncode', 
                'This action code already exists',
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
        lc-mode       = get-value("mode")
        lc-rowid      = get-value("rowid")
        lc-search     = get-value("search")
        lc-firstrow   = get-value("firstrow")
        lc-lastrow    = get-value("lastrow")
        lc-navigation = get-value("navigation").

    IF lc-mode = "" 
        THEN ASSIGN lc-mode       = get-field("savemode")
            lc-rowid      = get-field("saverowid")
            lc-search     = get-value("savesearch")
            lc-firstrow   = get-value("savefirstrow")
            lc-lastrow    = get-value("savelastrow")
            lc-navigation = get-value("savenavigation").

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title        = 'Add'
                lc-link-label   = "Cancel addition"
                lc-submit-label = "Add Action".
        WHEN 'view'
        THEN 
            ASSIGN 
                lc-title        = 'View'
                lc-link-label   = "Back"
                lc-submit-label = "".
        WHEN 'delete'
        THEN 
            ASSIGN 
                lc-title        = 'Delete'
                lc-link-label   = 'Cancel deletion'
                lc-submit-label = 'Delete Action'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title        = 'Update'
                lc-link-label   = 'Cancel update'
                lc-submit-label = 'Update Action'.
    END CASE.


    ASSIGN 
        lc-title    = lc-title + ' Action'
        lc-link-url = appurl + '/sys/webaction.p' + 
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
            set-user-field("nexturl",appurl + "/sys/webaction.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.

    RUN com-GetAutoAction ( lc-global-company , "", OUTPUT lc-list-action, OUTPUT lc-list-aname ).

    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-actioncode     = get-value("actioncode")
                lc-description    = get-value("description")
                lc-notes          = get-value("notes")
                lc-emailassign    = get-value("emailassign")
                lc-autoactioncode = get-value("autoactioncode")
                lc-actionClass          = get-value("actionclass")
                   
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
                        b-table.actioncode  = CAPS(lc-actioncode)
                        b-table.companycode = lc-global-company
                        lc-firstrow         = STRING(ROWID(b-table))
                        .
                    DO WHILE TRUE:
                        RUN lib/makeaudit.p (
                            "",
                            OUTPUT lf-audit
                            ).
                        IF CAN-FIND(FIRST WebAction
                            WHERE WebAction.ActionID = lf-audit NO-LOCK)
                            THEN NEXT.
                        ASSIGN
                            b-table.ActionID = lf-audit.
                        LEAVE.
                    END.
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.description    = lc-description
                        b-table.notes          = lc-notes
                        b-table.emailassign    = lc-emailassign = "on"
                        b-table.autoactioncode = lc-autoactioncode
                        b-table.actionClass    = lc-actionClass
                           
                        .
                   
                    RELEASE b-table.    
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
            RUN run-web-object IN web-utilities-hdl ("sys/webaction.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-actioncode = b-table.actioncode.


        RUN com-GetAutoAction ( lc-global-company , b-table.ActionCode, OUTPUT lc-list-action, OUTPUT lc-list-aname ).
        
        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN ASSIGN lc-description    = b-table.description
                lc-notes          = b-table.notes
                lc-emailassign    = IF b-table.EmailAssign
                                       THEN "on" ELSE ""
                lc-autoactioncode = b-table.Autoactioncode
                lc-actionClass          = b-table.actionClass
                .
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/webactionmnt.p' )
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
        ( IF LOOKUP("actioncode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Action Code")
        ELSE htmlib-SideLabel("Action Code"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("actioncode",20,lc-actioncode) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-actioncode),'left')
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
        (IF LOOKUP("qtype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Action Class")
        ELSE htmlib-SideLabel("Action Class"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
       htmlib-Select("actionclass",lc-global-webActionClass-code ,lc-global-webActionClass-Desc,lc-actionClass)
        '</TD>' skip.
    ELSE
    {&out} htmlib-TableField(html-encode(dynamic-function("com-DecodeLookup",lc-actionClass,
                                     lc-global-webActionClass-code,
                                     lc-global-webActionClass-Desc
                                     )),'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("notes",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Note")
        ELSE htmlib-SideLabel("Note"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("notes",lc-notes,5,60)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(replace(html-encode(lc-notes),"~n",'<br>'),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("emailassign",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Email User On Assignment?")
        ELSE htmlib-SideLabel("Email User On Assignment?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("emailassign", IF lc-emailassign = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-emailassign = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.


    

    {&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("autoactioncode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Automatic Action")
        ELSE htmlib-SideLabel("Automatic Action"))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("autoactioncode",lc-list-action,lc-list-aname,
        lc-autoactioncode)
    '</TD>' skip.
     else 
     {&out} htmlib-TableField(html-encode(
            dynamic-function("com-DecodeLookup",
                             lc-autoactioncode,
                             lc-list-action,
                             lc-list-aname)
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
         
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

