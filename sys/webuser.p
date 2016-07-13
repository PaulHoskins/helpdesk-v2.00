/***********************************************************************

    Program:        sys/webuser.p
    
    Purpose:        User Maintenance - Browser   
    
    Notes:
    
    
    When        Who         What
    09/04/2006  phoski      Contractor link to accounts
    10/04/2006  phoski      Company Code
    11/04/2006  phoski      Show customer for CUSTOMER type users
    13/06/2014  phoski      Various for UX
    26/09/2014  phoski      Disabled Features
    20/11/2014  phoski      Pass thru 'selacc' field to mnt page
    27/11/2014  phoski      Working Hours page & changes
    25/06/2015  phoski      Shorten account/user type width to stop 
                            overflow on toolbar
    03/07/2016  phoski      Show Mobile Number                        
    

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
DEFINE VARIABLE lc-ContactInfo AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-QPhrase     AS CHARACTER NO-UNDO.
DEFINE VARIABLE vhLBuffer      AS HANDLE    NO-UNDO.
DEFINE VARIABLE vhLQuery       AS HANDLE    NO-UNDO.


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


FUNCTION fnToolbarYearSelection RETURNS CHARACTER 
    (  ) FORWARD.

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
    
            IF NOT AVAILABLE b-query THEN vhLQuery:GET-FIRST(NO-LOCK).
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
                IF NOT AVAILABLE b-query THEN vhLQuery:GET-FIRST(NO-LOCK).
            END.
        END.
        ELSE
            IF lc-navigation = "refresh" THEN
            DO:
                vhLQuery:REPOSITION-TO-ROWID(TO-ROWID(lc-firstrow)) NO-ERROR.
                IF ERROR-STATUS:ERROR = FALSE THEN
                DO:
                    vhLQuery:GET-NEXT(NO-LOCK).
                    IF NOT AVAILABLE b-query THEN vhLQuery:GET-FIRST(NO-LOCK).
                END.  
                ELSE vhLQuery:GET-FIRST(NO-LOCK).
            END.
            ELSE 
                IF lc-navigation = "lastpage" THEN
                DO:
                    vhLQuery:GET-LAST(NO-LOCK).
                    vhLQuery:reposition-backwards(li-max-lines).
                    vhLQuery:GET-NEXT(NO-LOCK).
                    IF NOT AVAILABLE b-query THEN vhLQuery:GET-FIRST(NO-LOCK).
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

    {lib/checkloggedin.i}

    ASSIGN 
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation")
        lc-selacc     = get-value("selacc").
        
    IF get-value("submityear") = ""
        THEN set-user-field("submityear",STRING(YEAR(TODAY),"9999")).
    
    
    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow +
                           "&selacc=" + lc-selacc.

    
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
    
    {&out} htmlib-Header("Maintain Users") skip.

    {&out} htmlib-JScript-Maintenance() skip.
    RUN ip-ExportJScript.

    {&out} htmlib-StartForm("mainform","post", appurl + '/sys/webuser.p' ) skip.

    {&out} htmlib-ProgramTitle("Maintain Users") skip
           htmlib-hidden("submitsource","") skip.
    
  
    {&out}
    tbar-Begin(
        DYNAMIC-FUNCTION('fnToolbarYearSelection')
        + '&nbsp;' + 
        DYNAMIC-FUNCTION('fnToolbarAccountSelection':U) 
        + 
        tbar-FindLabel(appurl + "/sys/webuser.p","Find Name")
        )
    tbar-Link("add",?,appurl + '/' + "sys/webusermnt.p",lc-link-otherp)
    tbar-BeginOption()
    tbar-Link("view",?,"off",'')
    tbar-Link("update",?,"off",'')
    tbar-Link("delete",?,"off",'')
    tbar-Link("genpassword",?,"off",'')
    tbar-Link("contaccess",?,"off",'')
    tbar-Link("wrk-hr",?,"off",'')
    tbar-Link("conttime",?,"off",'')
    tbar-EndOption()
    tbar-End().

    {&out} skip
           htmlib-StartMntTable().

    {&out}
    htmlib-TableHeading(
        "User Name^left|Name^left|Customer|Email<br/>Mobile^left|Last Password Change^left|Last Login^left|Disabled?"
        ) skip.

    lc-QPhrase = 
        "for each b-query NO-LOCK where b-query.CompanyCode = '" + string(lc-Global-Company) + "'".

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


     
    IF lc-search <> "" THEN
    DO:
        ASSIGN
            lc-qPhrase = lc-qphrase + " and b-query.name contains '" + lc-search + "'".
    END.

    lc-QPhrase = lc-QPhrase + ' INDEXED-REPOSITION'.
    
    CREATE QUERY vhLQuery.

    vhLBuffer = BUFFER b-query:handle.

    vhLQuery:SET-BUFFERS(vhLBuffer).
    vhLQuery:QUERY-PREPARE(lc-QPhrase).
    vhLQuery:QUERY-OPEN().


    vhLQuery:GET-FIRST(NO-LOCK).

    RUN ip-navigate.


    ASSIGN 
        li-count = 0
        lr-first-row = ?
        lr-last-row  = ?.

    REPEAT WHILE vhLBuffer:AVAILABLE: 

        
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
            THEN ASSIGN lr-first-row = ROWID(b-query).
        ASSIGN 
            lr-last-row = ROWID(b-query).
        
        ASSIGN 
            lc-link-otherp = 'search=' + lc-search +
                             '&firstrow=' + string(lr-first-row) +
                             "&selacc=" + lc-selacc +
                             "&submityear=" + get-value("submityear")
            .
                                
                                

        IF b-query.LastDate <> ? 
            THEN ASSIGN lc-LastLogin = STRING(b-query.LastDate,'99/99/9999') + ' ' + string(b-query.LastTime,'hh:mm').
        ELSE ASSIGN lc-lastlogin = "".
        
        IF b-query.LastPasswordChange <> ?
            THEN lc-LastPass = STRING(b-query.LastPasswordChange,'99/99/9999').
        ELSE lc-LastPass = "".
        
        ASSIGN 
            lc-nopass = IF b-query.passwd = ""
                           OR b-query.passwd = ?
                           THEN " (No password)"
                           ELSE "".
        IF b-query.Disabled AND b-query.AutoDisableTime <> ? THEN
        DO:
            lc-nopass = ' ' + TRIM(lc-nopass + ' ' + string(b-query.AutoDisableTime,"99/99/9999 hh:mm")).
        END.     
        ASSIGN
         lc-contactInfo = b-query.email.
         IF b-query.Mobile <> "" THEN
         DO:
             IF lc-contactInfo = ""
             THEN lc-contactinfo = b-query.mobile.
             ELSE lc-contactinfo = lc-contactInfo + "<br/>" + b-query.mobile.
         END.
         
                      
        {&out}
            skip
            tbar-tr(rowid(b-query))
            skip
            htmlib-MntTableField(html-encode(b-query.loginid),'left')
            htmlib-MntTableField(html-encode(b-query.name),'left')
            htmlib-MntTableField(html-encode(lc-CustomerInfo),'left')
            htmlib-MntTableField(lc-contactInfo,'left')
            htmlib-MntTableField(html-encode(lc-lastPass),'left')
            htmlib-MntTableField(html-encode(lc-lastLogin),'left')
            htmlib-MntTableField(html-encode((if b-query.disabled = true
                                          then 'Yes' else 'No') + lc-nopass),'left') skip

            tbar-BeginHidden(rowid(b-query))
                tbar-Link("view",rowid(b-query),appurl + '/' + "sys/webusermnt.p",lc-link-otherp)
                tbar-Link("update",rowid(b-query),appurl + '/' + "sys/webusermnt.p",lc-link-otherp)
                tbar-Link("delete",rowid(b-query),
                          if DYNAMIC-FUNCTION('com-CanDelete':U,lc-user,"webuser",rowid(b-query))
                          then ( appurl + '/' + "sys/webusermnt.p") else "off",
                          lc-link-otherp)
                tbar-Link("genpassword",rowid(b-query),appurl + '/' + "sys/webusergen.p","customer=" + 
                                                string(rowid(b-query)) 
                                                )
                tbar-Link("contaccess",rowid(b-query),
                              if b-query.UserClass = "CONTRACT"
                              then ( appurl + '/' + "sys/webcontaccess.p") else "off",lc-link-otherp)
                tbar-Link("wrk-hr",rowid(b-query),
                              if b-query.UserClass = "INTERNAL"
                              then ( appurl + '/' + "sys/webwrkhour.p") else "off",lc-link-otherp)

                tbar-Link("conttime",rowid(b-query),
                              if b-query.UserClass = "INTERNAL"
                              then ( appurl + '/' + "sys/webconttime.p") else "off",lc-link-otherp)
            tbar-EndHidden()
            '</tr>' skip.

       

        IF li-count = li-max-lines THEN LEAVE.


       
        vhLQuery:GET-NEXT(NO-LOCK). 

            
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


    {&out}  '<tr><td align="left">'.


    IF lr-first-row <> ? THEN
    DO:
        vhLQuery:GET-FIRST(NO-LOCK). 
       
        IF ROWID(b-query) = lr-first-row 
            THEN ASSIGN ll-prev = FALSE.
        ELSE ASSIGN ll-prev = TRUE.

        
        vhLQuery:GET-LAST(NO-LOCK). 

        IF ROWID(b-query) = lr-last-row
            THEN ASSIGN ll-next = FALSE.
        ELSE ASSIGN ll-next = TRUE.

        IF ll-prev 
            THEN {&out} htmlib-MntButton(appurl + '/' + "sys/webuser.p","PrevPage","Prev Page").


        IF ll-next 
            THEN {&out} htmlib-MntButton(appurl + '/' + "sys/webuser.p","NextPage","Next Page").

        IF NOT ll-prev
            AND NOT ll-next 
            THEN {&out} "&nbsp;".


    END.
    ELSE {&out} "&nbsp;".

    {&out} '</td><td align="right">' htmlib-ErrorMessage(lc-smessage)
    '</td></tr>'.

    {&out} htmlib-EndPanel().

     
    {&out} skip
           htmlib-Hidden("firstrow", string(lr-first-row)) skip
           htmlib-Hidden("lastrow", string(lr-last-row)) skip
           skip.
    {&out} 
    '<div id="urlinfo">|selacc=' lc-selacc  '</div>' skip.
    
    
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
            lc-names = lc-names + "|" + trim(substr(customer.NAME,1,30)).

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

FUNCTION fnToolbarYearSelection RETURNS CHARACTER 
    (  ):

    DEFINE VARIABLE lc-return       AS CHARACTER     NO-UNDO.

    DEFINE VARIABLE lc-codes        AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-names        AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-this         AS CHARACTER     NO-UNDO.

    DEFINE BUFFER customer FOR customer.

    ASSIGN
        lc-codes = STRING(YEAR(TODAY) - 1,"9999") + "|" +
                   string(YEAR(TODAY),"9999") + "|" +
                   string(YEAR(TODAY) + 1,"9999") 
        lc-names = lc-codes
        lc-this  = get-value("submityear").
   
    

    lc-return =  htmlib-SelectJS(
        "submityear",
        'OptionChange(this)',
        lc-codes,
        lc-names,
        lc-this
        ).



    lc-return = "<b>Year:</b>" + lc-return + "&nbsp;".

    RETURN lc-return.


		
END FUNCTION.
