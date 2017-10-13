/***********************************************************************

    Program:        mn/menupanel.p
    
    Purpose:        Left Panel Menu   
    
    Notes:
    
    
    When        Who         What
    22/04/2006  phoski      Initial - replace old leftpanel.p  
    26/06/2006  phoski      Prototype    
    25/09/2014  phoski      Security Lib
    10/09/2016  phoski      CRM
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-user        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pass        AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-item        AS INTEGER   NO-UNDO.


DEFINE TEMP-TABLE tt-menu NO-UNDO
    FIELD ItemNo      AS INTEGER
    FIELD Level       AS INTEGER
    FIELD Description AS CHARACTER 
    FIELD ObjURL      AS CHARACTER
    FIELD ObjTarget   AS CHARACTER
    FIELD ObjType     AS CHARACTER
    FIELD AltInfo     AS CHARACTER
    FIELD aTitle      AS CHARACTER 
    FIELD OverDue     AS LOG

    INDEX ItemNo IS PRIMARY UNIQUE
    ItemNo.

DEFINE VARIABLE lc-system  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-image   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-company AS CHARACTER NO-UNDO.




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
    
    lc-value = DYNAMIC-FUNCTION("sysec-DecodeValue","System",TODAY,"Password",lc-value).

    ASSIGN 
        lc-user = htmlib-DecodeUser(lc-value).

    ASSIGN 
        lc-system = htmlib-GetAttr("system","systemname")
        lc-image  = htmlib-GetAttr("system","companylogo")
        lc-company = htmlib-GetAttr("system","companyname").

    RUN outputHeader.
    
    
    {&out}
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' SKIP "~n" +
         '<HTML>' SKIP
         '<HEAD>' SKIP
         '<meta http-equiv="Cache-Control" content="No-Cache">' SKIP
         '<meta http-equiv="Pragma"        content="No-Cache">' SKIP
         '<meta http-equiv="Expires"       content="0">' SKIP
         '<TITLE></TITLE>' SKIP
         DYNAMIC-FUNCTION('htmlib-StyleSheet':U) SKIP.
    {&out} '<link rel="stylesheet" href="/style/menu.css" type="text/css">' SKIP.

    
    {&out}
    '<script language="JavaScript" src="/scripts/js/standard.js"></script>' SKIP
        '<script language="JavaScript" src="/scripts/js/menu.js"></script>' SKIP
        '<script language="JavaScript" src="/scripts/js/prototype.js"></script>' SKIP
        '<script language="JavaScript" src="/scripts/js/scriptaculous.js"></script>' SKIP
    .


    FIND webuser WHERE webuser.loginid = lc-user NO-LOCK NO-ERROR.
    IF AVAILABLE webuser THEN
    DO:

        {&out} 
        '<script>' SKIP
            'function GetAlerts(target) ~{' SKIP
            '   var url = "' appurl '/mn/ajax/menu.p?user=' webuser.LoginID '"' SKIP
            '   var myAjax = new Ajax.PeriodicalUpdater( target, url, ~{evalScripts: true, asynchronous:true, frequency:28800 ~});' SKIP
            '~}' SKIP.

        IF DYNAMIC-FUNCTION("com-QuickView",webuser.LoginID) AND NOT WebUser.engType BEGINS "SAL" 
        THEN {&out}
        'function SuperUser(target) ~{' SKIP
                '   var url = "' appurl '/mn/ajax/superuser.p?user=' webuser.LoginID '"' SKIP
                '   var myAjax = new Ajax.PeriodicalUpdater( target, url, ~{evalScripts: true, asynchronous:true, frequency:28800 ~});' SKIP
                '~}' SKIP.
        IF WebUser.engType BEGINS "SAL" 
        THEN {&out}
        'function SuperUser(target) ~{' SKIP
                '   var url = "' appurl '/mn/ajax/crmuser.p?user=' webuser.LoginID '"' SKIP
                '   var myAjax = new Ajax.PeriodicalUpdater( target, url, ~{evalScripts: true, asynchronous:true, frequency:28800 ~});' SKIP
                '~}' SKIP.        
        {&out}
        'function InitialisePage() ~{' SKIP
            '  GetAlerts("ajaxmenu");' SKIP.
        

        IF DYNAMIC-FUNCTION("com-QuickView",webuser.LoginID) OR WebUser.engType BEGINS "SAL" 
            THEN {&out} '  SuperUser("superuser");' SKIP.

        {&out}
        '~}' SKIP
            '</script>' SKIP.   

        {&out}
        '</head>' SKIP '<body onLoad="InitialisePage()">'.

   

        {&out} '<br /><div style="text-align: center;">'.
        {&out} '<button onclick="window.location.reload(true);">Refresh Menu</button>' SKIP.
        {&out} '</div><br />'.

        {&out} '<div id="ajaxmenu"></div>' SKIP.
        
        IF DYNAMIC-FUNCTION("com-QuickView",webuser.LoginID) OR WebUser.engType BEGINS "SAL" 
            THEN {&out} '<div id="superuser"></div>' SKIP.

    END.
    ELSE {&out}
    '</head>' SKIP '<body>'.
    
   
    {&OUT} htmlib-Footer() SKIP.
    
  
END PROCEDURE.


&ENDIF

