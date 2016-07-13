/***********************************************************************

    Program:        mn/main.p
    
    Purpose:        main frame 
    
    Notes:
    
    
    When        Who         What
    22/04/2006  phoski      Initial  
    25/09/2014  phoski      Security Lib
    27/02/2016  phoski      Pass thru link from SLA
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-mode       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-passtype   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-passref    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-frame-args AS CHARACTER NO-UNDO.



/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 11.58
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
    output-http-header("Cache-Control", "no-cache":U).  
    output-http-header("Pragma", "no-cache":U).  
    output-http-header("Expires", "Thu, 01 Dec 1994 16:00:00 GMT":U).

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
        
    DEFINE VARIABLE lc-user AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-value AS CHARACTER NO-UNDO.
    
    ASSIGN 
        lc-user = get-user-field("ExtranetUser").
    IF lc-user = "" THEN
    DO:
    
        ASSIGN 
            lc-value = get-cookie(lc-global-cookie-name).
            
        lc-value = DYNAMIC-FUNCTION("sysec-DecodeValue","System",TODAY,"Password",lc-value).
        MESSAGE "in main " lc-value.
            
    
        ASSIGN 
            lc-user = htmlib-DecodeUser(lc-value).
    END.

    
    IF lc-user = "" THEN
    DO:
        
        RUN run-web-object IN web-utilities-hdl ("mn/notloggedin.p").
        RETURN.
    END.
    
    ASSIGN
        lc-mode = get-value("mode")
        lc-passtype = get-value("passtype")
        lc-passref = get-value("passref").
        

    FIND webuser WHERE webuser.LoginID = lc-user NO-LOCK NO-ERROR.

    FIND company WHERE company.CompanyCode = webuser.CompanyCode NO-LOCK NO-ERROR.

  
    set-user-field("ExtranetUser",webuser.LoginID).
    
    /*
    ***
    *** Customers dont get pass thru links ever!
    ***
    */
    IF WebUser.UserClass <> "customer" THEN
    DO:
        set-user-field("mode",lc-mode).
        set-user-field("passtype",lc-passtype).
        set-user-field("passref",lc-passref).
        IF lc-mode = "passthru"
        THEN lc-frame-args = "?mode=" + lc-mode + "&passtype=" + lc-passtype + "&passref=" + lc-passref.
    END.
    
   
    lc-value = DYNAMIC-FUNCTION("sysec-EncodeValue","System",TODAY,"Password",htmlib-EncodeUser(webuser.LoginID)).
      
    Set-Cookie(lc-global-cookie-name,
        lc-value,
        DYNAMIC-FUNCTION("com-CookieDate",lc-user),
        DYNAMIC-FUNCTION("com-CookieTime",lc-user),
        APPurl,
        ?,
        IF hostURL BEGINS "https" THEN "secure" ELSE ?).

    RUN outputHeader.
  
    {&OUT}
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' skip "~n" +
         '<HTML>' skip
         '<HEAD>' skip
         "<TITLE>" Company.name ' - Help Desk' "</TITLE>":U SKIP
         '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">' skip 
         "</HEAD>":U SKIP.
    
    
    {&out}
    '<frameset rows="50,*" cols="*" frameborder="NO" border="0" framespacing="0">' skip
            '<frame src="' appurl '/mn/menutop.p" name="menutop" scrolling="NO" noresize>' skip
            '<frameset cols="250,*" frameborder="NO" border="0" framespacing="0">' skip
                '<frame src="' appurl '/mn/menupanel.p" name="leftpanel" scrolling="YES" noresize>' skip
                '<frame src="' appurl '/mn/mainframe.p' lc-frame-args '" name="mainwindow">' skip
            '</frameset>' skip
        '</frameset>' skip.

    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

