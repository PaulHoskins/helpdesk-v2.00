/***********************************************************************

    Program:        mn/menutop.p
    
    Purpose:        Menu Top Panel            
    
    Notes:
    
    
    When        Who         What
    23/04/2006  phoski      Various
    25/09/2014  phoski      Security Lib
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-user AS CHARACTER NO-UNDO.

DEFINE TEMP-TABLE tt-menu NO-UNDO
    FIELD ItemNo       AS INTEGER
    FIELD Level        AS INTEGER
    FIELD Description  AS CHARACTER 
    FIELD ObjURL       AS CHARACTER
    FIELD ObjTarget    AS CHARACTER
    FIELD ObjType      AS CHARACTER
    FIELD MenuLocation AS CHARACTER
    FIELD TopOrder     AS INTEGER

    INDEX ItemNo IS PRIMARY UNIQUE
    ItemNo.




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

&IF DEFINED(EXCLUDE-ip-BeginMenu) = 0 &THEN

PROCEDURE ip-BeginMenu :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    FIND webuser WHERE webuser.loginid = lc-user NO-LOCK NO-ERROR.

    IF NOT AVAILABLE webUser THEN RETURN.

    FIND company OF webuser NO-LOCK NO-ERROR.


    
    {&OUT}
    '<div id="topcontent"><div id="topheader">':U SKIP
   
    '<img src="/images/topbar/' 
        lc(webUser.companyCode) '/small-logo.gif" style="float: left;">' skip '&nbsp;' 
        html-encode(Company.Name) ' - Help Desk':U SKIP
    '   </div>':U SKIP
    '   <div id="topbarmenu">':U SKIP.


    {&out}
    '<span class="topbarinfo">&nbsp;User: ' html-encode(webuser.name).
     
    
    IF com-IsCustomer(webuser.CompanyCode,webuser.LoginID) THEN
    DO:
        FIND customer WHERE customer.CompanyCode = webuser.CompanyCode
            AND customer.AccountNumber = webuser.AccountNumber
            NO-LOCK NO-ERROR.
        IF AVAILABLE customer
            THEN {&out} html-encode(' - ' + customer.name).
    END.
    {&out} '</span>'
        .

    {&out} '               <span id="topbaritem">':U SKIP.


    IF AVAILABLE webuser THEN
    DO:
        RUN mnlib-BuildMenu ( webuser.pagename, 1 ).
        RUN ip-BuildLinks.
    END.

    {&OUT}
    '&nbsp;</span></div></div>':U SKIP.
    
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-BuildLinks) = 0 &THEN

PROCEDURE ip-BuildLinks :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-htm-2 AS CHARACTER INITIAL
        '<a href="&1" target="mainwindow" title="&2">&3</a>' 
        NO-UNDO.
    DEFINE VARIABLE lc-out       AS CHARACTER NO-UNDO.
    

    FOR EACH tt-menu EXCLUSIVE-LOCK
        BY tt-menu.TopOrder:
        IF tt-menu.ObjType <> 'WS' THEN NEXT.
        
        IF CAN-DO("B,T",tt-menu.MenuLocation) = FALSE THEN NEXT.
        ASSIGN 
            tt-menu.ObjURL = appurl + '/' + tt-menu.ObjURL.
        
        
        ASSIGN 
            lc-out = SUBSTITUTE(lc-htm-2,tt-menu.Objurl,html-encode(tt-menu.description),html-encode(tt-menu.description)).
        
        {&out} lc-out skip.
  
    END.

    IF webuser.UserClass <> "CUSTOMER"
        AND webuser.AccessSMS 
        THEN {&out} '<a href="' appurl '/sys/sms-send.p" target="mainwindow">SMS</a>'.

    {&out} '<a href="' appurl "/mn/login.p?logoff=yes&company=" webuser.Company '" target="_top" title="Log off helpdesk">Log Off</a>'.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-JScript) = 0 &THEN

PROCEDURE ip-JScript :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Style) = 0 &THEN

PROCEDURE ip-Style :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    RETURN.
/*
    {&out} 

'<style>' skip
'body ~{ margin-top: 0px;' skip 
        'margin-left: 0px;' skip 
        'margin-right: 0px; ~}' skip

'</style>' skip.
*/
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-mnlib-BuildMenu) = 0 &THEN

