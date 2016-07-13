/***********************************************************************

    Program:        sys/websubclassmnt.p
    
    Purpose:        Equipment Subclass Maintenance             
    
    Notes:
    
    
    When        Who         What
    12/04/2006  phoski      Initial

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


DEFINE BUFFER ivClass FOR ivClass.
DEFINE BUFFER b-valid FOR ivSub.
DEFINE BUFFER b-table FOR ivSub.


DEFINE VARIABLE lc-search          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters      AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url        AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-subcode         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-name            AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-ClassCode       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstback       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lf-Audit           AS DECIMAL   NO-UNDO.
DEFINE VARIABLE lc-style           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-displaypriority AS CHARACTER NO-UNDO.




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

    DEFINE VARIABLE li-int                  AS INTEGER NO-UNDO.

    IF lc-mode = "ADD":U THEN
    DO:
        IF lc-subcode = ""
            OR lc-subcode = ?
            THEN RUN htmlib-AddErrorMessage(
                'subcode', 
                'You must enter the code',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.companycode = lc-global-company
            AND b-valid.ClassCode = ivClass.ClassCode
            AND b-valid.subcode = lc-subcode
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'subcode', 
                'This code already exists',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    END.

    IF lc-name = ""
        OR lc-name = ?
        THEN RUN htmlib-AddErrorMessage(
            'name', 
            'You must enter the class name',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

   
    ASSIGN 
        li-int = int(lc-displaypriority) no-error.
    IF ERROR-STATUS:ERROR
        OR li-int < 0
        THEN RUN htmlib-AddErrorMessage(
            'displaypriority', 
            'The display priority must be zero or a positive number',
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
        lc-classcode = get-value("classcode").

    FIND ivClass WHERE ROWID(ivClass) = to-rowid(lc-classcode) NO-LOCK NO-ERROR.

    
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
    ASSIGN
        lc-firstback = get-value("firstback").

    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title = 'Add'
                lc-link-label = "Cancel addition"
                lc-submit-label = "Add Sub Classification".
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
                lc-submit-label = 'Delete Sub Classification'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Sub Classification'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Inventory Sub Classification - '
                + html-encode(ivClass.name)
        lc-link-url = appurl + '/sys/websubclass.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME) + 
                                  '&classcode=' + lc-classcode +
                                  '&firstback=' + lc-firstback 
        .

    IF CAN-DO("view,update,delete",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/sys/websubclass.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-subcode   = get-value("subcode")
                lc-name          = get-value("name")
                lc-style       = get-value("style")
                lc-displaypriority = get-value("displaypriority")

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
                        b-table.Companycode = lc-global-company
                        b-table.ClassCode   = ivClass.ClassCode
                        b-table.subcode     = CAPS(lc-subcode)
                        lc-firstrow         = STRING(ROWID(b-table))
                        .
                    DO WHILE TRUE:
                        RUN lib/makeaudit.p (
                            "",
                            OUTPUT lf-audit
                            ).
                        IF CAN-FIND(FIRST ivSub
                            WHERE ivSub.ivSubID = lf-audit NO-LOCK)
                            THEN NEXT.
                        ASSIGN
                            b-table.ivSubID = lf-audit.
                        LEAVE.
                    END.
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.name            = lc-name
                        b-table.style           = lc-style
                        b-table.displaypriority = int(lc-displaypriority)
                        
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
            ELSE
            DO: 
                FOR EACH ivField WHERE ivField.ivSubID = b-table.ivSubID EXCLUSIVE-LOCK:
                    FOR EACH custField WHERE custField.ivFieldID = ivField.ivFieldID EXCLUSIVE-LOCK:
                        DELETE custField.
                    END.
                    DELETE ivField.
                END.
                FOR EACH custIv WHERE custIv.ivSubID = b-table.ivSubID EXCLUSIVE-LOCK:
                    DELETE custIv.
                END.

                DELETE b-table.
            END.
        END.

        IF lc-error-field = "" THEN
        DO:
            RUN outputHeader.
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            set-user-field("classcode",lc-classcode).
            set-user-field("firstback",lc-firstback).
            RUN run-web-object IN web-utilities-hdl ("sys/websubclass.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-subcode = b-table.SubCode.

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN ASSIGN 
                lc-name             = b-table.name
                lc-style            = b-table.style
                lc-displaypriority  = STRING(b-table.displaypriority)
                .
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/websubclassmnt.p' )
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    IF lc-mode = "DELETE" THEN
    DO:
        {&out}  '<div class="infobox">'
        'Warning:<br>'
        'Deletion of this subclass will also delete all other related details, e.g customer inventory of this subclass'
        '</div>' skip.
    END.

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("subcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Sub Classificaton")
        ELSE htmlib-SideLabel("Sub Classification"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("subcode",10,lc-subcode) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-subcode),'left')
           skip.


    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("name",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Name")
        ELSE htmlib-SideLabel("Name"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("name",40,lc-name) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-name),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("displaypriority",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Display Priority")
        ELSE htmlib-SideLabel("Display Priority"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("displaypriority",3,lc-displaypriority) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-displaypriority),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("style",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Display CSS")
        ELSE htmlib-SideLabel("Display CSS"))
    '</TD>' skip.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("style",lc-style,10,60)
    '</TD>' 
            skip.
    else {&out} '<td valign="top">'
            replace(html-encode(lc-style),'~n','<br>')
        '</td>' skip.
    {&out} '</tr>' skip.

  
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
          
    {&out}
    htmlib-Hidden("classcode", lc-classcode) skip
           htmlib-Hidden("firstback",lc-firstback) skip.

    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

