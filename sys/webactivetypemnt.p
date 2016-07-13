/***********************************************************************

    Program:        sys/webactivetypemnt.p
    
    Purpose:        Activity Type Maintenance             
    
    Notes:
    
    
    When        Who         What
    12/04/2006  phoski      Initial
    01/07/2016  phoski      isAdminTime field

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


DEFINE BUFFER b-valid FOR WebActType.
DEFINE BUFFER b-table FOR WebActType.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.



DEFINE VARIABLE li-typeid       AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-actype       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-desc         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mintime      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-isAdminTime  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-notes        AS CHARACTER NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 6.19
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

    DEFINE VARIABLE li-int                  AS INTEGER NO-UNDO.
 
    IF lc-mode = "ADD":U THEN
    DO:
        IF lc-actype = ""
            OR lc-actype = ?
            THEN RUN htmlib-AddErrorMessage(
                'acttype', 
                'You must enter the code',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.companycode = lc-global-company
            AND b-valid.ActivityType = lc-actype
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'acttype', 
                'This code already exists',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    END.

    IF lc-desc = ""
        OR lc-desc = ?
        THEN RUN htmlib-AddErrorMessage(
            'desc', 
            'You must enter the activity type desc',
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
                lc-submit-label = "Add Activity Type".
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
                lc-submit-label = 'Delete Activity Type'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Activity Type'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Activity Type'
        lc-link-url = appurl + '/sys/webactivetype.p' + 
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
            set-user-field("nexturl",appurl + "/sys/webactivetype.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-actype      = get-value("acttype")
                lc-desc        = get-value("desc")
                lc-mintime     = get-value("mintime")
                lc-isAdminTime   = get-value("isadmintime")
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
                    ASSIGN li-TypeID = 1.
                    FOR EACH WebActType WHERE WebActType.Companycode = lc-global-company BY WebActType.TypeID:
                        li-typeid = WebActType.TypeID + 1.
                      
                    END.
                    
                    CREATE b-table.
                    ASSIGN 
                        b-table.Companycode     = lc-global-company
                        b-table.TypeID          = li-typeid
                        b-table.ActivityType    = lc-actype
                        lc-firstrow             = STRING(ROWID(b-table))
                        .
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.Description     = lc-desc
                        b-table.mintime         = INTEGER(lc-mintime)
                        b-table.isAdminTime     = lc-isAdminTime = "on"
                        
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
            RUN run-web-object IN web-utilities-hdl ("sys/webactivetype.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            li-typeid = b-table.TypeID.

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN ASSIGN 
                lc-actype         = b-table.activitytype
                lc-desc           = b-table.Description
                lc-mintime        = STRING(b-table.mintime)
                lc-isAdminTime    = IF b-table.isAdminTime THEN "on" ELSE ""
                .
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/webactivetypemnt.p' )
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
        {&out}  '<div activitytype="infobox">'
        'Warning:<br>'
        'Deletion of this activity type will also delete all other related details '
        '</div>' skip.
    END.

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("acttype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Activity Type Code")
        ELSE htmlib-SideLabel("Activity Type Code"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("acttype",10,lc-actype) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-actype),'left')
           skip.


    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("desc",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("desc",40,lc-desc) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-desc),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("mintime",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Minimum Time (Minutes)")
        ELSE htmlib-SideLabel("Minimum Time (Minutes)"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("mintime",3,lc-mintime)
              
    '</TD>' skip.
    else
    {&out} htmlib-TableField(html-encode(lc-mintime),'left')
           skip.
    {&out} '</TR>' skip.

/*
{&out} '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("Show Full Survey Results")
    '</td>'
    '<td valign="top" align="left">'
    htmlib-checkBox("showall",get-value("showall") = "on")
    '</td></tr>' skip.
    */

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("isadmintime",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Administration Time?")
        ELSE htmlib-SideLabel("Administration Time?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
     htmlib-checkBox("isadmintime",lc-isAdminTime = "on")
              
    '</TD>' skip.
    else
    {&out} htmlib-TableField(html-encode(IF lc-isadminTime = "on" THEN "Yes" ELSE "No"),'left')
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

