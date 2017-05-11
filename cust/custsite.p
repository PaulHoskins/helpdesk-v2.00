/***********************************************************************

    Program:        cust/custsite.p
    
    Purpose:        Customer Maintenance - Sites    
    
    Notes:
    
    
    When        Who         What
    30/04/2017  phoski      Initial
    10/05/2017  phoski      Site Name
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.


DEFINE VARIABLE li-max-lines   AS INTEGER   INITIAL 12 NO-UNDO.
DEFINE VARIABLE lr-first-row   AS ROWID     NO-UNDO.
DEFINE VARIABLE lr-last-row    AS ROWID     NO-UNDO.
DEFINE VARIABLE li-count       AS INTEGER   NO-UNDO.
DEFINE VARIABLE ll-prev        AS LOG       NO-UNDO.
DEFINE VARIABLE ll-next        AS LOG       NO-UNDO.
DEFINE VARIABLE lc-search      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-smessage    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-otherp AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-char        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-customer    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-returnback  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-temp        AS CHARACTER NO-UNDO.


DEFINE BUFFER Customer FOR Customer.
DEFINE BUFFER b-query  FOR CustSite.
DEFINE BUFFER b-search FOR CustSite.


DEFINE QUERY q FOR b-query SCROLLING.




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
  
    {lib/checkloggedin.i}

   
    ASSIGN 
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation").
    
    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    ASSIGN
        lc-customer = get-value("customer")
        lc-returnback = get-value("returnback").
    
    ASSIGN 
        lc-char = htmlib-GetAttr('system','MNTNoLinesDown').
    
    ASSIGN 
        li-max-lines = int(lc-char) no-error.
    IF ERROR-STATUS:ERROR
        OR li-max-lines < 1
        OR li-max-lines = ? THEN li-max-lines = 12.

    FIND customer
        WHERE ROWID(customer) = to-rowid(lc-customer) NO-LOCK NO-ERROR.

    lc-link-url = appurl + '/cust/cust.p' + 
        '?firstrow=' + lc-returnback + 
        '&navigation=refresh' +
        '&time=' + string(TIME).

    RUN outputHeader.
    
    {&out} htmlib-Header("Maintain Customer Sites") SKIP.

   
    {&out} htmlib-JScript-Maintenance() SKIP.

    {&out} htmlib-StartForm("mainform","post", appurl + '/cust/custsite.p' ) SKIP.

    {&out} htmlib-ProgramTitle("Maintain Customer Sites -  " + 
        customer.name) SKIP.
    
    {&out} htmlib-TextLink("Back",lc-link-url) '<BR><BR>' SKIP.

    {&out}
    tbar-Begin(
        tbar-Find(appurl + "/cust/custsite.p")
        )
    tbar-Link("add",?,appurl + '/cust/custsitemnt.p',"customer=" +
        lc-customer + "&returnback=" + lc-returnback)
    tbar-BeginOption()
    tbar-Link("view",?,"off",lc-link-otherp)
    tbar-Link("update",?,"off",lc-link-otherp)
    tbar-Link("delete",?,"off",lc-link-otherp)
    tbar-EndOption()
    tbar-End().

    {&out} SKIP
           htmlib-StartMntTable().

    {&out}
    htmlib-TableHeading(
        "Site Code|Name|Address|Contact|Telephone|Notes"
        ) SKIP.


    OPEN QUERY q FOR EACH b-query NO-LOCK
    WHERE b-query.companyCode = Customer.CompanyCode
      AND b-query.AccountNumber = Customer.AccountNumber
      AND b-query.site > "".
       

    GET FIRST q NO-LOCK.

    IF lc-navigation = "nextpage" THEN
    DO:
        REPOSITION q TO ROWID TO-ROWID(lc-lastrow) NO-ERROR.
        IF ERROR-STATUS:ERROR = FALSE THEN
        DO:
            GET NEXT q NO-LOCK.
            GET NEXT q NO-LOCK.
            IF NOT AVAILABLE b-query THEN GET FIRST q.
        END.
    END.
    ELSE
        IF lc-navigation = "prevpage" THEN
        DO:
            REPOSITION q TO ROWID TO-ROWID(lc-firstrow) NO-ERROR.
            IF ERROR-STATUS:ERROR = FALSE THEN
            DO:
                GET NEXT q NO-LOCK.
                REPOSITION q BACKWARDS li-max-lines + 1.
                GET NEXT q NO-LOCK.
                IF NOT AVAILABLE b-query THEN GET FIRST q.
            END.
        END.
        ELSE
            IF lc-navigation = "search" THEN
            DO:
                FIND FIRST b-search
                    WHERE b-search.CompanyCode = lc-global-company
                    AND b-search.AccountNumber = customer.AccountNumber
                    AND b-search.Site >= lc-Search NO-LOCK NO-ERROR.
                IF AVAILABLE b-search THEN
                DO:
                    REPOSITION q TO ROWID ROWID(b-search) NO-ERROR.
                    GET NEXT q NO-LOCK.
                END.
                ELSE ASSIGN lc-smessage = "Your search found no records, displaying all".
            END.
            ELSE
                IF lc-navigation = "refresh" THEN
                DO:
                    GET FIRST q.
                END.

    ASSIGN 
        li-count = 0
        lr-first-row = ?
        lr-last-row  = ?.

    REPEAT WHILE AVAILABLE b-query:
   
        
        ASSIGN 
            lc-rowid = STRING(ROWID(b-query)).
        
        ASSIGN 
            li-count = li-count + 1.
        IF lr-first-row = ?
            THEN ASSIGN lr-first-row = ROWID(b-query).
        ASSIGN 
            lr-last-row = ROWID(b-query).
        
        ASSIGN 
            lc-link-otherp = 'search=' + lc-search +
                                '&firstrow=' + string(lr-first-row) +
                                '&customer=' + lc-customer + 
                                '&returnback=' + lc-returnback.

      

        ASSIGN lc-temp = b-query.address1.
        
        IF b-query.address2 <> ""
        THEN lc-temp = lc-temp + "<br />" + b-query.address2.
        
        IF b-query.city <> ""
        THEN lc-temp = lc-temp + "<br />" + b-query.city.
        IF b-query.county <> ""
        THEN lc-temp = lc-temp + "<br />" + b-query.county.
        
        IF b-query.country <> ""
        THEN lc-temp = lc-temp + "<br />" + b-query.country.
        
        IF b-query.postcode <> ""
        THEN lc-temp = lc-temp + "<br />" + b-query.postcode.
        
        
        {&out}
            SKIP
            tbar-tr(ROWID(b-query))
            SKIP
           
            htmlib-MntTableField(html-encode(b-query.site),'left')
            htmlib-MntTableField(b-query.name,'left')
            htmlib-MntTableField(lc-temp,'left')
            htmlib-MntTableField(html-encode(b-query.Contact),'left')
            htmlib-MntTableField(html-encode(b-query.Telephone),'left')
            htmlib-MntTableField(REPLACE(html-encode(b-query.notes),"~n","<br>"),"left")
           
          

            tbar-BeginHidden(ROWID(b-query))
                tbar-Link("view",ROWID(b-query),appurl + '/cust/custsitemnt.p',lc-link-otherp)
                tbar-Link("update",ROWID(b-query),appurl + '/cust/custsitemnt.p',lc-link-otherp)
                tbar-Link("delete",ROWID(b-query),IF DYNAMIC-FUNCTION('com-CanDelete':U,lc-user,"site",ROWID(b-query))
                          THEN ( appurl + '/' + "cust/custsitemnt.p") ELSE "off",
                          lc-link-otherp)
                                
            tbar-EndHidden()
            '</tr>' SKIP.

       

        

        GET NEXT q NO-LOCK.
            
    END.
    
    {&out} SKIP 
           htmlib-EndTable()
           SKIP.

 
    {&out} SKIP
           htmlib-Hidden("firstrow", STRING(lr-first-row)) SKIP
           htmlib-Hidden("lastrow", STRING(lr-last-row)) SKIP
           htmlib-Hidden("customer",lc-customer) SKIP
           htmlib-Hidden("returnback",lc-returnback)
           SKIP.

    {&out} 
    '<div id="urlinfo">|customer=' lc-customer "|returnback=" lc-returnback '</div>'.

    {&out} htmlib-EndForm().

    
    {&OUT} htmlib-Footer() SKIP.
    
  
END PROCEDURE.


&ENDIF

