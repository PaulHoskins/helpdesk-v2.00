/***********************************************************************

    Program:        mn/ajax/superuser.p
    
    Purpose:        Super User Ajax Panel
    
    Notes:
    
    
    When        Who         What
    06/08/2006  phoski      Initial   
    
    03/08/2010  DJS         Small changes for possible speedup
    22/10/2015  phoski      AllowAllTeams show quick view
     
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */



DEFINE VARIABLE lc-user      AS CHARACTER NO-UNDO.

DEFINE VARIABLE ll-SuperUser AS LOG       NO-UNDO.

DEFINE VARIABLE lc-Enc-Key   AS CHARACTER NO-UNDO.



/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.15
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

&IF DEFINED(EXCLUDE-ip-ContractorView) = 0 &THEN

PROCEDURE ip-ContractorView :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    {&out} '<div id="quickview" style="display: none; margin: 7px;">'.
   
    {&out} htmlib-BeginCriteria("Quick View").

    {&out} '<table style="font-size: 10px;" id="customerList">'.
    FOR EACH customer  
        NO-LOCK
        WHERE customer.CompanyCode = webuser.CompanyCode USE-INDEX Name
        ,
        FIRST ContAccess
        NO-LOCK
        WHERE ContAccess.LoginId = lc-user
        AND ContAccess.AccountNumber = customer.AccountNumber 
              
        :
        
        
        ASSIGN 
            lc-enc-key =
                 DYNAMIC-FUNCTION("sysec-EncodeValue",lc-user,TODAY,"customer",STRING(ROWID(customer))).
                 
        

        {&out}
        '<tr><td>'
        '<a title="View Customer" target="mainwindow" class="tlink" style="border:none;" href="' appurl '/cust/custview.p?source=menu&rowid=' 
        url-encode(lc-enc-key,"Query")  '">'
        html-encode(customer.Name)
        '</a></td></tr>'.

    END.
    
    {&out} '</table>'.
    {&out} htmlib-EndCriteria().
    {&out} '</div>'.

    {&out}
    '<script>' skip
        'superuserresp = function() ~{' skip
        /* ' Effect.SlideDown(~'overview~', ~{duration:3~});' skip */
        ' Effect.Grow(~'quickview~');' skip

        '~}' skip 
        'superuserresp();' skip
        '</script>'.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-CustomerQuickView) = 0 &THEN

PROCEDURE ip-CustomerQuickView :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE ll-Steam    AS LOG NO-UNDO.
    DEFINE VARIABLE ll-HasIss   AS LOG NO-UNDO.

    {&out} '<div id="quickview" style="display: none; margin: 7px;">'.
    {&out} htmlib-BeginCriteria("Quick View").
    
    {&out} '<table style="font-size: 10px;" id="customerList">'.

   
    ll-Steam = CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = lc-user NO-LOCK).



    FOR EACH customer  NO-LOCK
        WHERE customer.CompanyCode = webuser.CompanyCode 
        AND customer.iSActive
        USE-INDEX Name:

        /*
        *** if user is in teams then customer must be in 1 of the users teams
        *** or they have been assigned to the an issue for the customer
        */
        IF Customer.allowAllTeams = FALSE THEN
        DO:
            IF ll-steam
                AND NOT CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = lc-user
                AND webusteam.st-num = customer.st-num NO-LOCK) 
                THEN 
            DO:
                ASSIGN 
                    ll-HasIss = FALSE.
                FOR EACH Issue NO-LOCK
                    WHERE Issue.CompanyCode = webuser.CompanyCode
                    AND Issue.AssignTo = webuser.LoginID
                    AND issue.AccountNumber = customer.AccountNumber,
                    FIRST WebStatus NO-LOCK
                    WHERE WebStatus.CompanyCode = Issue.CompanyCode 
                    AND WebStatus.StatusCode = Issue.StatusCode
                    AND WebStatus.CompletedStatus = FALSE:
                    ll-HasIss = TRUE.
                    LEAVE.
                END.
                IF NOT ll-HasIss THEN NEXT.
            END.
        END.
        
        ASSIGN 
            lc-enc-key =
                 DYNAMIC-FUNCTION("sysec-EncodeValue",lc-user,TODAY,"customer",STRING(ROWID(customer))).
                 
        {&out}
        '<tr><td>'
        '<a title="View Customer" target="mainwindow" class="tlink" style="border:none;" href="' appurl '/cust/custview.p?source=menu&rowid=' 
        url-encode(lc-enc-key,"Query") '">'
        html-encode(customer.Name)
        '</a></td></tr>'.

    END.

    {&out} '</table>'.
    {&out} htmlib-EndCriteria().
    {&out} '</div>'.

    {&out}
    '<script>' skip
        'superuserresp = function() ~{' skip
        /* ' Effect.SlideDown(~'overview~', ~{duration:3~});' skip */
        ' Effect.Grow(~'quickview~');' skip

        '~}' skip 
        'superuserresp();' skip
        '</script>'.


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
        lc-user = get-value("user").


    RUN outputHeader.
    
    
    FIND webuser WHERE webuser.loginid = lc-user NO-LOCK NO-ERROR.

    
    IF NOT AVAILABLE webuser THEN RETURN.
    
    ll-superUser = DYNAMIC-FUNCTION("com-IsSuperUser",webuser.LoginID).


    IF NOT DYNAMIC-FUNCTION("com-QuickView",webuser.LoginID)
        THEN RETURN.

    IF ll-SuperUser
        OR webUser.UserClass = "INTERNAL"
        THEN RUN ip-CustomerQuickView.
    ELSE RUN ip-ContractorView.

    
  
END PROCEDURE.


&ENDIF

