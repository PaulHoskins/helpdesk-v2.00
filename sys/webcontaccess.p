/***********************************************************************

    Program:        sys/webcontaccess.p
    
    Purpose:        User Maintenance - Contract Account Access
    
    Notes:
    
    
    When        Who         What
    09/04/2006  phoski      Initial
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


DEFINE BUFFER b-valid FOR webuser.
DEFINE BUFFER b-table FOR webuser.
DEFINE BUFFER b-query FOR Customer.


DEFINE VARIABLE lc-search        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters    AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url      AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-loginid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-forename      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-surname       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-email         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-usertitle     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pagename      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-disabled      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accountnumber AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-jobtitle      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-telephone     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-password      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-userClass     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-usertitleCode AS CHARACTER
    INITIAL '' NO-UNDO.
DEFINE VARIABLE lc-usertitleDesc AS CHARACTER
    INITIAL '' NO-UNDO.




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
    
    DEFINE VARIABLE lc-object       AS CHARACTER     NO-UNDO.

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

   
    .

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

    ASSIGN 
        lc-title = 'Account Access For ' + 
            html-encode(b-table.forename + " " + b-table.surname)
        lc-link-label = "Cancel"
        lc-submit-label = "Update Account Access".
       
    ASSIGN 
        lc-link-url = appurl + '/sys/webuser.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME).

   

    IF request_method = "POST" THEN
    DO:
        FOR EACH ContAccess EXCLUSIVE-LOCK
            WHERE ContAccess.Loginid = b-table.LoginID:
            DELETE ContAccess.
        END.
        FOR EACH b-query NO-LOCK
            WHERE b-query.CompanyCode = lc-global-company:
            ASSIGN 
                lc-object = "ob" + string(ROWID(b-query)).
            IF get-value(lc-object) = "on" THEN
            DO:
                CREATE ContAccess.
                ASSIGN 
                    ContAccess.Loginid = b-table.LoginID
                    ContAccess.AccountNumber = b-query.AccountNumber.
            END.
        END.
        set-user-field("navigation",'refresh').
        set-user-field("firstrow",lc-firstrow).
        set-user-field("search",lc-search).
        RUN run-web-object IN web-utilities-hdl ("sys/webuser.p").
        RETURN.
    END.

    ASSIGN 
        lc-loginid = b-table.loginid.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    
    {&out} skip
          htmlib-StartMntTable().
    {&out}
    htmlib-TableHeading(
        "Access?|Account|Name"
        ) skip.

    FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = lc-global-company:
        
        ASSIGN 
            lc-object = "ob" + string(ROWID(b-query)).

        
        {&out}
        htmlib-trmouse()
        '<td>'
        htmlib-CheckBox(lc-object,
            CAN-FIND(FIRST ContAccess
            WHERE ContAccess.Loginid = 
            b-table.LoginID
            AND ContAccess.AccountNumber =
            b-query.AccountNumber NO-LOCK))
        '</td>'
        htmlib-MntTableField(html-encode(b-query.accountnumber),'left')
        htmlib-MntTableField(html-encode(b-query.name),'left')
        '</tr>' skip.

    END.

    {&out} skip 
           htmlib-EndTable()
           skip.

    {&out} htmlib-StartPanel() 
           skip.

    {&out} 
    '<tr><td align="left">' htmlib-SubmitButton("submitform",lc-submit-label) 
    '</td></tr>' skip.
    {&out} htmlib-EndPanel().
         
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

