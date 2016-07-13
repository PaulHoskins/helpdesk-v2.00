/***********************************************************************

    Program:        sys/iemailtmpmnt.p
    
    Purpose:        Email Template Maintenance     
    
    Notes:
    
    
    When        Who         What
    16/05/2014  phoski      Initial    
    20/06/2015  phoksi      Fix labels if undefined on merge list  
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


DEFINE BUFFER b-valid FOR iemailtmp.
DEFINE BUFFER b-table FOR iemailtmp.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-descr        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-tmpcode      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-tmptxt       AS CHARACTER NO-UNDO.




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
    DEFINE VARIABLE li-int      AS INTEGER      NO-UNDO.



    IF lc-mode = "ADD":U THEN
    DO:
       
        IF lc-tmpcode = ""
            OR lc-tmpcode = ? THEN
        DO:
            RUN htmlib-AddErrorMessage(
                'tmpcode', 
                'The code must be entered',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
            RETURN.
        END.
        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.tmpcode = lc-tmpcode
            AND b-valid.companycode = lc-global-company
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'tmpcode', 
                'This code already exists',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    END.

    IF lc-descr = ""
        OR lc-descr = ?
        THEN RUN htmlib-AddErrorMessage(
            'descr', 
            'You must enter the description',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ipShowMergeFields) = 0 &THEN

PROCEDURE ipShowMergeFields :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
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
     *      The following example sets cutmpcode=23 and expires tomorrow at (about) the 
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
    
    DEFINE VARIABLE iloop       AS INTEGER      NO-UNDO.
    DEFINE VARIABLE cPart       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cCode       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cDesc       AS CHARACTER     NO-UNDO.

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
                lc-submit-label = "Add Email Template".
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
                lc-submit-label = 'Delete Email Template'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Email Template'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Email Template'
        lc-link-url = appurl + '/sys/iemailtmp.p' + 
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
            set-user-field("nexturl",appurl + "/sys/iemailtmp.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-descr     = get-value("descr")
                lc-tmpcode   = get-value("tmpcode")
                lc-tmptxt    = get-value("tmptxt")
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
                        b-table.tmpcode = CAPS(lc-tmpcode)
                        b-table.companycode = lc-global-company
                        lc-firstrow      = STRING(ROWID(b-table))
                        .
                   
                END.
                
                ASSIGN 
                    b-table.descr     = lc-descr
                    b-table.tmptxt    = lc-tmptxt.
                  
                    
                
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
            RUN run-web-object IN web-utilities-hdl ("sys/iemailtmp.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-tmpcode = STRING(b-table.tmpcode)
            .

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN ASSIGN lc-descr   = b-table.descr
                lc-tmptxt  = b-table.tmptxt
                .
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/iemailtmpmnt.p' )
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
        ( IF LOOKUP("tmpcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Code")
        ELSE htmlib-SideLabel("Code"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("tmpcode",15,lc-tmpcode) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-tmpcode),'left')
           skip.


    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("descr",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("descr",40,lc-descr) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-descr),'left')
           skip.
    {&out} '</TR>' skip.
    

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("tmptxt",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Template Text")
        ELSE htmlib-SideLabel("Template Text"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-textArea("tmptxt",lc-tmptxt,40,120) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(REPLACE(lc-tmptxt,'~n','<br />'),'left')
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

