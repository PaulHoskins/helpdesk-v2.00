/***********************************************************************

    Program:        lookup/customer.p
    
    Purpose:        Customer Lookup      
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      CompanyCode
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-field1      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-field2      AS CHARACTER NO-UNDO.

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

    
    {lib/checkloggedin.i}

    DEFINE BUFFER b-attr FOR webattr.

    ASSIGN 
        lc-field1 = get-field("fieldname")
        lc-field2 = get-field("description").

    
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
    
    {&out} htmlib-Header("Lookup Customer") skip.
    {&out} htmlib-JScript-Lookup() skip.

    {&out} htmlib-StartForm("mainform","post", appurl + '/lookup/customer.p' ).

    {&out} htmlib-Hidden("fieldname",lc-field1) skip
           htmlib-Hidden("description",lc-field2) skip.

    {&out} htmlib-ProgramTitle("Lookup Customer").

    {&out} skip
          htmlib-StartMntTable().




    {&out}
    htmlib-TableHeading(
        "Account|Name"
        ) skip.


    OPEN QUERY q FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = lc-global-company.

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
                    AND b-search.accountnumber >= lc-search NO-LOCK NO-ERROR.
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
                    REPOSITION q TO ROWID TO-ROWID(lc-firstrow) NO-ERROR.
                    IF ERROR-STATUS:ERROR = FALSE THEN
                    DO:
                        GET NEXT q NO-LOCK.
                        IF NOT AVAILABLE b-query THEN GET FIRST q.
                    END.  
                    ELSE GET FIRST q.
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
                               '&firstrow=' + string(lr-first-row).

        {&out}
        '<tr class="tabrow1">' skip
           '<td>'
           htmlib-AnswerHyperLink(lc-field1,
                             b-query.accountnumber,
                             lc-field2,
                             b-query.name,
                             b-query.accountnumber)
           '</td>'
           htmlib-TableField(html-encode(b-query.name),'left')
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

    {&out} htmlib-StartPanel() 
         skip.


    {&out}  '<tr><td align="left">'
        .

    IF lr-first-row <> ? THEN
    DO:
        GET FIRST q NO-LOCK.
        IF ROWID(b-query) = lr-first-row 
            THEN ASSIGN ll-prev = FALSE.
        ELSE ASSIGN ll-prev = TRUE.

        GET LAST q NO-LOCK.
        IF ROWID(b-query) = lr-last-row
            THEN ASSIGN ll-next = FALSE.
        ELSE ASSIGN ll-next = TRUE.

        IF ll-prev 
            THEN {&out} htmlib-LookupAction(appurl + '/' + "lookup/customer.p","PrevPage","Prev Page").


        IF ll-next 
            THEN {&out} htmlib-LookupAction(appurl + '/' + "lookup/customer.p","NextPage","Next Page").

    END.

    {&out} '</td><td align="right">' htmlib-ErrorMessage(lc-smessage) '&nbsp;' htmlib-SideLabel("Search").
    {&out} htmlib-InputField("search",20,lc-search)
    '&nbsp;' htmlib-LookUpAction(appurl + '/' + "lookup/customer.p","search","Search")
    '&nbsp;' skip
                 htmlib-HelpButton(appurl , "lookup/customer" )
                 skip
         '</td></tr>'.

    {&out} htmlib-EndPanel().

    {&out} skip
          htmlib-Hidden("firstrow", string(lr-first-row)) skip
          htmlib-Hidden("lastrow", string(lr-last-row)) skip
          skip.


    {&out} htmlib-EndForm().


    {&OUT} htmlib-Footer() skip.

    {&out} htmlib-EndForm() skip.
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

