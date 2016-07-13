/***********************************************************************

    Program:        mn/loginpass.p
    
    Purpose:        Send user password from main login page  
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      CompanyCode    
    26/09/2014  phoski      function disabled  
    24/02/2016  phoski      Reinstated for internal users
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
   
    DEFINE VARIABLE lc-lkey      AS CHARACTER NO-UNDO.
   
    ASSIGN 
        lc-rowid = get-value("rowid").
    
    IF lc-rowid = "" 
        THEN ASSIGN lc-rowid = get-field("saverowid")
            .
    
        
    lc-lkey = DYNAMIC-FUNCTION("sysec-DecodeValue","System",TODAY,"webuser",lc-rowid).
    
    ASSIGN 
        lc-title = 'New Password Sent'.
           
    
    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-lkey) EXCLUSIVE-LOCK NO-ERROR.
    
    IF AVAILABLE b-table AND b-table.UserClass = "internal" THEN
    DO:

        ASSIGN 
            lc-length = htmlib-GetAttr ('PASSWORDRULE', 'MinLength').

        ASSIGN 
            li-length = int(lc-length) no-error.
        IF li-length = ?
        OR li-length <= 0 
        THEN li-length = 8.

        ASSIGN 
            lc-newPassword = htmlib-GenPassword(li-length).


        DYNAMIC-FUNCTION("mlib-SendPassword",b-table.loginid,lc-newpassword).
    
        ASSIGN 
            b-table.PassWd = ENCODE(lc-newpassword)
            b-table.FailedLoginCount = 0
            b-table.LastPasswordChange = TODAY - 365.

    END.
    ELSE lc-title = "Function not allowed".
        
    
    RUN outputHeader.
    
    /* lc-title = "Function disabled" */.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/mn/loginpass.p')
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("saverowid", lc-rowid) skip
    .
        
    IF AVAILABLE b-table AND b-table.UserClass = "internal" THEN
    DO:
        {&out} '<table align=center>' 
        '<tr><td>Your new password has been sent to your email address at '
        b-table.email '.</td></tr>' SKIP
                   '</table>'.
    
    END.
    
    
    
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

