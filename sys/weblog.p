/***********************************************************************

    Program:        sys/weblog.p
    
    Purpose:        System log view
    
    Notes:
    
    
    When        Who         What
    05/10/2014  phoski      initial

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
DEFINE VARIABLE lc-selacc      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-LastLogin   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-LastPass    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-QPhrase     AS CHARACTER NO-UNDO.
DEFINE VARIABLE vhLBuffer1     AS HANDLE    NO-UNDO.
DEFINE VARIABLE vhLBuffer2     AS HANDLE    NO-UNDO.
DEFINE VARIABLE vhLQuery       AS HANDLE    NO-UNDO.
DEFINE VARIABLE lc-lodate      AS CHARACTER FORMAT "99/99/9999" NO-UNDO.


DEFINE BUFFER b-query  FOR webuser.
DEFINE BUFFER b-search FOR webuser.


/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fnToolbarAccountSelection) = 0 &THEN

FUNCTION fnToolbarAccountSelection RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


&ENDIF


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

&IF DEFINED(EXCLUDE-ip-ExportJScript) = 0 &THEN

PROCEDURE ip-ExportJScript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out}
    '<script language="JavaScript" src="/scripts/js/menu.js"></script>' skip
        '<script language="JavaScript" src="/scripts/js/prototype.js"></script>' skip
        '<script language="JavaScript" src="/scripts/js/scriptaculous.js"></script>' skip
    .

    {&out} skip
            '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' skip.

    {&out} skip 
          '<script language="JavaScript">' skip.

    {&out} skip
        'function OptionChange(obj) ~{' skip
        '   SubmitThePage("selection");' SKIP
        '~}' SKIP
        'function ChangeDates() ~{' SKIP
        '   SubmitThePage("DatesChange")' skip
        '~}' skip.
        
        

    {&out} skip
           '</script>' skip.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-navigate) = 0 &THEN

PROCEDURE ip-navigate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
  
    IF lc-navigation = "nextpage" THEN
    DO:
        vhLQuery:REPOSITION-TO-ROWID(TO-ROWID(lc-lastrow)) .
        IF ERROR-STATUS:ERROR = FALSE THEN
        DO:
            vhLQuery:GET-NEXT(NO-LOCK).
            vhLQuery:GET-NEXT(NO-LOCK).
    
            IF NOT AVAILABLE SysAct THEN vhLQuery:GET-FIRST(NO-LOCK).
        END.
    END.
    ELSE
        IF lc-navigation = "prevpage" THEN
        DO:
            vhLQuery:REPOSITION-TO-ROWID(TO-ROWID(lc-firstrow)) NO-ERROR.
            IF ERROR-STATUS:ERROR = FALSE THEN
            DO:
                vhLQuery:GET-NEXT(NO-LOCK).
                vhLQuery:reposition-backwards(li-max-lines + 1). 
                vhLQuery:GET-NEXT(NO-LOCK).
                IF NOT AVAILABLE Sysact THEN vhLQuery:GET-FIRST(NO-LOCK).
            END.
        END.
        ELSE
            IF lc-navigation = "refresh" THEN
            DO:
                vhLQuery:REPOSITION-TO-ROWID(TO-ROWID(lc-firstrow)) NO-ERROR.
                IF ERROR-STATUS:ERROR = FALSE THEN
                DO:
                    vhLQuery:GET-NEXT(NO-LOCK).
                    IF NOT AVAILABLE sysAct THEN vhLQuery:GET-FIRST(NO-LOCK).
                END.  
                ELSE vhLQuery:GET-FIRST(NO-LOCK).
            END.
            ELSE 
                IF lc-navigation = "lastpage" THEN
                DO:
                    vhLQuery:GET-LAST(NO-LOCK).
                    vhLQuery:reposition-backwards(li-max-lines).
                    vhLQuery:GET-NEXT(NO-LOCK).
                    IF NOT AVAILABLE Sysact THEN vhLQuery:GET-FIRST(NO-LOCK).
                END.

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
  
    DEFINE VARIABLE lc-CustomerInfo     AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE ld-date             AS DATE              NO-UNDO.
    

    {lib/checkloggedin.i}

    ASSIGN 
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation")
        lc-lodate      = get-value("lodate")  
        lc-selacc     = get-value("selacc").
   
    
    ld-date = DATE(lc-lodate) NO-ERROR.
    IF ld-date = ?
    OR ERROR-STATUS:ERROR 
    THEN ASSIGN lc-lodate = "".
    ELSE ASSIGN lc-lodate = STRING(ld-date,"99/99/9999").
    
    
    
    
    ASSIGN 
        lc-parameters = "search=" + lc-search +
                        "&firstrow=" + lc-firstrow + 
                        "&lastrow=" + lc-lastrow +
                        "&selacc=" + lc-selacc + 
                        "&lodate=" + lc-lodate.

  
      
    ASSIGN
        lc-link-otherp = lc-parameters.

    
    ASSIGN 
        lc-char = htmlib-GetAttr('system','MNTNoLinesDown').
    
    ASSIGN 
        li-max-lines = int(lc-char) no-error.
    IF ERROR-STATUS:ERROR
        OR li-max-lines < 1
        OR li-max-lines = ? THEN li-max-lines = 12.


    RUN outputHeader.
    
    {&out} htmlib-Header("System Log") skip.
    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.
    
    {&out} htmlib-JScript-Maintenance() skip.
    RUN ip-ExportJScript.

    {&out} htmlib-StartForm("mainform","post", appurl + '/sys/weblog.p' ) skip.

    {&out} htmlib-ProgramTitle("System Log") skip
           htmlib-hidden("submitsource","") skip.
    
    {&out}
    tbar-Begin(
    
        DYNAMIC-FUNCTION('fnToolbarAccountSelection':U) 
        + 
        tbar-FindLabel(appurl + "/sys/weblog.p","Find User Name")
        + "<b>From:</b> " + htmlib-CalendarInputField("lodate",10,lc-lodate) 
        + htmlib-CalendarLink("lodate")
      
        )
   
    
    tbar-BeginOption()
  
    tbar-EndOption()
    tbar-End().

    {&out} skip
           htmlib-StartMntTable().

    {&out}
    htmlib-TableHeading(
        "Date|Action|Other Info|User Name^left|Name^left|Customer"
        ) skip.


    lc-qPhrase = "for each SysAct no-lock use-index Activity ".
    IF ld-date <> ? 
    THEN lc-qphrase = lc-qphrase + ' where sysact.actDate >= ' + lc-lodate.
    
    IF lc-search <> "" THEN
    DO:
        IF ld-date <> ?
        THEN lc-qphrase = lc-qphrase + " and ".
        ELSE lc-qphrase = lc-qphrase + " where ".
        ASSIGN
            lc-qPhrase = lc-qphrase + "  SysAct.Loginid begins '" + lc-search + "'".
    END.
    
    
    
    lc-QPhrase = lc-qPhrase +
        " , FIRST b-query NO-LOCK where b-query.loginid = Sysact.LoginId and b-query.CompanyCode = '" + string(lc-Global-Company) + "'".

    IF lc-selacc <> "" THEN
    DO:
        IF lc-selacc = "INTERNAL"
            THEN ASSIGN 
                lc-qPhrase = lc-qphrase + " and b-query.AccountNumber = ''".
        ELSE
            IF lc-selacc = "ALLC"
                THEN ASSIGN 
                    lc-qPhrase = lc-qphrase + " and b-query.AccountNumber > ''".
            ELSE ASSIGN 
                    lc-qPhrase = lc-qphrase + " and b-query.AccountNumber = '" + lc-selacc + "'".
    END.


     
    
    lc-QPhrase = lc-QPhrase + ' INDEXED-REPOSITION'.
    
    CREATE QUERY vhLQuery.

    vhLBuffer1 = BUFFER SysAct:HANDLE.
    vhLBuffer2 = BUFFER b-query:handle.

    vhLQuery:SET-BUFFERS(vhLBuffer1,vhlBuffer2).
    vhLQuery:QUERY-PREPARE(lc-QPhrase).
    vhLQuery:QUERY-OPEN().
    /*
    DYNAMIC-FUNCTION("com-WriteQueryInfo",vhlQuery).
    */
    
    vhLQuery:GET-FIRST(NO-LOCK).

    RUN ip-navigate.


    ASSIGN 
        li-count = 0
        lr-first-row = ?
        lr-last-row  = ?.

    REPEAT WHILE vhLBuffer1:AVAILABLE: 

        
        ASSIGN
            lc-CustomerInfo = DYNAMIC-FUNCTION("com-UsersCompany",
                                               b-query.LoginID).
        
        IF lc-CustomerInfo <> ""
            THEN ASSIGN lc-customerInfo = b-query.AccountNumber + " " +
                                      lc-CustomerInfo.

        ASSIGN 
            lc-rowid = STRING(ROWID(b-query)).
        
        ASSIGN 
            li-count = li-count + 1.
        IF lr-first-row = ?
            THEN ASSIGN lr-first-row = ROWID(SysAct).
        ASSIGN 
            lr-last-row = ROWID(SysAct).
        
        ASSIGN 
            lc-link-otherp = 'search=' + lc-search +
                             '&firstrow=' + string(lr-first-row).

                   
        {&out}
            skip
            tbar-tr(rowid(SysAct))
            SKIP
            
            htmlib-MntTableField(string(SysAct.ActDate,"99/99/9999") + 
                                 ' ' + string(SysAct.ActTime,"hh:mm:ss") ,'left')
            
            htmlib-MntTableField(html-encode(SysAct.ActType),'left')
            htmlib-MntTableField(html-encode(SysAct.AttrData),'left')
            
            htmlib-MntTableField(html-encode(b-query.loginid),'left')
            htmlib-MntTableField(html-encode(b-query.name),'left')
            htmlib-MntTableField(html-encode(lc-CustomerInfo),'left')

             
            tbar-BeginHidden(rowid(SysAct))
           
            
            tbar-EndHidden()
            '</tr>' skip.

       

        IF li-count = li-max-lines THEN LEAVE.


       
        vhLQuery:GET-NEXT(NO-LOCK). 

            
    END.


    {&out} skip 
           htmlib-EndTable()
           skip.

   
    {&out} htmlib-StartPanel() 
            skip.


    {&out}  '<tr><td align="left">'.


    IF lr-first-row <> ? THEN
    DO:
        vhLQuery:GET-FIRST(NO-LOCK). 
       
        IF ROWID(SysAct) = lr-first-row 
            THEN ASSIGN ll-prev = FALSE.
        ELSE ASSIGN ll-prev = TRUE.

        
        vhLQuery:GET-LAST(NO-LOCK). 

        IF ROWID(SysAct) = lr-last-row
            THEN ASSIGN ll-next = FALSE.
        ELSE ASSIGN ll-next = TRUE.

        IF ll-prev 
            THEN {&out} htmlib-MntButton(appurl + '/' + "sys/weblog.p","PrevPage","Prev Page").


        IF ll-next 
            THEN {&out} htmlib-MntButton(appurl + '/' + "sys/weblog.p","NextPage","Next Page").

        IF NOT ll-prev
            AND NOT ll-next 
            THEN {&out} "&nbsp;".


    END.
    ELSE {&out} "&nbsp;".

    IF lr-first-row = ? THEN lc-smessage = "No Data Found".
    {&out} '</td><td align="right">' htmlib-ErrorMessage(lc-smessage)
    '</td></tr>'.

     
    {&out} htmlib-EndPanel().
   
    
    {&out} skip
           htmlib-Hidden("firstrow", string(lr-first-row)) skip
           htmlib-Hidden("lastrow", string(lr-last-row)) skip
           skip.

    {&out} 
    '<div id="urlinfo">|selacc=' lc-selacc  '|lodate=' lc-lodate '</div>' skip.
    {&out} htmlib-CalendarScript("lodate") SKIP.
    
    
    
    {&out} htmlib-EndForm().

    
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fnToolbarAccountSelection) = 0 &THEN

FUNCTION fnToolbarAccountSelection RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    
    DEFINE VARIABLE lc-return       AS CHARACTER     NO-UNDO.

    DEFINE VARIABLE lc-codes        AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-names        AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-this         AS CHARACTER     NO-UNDO.

    DEFINE BUFFER customer FOR customer.

    ASSIGN
        lc-codes = "|INTERNAL|ALLC"
        lc-names = "All Users|Internal Users|All Customer Users"
        lc-this  = get-value("selacc").
   
    FOR EACH customer NO-LOCK
        WHERE customer.companyCode = lc-global-company
        BY customer.NAME:
        ASSIGN 
            lc-codes = lc-codes + "|" + customer.AccountNumber
            lc-names = lc-names + "|" + trim(substr(customer.NAME,1,40)).

    END.

    lc-return =  htmlib-SelectJS(
        "selacc",
        'OptionChange(this)',
        lc-codes,
        lc-names,
        lc-this
        ).



    lc-return = "<b>Account/User Type:</b>" + lc-return + "&nbsp;".

    RETURN lc-return.

END FUNCTION.


&ENDIF

