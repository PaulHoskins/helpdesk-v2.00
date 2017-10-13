/***********************************************************************

    Program:        sys/webuserpref.p
    
    Purpose:        User Preferences
    
    Notes:
    
    
    When        Who         What
    28/04/2006  phoski      Initial
    04/08/2017  phoksi      Activity Default
    13/10/2017  phoski      send-2fa field
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg      AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title          AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-search         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters     AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-actcode   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-actdesc   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ActivityType   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-actid     AS CHARACTER NO-UNDO.  
DEFINE VARIABLE lc-list-activtype AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-list-activdesc AS CHARACTER NO-UNDO.  
DEFINE VARIABLE lc-list-activtime AS CHARACTER NO-UNDO.





DEFINE VARIABLE lc-loginid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-forename       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-surname        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-email          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-usertitle      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pagename       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-disabled       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accountnumber  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-jobtitle       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-telephone      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-password       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-userClass      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-customertrack  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-recordsperpage AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-usertitleCode  AS CHARACTER
    INITIAL '' NO-UNDO.
DEFINE VARIABLE lc-usertitleDesc  AS CHARACTER
    INITIAL '' NO-UNDO.
DEFINE VARIABLE lc-send-2fa        AS CHARACTER NO-UNDO.



DEFINE BUFFER b-valid FOR webuser.
DEFINE BUFFER b-table FOR webuser.

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
{lib/maillib.i}



 




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


    DEFINE VARIABLE li-int AS INTEGER NO-UNDO.

    

    ASSIGN 
        li-int = int(lc-recordsperpage) no-error.
    IF ERROR-STATUS:ERROR 
        OR li-int < 5 THEN RUN htmlib-AddErrorMessage(
            'recordsperpage', 
            'The number of records to display must be 5 or greater',
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


    
    FIND webuser WHERE webuser.loginid = lc-user NO-LOCK NO-ERROR.
    
    RUN com-GetAction ( lc-global-company , OUTPUT lc-list-actcode, OUTPUT lc-list-actdesc ).
       
    RUN com-GetActivityType ( lc-global-company , OUTPUT lc-list-actid, OUTPUT lc-list-activtype, OUTPUT lc-list-activdesc, OUTPUT lc-list-activtime ).
    

    ASSIGN 
        lc-mode  = "UPDATE"
        lc-rowid = STRING(ROWID(webuser))
        .

    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
        NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-table THEN
    DO:
        set-user-field("mode",lc-mode).
        set-user-field("title",lc-title).
        RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
        RETURN.
    END.


    IF request_method = "POST" THEN
    DO:
        
        ASSIGN 
            lc-customertrack  = get-value("customertrack")
            lc-recordsperpage = get-value("recordsperpage")
            lc-ActivityType   = get-value("activitytype")
            lc-send-2fa       = get-value("send-2fa")
            .
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
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
                ASSIGN 
                    b-table.customertrack    = lc-customertrack = 'on'
                    b-table.recordsperpage   = int(lc-recordsperpage)
                    b-table.def-activityType = lc-ActivityType
                    b-table.send-2fa         = lc-send-2fa.
                .
                
                set-user-field("prefsaved","yes").

            END.
        END.
    END.

  
    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
    
    IF request_method <> "post"
        THEN ASSIGN 
            lc-customertrack  = IF b-table.customertrack THEN 'on' ELSE ''
            lc-recordsperpage = STRING(b-table.recordsperpage)
            lc-ActivityType   = b-table.def-activityType
            lc-send-2fa       = b-table.send-2fa
            .

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) SKIP
        htmlib-StartForm("mainform","post", selfurl )
        htmlib-ProgramTitle("Your Preferences - " + WebUser.Name) SKIP.


    
    {&out} htmlib-StartInputTable() SKIP.

    IF get-value("prefsaved") = "yes" THEN
    DO:
        {&out} 
            '<tr><th colspan="2" style="text-align: center;">Your preferences have been saved.<br><br></th></tr>'.
    END.


    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("customertrack",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Track Your Issues?")
        ELSE htmlib-SideLabel("Track Your Issues?"))
        '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-CheckBox("customertrack", IF lc-customertrack = 'on'
            THEN TRUE ELSE FALSE) 
            '</TD>' SKIP.
    ELSE 
        {&out} htmlib-TableField(html-encode(IF lc-customertrack = 'on'
            THEN 'yes' ELSE 'no'),'left')
            SKIP.
    
    {&out} 
        '</TR>' SKIP.

    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("recordperpage",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Records Per Page")
        ELSE htmlib-SideLabel("Records Per Page"))
        '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("recordsperpage",2,lc-recordsperpage) 
            '</TD>' SKIP.
    ELSE 
        {&out} htmlib-TableField(html-encode(lc-recordsperpage),'left')
            SKIP.
    {&out} 
        '</TR>' SKIP.

    
    {&out} 
        '<tr><td valign="top" align="right">' 
        (IF LOOKUP("activitytype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Default Activity Type")
        ELSE htmlib-SideLabel("Default Activity Type"))
        '</td>' 
        '<td valign="top" align="left">'
        htmlib-Select("activitytype",lc-list-actid,lc-list-activtype,lc-ActivityType) SKIP
        '</td></tr>' SKIP. 
                    
     
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("send-2fa",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Send 2FA To Device")
        ELSE htmlib-SideLabel("Send 2FA To Device"))
        '</TD><TD VALIGN="TOP" ALIGN="left">'
            htmlib-Select("send-2fa",lc-global-send-2fa-Code ,lc-global-send-2fa-Desc,lc-send-2fa) 
            '</TD></TR>' SKIP.
        

    {&out} htmlib-EndTable() SKIP.


    IF lc-error-msg <> "" THEN
    DO:
        {&out} 
            '<BR><BR><CENTER>' 
            htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' SKIP.
    END.
    
    {&out} 
        '<center>' htmlib-SubmitButton("submitform","Update") 
        '</center>' SKIP.
    
         
    {&out} htmlib-EndForm() SKIP
        htmlib-Footer() SKIP.
    
  
END PROCEDURE.


&ENDIF

