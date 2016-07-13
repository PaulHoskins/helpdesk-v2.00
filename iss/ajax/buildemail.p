/***********************************************************************

    Program:        iss/ajax/buildemail.p
    
    Purpose:        Build Issue Email - Ajax     
    
    Notes:
    
    
    When        Who         What
    09/06/2014  phoski      Initial
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE BUFFER iemailtmp FOR iemailtmp.


DEFINE VARIABLE lc-company   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-reference AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-edit      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-tmpcode   AS CHARACTER NO-UNDO.




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
    output-content-type("text/plain~; charset=iso-8859-1":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
  
    DEFINE VARIABLE lc-descr        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-convtxt      AS CHARACTER NO-UNDO.

    ASSIGN
        lc-company = get-value("company")
        lc-Reference = REPLACE(get-value("Reference"),"tmpsel","")
        lc-reference = SUBSTR(lc-reference,2)
        lc-tmpcode =  get-value("template") 
        lc-tmpcode =  get-value("template")
        lc-edit    = get-value("edit").

    IF lc-tmpcode <> "" THEN
    DO:
        FIND iemailtmp
            WHERE iemailtmp.companyCode = lc-company
            AND iemailtmp.tmpCode = lc-tmpCode
            NO-LOCK NO-ERROR.
        RUN lib/translatetemplate.p 
            (
            lc-company,
            lc-tmpcode,
            int(lc-reference),
            NO,
            iemailtmp.tmptxt,
            OUTPUT lc-convtxt,
            OUTPUT lc-descr
            ).
    END.
    ELSE lc-convtxt = "No email will be sent".
   
    
    RUN outputHeader.
    
    {&out} lc-convtxt.



END PROCEDURE.


&ENDIF

