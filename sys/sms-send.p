/***********************************************************************

    Program:        sys/sms-send.p
    
    Purpose:        User Preferences
    
    Notes:
    
    
    When        Who         What
    28/04/2006  phoski      Initial
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-from        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-to          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-text        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-url         AS CHARACTER NO-UNDO.




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

&IF DEFINED(EXCLUDE-ip-AccessDenied) = 0 &THEN

PROCEDURE ip-AccessDenied :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    RUN outputHeader.
    
    {&out} htmlib-Header("Send SMS Message") skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle("Send SMS Message") skip.


    
    {&out} 
    '<p class="errormessage">'
    'You do not have access to this web page'
    '</p>'.
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.

    IF lc-from = ""
        THEN RUN htmlib-AddErrorMessage(
            'from', 
            'You must enter who the message is from',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    IF LENGTH(lc-from) > 11
        THEN RUN htmlib-AddErrorMessage(
            'from', 
            'The from field can not be over 11 characters long',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    IF lc-to = ""
        THEN RUN htmlib-AddErrorMessage(
            'to', 
            'You must enter one or more mobiles numbers',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
                
    IF lc-text = ""
        THEN RUN htmlib-AddErrorMessage(
            'text', 
            'You must enter a message to send',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    IF LENGTH(lc-text) > 160 
        THEN RUN htmlib-AddErrorMessage(
            'text', 
            'The message can not be over 160 characters long',
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

    IF webuser.UserClass = "CUSTOMER"
        OR NOT webuser.AccessSMS THEN
    DO:
        RUN ip-AccessDenied.
        RETURN.

    END.

    ASSIGN
        lc-to = get-value("to")
        lc-text = get-value("text")
        lc-from = get-value("from").

    IF request_method = "POST" THEN
    DO:
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-field = "" THEN
        DO:
            ASSIGN
                lc-url = 
                appurl + '/sys/sms-post.p'
                + '?username=' + lc-global-sms-username 
                + '&password=' + lc-global-sms-password
                + '&from=' + lc-from
                + '&to=' + lc-to
                + '&text=' + replace(lc-text,"~n"," ")
                .
                                  

        END.
    END.
    ELSE
    DO:
        FIND company WHERE company.companycode = webuser.CompanyCode NO-LOCK NO-ERROR.
        ASSIGN 
            lc-from = TRIM(substr(company.name,1,11)).
        
    END.
  
    RUN outputHeader.
    
    {&out} htmlib-Header("Send SMS Message") skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle("Send SMS Message") skip.


    
    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("from",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("From")
        ELSE htmlib-SideLabel("From"))
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-InputField("from",11,lc-from) skip
           '</TD>'
           '<td valign="top" style="font-size: 10px;padding-left: 10px; padding-bottom: 10px;">Can be your mobile number or a name etc.<br>(11 characters max)</td>'
           '</tr>'.
                    

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("to",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Send To Mobiles")
        ELSE htmlib-SideLabel("Send To Mobiles"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("to",lc-to,4,30)
    '</TD>' skip
            '<td valign="top" style="font-size: 10px; padding-left: 10px; padding-bottom: 10px;">Enter the mobiles numbers, comma separated, to send the message to.<br>(100 numbers max)</td>'
            '</tr>'.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("text",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Message")
        ELSE htmlib-SideLabel("Message"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("text",lc-text,4,30)
    '</TD>' skip
         '<td valign="top" style="font-size: 10px; padding-left: 10px; padding-bottom: 10px;">Enter your message.<br>(160 characters max)</td>'

            '</tr>'.

    
    {&out} htmlib-EndTable() skip.


    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.
    
    IF lc-url <> "" THEN
    DO:
        {&out} skip
           '<div id="sms">'
           htmlib-StartFieldSet("Sending Message").

        {&out} '<p>Please wait.... See below for success ...</p>'.
        {&out} '<iframe src="' lc-url '" frameborder="0"></iframe>'.
        {&out} 
        htmlib-EndFieldSet() 
        '</div>'.

    END.
    {&out} '<center>' htmlib-SubmitButton("submitform","Send Message") 
    '</center>' skip.
    
         
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

