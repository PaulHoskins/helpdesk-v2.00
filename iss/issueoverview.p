/***********************************************************************

    Program:        iss/issueoverview.p
    
    Purpose:        Issue Overview - Summarise whats open etc
    
    Notes:
    
    
    When        Who         What
    26/05/2006  phoski      Initial
    28/09/2014  phoski      Only super users get this page and no customers

***********************************************************************/
CREATE WIDGET-POOL.

&GlOBAL-DEFINE object-class INTERNAL-ONLY


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */




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
{iss/issue.i}



 




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

    FIND webuser WHERE webuser.loginid = lc-user NO-LOCK NO-ERROR.
    
    RUN outputHeader.
      
    {&out}
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' skip 
         '<HTML>' skip
         '<HEAD>' skip
          
         '<meta http-equiv="Cache-Control" content="No-Cache">' skip
         '<meta http-equiv="Pragma"        content="No-Cache">' skip
         '<meta http-equiv="Expires"       content="0">' skip
         DYNAMIC-FUNCTION('htmlib-StyleSheet':U) skip
         '<script language="JavaScript" src="/scripts/js/standard.js"></script>'
          skip
         '<script language="JavaScript" src="/scripts/js/prototype.js"></script>' skip
         '<script language="JavaScript" src="/scripts/js/scriptaculous.js"></script>' skip
    .
    .

    IF AVAILABLE webuser AND dynamic-function("com-IsSuperUser",webuser.LoginID) 
    AND DYNAMIC-FUNCTION("com-IsCustomer",lc-global-company,webuser.LoginID) = FALSE THEN
    DO:
        {&out} 
        '<SCRIPT LANGUAGE = "JavaScript">' skip
           'function GetAlerts(target) ~{' skip
            '   var url = "' appurl '/iss/ajax/overview.p?user=' webuser.LoginID '"' skip
            '   var myAjax = new Ajax.PeriodicalUpdater( target, url, ~{evalScripts: true, asynchronous:true, frequency:60 ~});' skip
            '~}' skip
           'function AjaxStartPage() ~{' skip
           ' GetAlerts("ajaxdiv")' skip
           '~}' skip
        '</script>' skip.


        {&out}
        '</HEAD>' skip '<body onLoad="AjaxStartPage()">'.

    END.
    ELSE {&out}
    '</HEAD>' skip
         '<body class="normaltext" onUnload="ClosePage()">' skip
    .


   
  

    {&out}
    htmlib-StartForm("mainform","post", appurl + '/iss/issueoverview.p' )
    htmlib-ProgramTitle("HelpDesk Monitor").


    IF AVAILABLE webuser THEN
    DO:
        {&out} '<div id="ajaxdiv">Please wait.....</div>' skip.
    END.


    {&out} htmlib-Hidden("submitsource","null").

    
    {&OUT} htmlib-EndForm() skip.

   
    {&out} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

