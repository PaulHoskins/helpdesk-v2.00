/***********************************************************************

    Program:        mn/changepassword.p
    
    Purpose:        Helpdesk Change Login               
    
    Notes:
    
    
    When        Who         What
    27/02/2016  phoski      Issue link from SLA Email

***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-oldpass     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-newpass1    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-newpass2    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-expire      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-AttrData    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-mode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-passtype    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-passref     AS CHARACTER NO-UNDO.



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

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-user AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE li-length AS INTEGER NO-UNDO.

    DEFINE BUFFER b-user FOR webuser.


    ASSIGN 
        li-length = int(htmlib-GetAttr("PasswordRule","MinLength")).

    FIND b-user WHERE b-user.loginid = pc-user NO-LOCK NO-ERROR.

    IF NOT AVAILABLE b-user THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'null', 
            'Your user record has been deleted',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
        RETURN.
    END.
    IF lc-oldpass = "" 
        THEN RUN htmlib-AddErrorMessage(
            'oldpass', 
            'You must enter your old password',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    ELSE 
        IF ENCODE(lc-oldpass) <> b-user.passwd 
            THEN RUN htmlib-AddErrorMessage(
                'oldpass', 
                'This is not the correct password',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    IF lc-newpass1 = "" 
        THEN RUN htmlib-AddErrorMessage(
            'newpass1', 
            'You must enter the new password',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    ELSE
        IF LENGTH(lc-newpass1) < li-length 
            THEN RUN htmlib-AddErrorMessage(
                'newpass1', 
                'Your new password must be at least ' + 
                string(li-length) + ' characters long',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        ELSE
            IF lc-newpass1 BEGINS pc-user 
                THEN RUN htmlib-AddErrorMessage(
                    'newpass1', 
                    'Your new password can start with or be your user name',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).
            ELSE
                IF lc-newpass1 <> lc-newpass2 
                    THEN RUN htmlib-AddErrorMessage(
                        'newpass1', 
                        'The new passwords must be the same',
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
    
    DEFINE BUFFER b-user FOR webuser.

    {lib/checkloggedin.i}

    ASSIGN
        lc-expire    = get-value("expire")
        lc-mode = get-value("mode")
        lc-passtype = get-value("passtype")
        lc-passref = get-value("passref").

    IF request_method = "POST" THEN
    DO:
        ASSIGN 
            lc-oldpass   = get-value("oldpass")
            lc-newpass1  = get-value("newpass1")
            lc-newpass2  = get-value("newpass2")
            .
        RUN ip-Validate ( lc-user ,
            OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).
        IF lc-error-msg = "" THEN
        DO:

            FIND b-user WHERE b-user.loginid = lc-user
                EXCLUSIVE-LOCK.
            ASSIGN 
                b-user.passwd = ENCODE(lc-newpass1).

            ASSIGN 
                b-user.LastPasswordChange = TODAY.

            lc-AttrData ="IP|" + remote_addr.
            

            com-SystemLog("OK:PasswordChanged",lc-user,lc-AttrData).
            
            
            set-user-field("passwordchanged","yes").
            
            set-user-field("mode",lc-mode).
            set-user-field("passtype",lc-passtype).
            set-user-field("passref",lc-passref).
    
            IF lc-expire = "yes"
                THEN RUN run-web-object IN web-utilities-hdl ("mn/main.p").
            ELSE RUN run-web-object IN web-utilities-hdl ("mn/mainframe.p").
            RETURN.

        END.
                   
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header("Change Password") 
    htmlib-StartForm("mainform","post", appurl + '/mn/changepassword.p' ).

    IF lc-expire = "yes"
        THEN {&out} htmlib-ProgramTitle("Password Expired - Please Select A New One").
    else {&out} htmlib-ProgramTitle("Change Your Password").

    IF lc-expire = "yes" THEN
        {&out}
    '<div style="border: 1px dotted red; padding: 15px; margin-bottom: 10px; margin-top: 10px; font-weight: bold; font-size: 12px; background-color: #FFFFCC;">'
                
    '<p>For security reasons your password is required to be changed.<p>'
        
    '</div>' skip.

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("oldpass",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Old Password")
        ELSE htmlib-SideLabel("Old Password"))
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-InputPassword("oldpass",20,"") skip
           '</TD></TR>' SKIP.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("newpass1",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("New Password")
        ELSE htmlib-SideLabel("New Password"))
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-InputPassword("newpass1",20,"") skip
           '</TD></TR>' SKIP.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("newpass2",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Re-enter New Password")
        ELSE htmlib-SideLabel("Re-enter New Password"))
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-InputPassword("newpass2",20,"") skip
           '</TD></TR>' SKIP.


    {&out} htmlib-EndTable() skip.

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    {&out} '<center>' htmlib-SubmitButton("submitform","Change Password") 
    '</center>' skip.
    
    {&out}
    htmlib-hidden("expire",get-value("expire"))
    htmlib-Hidden("mode",lc-mode)
    htmlib-Hidden("passtype",lc-passtype)
    htmlib-Hidden("passref",lc-passref).

    {&OUT} htmlib-EndForm() skip 
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

