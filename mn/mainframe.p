/***********************************************************************

    Program:        mn/mainframe.p
    
    Purpose:        right hand panel
    
    Notes:
    
    
    When        Who         What
    27/02/2016  phoski      Pass thru link from SLA
***********************************************************************/

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-meg       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-passtype        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-passref         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-passwordchanged AS CHARACTER NO-UNDO.


DEFINE BUFFER b-user FOR webuser.




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
    
    
    {lib/checkloggedin.i}

    ASSIGN 
        lc-passwordchanged = get-value("passwordchanged").


    set-user-field("passwordchanged","no").

    FIND b-user WHERE b-user.loginid = lc-user NO-LOCK NO-ERROR.

    IF NOT AVAILABLE b-user THEN RETURN.

     
    IF b-user.UserClass = "CUSTOMER" THEN
    DO:
        ASSIGN 
            request_method = 'get'.
        RUN run-web-object IN web-utilities-hdl ("iss/issue.p").
        RETURN.
        
    END.
    
     ASSIGN
        lc-mode = get-value("mode")
        lc-passtype = get-value("passtype")
        lc-passref = get-value("passref").

    
    IF lc-mode = "passthru" THEN
    DO:
        
        CASE lc-passtype:
        WHEN "issue" THEN
        DO:
            FIND Issue WHERE Issue.CompanyCode = b-User.CompanyCode
                         AND Issue.IssueNumber = int(lc-passref) NO-LOCK NO-ERROR.
            IF AVAILABLE Issue
            AND LOOKUP(lc-user,issue.alertUsers) > 0  THEN
            DO:
                set-user-field("mode","update").
                set-user-field("rowid",STRING(ROWID(issue))).
               
                ASSIGN 
                    request_method = 'get'.
                RUN run-web-object IN web-utilities-hdl ("iss/issueframe.p").
                RETURN.
            END.
            
                         
                         
        END.
        END CASE.
        
    END.

    set-user-field("status","AllOpen").
    set-user-field("assign",b-user.loginid).
    ASSIGN 
        request_method = 'get'.
    RUN run-web-object IN web-utilities-hdl ("iss/issue.p").
    RETURN.

  
END PROCEDURE.


&ENDIF

