/***********************************************************************

    Program:        mn/login.p
    
    Purpose:        Helpdesk Login               
    
    Notes:
    
    
    When        Who         What
    08/04/2006  phoski      Page layout changes
    11/04/2006  phoski      Email password changes
    23/04/2006  phoski      Form changed
    25/09/2014  phoski      Security Lib
    24/02/2016  phoski      Email new password for internal users
    27/02/2016  phoski      Issue link from SLA Email
    06/07/2016  phoski      2 Factor Auth

***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-user        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pass        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-value       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-reason      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-passtype    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-passref     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lkey        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ws-fields   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-key         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-url-company AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Auth-Pass   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Pin-ID      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pin         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-getPin      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AuthUser    AS CHARACTER NO-UNDO.





DEFINE BUFFER WebUser FOR webuser.
DEFINE BUFFER company FOR company.

DEFINE VARIABLE lc-AttrData AS CHARACTER NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 12.92
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

&IF DEFINED(EXCLUDE-ip-CompanyInfo) = 0 &THEN

PROCEDURE ip-CompanyInfo :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out} '<br><br><div class="loglink" style="clear:both;">'.
    IF company.helpdeskEmail <> "" 
        THEN {&out} '<p><img src="/images/contact/email.gif">&nbsp;' 
    '<a href="mailto:' company.HelpDeskEmail '">'
        
    html-encode(company.helpdeskemail) 
    '</a>'
    '</p>'.
    IF company.helpdeskPhone <> "" 
        THEN {&out} '<p><img src="/images/contact/phone.gif">&nbsp;' 
    html-encode(company.helpdeskphone) '</p>'.
    IF company.WebAddress <> "" 
        THEN {&out} '<p><img  src="/images/contact/web.gif">&nbsp;'
    '<a href="' company.WebAddress '">'
    html-encode(company.WebAddress) 
    '</a>'
    '</p>'.
    


    {&out} '</div>'.
    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER pc-user AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-pass AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-reason AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    ASSIGN 
        pc-reason = "".

    DEFINE BUFFER b-webuser FOR webuser.

    IF pc-user = "" THEN
    DO:
        RUN htmlib-AddErrorMessage('User', 'You must enter your user name',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
        RETURN.
    END.
    
    
    FIND b-webuser WHERE b-webuser.LoginID = pc-user EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    IF LOCKED b-webuser THEN
    DO:
        RUN htmlib-AddErrorMessage('User', 'Your account is not available at the moment - please retry',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
        RETURN.
    END.
    
    IF NOT AVAILABLE b-webuser 
        OR b-webuser.companycode <> lc-url-company THEN
    DO:
        RUN htmlib-AddErrorMessage('User', 'This user name does not exist',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
        RETURN.
    END.

    IF b-webuser.disabled THEN
    DO:
        lc-AttrData ="IP|" + remote_addr.
        com-SystemLog("ERROR:LoginDisabledAccount",pc-user,lc-AttrData).
        
        RUN htmlib-AddErrorMessage('User', 'Your user account has been disabled',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
        RETURN.

    END.

    IF ENCODE(lc-pass) <> b-webuser.Passwd 
        OR b-webuser.Passwd = "" THEN
    DO:
        lc-AttrData ="IP|" + remote_addr.
            

        com-SystemLog("ERROR:LoginPassWordIncorrect",pc-user,lc-AttrData).
        
        ASSIGN
            b-webuser.FailedLoginCount = b-webuser.FailedLoginCount + 1.
            
        IF b-webuser.FailedLoginCount > li-global-pass-max-retry THEN
        DO:
            com-SystemLog("ERROR:LoginAutoDisable",pc-user,lc-AttrData).
            ASSIGN 
                b-webuser.disabled        = TRUE
                b-webuser.AutoDisableTime = NOW.
            RUN htmlib-AddErrorMessage('User', 'For security reasons your account has been disabled',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
            ASSIGN 
                pc-reason = "AutoDisable".
            RETURN.
        
          
        END.
        
        RUN htmlib-AddErrorMessage('User', 'The password is incorrect',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
        ASSIGN 
            pc-reason = "password".
        RETURN.
    END.
    
    /*
    ***
    *** if they don't have a mobile and 2 factor then they can't login!
    ***
    */
    IF syec-useTwoFactorAuth(b-WebUser.LoginID) = TRUE AND b-WebUser.Mobile = ""
    THEN RUN htmlib-AddErrorMessage('User', 'This site requires a mobile number for security reaons - Please contact the helpdesk',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    

    CASE b-webuser.UserClass:
        WHEN "CONTRACT" THEN
            DO:
                IF NOT CAN-FIND(FIRST ContAccess
                    WHERE ContAccess.Loginid = b-webuser.LoginID
                    NO-LOCK) THEN
                DO:


                END.
            END.
    END CASE.

    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN


PROCEDURE ipMainWeb:

    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    ASSIGN 
        lc-value = htmlib-EncodeUser(lc-user). 
    lc-key = DYNAMIC-FUNCTION("sysec-EncodeValue","System",TODAY,"Password",lc-value).
           
    ASSIGN
        lc-authUser = lc-key.
    
    FIND webUser 
        WHERE webUser.LoginID = lc-user EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    IF AVAILABLE WebUser THEN
    DO:
        ASSIGN 
            WebUser.LastDate         = TODAY
            WebUser.LastTime         = TIME
            WebUser.FailedLoginCount = 0.
    END. 
            
    delete-cookie(lc-global-cookie-name,appurl,"").
    delete-cookie(lc-global-cookie-name,appurl,?).
        
    Set-Cookie(lc-global-cookie-name,
        lc-key,
        DYNAMIC-FUNCTION("com-CookieDate",lc-user),
        DYNAMIC-FUNCTION("com-CookieTime",lc-user),
        APPurl,
        ?,
        IF hostURL BEGINS "https" THEN "secure" ELSE ?).

    ASSIGN
        REQUEST_METHOD = "GET".
    set-user-field("ExtranetUser",lc-user).
    set-user-field("mode",lc-mode).
    set-user-field("authpass",lc-auth-pass).
    set-user-field("passtype",lc-passtype).
    set-user-field("passref",lc-passref).
    IF lc-auth-pass = "password" THEN
    DO:
        IF syec-useTwoFactorAuth(lc-user) = TRUE THEN
        DO:
            ASSIGN
                lc-pin-id = syec-CreateTwoFactorPinForUser(lc-user).
                
            ASSIGN
                lc-getPin = syec-GetCurrentPinForUser(lc-user).
            
            RUN lib/sendsms.p ( lc-user , "Login:Pin", "Your Helpdesk Access Pin is " + lc-getPin).
                
            set-user-field("authpass","sms").
            set-user-field("pinid",lc-pin-id).
            set-user-field("authuser",lc-AuthUser).
            RUN run-web-object IN web-utilities-hdl ("mn/login.p").
            RETURN.
            
            
        END.
    END.
    
    IF DYNAMIC-FUNCTION("com-RequirePasswordChange",lc-user) THEN 
    DO:
        set-user-field("expire","yes").
        RUN run-web-object IN web-utilities-hdl ("mn/changepassword.p").

    END.
    ELSE RUN run-web-object IN web-utilities-hdl ("mn/main.p").
    RETURN.
            

END PROCEDURE.



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
    
     

    ASSIGN
        lc-url-company = get-value("company")
        lc-mode = get-value("mode")
        lc-passtype = get-value("passtype")
        lc-passref = get-value("passref")
        lc-auth-Pass = get-value("authpass")
        lc-pin-id    = get-value("pin-id")
        lc-pin       = get-value("pin")
        lc-authUser  = get-value("authuser").
        
        
    IF lc-Auth-Pass = ""
        THEN lc-Auth-Pass = "password".
    

    IF lc-url-company = ""
        OR NOT CAN-FIND(company WHERE company.companycode = lc-url-company)
        THEN ASSIGN lc-url-company = "MICAR".


    ASSIGN
        lc-url-company    = LC(lc-url-company)
        lc-global-company = lc-url-company.

    FIND company WHERE company.companycode = lc-url-company NO-LOCK NO-ERROR.
    /* need to check if already logged in and if so pass on to main web page */
    
    IF request_method = "GET" AND lc-mode = "passthru" THEN
    DO:
        ASSIGN 
            lc-value = get-cookie(lc-global-cookie-name).
        lc-lkey = DYNAMIC-FUNCTION("sysec-DecodeValue","System",TODAY,"Password",lc-value).

        ASSIGN 
            lc-user = htmlib-DecodeUser(lc-lkey).
            
        IF lc-user <> "" THEN
        DO:
            RUN ipMainWeb.
            RETURN.
        END.
        
    END.
    
    IF request_method = "GET" AND get-value("logoff") = "yes" THEN
    DO:
        delete-cookie(lc-global-cookie-name,appurl,"").
        delete-cookie(lc-global-cookie-name,appurl,?).
          
    END.

    IF request_method = "POST" THEN
    DO:
        IF lc-Auth-Pass = "password" THEN
        DO:
            ASSIGN 
                lc-user = get-field("user")
                lc-pass = get-field("password").

            RUN ip-Validate ( 
                INPUT lc-user,
                INPUT lc-pass,
                OUTPUT lc-reason,
                OUTPUT lc-error-field,
                OUTPUT lc-error-mess ).  
        END.
        ELSE
        DO:
            ASSIGN
                 lc-user = DYNAMIC-FUNCTION("sysec-DecodeValue","System",TODAY,"Password",lc-AuthUser).
              
            lc-user = htmlib-DecodeUser(lc-user).
            
            ASSIGN
                lc-getPin = syec-GetCurrentPinForUser(lc-user).
                
            IF lc-getPin <> lc-pin 
            THEN ASSIGN 
                   lc-error-field = "PIN"
                   lc-error-mess = "The PIN is incorrect".
                   
        END.
        
        IF lc-error-mess = "" THEN
        DO:
           
            lc-AttrData ="IP|" + remote_addr.
            

            com-SystemLog("OK:Login",lc-user,lc-AttrData).

            RUN ipMainWeb.
            RETURN.
           
        END.
        
    END.

    

    RUN outputHeader.
    
    {&out} htmlib-Header(company.name + " - Help Desk Login") skip.
    
    
    {&out} '<script>' SKIP
           'document.cookie = "' lc-global-cookie-name '=; expires=Thu, 01 Jan 1970 00:00:00 UTC";' SKIP
           '</script>' SKIP.
           
    
    {&out}
    '<div style="width: 100%;">'
    '<img src="/images/menu/' lc-url-company '/banner.jpg" style="float: right;">'
    '</div>' skip.
   
    {&out} '<div style="clear: both;">'.

    {&out} htmlib-StartForm("mainform","post", selfurl ).
    
    
    
    IF lc-Auth-Pass = "password" THEN
    DO:
        {&out} '<table align="left" width="80%" style="font-size: 10px;">' skip
           '<tr><td align="left" rowspan="3" valign="top" style="xborder-right: 1px dotted black;">'
           '<img src="/images/topbar/' lc-url-company '/logo.gif" style="float: left; margin-right: 15px; margin-bottom: 15px;">'
           '<p><strong>Welcome to the ' company.name ' Help Desk</strong><p>'
           'Please enter your user name and password to login to the Help Desk.<br><br>'
           'If you require a user name and/or password then you can contact us using the following details:' skip.

    
        RUN ip-CompanyInfo.
    
    
        IF lc-reason = "password" THEN 
        DO:
            FIND WebUser WHERE WebUser.Loginid = lc-user NO-LOCK NO-ERROR.
        
            FIND company WHERE company.companycode = WebUser.companycode NO-LOCK.

            IF WebUser.email <> "" 
                AND WebUser.UserClass = "internal"
                AND ( company.smtp <> "" AND company.helpdeskemail <> "" ) THEN
            DO:
                ASSIGN 
                    lc-value = STRING(ROWID(WebUser)).
                 
                lc-key = DYNAMIC-FUNCTION("sysec-EncodeValue","System",TODAY,"webuser",lc-value).
            
                {&out} '<br><br><div class="loglink">'
                    
                '<p>Hi ' WebUser.forename ',<br>' skip
                   'The password entered was incorrect for your user name.&nbsp;'
                   'Click ' 
                        '<a href="' appurl "/mn/loginpass.p?rowid=" url-encode(lc-key,"Query") '" style="font-weight: bolder;">'
                        'here</a>'
                        ' for a new password to be generated and sent to your email address.'

                
                   '</p>' skip
                    '</div>'.
            END.
        END.
   
        {&out} '</td><td valign="top" align="right">' skip.


        {&out} '<table><tr><td>'.

        {&out} ( IF LOOKUP("user",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("User Name")
            ELSE htmlib-SideLabel("User Name"))
           skip
           '</td><td valign="top" align="left">'
           htmlib-InputField("user",20,lc-user)
           skip
           '</td></tr><tr><td valign="top" align="right">' skip
           if lookup("password",lc-error-field,'|') > 0 
           then htmlib-SideLabelError("Password")
           else htmlib-SideLabel("Password")
           skip
           '</td><td valign="top" align="left">'
           htmlib-InputPassword("password",20,"")
           '</td></tr>'.

  
        {&out} '<tr><td align=center colspan="2" nowrap><BR>' htmlib-MultiplyErrorMessage(lc-error-mess)
        htmlib-SubmitButton("submitform","Login") skip
          '</td></tr></table>' skip.

    

        {&out} '</td></tr></table>' skip.

    END.
    /*
    ***
    *** PIN Entry
    ***
    */
    ELSE
    DO:
        lc-user = DYNAMIC-FUNCTION("sysec-DecodeValue","System",TODAY,"Password",lc-AuthUser).
        lc-user = htmlib-DecodeUser(lc-user).
        
        FIND WebUser WHERE WebUser.LoginID = lc-user NO-LOCK NO-ERROR.
        
        
        {&out} '<table align="left" width="80%" style="font-size: 10px;">' skip
           '<tr><td align="left" rowspan="3" valign="top" style="xborder-right: 1px dotted black;">'
           '<img src="/images/topbar/' lc-url-company '/logo.gif" style="float: left; margin-right: 15px; margin-bottom: 15px;">'
           '<p><strong>Welcome to the ' company.name ' Help Desk</strong><p>'
           'This website uses 2 Factor Authentication - An access PIN has been sent to your mobile on '
           '<b>' WebUser.Mobile '</b>.<br />Please contact the helpdesk if your number is incorrect or you do not receive the message.'
           SKIP.
    
        RUN ip-CompanyInfo.
    
    
        IF lc-reason = "pin" THEN 
        DO:
            FIND WebUser WHERE WebUser.Loginid = lc-user NO-LOCK NO-ERROR.
        
            FIND company WHERE company.companycode = WebUser.companycode NO-LOCK.

            IF WebUser.email <> "" 
                AND WebUser.UserClass = "internal"
                AND ( company.smtp <> "" AND company.helpdeskemail <> "" ) THEN
            DO:
                ASSIGN 
                    lc-value = STRING(ROWID(WebUser)).
                 
                lc-key = DYNAMIC-FUNCTION("sysec-EncodeValue","System",TODAY,"webuser",lc-value).
            
                {&out} '<br><br><div class="loglink">'
                    
                '<p>Hi ' WebUser.forename ',<br>' skip
                   'The password entered was incorrect for your user name.&nbsp;'
                   'Click ' 
                        '<a href="' appurl "/mn/loginpass.p?rowid=" url-encode(lc-key,"Query") '" style="font-weight: bolder;">'
                        'here</a>'
                        ' for a new password to be generated and sent to your email address.'

                
                   '</p>' skip
                    '</div>'.
            END.
        END.
   
        {&out} '</td><td valign="top" align="right">' skip.


        {&out} '<table><tr><td>'.

        {&out} ( IF LOOKUP("pin",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("PIN")
            ELSE htmlib-SideLabel("PIN"))
           skip
           '</td><td valign="top" align="left">'
           htmlib-InputField("pin",20,lc-pin)
           skip
           '</td></tr>'.

  
        {&out} '<tr><td align=center colspan="2" nowrap><BR>' htmlib-MultiplyErrorMessage(lc-error-mess)
        htmlib-SubmitButton("submitform","Login") skip
          '</td></tr></table>' skip.

    

        {&out} '</td></tr></table>' skip.

    END.
    
    
    
    {&out} htmlib-Hidden("company",lc-url-company)
    htmlib-Hidden("mode",lc-mode)
    htmlib-hidden("authpass",lc-auth-pass)
    htmlib-hidden("pin-id", lc-pin-id)
    htmlib-Hidden("passtype",lc-passtype)
    htmlib-hidden("authuser",lc-Authuser)
    htmlib-Hidden("passref",lc-passref).     
    
 

    {&out} htmlib-EndForm() skip '</div>'.
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