PROCEDURE mnlib-BuildMenu :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER pc-menu     AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pi-level    AS INTEGER  NO-UNDO.

    DEFINE BUFFER b-menu FOR webmhead.
    DEFINE BUFFER b2-menu FOR webmhead.
    DEFINE BUFFER b-line FOR webmline.
    DEFINE BUFFER b2-line FOR webmline.
    DEFINE BUFFER b-object FOR webobject.

    DEFINE VARIABLE li-ItemNo       AS INTEGER NO-UNDO.


    FIND b-menu WHERE b-menu.pagename = pc-menu NO-LOCK NO-ERROR.

    IF NOT AVAILABLE b-menu THEN RETURN.

    FOR EACH b-line OF b-menu NO-LOCK:
        IF b-line.linktype = 'page' THEN
        DO:
            FIND b2-menu WHERE b2-menu.pagename = b-line.linkobject
                NO-LOCK NO-ERROR.
            IF NOT AVAILABLE b2-menu THEN NEXT.
            FIND FIRST b2-line OF b2-menu NO-LOCK NO-ERROR.
            IF NOT AVAILABLE b2-line THEN NEXT.
        END.
        ELSE
        DO:
            FIND b-object WHERE b-object.objectid = b-line.linkobject
                NO-LOCK NO-ERROR.
            IF NOT AVAILABLE b-object THEN
            DO: 
               
                NEXT.
            END.
        END.
        FIND LAST tt-menu NO-LOCK NO-ERROR.
        ASSIGN 
            li-itemno = IF AVAILABLE tt-menu 
                           THEN tt-menu.itemno + 1
                           ELSE 1.
        IF b-line.linktype = 'Page' THEN
        DO:
            CREATE tt-menu.
            ASSIGN 
                tt-menu.ItemNo = li-itemno
                tt-menu.Level  = pi-Level
                tt-menu.Description  = b2-menu.PageDesc.
            RUN mnlib-BuildMenu( b2-menu.PageName, pi-level + 1 ).

        END.
        ELSE
        DO:
            CREATE tt-menu.
            ASSIGN 
                tt-menu.ItemNo = li-itemno
                tt-menu.Level  = pi-Level
                tt-menu.Description = b-object.Description
                tt-menu.ObjURL      = b-object.ObjURL
                tt-menu.ObjTarget   = b-object.ObjTarget
                tt-menu.ObjType     = b-object.ObjType
                tt-menu.MenuLocation = b-object.MenuLocation
                tt-menu.TopOrder     = b-object.TopOrder.

        END.
    END.

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
  
    DEFINE VARIABLE lc-value AS CHARACTER NO-UNDO.

    ASSIGN 
        lc-value = get-cookie(lc-global-cookie-name).
    
    ASSIGN
        lc-value = DYNAMIC-FUNCTION("sysec-DecodeValue","System",TODAY,"Password",lc-value).
    

    ASSIGN 
        lc-user = htmlib-DecodeUser(lc-value).

    RUN outputHeader.
  
    {&out}
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' skip 
    '<HTML>' 
         '<HEAD>' 
         '<meta http-equiv="Cache-Control" content="No-Cache">' 
         '<meta http-equiv="Pragma"        content="No-Cache">'
         '<meta http-equiv="Expires"       content="0">' 
         '<TITLE>' + "menutop" + '</TITLE>' 
         DYNAMIC-FUNCTION('htmlib-StyleSheet':U).

    RUN ip-Style.
    RUN ip-JScript.
    {&out}
        
    '<script language="JavaScript" src="/scripts/js/standard.js"></script>' +
        '</HEAD>' +
        '<BODY>'.

    RUN ip-BeginMenu.

    {&OUT} htmlib-Footer() skip.
  
END PROCEDURE.


&ENDIF

