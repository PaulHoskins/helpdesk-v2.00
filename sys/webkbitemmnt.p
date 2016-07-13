/***********************************************************************

    Program:        sys/webkbitemmnt.p
    
    Purpose:        KB Item Maintenance       
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      CompanyCode      
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


DEFINE BUFFER b-valid FOR knbitem.
DEFINE BUFFER b-table FOR knbitem.
DEFINE BUFFER knbText FOR knbText.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lf-knbid        LIKE b-table.knbid NO-UNDO.



DEFINE VARIABLE lc-knbcode      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ktitle       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-text         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-code         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-desc         AS CHARACTER NO-UNDO.




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

    DEFINE VARIABLE lc-code     AS CHARACTER NO-UNDO.

    /*if lc-mode = "ADD":U then
    do:
        if lc-knbcode = ""
        or lc-knbcode = ?
        then run htmlib-AddErrorMessage(
                    'knbcode', 
                    'You must enter the section code',
                    input-output pc-error-field,
                    input-output pc-error-msg ).
        

        if can-find(first b-valid
                    where b-valid.knbcode = lc-knbcode
                      and b-valid.companycode = lc-global-company
                    no-lock)
        then run htmlib-AddErrorMessage(
                    'knbcode', 
                    'This section already exists',
                    input-output pc-error-field,
                    input-output pc-error-msg ).

    end.
    */

    IF lc-ktitle = ""
        OR lc-ktitle = ?
        THEN RUN htmlib-AddErrorMessage(
            'ktitle', 
            'You must enter the title',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-text = ""
        OR lc-text = ?
        THEN RUN htmlib-AddErrorMessage(
            'text', 
            'You must enter the text',
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
                lc-submit-label = "Add Item".
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
                lc-submit-label = 'Delete Item'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Item'.
    END CASE.


    RUN com-GetKBSection(lc-global-company,
        OUTPUT lc-code,
        OUTPUT lc-desc).

    ASSIGN 
        lc-title = lc-title + ' KB Item'
        lc-link-url = appurl + '/sys/webkbitem.p' + 
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
            set-user-field("nexturl",appurl + "/sys/webkbitem.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-knbcode   = get-value("knbcode")
                lc-ktitle    = get-value("ktitle")
                lc-text      = get-value("text")
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
                    DO WHILE TRUE:
                        FIND LAST b-table NO-LOCK NO-ERROR.
                        ASSIGN 
                            lf-knbid = 
                            IF AVAILABLE b-table THEN b-table.knbid + 1
                            ELSE 1.
                        LEAVE.
                    END.

                    CREATE b-table.
                    ASSIGN 
                        b-table.knbcode      = CAPS(lc-knbcode)
                        b-table.companycode  = lc-global-company
                        b-table.knbid        = lf-knbid
                        lc-firstrow          = STRING(ROWID(b-table))
                        b-table.CreateBy     = lc-user
                        b-table.CreateDate   = TODAY
                        .
                    
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.ktitle  = lc-ktitle
                        b-table.knbcode = lc-knbcode
                        .
                    IF NOT NEW b-table
                        THEN ASSIGN b-table.AmendBy     = lc-user
                            b-table.AmendDate   = TODAY.

                    FOR EACH knbtext WHERE knbtext.knbid = 
                        b-table.knbID EXCLUSIVE-LOCK:
                        DELETE knbtext.
                    END.
                    CREATE knbtext.
                    ASSIGN 
                        knbtext.knbid = b-table.knbid
                        knbtext.dtype = "I"
                        knbtext.dData = lc-text
                        knbtext.Companycode = b-table.CompanyCode
                        knbtext.knbCode     = b-table.knbCode.
                    CREATE knbtext.
                    ASSIGN 
                        knbtext.knbid = b-table.knbid
                        knbtext.dtype = "C"
                        knbtext.dData = lc-ktitle + " " + lc-text
                        knbtext.Companycode = b-table.CompanyCode
                        knbtext.knbCode     = b-table.knbCode.
                    CREATE knbtext.
                    ASSIGN 
                        knbtext.knbid = b-table.knbid
                        knbtext.dtype = "T"
                        knbtext.dData = lc-ktitle
                        knbtext.Companycode = b-table.CompanyCode
                        knbtext.knbCode     = b-table.knbCode.

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
            RUN run-web-object IN web-utilities-hdl ("sys/webkbitem.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-knbcode = b-table.knbcode.

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post" THEN 
        DO:
            ASSIGN 
                lc-ktitle   = b-table.ktitle
                .
            FIND knbtext 
                WHERE knbtext.knbid = b-table.knbID
                AND knbtext.dType = "I"
                NO-LOCK NO-ERROR.
            IF AVAILABLE knbtext
                THEN ASSIGN lc-text = knbtext.dData.
        END.
       
    END.
    ELSE
        IF request_method = "GET" AND get-value("copyissue") <> "" THEN
        DO:
            FIND issue WHERE ROWID(issue) = to-rowid(get-value("copyissue")) 
                NO-LOCK NO-ERROR.
            IF AVAILABLE issue THEN
            DO:
                ASSIGN 
                    lc-ktitle = issue.BriefDescription
                    lc-text   = Issue.LongDescription.

                FOR EACH IssNote NO-LOCK OF Issue BY IssNote.CreateDate:
                    IF issNote.contents = "" 
                        OR issNote.NoteCode BEGINS "sys" THEN NEXT.

                    ASSIGN
                        lc-text = lc-text + "~n~n" + issNote.contents.

                END.
            END.
        END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip.

    {&out}
    htmlib-StartForm("mainform","post", appurl + '/sys/webkbitemmnt.p' )
    htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) skip
           htmlib-Hidden ("copyissue", get-value("copyissue") ) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("knbcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Section Code")
        ELSE htmlib-SideLabel("Section Code"))
    '</TD>' skip
    .

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("knbcode",lc-code,lc-desc,
        lc-knbcode)
    '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(
        dynamic-function("com-DecodeLookup",
                                 lc-knbcode,
                                 lc-code,
                                 lc-desc)
                                 ),'left')
           skip.


    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("ktitle",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Title")
        ELSE htmlib-SideLabel("Title"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("ktitle",80,lc-ktitle) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-ktitle),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("text",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Text")
        ELSE htmlib-SideLabel("Text"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("text",lc-text,20,80)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(replace(html-encode(lc-text),
                                     '~n','<br/>'),'left')
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

