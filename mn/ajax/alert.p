/***********************************************************************

    Program:        mn/ajax/alert.p
    
    Purpose:        Menu Ajax Alert
    
    Notes:
    
    
    When        Who         What
    22/04/2006  phoski      Initial
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-loginid AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-Alert   AS LOG       NO-UNDO.

DEFINE BUFFER webuser FOR webuser.




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

&IF DEFINED(EXCLUDE-ip-InternalUser) = 0 &THEN

PROCEDURE ip-InternalUser :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-ActionCount AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-AlertCount  AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-EmailCount  AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-OpenAction  AS INTEGER NO-UNDO.
    
    DEFINE VARIABLE lc-Random      AS CHARACTER NO-UNDO.


    li-ActionCount = com-NumberOfActions(webUser.LoginID).
    li-AlertCount  = com-NumberOfAlerts(webUser.LoginID).
    li-EmailCount  = com-NumberOfEmails(webUser.LoginID).
    li-OpenAction  = com-NumberOfOpenActions(webUser.LoginId).

    ASSIGN
        ll-Alert = li-ActionCount > 0 OR li-AlertCount > 0 
        .

    IF ll-Alert THEN
    DO:
        ASSIGN
            lc-Random = "?random=" + string(int(TODAY)) + string(TIME) + string(ETIME) + string(ROWID(webuser)).
        {&out} 
        '<br /><a class="tlink" style="width: 100%;" href="' appurl
        '/mn/alertpage.p' lc-random '" target="mainwindow" title="Alerts">Your' skip.
         
        IF li-ActionCount > 0 THEN
            {&out} ' actions (' li-ActionCount ')'.
        IF li-AlertCount > 0 THEN
        DO:
            {&out} ( IF li-ActionCount > 0 THEN ' & ' ELSE ' ' ) 'SLA alerts (' li-AlertCount ')'.
        END.
        {&out} '</a><br /><br />' skip.
    END.

    IF li-EmailCount > 0 THEN
    DO:
        ASSIGN
            lc-Random = "?random=" + string(int(TODAY)) + string(TIME) + string(ETIME) + string(ROWID(webuser)).
        {&out} 
        '<br /><a class="tlink" style="width: 100%;" href="' appurl
        '/mn/dummy.p' lc-random '" target="mainwindow" title="HelpDesk emails">' skip
                'Emails (' li-EmailCount ')'
                '</a><br /><br />' skip.
         
        
    END.

    IF li-OpenAction > 0 THEN
    DO:
        ASSIGN
            lc-Random = "?random=" + string(int(TODAY)) + string(TIME) + string(ETIME) + string(ROWID(webuser)).
        {&out} 
        '<br /><a class="tlink" style="width: 100%;" href="' appurl
        '/iss/openaction.p' lc-random '" target="mainwindow" title="Open Actions">' skip
                'Open Actions (' li-OpenAction ')'
                '</a><br /><br />' skip.

    END.

    MESSAGE "Action = " li-OpenAction.

    
END PROCEDURE.


&ENDIF

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
    output-content-type("text/plain~; charset=iso-8859-1":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
  
    ASSIGN
        lc-loginID = get-value("user").

    
    RUN outputHeader.
    
    FIND WebUser WHERE Webuser.LoginID = lc-LoginID NO-LOCK NO-ERROR.

    IF NOT AVAILABLE WebUser THEN RETURN.

    IF CAN-DO(lc-global-internal,WebUser.UserClass) THEN
    DO:
        RUN ip-InternalUser.
    END.
END PROCEDURE.


&ENDIF

