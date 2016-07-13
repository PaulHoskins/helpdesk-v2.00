/***********************************************************************

    Program:        cust/cust.p
    
    Purpose:        Customer Maintenance - Browse        
    
    Notes:
    
    
    When        Who         What
    09/04/2006  phoski      Document link 
    10/04/2006  phoski      CompanyCode
    22/04/2006  phoski      Equip maint link
    27/09/2014  phoski      Encrypted rowid to custview.p
    05/06/2015  phoski      Contract Page
    08/11/2015  phoski      Show account Ref & show def contract
    02/07/2016  phoski      com-getTicketBalance
   
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
DEFINE VARIABLE lc-Enc-Key     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-def-cont    AS CHARACTER NO-UNDO.





DEFINE BUFFER b-query  FOR customer.
DEFINE BUFFER b-search FOR customer.


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
  
    DEFINE VARIABLE lc-view-Link AS CHARACTER NO-UNDO.
    
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
        lc-char = htmlib-GetAttr('system','MNTNoLinesDown').
    
    ASSIGN 
        li-max-lines = int(lc-char) no-error.
    IF ERROR-STATUS:ERROR
        OR li-max-lines < 1
        OR li-max-lines = ? THEN li-max-lines = 12.

    RUN outputHeader.
    
    {&out} htmlib-Header("Maintain Customers") skip.

    {&out} htmlib-JScript-Maintenance() skip.

   
    {&out} htmlib-StartForm("mainform","post", appurl + '/cust/cust.p' ) skip.

    {&out} htmlib-ProgramTitle("Maintain Customers") skip.
    

    {&out}
    tbar-Begin(
        tbar-Find(appurl + "/cust/cust.p")
        )
    tbar-Link("add",?,appurl + '/' + "cust/custmnt.p",lc-link-otherp)
    tbar-BeginOption()
    tbar-Link("view",?,"off",lc-link-otherp)
    tbar-Link("update",?,"off",lc-link-otherp)
    tbar-Link("delete",?,"off",lc-link-otherp)
    tbar-Link("custequip",?,"off",lc-link-otherp)
    tbar-Link("doclist",?,"off",lc-link-otherp)
    tbar-Link("ticketadd",?,"off",lc-link-otherp)
    tbar-Link("CustAsset",?,"off",lc-link-otherp)
    tbar-Link("CustContract",?,"off",lc-link-otherp)
    tbar-EndOption()
    tbar-End().



    {&out} skip
           htmlib-StartMntTable().

    {&out}
    htmlib-TableHeading(
        "Account|Name|Contact|Telephone|Account Ref|Default Contract|Ticket Balance^right"
        ) skip.

    IF lc-search = ""
        THEN OPEN QUERY q FOR EACH b-query NO-LOCK
            WHERE b-query.CompanyCode = lc-global-company.
    ELSE OPEN QUERY q FOR EACH b-query NO-LOCK
            WHERE b-query.CompanyCode = lc-global-company
            AND b-query.Name CONTAINS lc-search
            BY b-query.AccountNumber.


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
            IF lc-navigation = "refresh" THEN
            DO:
                REPOSITION q TO ROWID TO-ROWID(lc-firstrow) NO-ERROR.
                IF ERROR-STATUS:ERROR = FALSE THEN
                DO:
                    GET NEXT q NO-LOCK.
                    IF NOT AVAILABLE b-query THEN GET FIRST q.
                END.  
                ELSE GET FIRST q.
            END.
            ELSE 
                IF lc-navigation = "lastpage" THEN
                DO:
                    GET LAST q.
                    REPOSITION q BACKWARDS li-max-lines.
                    GET NEXT q NO-LOCK.
                    IF NOT AVAILABLE b-query THEN GET FIRST q.
                END.

    ASSIGN 
        li-count = 0
        lr-first-row = ?
        lr-last-row  = ?.

    REPEAT WHILE AVAILABLE b-query:
   
        
        ASSIGN 
            lc-rowid = STRING(ROWID(b-query)).
            
        ASSIGN 
            lc-enc-key =
                 DYNAMIC-FUNCTION("sysec-EncodeValue",lc-user,TODAY,"customer",STRING(ROWID(b-query))).
                 
        
        ASSIGN 
            li-count = li-count + 1.
        IF lr-first-row = ?
            THEN ASSIGN lr-first-row = ROWID(b-query).
        ASSIGN 
            lr-last-row = ROWID(b-query).
        
        ASSIGN 
            lc-link-otherp = 'search=' + lc-search +
                                '&firstrow=' + string(lr-first-row).
        ASSIGN
            lc-view-link = tbar-Link("view",ROWID(b-query),appurl + '/' + "cust/custview.p",lc-link-otherp).
        ASSIGN
            lc-view-link = REPLACE(lc-view-link,STRING(ROWID(b-query)),url-encode(lc-enc-key,"Query"))
            lc-def-cont = "<b>** None **</b>".
            
        FIND FIRST WebissCont 
            WHERE WebissCont.CompanyCode = b-query.companyCode
              AND WebissCont.Customer  = b-query.AccountNumber
              AND WebissCont.defcon = TRUE
              NO-LOCK NO-ERROR.
        IF AVAILABLE WebissCont
        THEN lc-def-cont = WebissCont.ContractCode.
                    
        {&out}
            skip
            tbar-tr(rowid(b-query))
            skip
            htmlib-MntTableField(html-encode(b-query.accountnumber),'left')
            htmlib-MntTableField(html-encode(b-query.name),'left')
            htmlib-MntTableField(html-encode(b-query.contact),'left')
            htmlib-MntTableField(html-encode(b-query.telephone),'left')
            htmlib-MntTableField(html-encode(b-query.accountref),'left')
            htmlib-MntTableField((lc-def-cont),'left')
            htmlib-MntTableField(if DYNAMIC-FUNCTION('com-AllowTicketSupport':U,rowid(b-query))
                                 then dynamic-function("com-TimeToString",com-GetTicketBalance(b-query.companyCode,b-query.accountnumber))
                                 else "&nbsp;",'right')

            tbar-BeginHidden(rowid(b-query))
                lc-view-Link
                tbar-Link("update",rowid(b-query),appurl + '/' + "cust/custmnt.p",lc-link-otherp)
                tbar-Link("delete",rowid(b-query),
                          if DYNAMIC-FUNCTION('com-CanDelete':U,lc-user,"customer",rowid(b-query))
                          then ( appurl + '/' + "cust/custmnt.p") else "off",
                          lc-link-otherp)
                tbar-Link("custequip",rowid(b-query),appurl + '/' + "cust/custequip.p","customer=" + 
                                                string(rowid(b-query)) + 
                                                "&returnback=" + string(lr-first-row)
                                                )
                tbar-Link("doclist",rowid(b-query),appurl + '/' + "cust/custdoc.p",lc-link-otherp)
                tbar-Link("ticketadd",rowid(b-query),
                          if DYNAMIC-FUNCTION('com-AllowTicketSupport':U,rowid(b-query))
                          then ( appurl + '/' + "cust/custticket.p") else "off",
                          lc-link-otherp)
                tbar-Link("CustAsset",rowid(b-query),appurl + '/' + "cust/custasset.p","customer=" + 
                                                string(rowid(b-query)) + 
                                                "&returnback=" + string(lr-first-row)
                                                )
                 tbar-Link("CustContract",rowid(b-query),appurl + '/' + "cust/custcontract.p","customer=" + 
                                                string(rowid(b-query)) + 
                                                "&returnback=" + string(lr-first-row)
                                                )

            tbar-EndHidden()

            '</tr>' skip.

       

        IF li-count = li-max-lines THEN LEAVE.

        GET NEXT q NO-LOCK.
            
    END.

    IF li-count < li-max-lines THEN
    DO:
        {&out} skip htmlib-BlankTableLines(li-max-lines - li-count) skip.
    END.

    {&out} skip 
           htmlib-EndTable()
           skip.

    
    
    {lib/navpanel2.i "cust/cust.p"}

    {&out} skip
           htmlib-Hidden("firstrow", string(lr-first-row)) skip
           htmlib-Hidden("lastrow", string(lr-last-row)) skip
           skip.

    
    {&out} htmlib-EndForm().

    
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

