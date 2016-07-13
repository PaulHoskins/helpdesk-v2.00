/***********************************************************************

    Program:        sys/webissareamnt.p
    
    Purpose:        Issue Area Maintenance       
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      CompanyCode
    02/07/2006  phoski      Default Actions      
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


DEFINE BUFFER b-valid FOR webissarea.
DEFINE BUFFER b-table FOR webissarea.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-field        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-areacode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-description  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-groupid      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-actioncode   AS CHARACTER EXTENT 10 NO-UNDO.
DEFINE VARIABLE li-loop         AS INTEGER  NO-UNDO.
DEFINE VARIABLE lc-act-code     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-act-desc     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-grp-code     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-grp-desc     AS CHARACTER NO-UNDO.




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

&IF DEFINED(EXCLUDE-ip-ActionCode) = 0 &THEN

PROCEDURE ip-ActionCode :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pc-CompanyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-IssArea FOR WebAction.

    ASSIGN 
        pc-Codes = ""
        pc-Desc = "None".


    FOR EACH b-IssArea NO-LOCK 
        WHERE b-IssArea.CompanyCode = pc-CompanyCode
        BY b-IssArea.Description:
        ASSIGN 
            pc-Codes = pc-Codes + '|' + 
               b-IssArea.ActionCode
            pc-Desc = pc-Desc + '|' + 
               b-IssArea.Description.
    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-GroupCode) = 0 &THEN

PROCEDURE ip-GroupCode :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pc-CompanyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-buffer FOR WebIssAGrp.

    ASSIGN 
        pc-Codes = ""
        pc-Desc = "None".


    FOR EACH b-buffer NO-LOCK 
        WHERE b-buffer.CompanyCode = pc-CompanyCode:

        IF pc-Codes = ""
            THEN ASSIGN pc-Codes = b-buffer.GroupID
                pc-desc  = b-buffer.Description.
        ELSE
            ASSIGN pc-Codes = pc-Codes + '|' + 
               b-buffer.GroupID
                pc-Desc = pc-Desc + '|' + 
               b-buffer.Description.
    END.
END PROCEDURE.


&ENDIF

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
        IF lc-areacode = ""
            OR lc-areacode = ?
            THEN RUN htmlib-AddErrorMessage(
                'areacode', 
                'You must enter the area code',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.areacode = lc-areacode
            AND b-valid.companycode = lc-global-company
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'areacode', 
                'This area code already exists',
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
                lc-submit-label = "Add Area".
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
                lc-submit-label = 'Delete Area'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Area'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Area'
        lc-link-url = appurl + '/sys/webissarea.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME)
        .

    RUN ip-ActionCode ( lc-global-company,
        OUTPUT lc-act-code,
        OUTPUT lc-act-desc ).
    RUN ip-GroupCode ( lc-global-company,
        OUTPUT lc-grp-code,
        OUTPUT lc-grp-desc ).

    IF CAN-DO("view,update,delete",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/sys/webissarea.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-areacode   = get-value("areacode")
                lc-description  = get-value("description")
                lc-groupid      = get-value("groupid")
                .

            DO li-loop = 1 TO 10:
                ASSIGN 
                    lc-actioncode[li-loop] =
                        get-value("actioncode" + string(li-loop)).
            END.
  
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
                        b-table.areacode = CAPS(lc-areacode)
                        b-table.companycode = lc-global-company
                        lc-firstrow      = STRING(ROWID(b-table))
                        .
                    
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.description     = lc-description
                        b-table.groupid         = lc-groupid
                        .
                    DO li-loop = 1 TO 10:
                        ASSIGN
                            b-table.def-ActionCode[li-loop] = 
                            lc-actioncode[li-loop].
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
            RUN run-web-object IN web-utilities-hdl ("sys/webissarea.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-areacode = b-table.areacode.

        IF CAN-DO("view,delete",lc-mode) OR request_method <> "post"
            THEN 
        DO:
            ASSIGN 
                lc-description   = b-table.description
                lc-groupid       = b-table.groupid.
                    
            DO li-loop = 1 TO 10:
                ASSIGN 
                    lc-actioncode[li-loop] = b-table.def-ActionCode[li-loop].
            END.
        END.
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/webissareamnt.p' )
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
        ( IF LOOKUP("areacode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Area Code")
        ELSE htmlib-SideLabel("Area Code"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("areacode",20,lc-areacode) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-areacode),'left')
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
    

    {&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("groupid",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Area Group")
        ELSE htmlib-SideLabel("Area Group"))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("groupid",lc-grp-code,lc-grp-desc,
        lc-groupid)
    '</TD>' skip.
     else 
     
     do: 
FIND webissAgrp
    WHERE webissagrp.companycode = lc-global-company
    AND webissagrp.groupid = lc-groupid NO-LOCK NO-ERROR.

{&out} htmlib-TableField(html-encode(
    IF AVAILABLE webissagrp
    THEN webissagrp.description ELSE "")
    ,'left')

            skip.
END.
{&out} '</TR>' skip.

IF lc-act-code <> "" THEN
DO li-loop = 1 TO 10:
    IF lc-actioncode[li-loop] = ""
        AND can-do("view,delete",lc-mode) THEN NEXT.

    ASSIGN 
        lc-field = "actioncode" + string(li-loop).

    {&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP(lc-field,lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Default Action " + string(li-loop))
        ELSE htmlib-SideLabel("Default Action " + string(li-loop)))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select(lc-field,lc-act-code,lc-act-desc,
        lc-actioncode[li-loop])
    '</TD>' skip.
         else 
         {&out} htmlib-TableField(html-encode(
                dynamic-function("com-DecodeLookup",
                                 lc-actioncode[li-loop],
                                 lc-act-code,
                                 lc-act-desc)
                                 ),'left')

                skip.
    {&out} '</TR>' skip.
        



        

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

