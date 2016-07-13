/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*           This .W file was created with the Progress AppBuilder.     */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-title AS CHARACTER NO-UNDO.



DEFINE BUFFER b-query FOR webuser.
DEFINE QUERY q FOR b-query SCROLLING.




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
    
    
   
    RUN outputHeader.
    
    ASSIGN 
        lc-title = "Contacting " + 
                                 htmlib-GetAttr("system","CompanyName").

    {&out} htmlib-Header(lc-title) skip.

    {&out} htmlib-ProgramTitle(lc-title).

    {&out} skip
           htmlib-StartMntTable().

    {&out}
    htmlib-TableHeading(
        "Name^left|Position^left|Email|Telephone"
        ) skip.

    
    OPEN QUERY q FOR EACH b-query 
        WHERE CAN-DO(lc-global-internal,b-query.UserClass) = TRUE  
        AND b-query.AccountNumber = ""
        USE-INDEX Surname.

    GET FIRST q NO-LOCK.


    REPEAT WHILE AVAILABLE b-query:
        {&out}
        '<tr class="tabrow1">' skip
            htmlib-TableField(html-encode(b-query.name),'left')
            htmlib-TableField(html-encode(b-query.JobTitle),'left')
            '<td>'
            replace(htmlib-TextLink(html-encode(b-query.email),
                            'mailto:' + b-query.email),
                    '<a ','<a class="tablefield" ')
            '</td>'
            htmlib-TableField(html-encode(b-query.Telephone),'left')
            '</tr>' skip.

        GET NEXT q NO-LOCK.


    END.

    {&out} skip 
           htmlib-EndTable()
           skip.

    {&out} '<br><table align=right>' skip
           '<tr><td align=left>'
           'Micar Computer Systems Ltd<br>'
           '400a Hale End Road, Highams Park, London E4 9PB, UK<br>'
           'Tel +44 (0)20 8531 7444  Fax: +44 (0)20 8531 8427<br>'
           '</td></tr></table>'.


    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

