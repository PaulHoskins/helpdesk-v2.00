/***********************************************************************

    Program:        sys/kbsearch.p
    
    Purpose:        KB Search
    
    Notes:
    
    
    When        Who         What
    01/08/2006  phoski      Initial
     
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
DEFINE VARIABLE lc-nopass      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-code        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-desc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-knbcode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-type        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-type-code   AS CHARACTER
    INITIAL "T|I|C" NO-UNDO.
DEFINE VARIABLE lc-type-desc   AS CHARACTER
    INITIAL "Title|Text|Both Title And Text" NO-UNDO.


DEFINE BUFFER b-query  FOR knbtext.
DEFINE BUFFER b-search FOR knbtext.
DEFINE QUERY q FOR b-query SCROLLING.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fnText) = 0 &THEN

FUNCTION fnText RETURNS CHARACTER
    ( pf-knbid AS DECIMAL,
    pi-count AS INTEGER )  FORWARD.


&ENDIF


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

&IF DEFINED(EXCLUDE-ip-Search) = 0 &THEN

PROCEDURE ip-Search :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE BUFFER knbItem      FOR knbitem.
    DEFINE BUFFER knbSection   FOR knbSection.

    
    IF lc-knbCode = "ALL" THEN
        OPEN QUERY q FOR EACH b-query NO-LOCK
            WHERE b-query.dData CONTAINS lc-search
            AND b-query.dType = lc-type
            AND b-query.companycode = lc-global-company.
    ELSE 
        OPEN QUERY q FOR EACH b-query NO-LOCK
            WHERE b-query.dData CONTAINS lc-search
            AND b-query.dType = lc-type
            AND b-query.companycode = lc-global-company
            AND b-query.knbcode = lc-knbCode.

    {&out}
    tbar-Begin(
        ""
        )
    tbar-BeginOption()
    tbar-Link("view",?,"off",lc-link-otherp)
            
    tbar-EndOption()
    tbar-End().

    
    {&out} skip
           htmlib-StartMntTable().

    {&out}
    htmlib-TableHeading(
        "Title|Section|Ref"
        ) skip.

    GET FIRST q NO-LOCK.

    IF lc-navigation = "nextpage" THEN
    DO:
        REPOSITION q TO ROWID TO-ROWID(lc-lastrow) NO-ERROR.
        IF ERROR-STATUS:ERROR = FALSE THEN
        DO:
            GET NEXT q NO-LOCK.
            GET NEXT q NO-LOCK.
            IF NOT AVAILABLE b-query THEN GET FIRST q NO-LOCK.
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
                IF NOT AVAILABLE b-query THEN GET FIRST q NO-LOCK.
            END.
        END.
        ELSE
            IF lc-navigation = "refresh" THEN
            DO:
                REPOSITION q TO ROWID TO-ROWID(lc-firstrow) NO-ERROR.
                IF ERROR-STATUS:ERROR = FALSE THEN
                DO:
                    GET NEXT q NO-LOCK.
                    IF NOT AVAILABLE b-query THEN GET FIRST q NO-LOCK.
                END.  
                ELSE GET FIRST q NO-LOCK.
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

        FIND knbItem WHERE knbItem.knbID = b-query.knbID NO-LOCK NO-ERROR.
        FIND knbSection OF knbItem NO-LOCK NO-ERROR.
       
        {&out}
            skip
            tbar-tr(rowid(b-query))
            skip(4)
            htmlib-MntTableField(html-encode(knbItem.kTitle)
                                 + '<br>' 
                                 + '<div class="hi">'
                                 + DYNAMIC-FUNCTION('fnText':U,b-query.knbId,5)
                                 + '</div>','left')
            skip(4)
            htmlib-MntTableField(html-encode(knbSection.description),'left')
            htmlib-MntTableField(html-encode(string(b-query.knbID)),'left')
            
            skip
                tbar-BeginHidden(rowid(b-query))
                tbar-Link("view",rowid(b-query),
                          'javascript:HelpWindow('
                          + '~'' + appurl 
                          + '/sys/kbview.p?rowid=' + string(rowid(b-query)) +
                            '&search=' + url-encode(lc-search,"")
                          + '~'' 
                          + ');'
                          ,lc-link-otherp)
                
                tbar-EndHidden()
                skip
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

    
    IF lr-first-row = ? 
        THEN lc-error-mess = "No entries where found".

    {lib/navpanel.i "sys/kbsearch.p"}

    
    {&out} 
    '<div id="urlinfo">|type=' lc-type "|knbcode=" lc-knbcode '</div>'.
    {&out} skip
           htmlib-Hidden("firstrow", string(lr-first-row)) skip
           htmlib-Hidden("lastrow", string(lr-last-row)) skip
           skip.


END PROCEDURE.


&ENDIF

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
        lc-char = htmlib-GetAttr('system','MNTNoLinesDown').
    
    ASSIGN 
        li-max-lines = int(lc-char) no-error.
    IF ERROR-STATUS:ERROR
        OR li-max-lines < 1
        OR li-max-lines = ? THEN li-max-lines = 12.

    ASSIGN
        li-max-lines = 5.

    RUN com-GetKBSection(lc-global-company,
        OUTPUT lc-code,
        OUTPUT lc-desc).

    ASSIGN 
        lc-code = "ALL|" + lc-code
        lc-desc = "All Sections|" + lc-desc.

    ASSIGN
        lc-knbcode = get-value("knbcode")
        lc-type    = get-value("type").


    RUN outputHeader.
    
    {&out} htmlib-Header("KB Search") skip.

    {&out}
    '<style>' skip
           '.hi ~{ color: red; font-size: 10px; margin-left: 15px; font-style: italic;~}' skip
           '</style>' skip.

    {&out} htmlib-JScript-Maintenance() skip.

    {&out} htmlib-StartForm("mainform","post", appurl + '/sys/kbsearch.p' ) skip.

    {&out} htmlib-ProgramTitle("KB Search") skip.
    

    {&out} htmlib-BeginCriteria("Search Issues").

    {&out} '<table align=center>' skip.

    {&out}
    '<tr>'
    '<td align=right valign=top>' htmlib-SideLabel("Search For") '</td>'
    '<td align=left valign=top>' 
    htmlib-InputField("search",80,lc-search) '</td></tr>' 
            skip.
    {&out}
    '<tr>'
    '<td align=right valign=top>' htmlib-SideLabel("In Sections") '</td>'
    '<td align=left valign=top>' 
    htmlib-Select("knbcode",lc-code,lc-desc,lc-knbcode)
            skip.

    {&out}
    '<tr>'
    '<td align=right valign=top>' htmlib-SideLabel("Search In") '</td>'
    '<td align=left valign=top>' 
    htmlib-Select("type",lc-type-code,lc-type-desc,lc-type)
            skip.

    {&out} '</table>'.

    /*
    {&out} '<p>'
                'Method= ' request_method '<br>'
                'Search= ' lc-search '<br>'
                'First = ' lc-firstrow '<br>'
                'Last  = ' lc-lastrow '<br>'
                'Nav   = ' lc-navigation '<br>'
                'Sect  = ' lc-knbcode '<br>'
                'Type  = ' lc-type '<br>'
            '</p>'.
     */       
    {&out} '<center>' htmlib-SubmitButton("submitform","Search") 
    '</center>' skip.
    

    {&out} htmlib-EndCriteria().

    IF lc-search <> "" THEN
    DO:
        RUN ip-Search.
    END.
    ELSE 
        IF request_method = "post"
            THEN lc-error-mess = "You must select something to search for".

    

    IF lc-error-mess <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-mess) '</CENTER>' skip.
    END.

    {&out} htmlib-EndForm().

    
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fnText) = 0 &THEN

FUNCTION fnText RETURNS CHARACTER
    ( pf-knbid AS DECIMAL,
    pi-count AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER knbText  FOR knbText.  
    DEFINE VARIABLE li-count    AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-found    AS INTEGER NO-UNDO.
    DEFINE VARIABLE lc-return   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-char     AS CHARACTER NO-UNDO.

    FIND knbText WHERE knbText.knbID = pf-knbID
        AND knbText.dType = "I" NO-LOCK NO-ERROR.
    IF NOT AVAILABLE knbText THEN RETURN "&nbsp;".


    DO li-count = 1 TO NUM-ENTRIES(knbText.dData,"~n"):

        ASSIGN 
            lc-char = ENTRY(li-count,knbText.dData,"~n").
        IF TRIM(lc-char) = "" THEN NEXT.

       
        IF li-found = 0
            THEN ASSIGN lc-return = RIGHT-TRIM(lc-char).
        ELSE ASSIGN lc-return = lc-return + "<br>" + right-trim(lc-char).

        ASSIGN 
            li-found = li-found + 1.

        IF li-found = pi-count THEN LEAVE.

    END.

    RETURN lc-return.

END FUNCTION.


&ENDIF

