/***********************************************************************

    Program:        crm/view.p
   
    Purpose:        CRM View 
    
    Notes:
    
    
    When        Who         What
    16/10/2016  phoski      Initial
   
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url       AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lr-rowid          AS ROWID     NO-UNDO.

DEFINE VARIABLE lc-title          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitsource   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode           AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-Enc-Key        AS CHARACTER NO-UNDO.  

DEFINE VARIABLE lc-sela-Code      AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE lc-sela-Name      AS LONGCHAR  NO-UNDO.
    
DEFINE VARIABLE lc-selr-Code      AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE lc-selr-Name      AS LONGCHAR  NO-UNDO.

DEFINE VARIABLE lc-sels-code      AS CHARACTER NO-UNDO
    INITIAL 'b-query.Rating|b-query.createDate|b-query.op_no|b-qcust.name|b-qcust.salesmanager|b-query.nextstep|b-query.Probability' .
DEFINE VARIABLE lc-sels-name      AS CHARACTER NO-UNDO
    INITIAL 'Traffic Light|Date|Opportunity Number|Customer|Sales Rep|Next Step|Probability' .


DEFINE VARIABLE lc-crit-account   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crit-rep       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crit-status    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crit-type      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crit-sort      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crit-SortOrder AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SortOptions    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-OrderOptions   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-lodate         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-hidate         AS CHARACTER NO-UNDO.


DEFINE VARIABLE li-max-lines      AS INTEGER   INITIAL 12 NO-UNDO.
DEFINE VARIABLE lr-first-row      AS ROWID     NO-UNDO.
DEFINE VARIABLE lr-last-row       AS ROWID     NO-UNDO.
DEFINE VARIABLE li-count          AS INTEGER   NO-UNDO.
DEFINE VARIABLE ll-prev           AS LOG       NO-UNDO.
DEFINE VARIABLE ll-next           AS LOG       NO-UNDO.
DEFINE VARIABLE lc-search         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-smessage       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-otherp    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-char           AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-QPhrase        AS CHARACTER NO-UNDO.
DEFINE VARIABLE vhLBuffer1        AS HANDLE    NO-UNDO.
DEFINE VARIABLE vhLBuffer2        AS HANDLE    NO-UNDO.
DEFINE VARIABLE vhLQuery          AS HANDLE    NO-UNDO.


DEFINE BUFFER b-query FOR op_master.
DEFINE BUFFER b-qcust FOR Customer.

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

PROCEDURE ip-BuildQueryPhrase:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/


    ASSIGN
        lc-QPhrase = 
        "for each b-query NO-LOCK where b-query.CompanyCode = '" + string(lc-Global-Company) + "'".

    IF lc-crit-account <> "ALL" 
        THEN ASSIGN 
            lc-QPhrase = lc-QPhrase + " and b-query.accountNumber = '"  + lc-crit-account + "'".
         
    
    IF lc-crit-status <> "ALL"
        THEN ASSIGN 
            lc-QPhrase = lc-QPhrase + " and b-query.opstatus = '"  + lc-crit-status + "'".
        
    IF lc-crit-type <> "ALL"
        THEN ASSIGN 
            lc-QPhrase = lc-QPhrase + " and b-query.opType = '"  + lc-crit-type + "'".
                    
    ASSIGN 
        lc-QPhrase = lc-QPhrase + 
            " and b-query.CreateDate >= '" + string(DATE(lc-lodate)) + "' " + 
            " and b-query.CreateDate <= '" + string(DATE(lc-hidate)) + "' ".
                            
    ASSIGN 
        lc-QPhrase = lc-QPhrase  + " , first b-qcust NO-LOCK where b-qcust.companyCode = b-query.companycode and b-qcust.accountnumber = b-query.accountnumber".
        
    IF lc-crit-rep <> "ALL"
        THEN ASSIGN 
            lc-QPhrase = lc-QPhrase + " and b-qcust.SalesManager = '"  + lc-crit-rep + "'".   
       

    IF lc-crit-Sort <> "" THEN
    DO:
        ASSIGN 
            lc-QPhrase = lc-QPhrase  
                + " by " + lc-crit-Sort + " " + ( IF lc-crit-sortOrder = "ASC" THEN "" ELSE lc-crit-SortOrder ).
        ASSIGN 
            lc-QPhrase = lc-QPhrase + " by b-query.op_no DESC".

    END.

    
    lc-QPhrase = lc-QPhrase + ' INDEXED-REPOSITION'.


END PROCEDURE.

PROCEDURE ip-BuildTable:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/

    
    
    ASSIGN 
        li-count = 0
        lr-first-row = ?
        lr-last-row  = ?.

    REPEAT WHILE vhLBuffer1:AVAILABLE: 
        
        ASSIGN 
            lc-rowid = STRING(ROWID(b-query)).
           
        ASSIGN 
            li-count = li-count + 1.
        IF lr-first-row = ?
            THEN ASSIGN lr-first-row = ROWID(b-query).
        ASSIGN 
            lr-last-row = ROWID(b-query).
        
         {&out}
            skip
            tbar-tr(rowid(b-query))
            skip.
            
        {&out} '<td valign="top" align="right">' SKIP.
        
        IF b-query.Rating = "COLD"
        THEN {&out} '&nbsp;' SKIP.
        ELSE
         IF b-query.Rating = "WARM"
        THEN {&out} '<img src="/images/sla/warn.jpg" height="20" width="20" alt="WARM">' SKIP.
        ELSE
        IF b-query.Rating = "HOT"
        THEN {&out} '<img src="/images/sla/ok.jpg" height="20" width="20" alt="HOT">' SKIP.
        ELSE {&out} '&nbsp;' SKIP.
        
        {&out} '</td>' skip.
            
         {&out}   
            htmlib-MntTableField(html-encode(STRING(b-query.op_no)),'right')  
            
            htmlib-MntTableField(html-encode(STRING(b-query.createDate,"99/99/9999")),'left')  
            
            htmlib-MntTableField(html-encode(com-userName(b-qcust.SalesManager)),'left') 
            htmlib-MntTableField(html-encode(b-qcust.name),'left')   
            htmlib-MntTableField(html-encode(b-query.descr),'left')  
            
            htmlib-MntTableField(html-encode(com-DecodeLookup(b-query.opStatus,lc-global-opStatus-Code,lc-global-opStatus-Desc )),'left') 
            htmlib-MntTableField(html-encode(com-DecodeLookup(b-query.opType,lc-global-opType-Code,lc-global-opType-Desc )),'left') 
            htmlib-MntTableField(IF b-query.CloseDate = ? THEN "&nbsp;" ELSE STRING(b-query.closeDate,"99/99/9999"),'left')  
            htmlib-MntTableField(STRING(b-query.Probability) + "%","right")
            htmlib-MntTableField("&pound" + com-money(b-query.Revenue) ,"right")
            htmlib-MntTableField("&pound" + com-money(b-query.CostOfSale) ,"right")
            htmlib-MntTableField("&pound" + com-money(b-query.Revenue - b-query.CostOfSale) ,"right")
             
                      
            .    
            
            
        {&out} skip
                    tbar-BeginHidden(rowid(b-query)).
       
        {&out} tbar-Link("update",ROWID(b-query),appurl + '/' + "iss/issueframe.p",lc-link-otherp + "|firstrow=" + string(lr-firstrow)).
          
        {&out}
        tbar-EndHidden()
                skip
               '</tr>' skip.
                   
        IF li-count = li-max-lines THEN LEAVE.
     
        vhLQuery:GET-NEXT(NO-LOCK). 
            
 
    END.
    

END PROCEDURE.

PROCEDURE ip-ExportJS:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    {&out} lc-global-jquery  SKIP
           '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>'  skip
           '<script language="javascript">' SKIP
           'var appurl = "' appurl '";' SKIP.

    {&out} skip
        'function ChangeCriteria() ~{' skip
        '   SubmitThePage("ChangeCriteria")' skip
        '~}' SKIP
        'function ChangeDates() ~{' skip
        '   SubmitThePage("DatesChange")' skip
        '~}' skip
          
           '</script>' SKIP
                   
           '<script language="JavaScript" src="/asset/page/crm/view.js?v=1.0.0"></script>' SKIP
           
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

PROCEDURE ip-navigate:
/*------------------------------------------------------------------------------
		Purpose:  																	  
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

PROCEDURE ip-Selection:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE iloop       AS INTEGER      NO-UNDO.
    DEFINE VARIABLE cPart       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cCode       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cDesc       AS CHARACTER     NO-UNDO.
    
    {&out} htmlib-BeginCriteria("Search Opportunities").
    
     ASSIGN
        lc-OrderOptions = "DESC|Descending,ASC|Ascending".
        
   
    
    
    {&out} '<table align=center>' skip.
    
    {&out} '<tr><td align=right valign=top>' htmlib-SideLabel("Customer") 
    '</td><td align=left valign=top colspan=5>'.
  
    
    {&out-long}
    htmlib-SelectJSLong(
        "account",
        'ChangeCriteria()',
        "All|" + lc-sela-code,
        "All|" + lc-sela-name,
        lc-crit-account
        ) '</td></tr>'.
    
    IF glob-webuser.engType <> "SAL"
        THEN ASSIGN lc-selr-code = "ALL|" + lc-selr-code
            lc-selr-name = "All|" + lc-selr-name.
                
                
    {&out} '<tr><td align=right valign=top>' htmlib-SideLabel("Sales Rep") 
    '</td><td align=left valign=top>'.
    
    {&out-long}
    htmlib-SelectJSLong(
        "rep",
        'ChangeCriteria()',
        lc-selr-code,
        lc-selr-name,
        lc-crit-rep
        ) '</td>'.
        
        
    {&out} '<td align=right valign=top>' htmlib-SideLabel("Status") 
    '</td><td align=left valign=top>'
      
    htmlib-SelectJS("status",'ChangeCriteria()',"ALL|" + lc-global-opstatus-Code ,"All|" + lc-global-opStatus-desc,lc-crit-status).
             
    {&out} '</td><td align=right valign=top>' htmlib-SideLabel("Type") 
    '</td><td align=left valign=top>'
    
    
    htmlib-SelectJS("type",'ChangeCriteria()',"ALL|" + lc-global-opType-Code ,"All|" + lc-global-opType-desc,lc-crit-Type).
    
    {&out} '</td></tr><tr>' SKIP.
    {&out} 
    '<td valign="top" align="right">' 
        (IF LOOKUP("lodate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("From Date")
        ELSE htmlib-SideLabel("From Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("lodate",10,lc-lodate) 
    htmlib-CalendarLink("lodate")
    '</td>' SKIP.
    {&out} '<td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To Date")
        ELSE htmlib-SideLabel("To Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("hidate",10,lc-hidate) 
    htmlib-CalendarLink("hidate")
    '</td>' skip.
    
    {&out} '</td><td align=right valign=top>' htmlib-SideLabel("Sort") 
    '</td><td align=left valign=top>'
    
    
    htmlib-SelectJS("sort",'ChangeCriteria()',lc-sels-code, lc-sels-name,lc-crit-sort)
    .
    
    {&out} '<br/>' 
    '<select name="sortorder" class="inputfield" onChange="ChangeCriteria()">' 
         SKIP.
    DO iloop = 1 TO NUM-ENTRIES(lc-orderOptions):
        cPart = ENTRY(iloop,lc-OrderOptions).
        cCode = ENTRY(1,cPart,"|").
        cDesc = ENTRY(2,cPart,"|").

        {&out}
        '<option value="' cCode '" ' 
        IF lc-Crit-SortOrder = cCode
            THEN "selected" 
        ELSE "" '>' html-encode(cDesc) '</option>' skip.

              
  
     END.
    {&out} '</select></td></tr>'.
    

   

       
    {&out} '</table>' htmlib-EndCriteria() '<br />'.
      
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
        lc-firstrow    = get-value("firstrow")
        lc-lastrow     = get-value("lastrow")
        lc-navigation  = get-value("navigation")
        lc-submitSource = get-value("submitsource")
        lc-crit-account = get-value("account")
        lc-crit-rep     = get-value("rep")
        lc-crit-status = get-value("status")
        lc-crit-type = get-value("type")
        lc-lodate      = get-value("lodate")         
        lc-hidate      = get-value("hidate")
        lc-crit-sort   = get-value("sort")
        lc-crit-SortOrder   = get-value("sortorder")
        .

                                    
         
    RUN crm/lib/getCustomerList.p ( lc-global-company, lc-global-user, OUTPUT lc-sela-Code, OUTPUT lc-sela-Name).
    RUN crm/lib/getRepList.p ( lc-global-company, lc-global-user, OUTPUT lc-selr-Code, OUTPUT lc-selr-Name).
        
    IF glob-webuser.engType = "SAL"
        THEN lc-crit-rep = lc-global-user.
        
    IF request_method = "POST" THEN
    DO:
                        
                        
    END.
        
    IF request_method = "GET" THEN
    DO:
        IF glob-webuser.engType = "SAL"
        THEN lc-crit-rep = lc-global-user.
        ELSE lc-crit-rep = "ALL".
        
        IF lc-crit-status = ""
            THEN lc-crit-status = "OP".  
        IF lc-lodate = ""
            THEN ASSIGN lc-lodate = STRING(TODAY - 365, "99/99/9999").

        IF lc-hidate = ""
            THEN ASSIGN lc-hidate = STRING(TODAY, "99/99/9999").
            
        IF lc-crit-sort = ""
            THEN lc-crit-sort = ENTRY(1,lc-sels-code,"|").  
        IF lc-crit-type = ""
            THEN lc-crit-type = "ALL".
            
        IF lc-crit-account= ""
        THEN lc-crit-account = "ALL".    
        
    
        IF  lc-crit-sortOrder = "" THEN lc-crit-SortOrder = "ASC".
              
        
    END.
            
     ASSIGN 
         lc-link-otherp = 'source=crmview' +
                          '&filteroptions=' + 
                          '|search=' + lc-search +
                          '|account=' + lc-crit-account + 
                             '|status=' + lc-crit-status + 
                             '|rep=' + lc-crit-rep + 
                             '|type=' + lc-crit-type + 
                             '|status=' + lc-crit-status +
                             '|lodate=' + lc-lodate +     
                             '|hidate=' + lc-hidate +
                             '|sort=' + lc-crit-Sort + 
                             '|sortorder=' + lc-crit-SortOrder 
                                .
                                
    RUN outputHeader.
    
    
    {&out} htmlib-Header("CRM Opportunities") skip.
    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.
    RUN ip-ExportJS.
    
    {&out} htmlib-StartForm("mainform","post", appurl + '/crm/view.p' ) SKIP
           htmlib-ProgramTitle("CRM Opportunities") skip
           htmlib-hidden("submitsource","") skip.
    RUN ip-Selection.
    {&out} htmlib-CalendarScript("lodate") skip
            htmlib-CalendarScript("hidate") skip.
     
     MESSAGE "link = "   lc-link-otherp " f=" STRING(lr-first-row)
     .    
    
    {&out}
        tbar-Begin(
        REPLACE(tbar-FindLabelIssue(appurl + "/crm/view.p","Search Opportunity Number/Description"),"IssueButtonPress","crmButton")
        )
        tbar-Link("add",?,appurl +  "/crm/view.p",lc-link-otherp)
        
        tbar-BeginOption()
        tbar-Link("update",?,"off",lc-link-otherp)
        tbar-EndOption() 
        tbar-End().
    
    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="100%"') skip
           htmlib-TableHeading(
            "Rating^right|Opportunity Number^right|Date|Sales Rep|Customer|Description|Status|Type|Close Date|Probabilty^right|Revenue^right|Cost^right|GP Profit^right"
            ) skip.
            
    RUN ip-BuildQueryPhrase.
     
      
    CREATE QUERY vhLQuery  
        ASSIGN 
        CACHE = 100 .

    vhLBuffer1 = BUFFER b-query:HANDLE.
    vhLBuffer2 = BUFFER b-qcust:HANDLE.

    vhLQuery:SET-BUFFERS(vhLBuffer1,vhLBuffer2).
    MESSAGE "Q = " lc-qPhrase.
    
    vhLQuery:QUERY-PREPARE(lc-QPhrase).
    vhLQuery:QUERY-OPEN().

    /*
    DYNAMIC-FUNCTION("com-WriteQueryInfo",vhlQuery).
    */
 
    vhLQuery:GET-FIRST(NO-LOCK).
    
    RUN ip-navigate.
    
    RUN ip-BuildTable.
    
    {&out} skip 
           htmlib-EndTable()
           skip.
           
    {lib/crmviewpanel.i "crm/view.p"}
    {&out} skip
           htmlib-Hidden("firstrow", string(lr-first-row)) skip
           htmlib-Hidden("lastrow", string(lr-last-row)) skip
           skip.
           
    {&OUT}  htmlib-EndForm() SKIP
            htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

