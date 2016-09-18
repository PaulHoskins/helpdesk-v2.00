/***********************************************************************

    Program:        crm/mainpage.p
   
    Purpose:        CRM Main Page ( Landing Page )
    
    Notes:
    
    
    When        Who         What
    01/08/2016  phoski      Initial
   
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lr-rowid         AS ROWID     NO-UNDO.

DEFINE VARIABLE lc-title         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitsource  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode          AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-Enc-Key       AS CHARACTER NO-UNDO.  

DEFINE VARIABLE lc-accountnumber AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-name          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-address1      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-address2      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-city          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-county        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-country       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-postcode      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-telephone     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-contact       AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-ct-code       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ct-desc       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cu-code       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cu-desc       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AccStatus     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SalesManager  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sm-code       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sm-desc       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SalesContact  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Website       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-noEmp         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-turn          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SalesNote     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-indsector     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ind-code      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ind-desc      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accountref    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-source        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parent        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-opt-TBAR      AS CHARACTER 
    INITIAL 'opu' NO-UNDO.
    
DEFINE VARIABLE lc-con-TBAR      AS CHARACTER 
    INITIAL 'con' NO-UNDO.
        
    



DEFINE BUFFER b-table FOR customer.




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
            
           '<script language="javascript">' SKIP
           'var appurl = "' appurl '";' SKIP
           '</script>' SKIP
           tbar-JavaScript(lc-Opt-TBAR) SKIP
           tbar-JavaScript(lc-Con-TBAR) SKIP
           
           '<script language="JavaScript" src="/asset/page/crm/customer.js?v=1.0.0"></script>' SKIP
           
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
        lc-title = 'View'
        lc-link-label = "Back"
        lc-submit-label = "Update CRM Details".
                    
        

    ASSIGN 
        lc-link-url = appurl + '/cust/cust.p' + 
                                  '?search=' +
                                  '&navigation=initial' +
                                  '&time=' + string(TIME).
                                  
   
    ASSIGN 
        lc-rowid = get-value("crmaccount")
        lc-mode = get-value("mode")
        lc-source = get-value("source")
        lc-parent = get-value("parent").
        
    IF lc-source = "dataset"
    THEN lc-link-url = appurl + '/crm/crmloadmnt.p' + 
                                  '?mode=view&rowid=' + lc-parent +
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME).    
    IF lc-mode = "CRM"
        THEN lc-mode = "UPDATE".
        
    ASSIGN 
        lc-enc-key = lc-rowid.
    
    ASSIGN
        lc-rowid = DYNAMIC-FUNCTION("sysec-DecodeValue",lc-user,TODAY,"Customer",lc-rowid).
        
    ASSIGN 
        lr-rowid = TO-ROWID(lc-rowid).
            
    

    FIND b-table WHERE ROWID(b-table) = lr-rowid
        NO-LOCK NO-ERROR.
        
    IF request_method = "POST" THEN
    DO:
                        
                        
    END.
        
    IF request_method = "GET" THEN
    DO:
       
        
    END.
    
    RUN outputHeader.
    
    
    {&out} htmlib-Header("CRM") skip.
 
    RUN ip-ExportJS.
    
    {&out} htmlib-StartForm("mainform","post", appurl + '/crm/mainpage.p' ) SKIP
           htmlib-ProgramTitle("CRM") skip.


    
    
    {&OUT}  htmlib-EndForm() SKIP
            htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

