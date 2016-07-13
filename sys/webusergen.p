/***********************************************************************

    Program:        sys/webusergen.p
    
    Purpose:        Generate User Password
    
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
DEFINE VARIABLE lc-sendmail    AS CHARACTER NO-UNDO.



DEFINE BUFFER b-valid FOR webuser.
DEFINE BUFFER b-table FOR webuser.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-newpassword  AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop         AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-length       AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-length       AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-expire       AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-expire       AS INTEGER   NO-UNDO.




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

    ASSIGN 
        lc-title = 'Generate Password'
        lc-link-label = 'Cancel'
        lc-submit-label = 'Confirm New Password'.

    ASSIGN 
        lc-title = lc-title + ' User'
        lc-link-url = appurl + '/sys/webuser.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME)
        .

    IF CAN-DO("view,update,delete,genpassword",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/sys/webuser.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:
        ASSIGN 
            lc-newpassword = get-value("newpass").
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            EXCLUSIVE-LOCK NO-ERROR.

        IF lc-newpassword <> "" THEN
        DO:
            ASSIGN 
                b-table.passwd = ENCODE(lc-newpassword).
            ASSIGN 
                lc-expire = htmlib-GetAttr ('PASSWORDRULE', 'ExpireDays').

            ASSIGN 
                li-expire = int(lc-expire) no-error.
            IF li-expire <= 0
                THEN li-expire = ?.
            
            /*
            ***
            *** If theres an expiry period then force the user
            *** to update their password next time they sign in
            ***
            */
            IF li-expire <> ?
                THEN ASSIGN b-table.expiredate = TODAY - 1.
            ELSE ASSIGN b-table.expiredate = ?.
        END.
        IF b-table.email <> ""
            THEN DYNAMIC-FUNCTION("mlib-SendPassword",b-table.loginid,lc-newpassword).
        RUN outputHeader.
        set-user-field("navigation",'refresh').
        set-user-field("firstrow",lc-firstrow).
        set-user-field("search",lc-search).
        RUN run-web-object IN web-utilities-hdl ("sys/webuser.p").
        RETURN.
    END.

    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.


    ASSIGN 
        lc-length = htmlib-GetAttr ('PASSWORDRULE', 'MinLength').

    ASSIGN 
        li-length = int(lc-length) no-error.
    IF li-length = ?
        OR li-length <= 0 
        THEN li-length = 8.

    ASSIGN 
        lc-newPassword = htmlib-GenPassword(li-length).


     

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/webusergen.p')
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) skip
           htmlib-Hidden ("newpass",lc-newpassword) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Name")
    '</TD>' skip
           htmlib-TableField(html-encode(b-table.name),'left')
           '</TR><TR><TD VALIGN="TOP" ALIGN="right">' 
           htmlib-SideLabel("Password")
           '</TD>' skip
           htmlib-TableField(html-encode(lc-newpassword),'left')
           skip.
         
    IF htmlib-GetAttr ('MAIL', 'SendPassword') = 'yes' 
        AND b-table.email <> "" THEN
    DO:
        {&out} '<tr><td colspan=5>&nbsp&nbsp(Password will be sent to ' b-table.Email 
        ' once confirmed.)</td></tr>' skip.
    END.


    DO li-loop = 1 TO 3:
        {&out} '<TR><TD>&nbsp</TD></TR>' skip.
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

