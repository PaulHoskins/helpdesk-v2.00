/***********************************************************************

    Program:        iss/confissue.p
    
    Purpose:        Confirm Issue Creation
    
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


DEFINE VARIABLE lc-issuenumber AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-customer    AS LOG       NO-UNDO.




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
{iss/issue.i}



 




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
      Notes:       In the event that this Web object is state-aware, this is
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
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE ll-ok AS LOG NO-UNDO.

    DEFINE VARIABLE lc-customer AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-raised   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-area     AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-cust FOR Customer.
    DEFINE BUFFER b-iss  FOR Issue.
    DEFINE BUFFER b-user FOR WebUser.
    DEFINE BUFFER b-area FOR WebIssArea.

    {lib/checkloggedin.i}

    ASSIGN 
        lc-issuenumber = get-value("newissue").
    IF lc-issuenumber = ""
        THEN ASSIGN lc-issuenumber = get-value("savenewissue").

    ll-customer = com-IsCustomer(lc-global-company,lc-user).

    ASSIGN 
        lc-title = 'Issue Created'.
   
    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip.
  
    {&out}
    htmlib-StartForm("mainform","post", appurl + '/iss/confissue.p' )
    htmlib-ProgramTitle(lc-title) skip.


    {&out} htmlib-Hidden("savenewissue",lc-issuenumber)
    htmlib-TextLink("Add New Issue",appurl + '/iss/addissue.p') '<BR><BR>' skip
           '<table align=center cellpadding="5">' skip.


    FIND b-iss WHERE b-iss.CompanyCode = lc-global-company
        AND b-iss.IssueNumber = int(lc-issuenumber) NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-iss THEN RETURN.

    FIND b-cust OF b-iss NO-LOCK NO-ERROR.
    IF AVAILABLE b-cust 
        THEN ASSIGN lc-customer = b-cust.AccountNumber + ' ' + b-cust.name.
    ELSE ASSIGN lc-customer = "".

    FIND b-user WHERE b-user.LoginId = b-iss.RaisedLoginID NO-LOCK NO-ERROR.
    IF AVAILABLE b-user 
        THEN ASSIGN lc-raised = b-user.name.
    ELSE ASSIGN lc-raised = "".

    FIND b-area OF b-iss NO-LOCK NO-ERROR.
    IF AVAILABLE b-area
        THEN ASSIGN lc-area = b-area.description.
    ELSE ASSIGN lc-area = "".

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Issue Number")
    '</TD>' 
    htmlib-TableField(html-encode(lc-issuenumber),'left')
    '<TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Customer")
    '</TD>' 
    htmlib-TableField(html-encode(lc-customer),'left')
    '</TR>' skip. 

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Raised By")
    '</TD>' 
    htmlib-TableField(html-encode(lc-raised),'left')
    '<TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Area")
    '</TD>' 
    htmlib-TableField(html-encode(lc-area),'left')
    '</TR>' skip. 

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Brief Description")
    '</TD>' 
    htmlib-TableField(html-encode(b-iss.BriefDescription),'left')
    '<TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Details")
    '</TD>' 
    htmlib-TableField(REPLACE(b-iss.LongDescription,'~n','<BR>'),'left')
    '</TR>' skip. 
   
    IF ll-customer THEN
    DO:
        {&out} '<tr><th colspan="4" align="center">'
        'The helpdesk have been informed about this issue'
        '</th></tr>'.
    END.
    {&out} htmlib-EndTable() skip.

    
    {&OUT}  htmlib-EndForm() skip
            htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

