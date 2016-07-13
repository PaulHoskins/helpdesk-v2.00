/***********************************************************************

    Program:        cust/cadddocument.p
    
    Purpose:        Customer document from custview
    
    Notes:
    
    
    When        Who         What
    09/12/2014  phoski      Initial
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-type   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-relkey AS CHARACTER NO-UNDO.




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


    ASSIGN 
        lc-type = "customer"
        lc-rowid = get-value("rowid").

    IF lc-rowid = ""
        THEN ASSIGN lc-rowid = get-value("ownerrowid").

    ASSIGN 
        lc-title = "Upload Document For".

    CASE lc-type:
        WHEN "customer" THEN
            DO:
                FIND customer WHERE ROWID(customer) = to-rowid(lc-rowid) NO-LOCK
                    NO-ERROR.
                IF AVAILABLE customer
                    THEN ASSIGN lc-title = lc-title + " Customer " + caps(customer.accountnumber) + 
                    " " + html-encode(customer.name).
                ASSIGN 
                    lc-relkey = customer.accountnumber.

            END.
        WHEN "issue" THEN
            DO:
                FIND issue WHERE ROWID(issue) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.
                IF AVAILABLE issue
                    THEN ASSIGN lc-title = lc-title + " Issue " + string(issue.issuenumber).
                ASSIGN 
                    lc-relkey = STRING(issue.issuenumber).


            END.
    END CASE.


    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
    .

    {&out} '<script language="JavaScript" src="/scripts/js/docupval.js"></script>' skip.   

    {&out}
    REPLACE(htmlib-StartForm("mainform","post", "/perl/uploaddoc.pl"),
        "<form",
        '<form ENCTYPE="multipart/form-data" ')
    htmlib-ProgramTitle(lc-title) skip.

    IF get-value("problem") <> "" 
        THEN {&out} '<div class="infobox">'
    get-value("problem")
    '</div>' skip.

    {&out} '<table align=center>'
    '<tr><td align="right">'  htmlib-SideLabel('Document') '</td><td><input size="60" class="inputfield" type="file" name="filename"></td></tr>'

    '<tr><td align="right">'  htmlib-SideLabel('Description') '</td><td>' htmlib-InputField("comment",60,"") '</td></tr>'
    '<tr><td align="right">'  htmlib-SideLabel('Customer View?') '</td><td>' 
    htmlib-CheckBox('custview', IF request_method = "get" THEN TRUE ELSE get-value("custview") = "on") '</td></tr>'

    '</table>'
        
    '<br><br><center><input class="actionbutton" type="button" value="Load Document" onclick="DoSubmit()"></center>'
        .
    {&out} htmlib-Hidden("type",lc-type)
    htmlib-Hidden("rowid",lc-rowid).

         
    {&out} htmlib-Hidden("OKPage", appurl + '/cust/cadddocumentok.p?type=' + lc-type
        + "&rowid=" + lc-rowid).

    {&out} htmlib-Hidden("NotOKPage", appurl + '/sys/docupfail.p?type=' + lc-type
        + "&rowid=" + lc-rowid).

    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

