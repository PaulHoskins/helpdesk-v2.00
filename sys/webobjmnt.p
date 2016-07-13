/***********************************************************************

    Program:        sys/webobjmnt.p
    
    Purpose:        Web Object Maintenance       
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      Initial
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


DEFINE BUFFER b-valid FOR webobject.
DEFINE BUFFER b-table FOR webobject.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-objectid     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-description  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-objurl       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-objtarget    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-objtype      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-menulocation AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-iconfile     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-toporder     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-objTypeCode  AS CHARACTER
    INITIAL 'WS|EXT' NO-UNDO.
DEFINE VARIABLE lc-ObjTypeDesc  AS CHARACTER
    INITIAL 'Webspeed|External Web Site/Document' NO-UNDO.
DEFINE VARIABLE lc-MenuLocCode  AS CHARACTER
    INITIAL "B|L|T" NO-UNDO.
DEFINE VARIABLE lc-MenuLocDesc  AS CHARACTER
    INITIAL "Both Panels|Left Panel|Top Panel" NO-UNDO.




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
      objtargets:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    DEFINE VARIABLE li-int  AS INTEGER      NO-UNDO.

    IF lc-mode = "ADD":U THEN
    DO:
        IF lc-objectid = ""
            OR lc-objectid = ?
            THEN RUN htmlib-AddErrorMessage(
                'objectid', 
                'You must enter the object id',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.objectid = lc-objectid
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'objectid', 
                'This object already exists',
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

    IF lc-objurl = ""
        OR lc-objurl = ?
        THEN RUN htmlib-AddErrorMessage(
            'objurl', 
            'You must enter the objects URL',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    ASSIGN
        li-int = int(lc-toporder) no-error.

    IF ERROR-STATUS:ERROR
        OR li-int < 0 THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'toporder', 
            'You top menu order must be zero or a positive number',
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
      objtargets:       In the event that this Web object is state-aware, this is
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
  objtargets:       
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
                lc-submit-label = "Add Web Object".
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
                lc-submit-label = 'Delete Web Object'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Web Object'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Web Object'
        lc-link-url = appurl + '/sys/webobj.p' + 
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
            set-user-field("nexturl",appurl + "/sys/webobj.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-objectid  = get-value("objectid")
                lc-description    = get-value("description")
                lc-objurl = get-value("objurl")
                lc-objtarget      = get-value("objtarget")
                lc-objtype        = get-value("objtype")
                lc-MenuLocation   = get-value("menulocation")
                lc-iconfile       = get-value("iconfile")
                lc-toporder       = get-value("toporder").
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
                        b-table.objectid = lc-objectid
                        lc-firstrow      = STRING(ROWID(b-table)).
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.description  = lc-description
                        b-table.objurl       = lc-objurl
                        b-table.objtarget    = lc-objtarget
                        b-table.objtype      = lc-objtype
                        b-table.menulocation = lc-menulocation
                        b-table.iconfile     = lc-iconfile
                        b-table.toporder     = int(lc-toporder)
                           
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
            RUN run-web-object IN web-utilities-hdl ("sys/webobj.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-objectid = b-table.objectid.

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN ASSIGN lc-objurl = b-table.objurl
                lc-objtarget      = b-table.objtarget
                lc-description   = b-table.description
                lc-objtype       = b-table.objtype
                lc-menulocation  = b-table.menulocation
                lc-iconfile      = b-table.iconfile
                lc-toporder      = STRING(b-table.toporder)
                .                                    
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("objectid",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Object ID")
        ELSE htmlib-SideLabel("Object ID"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("objectid",40,lc-objectid) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-objectid),'left')
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
        (IF LOOKUP("objurl",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("URL")
        ELSE htmlib-SideLabel("URL"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("objurl",40,lc-objurl) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-objurl),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("objtype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Object Type")
        ELSE htmlib-SideLabel("Object Type"))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("objtype",lc-ObjTypeCode,lc-ObjTypeDesc,lc-objtype) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(
        entry(lookup(lc-objtype,lc-objTypeCode,'|'),lc-ObjTypeDesc,'|')
        ),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("objtarget",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Target")
        ELSE htmlib-SideLabel("Target"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("objtarget",40,lc-objtarget) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-objtarget),'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("menulocation",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Menu Location")
        ELSE htmlib-SideLabel("Menu Location"))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("menulocation",lc-MenuLocCode,lc-MenuLocDesc,lc-menulocation) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(
        entry(lookup(lc-menulocation,lc-MenuLocCode,'|'),lc-MenuLocDesc,'|')
        ),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("iconfile",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Top Menu Icon")
        ELSE htmlib-SideLabel("Top Menu Icon"))
    '</TD>' skip
    .

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("iconfile",40,lc-iconfile) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-iconfile),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("toporder",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Top Menu Order")
        ELSE htmlib-SideLabel("Top Menu Order"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("toporder",2,lc-toporder) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-toporder),'left')
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

