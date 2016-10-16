/***********************************************************************

    Program:        crm/view.p
   
    Purpose:        CRM View 
    
    Notes:
    
    
    When        Who         What
    16/10/2016  phoski      Initial
   
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lr-rowid        AS ROWID     NO-UNDO.

DEFINE VARIABLE lc-title        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitsource AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-Enc-Key      AS CHARACTER NO-UNDO.  

DEFINE VARIABLE lc-sela-Code    AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE lc-sela-Name    AS LONGCHAR  NO-UNDO.
    
DEFINE VARIABLE lc-selr-Code    AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE lc-selr-Name    AS LONGCHAR  NO-UNDO.

DEFINE VARIABLE lc-sels-code    AS CHARACTER NO-UNDO
    INITIAL 'TL|DA|CU|REP|NS|PR' .
DEFINE VARIABLE lc-sels-name    AS CHARACTER NO-UNDO
    INITIAL 'Traffic Light|Date|Customer|Sales Rep|Next Step|Probability' .


DEFINE VARIABLE lc-crit-account AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crit-rep     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crit-status  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crit-type    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crit-sort    AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-lodate       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-hidate       AS CHARACTER NO-UNDO.



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

PROCEDURE ip-ExportJS:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    {&out} lc-global-jquery  SKIP
           '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>'  skip
           '<script language="javascript">' SKIP
           'var appurl = "' appurl '";' SKIP.

    {&out} skip
        'function ChangeCriteria() ~{' skip
        '   SubmitThePage("ChangeCriteria")' skip
        '~}' SKIP
        'function ChangeDates() ~{' skip
        '   SubmitThePage("DatesChange")' skip
        '~}' skip
          
           '</script>' SKIP
                   
           '<script language="JavaScript" src="/asset/page/crm/view.js?v=1.0.0"></script>' SKIP
           
    .
           
    
           

END PROCEDURE.

PROCEDURE ip-HTM-Header:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE OUTPUT PARAMETER pc-return       AS CHARACTER NO-UNDO.
    
/*
pc-return = '<script type="text/javascript" src="/scripts/js/tabber.js"></script>~n
<link rel="stylesheet" href="/style/tab.css" TYPE="text/css" MEDIA="screen">~n
<script language="JavaScript" src="/scripts/js/standard.js"></script>~n
'.
*/
   

    

END PROCEDURE.

PROCEDURE ip-Selection:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    {&out} htmlib-BeginCriteria("Search Opportunities").
    
    
   
    
    
    {&out} '<table align=center>' skip.
    
    {&out} '<tr><td align=right valign=top>' htmlib-SideLabel("Customer") 
    '</td><td align=left valign=top colspan=5>'.
  
    
    {&out-long}
    htmlib-SelectJSLong(
        "account",
        'ChangeCriteria()',
        "All|" + lc-sela-code,
        "All Customers|" + lc-sela-name,
        lc-crit-account
        ) '</td></tr>'.
    
    IF glob-webuser.engType <> "SAL"
    THEN ASSIGN lc-selr-code = "ALL|" + lc-selr-code
                lc-selr-name = "All Sales Reps|" + lc-selr-name.
                
                
    {&out} '<tr><td align=right valign=top>' htmlib-SideLabel("Sales Rep") 
    '</td><td align=left valign=top>'.
    
    {&out-long}
    htmlib-SelectJSLong(
        "rep",
        'ChangeCriteria()',
        lc-selr-code,
        lc-selr-name,
        lc-crit-account
        ) '</td>'.
        
        
    {&out} '<td align=right valign=top>' htmlib-SideLabel("Status") 
    '</td><td align=left valign=top>'
      
    htmlib-SelectJS("status",'ChangeCriteria()',"ALL|" + lc-global-opstatus-Code ,"All|" + lc-global-opStatus-desc,lc-crit-status).
             
    {&out} '</td><td align=right valign=top>' htmlib-SideLabel("Type") 
    '</td><td align=left valign=top>'
    
    
    htmlib-SelectJS("type",'ChangeCriteria()',"ALL|" + lc-global-opType-Code ,"All|" + lc-global-opType-desc,lc-crit-Type).
    
    {&out} '</td></tr><tr>' SKIP.
    {&out} 
    '<td valign="top" align="right">' 
        (IF LOOKUP("lodate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("From Date")
        ELSE htmlib-SideLabel("From Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("lodate",10,lc-lodate) 
    htmlib-CalendarLink("lodate")
    '</td>' SKIP.
    {&out} '<td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To Date")
        ELSE htmlib-SideLabel("To Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("hidate",10,lc-hidate) 
    htmlib-CalendarLink("hidate")
    '</td>' skip.
    
    {&out} '</td><td align=right valign=top>' htmlib-SideLabel("Sort") 
    '</td><td align=left valign=top>'
    
    
    htmlib-SelectJS("sort",'ChangeCriteria()',lc-sels-code, lc-sels-name,lc-crit-sort)
     '</td></tr>' skip.
    
       
    
       
    {&out} '</table>' htmlib-EndCriteria() '<br />'.
      
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
  
    {lib/checkloggedin.i}
    
    ASSIGN
        lc-submitSource = get-value("submitsource")
        lc-crit-account = get-value("account")
        lc-crit-rep = get-value("rep")
        lc-crit-status = get-value("status")
        lc-crit-type = get-value("type")
        lc-lodate      = get-value("lodate")         
        lc-hidate      = get-value("hidate")
        lc-crit-sort   = get-value("sort")
        .
         
    RUN crm/lib/getCustomerList.p ( lc-global-company, lc-global-user, OUTPUT lc-sela-Code, OUTPUT lc-sela-Name).
    RUN crm/lib/getRepList.p ( lc-global-company, lc-global-user, OUTPUT lc-selr-Code, OUTPUT lc-selr-Name).
        
    IF glob-webuser.engType = "SAL"
    THEN lc-crit-rep = lc-global-user.
        
    IF request_method = "POST" THEN
    DO:
                        
                        
    END.
        
    IF request_method = "GET" THEN
    DO:
        IF lc-crit-status = ""
            THEN lc-crit-status = "OP".  
        IF lc-lodate = ""
            THEN ASSIGN lc-lodate = STRING(TODAY - 365, "99/99/9999").

        IF lc-hidate = ""
            THEN ASSIGN lc-hidate = STRING(TODAY, "99/99/9999").
            
        IF lc-crit-sort = ""
        THEN lc-crit-sort = "TL".  
        IF lc-crit-type = ""
        THEN lc-crit-type = "ALL".
        
    
              
        
    END.
    
    RUN outputHeader.
    
    
    {&out} htmlib-Header("CRM Opportunities") skip.
    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.
    RUN ip-ExportJS.
    
    {&out} htmlib-StartForm("mainform","post", appurl + '/crm/view.p' ) SKIP
           htmlib-ProgramTitle("CRM Opportunities") skip
           htmlib-hidden("submitsource","") skip.
    RUN ip-Selection.
    {&out} htmlib-CalendarScript("lodate") skip
            htmlib-CalendarScript("hidate") skip.
           
    
    
    {&OUT}  htmlib-EndForm() SKIP
            htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

