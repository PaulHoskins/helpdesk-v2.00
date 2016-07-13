/***********************************************************************

    Program:        sys/webdashbmnt.p
    
    Purpose:        Dashboard Maintenance  	 
    
    Notes:
    
    
    When        Who         What
    24/05/2015  phoski      Initial
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


DEFINE BUFFER b-valid FOR dashb.
DEFINE BUFFER b-table FOR dashb.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-dashcode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-descr        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-isactive     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-panelCode    LIKE dashb.panelCode NO-UNDO.
DEFINE VARIABLE lc-panelParam   LIKE dashb.panelParam NO-UNDO.
DEFINE VARIABLE lc-pcode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pdesc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop         AS INT       NO-UNDO.
DEFINE VARIABLE lc-name         AS CHARACTER EXTENT 2 NO-UNDO.




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
{lib/dashlib.i}


 




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
        IF lc-dashcode = ""
            OR lc-dashcode = ?
            THEN RUN htmlib-AddErrorMessage(
                'dashcode', 
                'You must enter the dashboard code',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.dashcode = lc-dashcode
            AND b-valid.companycode = lc-global-company
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'dashcode', 
                'This dashboard already exists',
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
        lc-pdesc = "Empty".
        
    FOR EACH tt-dashlib NO-LOCK:
        ASSIGN
            lc-pcode = lc-pcode + "|" + tt-dashlib.panelCode
            lc-pdesc = lc-pdesc + "|" + tt-dashlib.descr.
            
    END.

    
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
                lc-submit-label = "Add Dashboard".
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
                lc-submit-label = 'Delete Dashboard'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Dashboard'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Dashboard'
        lc-link-url = appurl + '/sys/webdashb.p' + 
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
            set-user-field("nexturl",appurl + "/sys/webdashb.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-dashcode   = get-value("dashcode")
                lc-descr  = get-value("descr")
                lc-isactive  = get-value("isactive")
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
                        b-table.dashcode = CAPS(lc-dashcode)
                        b-table.companycode = lc-global-company
                        lc-firstrow      = STRING(ROWID(b-table))
                        .
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.descr     = lc-descr
                        b-table.isactive  = lc-isactive = 'on'
                        .
                    DO li-loop = 1 TO EXTENT(lc-panelCode):
                        ASSIGN
                            lc-name[1] = "panelcode" + string(li-loop)  
                            lc-name[2] = "panelparam" + string(li-loop). 
                        ASSIGN
                            b-table.panelCode[li-loop] = get-value(lc-name[1]) 
                            b-table.panelParam[li-loop] = get-value(lc-name[2]).       
                    END.    
                
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
            RUN run-web-object IN web-utilities-hdl ("sys/webdashb.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-dashcode = b-table.dashcode.
        
        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN 
        DO:
            ASSIGN 
                lc-descr   = b-table.descr
                lc-isactive   = IF b-table.isactive THEN 'on' ELSE ''
                .
            DO li-loop = 1 TO EXTENT(lc-panelCode):
                ASSIGN
                    lc-name[1] = "panelcode" + string(li-loop)  
                    lc-name[2] = "panelparam" + string(li-loop).       
                set-user-field(lc-name[1],b-table.panelCode[li-loop]).
                set-user-field(lc-name[2],b-table.panelParam[li-loop]).
                    
            END.
        END.
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/webdashbmnt.p' )
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
        ( IF LOOKUP("dashcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Dashboard Code")
        ELSE htmlib-SideLabel("Dashboard Code"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("dashcode",20,lc-dashcode) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-dashcode),'left')
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
        (IF LOOKUP("isactive",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Active?")
        ELSE htmlib-SideLabel("Active?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("isactive", IF lc-isactive = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-isactive = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("panel",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Panels")
        ELSE htmlib-SideLabel("Panels"))
    '</TD><td>' SKIP.

    {&out} skip
           htmlib-StartMntTable()
    htmlib-TableHeading(
        "#^right|Panel|Parameters"
         ) skip.
         
    DO li-loop = 1 TO EXTENT(lc-panelCode):
        ASSIGN
            lc-name[1] = "panelcode" + string(li-loop)  
            lc-name[2] = "panelparam" + string(li-loop).       
         
        {&out}
        '<tr>'
        htmlib-MntTableField(STRING(li-loop),'right').
            
        IF NOT CAN-DO("view,delete",lc-mode) THEN
        DO:    
            {&out}  
            htmlib-MntTableField(
                htmlib-Select(lc-name[1],lc-pcode,lc-pdesc,get-value(lc-name[1]))
                ,'left')
            htmlib-MntTableField( htmlib-InputField(lc-name[2],60,get-value(lc-name[2])) ,'left').
        END. 
        ELSE
        DO:
            FIND tt-dashlib WHERE tt-dashlib.PanelCode = get-value(lc-name[1]) NO-LOCK NO-ERROR.
              
            {&out}  
            htmlib-MntTableField(
                IF AVAILABLE tt-dashlib THEN tt-dashlib.descr ELSE "Empty"
                ,'left')
            htmlib-MntTableField( get-value(lc-name[2]) ,'left').
                    
        END. 
            
        {&out}   
        '</tr>' SKIP.
                                          
        
    END.     
    {&out} skip 
           htmlib-EndTable()
           skip.
           
        
    {&out} '</td></tr>' SKIP. /* Panel */    

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

