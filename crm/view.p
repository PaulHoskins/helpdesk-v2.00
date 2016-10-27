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


DEFINE TEMP-TABLE tt-sum NO-UNDO
    FIELD dType AS CHARACTER 
    FIELD key   AS CHARACTER
    FIELD dKey  AS CHARACTER 
    FIELD cnt   AS INTEGER
    FIELD rev   AS DECIMAL
    FIELD cost  AS DECIMAL
    INDEX dtype dtype KEY
    INDEX ddisp dtype dkey.
    
DEFINE BUFFER b-query FOR op_master.
DEFINE BUFFER b-qcust FOR Customer.

/* ********************  Preprocessor Definitions  ******************** */

FUNCTION CreateSummaryRecord RETURNS LOGICAL 
    (pc-dType AS CHARACTER,
    pc-key AS CHARACTER) FORWARD.

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
{lib/replib.i}



 




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
    DEFINE VARIABLE li-int          AS INTEGER NO-UNDO.
    

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
            " and b-query.CrtDate >= " + string(DATE(lc-lodate)) + " " + 
            " and b-query.CrtDate <= " + string(DATE(lc-hidate)) + " ".
            
    IF lc-search <> "" THEN
    DO:
        ASSIGN 
            li-int = int(lc-search) no-error.
        IF ERROR-STATUS:ERROR 
            THEN ASSIGN 
                lc-QPhrase = lc-QPhrase +  " and b-query.descr contains '" + lc-search + "'".
        ELSE ASSIGN 
                lc-QPhrase = lc-QPhrase +  " and b-query.op_no >= " + string(li-int).
            
    END.         
                            
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

PROCEDURE ip-BuildSummaryTable:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-width AS CHARACTER INITIAL 'width="100%"' NO-UNDO.
    
    {&out} SKIP
            '<br/><div class="infobox">Summary</div>' SKIP.
   
    {&out} REPLACE(htmlib-StartMntTable(),'width="100%"','') SKIP.
           
    {&out} '<tr>' SKIP.
                     
    {&out} '<td valign="top">'                
    REPLACE(htmlib-StartMntTable(),'width="100%"',lc-width) skip
               htmlib-TableHeading("Sales Rep|Opportunities^right|Revenue^right|Cost^right|GP Profit^right") skip.
            
    
    RUN ip-BuildSpecificSummaryTable("REP").
    
    {&out} skip 
            htmlib-EndTable()
            '</td>'
           skip.
           
    {&out} '<td valign="top">'                
    REPLACE(htmlib-StartMntTable(),'width="100%"',lc-width) skip
               htmlib-TableHeading("Status|Opportunities^right|Revenue^right|Cost^right|GP Profit^right") skip.
            
    
    RUN ip-BuildSpecificSummaryTable("STATUS").
    
    {&out} skip 
            htmlib-EndTable()
            '</td>'
           skip.
           
    {&out} '</tr>'.   
    {&out} '<tr>' SKIP.
                     
    {&out} '<td valign="top">'                
    REPLACE(htmlib-StartMntTable(),'width="100%"',lc-width) skip
               htmlib-TableHeading("Type|Opportunities^right|Revenue^right|Cost^right|GP Profit^right") skip.
            
    
    RUN ip-BuildSpecificSummaryTable("Type").
    
    {&out} skip 
            htmlib-EndTable()
            '</td>'
           skip.
           
    {&out} '<td valign="top">'                
    REPLACE(htmlib-StartMntTable(),'width="100%"',lc-width) skip
               htmlib-TableHeading("Next Step|Opportunities^right|Revenue^right|Cost^right|GP Profit^right") skip.
            
    
    RUN ip-BuildSpecificSummaryTable("NEXT").
    
    {&out} skip 
            htmlib-EndTable()
            '</td>'
           skip.
           
    {&out} '</tr>'.       
    
    {&out} '<tr><td valign="top" colspan=2>'                
    REPLACE(htmlib-StartMntTable(),'width="100%"',lc-width) skip
               htmlib-TableHeading("Customer|Opportunities^right|Revenue^right|Cost^right|GP Profit^right") skip.
            
    
    RUN ip-BuildSpecificSummaryTable("Customer").
    
    {&out} skip 
            htmlib-EndTable()
            '</td>'
           skip.
           
    {&out} '</tr>'. 
                

    {&out} skip 
            htmlib-EndTable()
    .

END PROCEDURE.

PROCEDURE ip-BuildSpecificSummaryTable:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER pc-dtype     AS CHARACTER NO-UNDO.
    

    DEFINE VARIABLE lf-cost     AS DECIMAL NO-UNDO.
    DEFINE VARIABLE lf-rev      AS DECIMAL NO-UNDO.
    DEFINE VARIABLE li-cnt      AS INTEGER NO-UNDO.
    
               
    ASSIGN
        li-cnt = 0
        lf-rev = 0
        lf-cost = 0.
                
    FOR EACH tt-sum NO-LOCK WHERE tt-sum.dtype = pc-dtype BY tt-sum.dkey:
        {&out} '<tr>' SKIP
        replib-RepField(html-encode(com-userName(tt-sum.dkey)),'left','') 
        replib-RepField(STRING(tt-sum.cnt),"right",'')
        replib-RepField("&pound" + com-money(tt-sum.Rev) ,"right",'')
        replib-RepField("&pound" + com-money(tt-sum.cost) ,"right",'')
        replib-RepField("&pound" + com-money(tt-sum.rev - tt-sum.Cost) ,"right",'')
            '</tr>' SKIP.
        
        ASSIGN 
            li-cnt = li-cnt + tt-sum.cnt
            lf-cost  = lf-cost + tt-sum.cost
            lf-rev = lf-rev + tt-sum.rev.
               

               
    END.  
     
    {&out} '<tr>'
    replib-RepField(html-encode("Total"),'left','') 
    replib-RepField(STRING(li-cnt),"right","border-top: 1px solid black;border-bottom: 1px solid black;")
    replib-RepField("&pound" + com-money(lf-Rev) ,"right","border-top: 1px solid black;border-bottom: 1px solid black;")
    replib-RepField("&pound" + com-money(lf-cost) ,"right","border-top: 1px solid black;border-bottom: 1px solid black;")
    replib-RepField("&pound" + com-money(lf-rev - lf-Cost) ,"right","border-top: 1px solid black;border-bottom: 1px solid black;")
    '</tr>' SKIP.
            

END PROCEDURE.

PROCEDURE ip-BuildTable:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    
    DEFINE VARIABLE lc-Enc-Key       AS CHARACTER NO-UNDO. 
    DEFINE VARIABLE lf-Amt           AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE lc-LastAct       AS CHARACTER NO-UNDO.

    ASSIGN 
        li-count = 0
        lr-first-row = ?
        lr-last-row  = ?.

    REPEAT WHILE vhLBuffer1:AVAILABLE: 
        
        
        ASSIGN 
            lc-enc-key =
                 DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(b-qcust))).
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
            
        ASSIGN
            lc-lastAct = "".
            
        FOR FIRST op_activity NO-LOCK
            WHERE op_activity.CompanyCode = b-query.CompanyCode
            AND op_activity.op_id = b-query.op_id
            BY op_activity.startDate DESCENDING
            BY op_activity.startTime DESCENDING:
   
            ASSIGN 
                lc-LastAct = STRING(op_activity.StartDate,"99/99/9999") + 
                    " " +
                   string(op_activity.StartTime,"hh:mm").
                   
            IF op_activity.activityType <> ""
                THEN ASSIGN lc-LastAct = lc-LastAct + " : " + op_activity.activityType + " - " + op_activity.Description.
                
                               
            LEAVE.
               
        END.
                       
        {&out}   
        htmlib-MntTableField(html-encode(STRING(b-query.op_no)),'right')  
            
        htmlib-MntTableField(html-encode(STRING(b-query.crtDate,"99/99/9999")),'left')  
            
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
        ASSIGN 
            lf-amt = ROUND(b-query.Revenue * (b-query.Probability / 100),2).       
         
        {&out} htmlib-MntTableField("&pound" + com-money(lf-amt) ,"right").  
         
        ASSIGN 
            lf-amt = ROUND(b-query.costofsale * (b-query.Probability / 100),2).       
         
        {&out} htmlib-MntTableField("&pound" + com-money(lf-amt) ,"right")
        htmlib-MntTableField(html-encode(com-GenTabDesc(b-query.companyCode,"CRM.NextStep",b-query.NextStep)),'left')  
        htmlib-MntTableField(html-encode(lc-lastAct),'left')  
            .
            
            
        {&out} skip
                    tbar-BeginHidden(rowid(b-query)).
                    
        {&out} tbar-Link("view",ROWID(b-query),appurl + "/crm/crmop.p","crmaccount=" + url-encode(lc-enc-key,"Query") + "&" + lc-link-otherp + "|firstrow^" + string(lr-first-row)).
        
        {&out} tbar-Link("update",ROWID(b-query),appurl + "/crm/crmop.p","crmaccount=" + url-encode(lc-enc-key,"Query") + "&" + lc-link-otherp + "|firstrow^" + string(lr-first-row)).
        IF glob-webuser.engType = "SAL"
            THEN {&out}  tbar-Link("delete",?,"off",lc-link-otherp).
        ELSE {&out}  tbar-Link("delete",ROWID(b-query),appurl + "/crm/crmop.p","crmaccount=" + url-encode(lc-enc-key,"Query") + "&" + lc-link-otherp + "|firstrow^" + string(lr-first-row)).
           
                  
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

PROCEDURE ip-GenerateSummary:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    EMPTY TEMP-TABLE tt-sum.
    
      
    vhLQuery:GET-FIRST(NO-LOCK).
    
    
    
    REPEAT WHILE vhLBuffer1:AVAILABLE: 
   
        CreateSummaryRecord("REP", b-qcust.SalesManager). 
        IF tt-sum.dKey = ""
            THEN tt-sum.dKey = com-userName(tt-sum.key).
        
        CreateSummaryRecord("STATUS", b-query.OpStatus). 
        IF tt-sum.dKey = ""
            THEN tt-sum.dKey = com-DecodeLookup(b-query.opStatus,lc-global-opStatus-Code,lc-global-opStatus-Desc ).
        
        CreateSummaryRecord("TYPE", b-query.OpType). 
        IF tt-sum.dKey = ""
            THEN tt-sum.dKey = com-DecodeLookup(b-query.opType,lc-global-opType-Code,lc-global-opType-Desc  ).
            
        CreateSummaryRecord("NEXT", b-query.NextStep).
        IF tt-sum.dKey = ""
            THEN tt-sum.dKey = com-GenTabDesc(b-query.companyCode,"CRM.NextStep",b-query.NextStep).
           
        CreateSummaryRecord("CUSTOMER",b-qcust.AccountNumber).
        IF tt-sum.dKey = ""
            THEN tt-sum.dKey = b-qcust.name.
                
            
     
        vhLQuery:GET-NEXT(NO-LOCK). 
                 
      
    END.
    
   
    
    

END PROCEDURE.

PROCEDURE ip-HTM-Header:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE OUTPUT PARAMETER pc-return       AS CHARACTER NO-UNDO.
    

   

    

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
        lc-search       = get-value("search")
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
            
        IF lc-crit-account = ""
            THEN lc-crit-account = "ALL".    
        
    
        IF  lc-crit-sortOrder = "" THEN lc-crit-SortOrder = "ASC".
              
        
    END.
            
    ASSIGN 
        lc-link-otherp = 'source=crmview' +
                          '&filteroptions=' + 
                          'search^' + lc-search +
                          '|account^' + lc-crit-account + 
                             '|status^' + lc-crit-status + 
                             '|rep^' + lc-crit-rep + 
                             '|type^' + lc-crit-type + 
                             '|lodate^' + lc-lodate +     
                             '|hidate^' + lc-hidate +
                             '|sort^' + lc-crit-Sort + 
                             '|sortorder^' + lc-crit-SortOrder 
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
     
       
    
    {&out}
    tbar-Begin(
        REPLACE(tbar-FindLabelIssue(appurl + "/crm/view.p","Search Description"),"IssueButtonPress","crmButton")
        )
    tbar-Link("add",?,appurl +  "/crm/crmop.p",lc-link-otherp)
        
    tbar-BeginOption()
    tbar-Link("view",?,"off",lc-link-otherp)
    tbar-Link("update",?,"off",lc-link-otherp)
    tbar-Link("delete",?,"off",lc-link-otherp)
        
    tbar-EndOption() 
    tbar-End().
    
    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="100%"') skip
           htmlib-TableHeading(
            "Rating^right|Opportunity Number^right|Date|Sales Rep|Customer|Description|Status|Type|Close Date|Probabilty^right|Revenue^right|Cost^right|GP Profit^right|Projected Revenue^right|Projected GP^right|Next Step|Last Activity"
            ) skip.
            
    RUN ip-BuildQueryPhrase.
     
      
    CREATE QUERY vhLQuery  
        ASSIGN 
        CACHE = 100.

    vhLBuffer1 = BUFFER b-query:HANDLE.
    vhLBuffer2 = BUFFER b-qcust:HANDLE.

    vhLQuery:SET-BUFFERS(vhLBuffer1,vhLBuffer2).
   
    vhLQuery:QUERY-PREPARE(lc-QPhrase).
    vhLQuery:QUERY-OPEN().

    /*
    DYNAMIC-FUNCTION("com-WriteQueryInfo",vhlQuery).
    */
 
    RUN ip-GenerateSummary.
    
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
     
    RUN ip-BuildSummaryTable.
           
    {&OUT}  htmlib-EndForm() SKIP
            htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF



/* ************************  Function Implementations ***************** */
FUNCTION CreateSummaryRecord RETURNS LOGICAL 
    ( pc-dType AS CHARACTER , pc-key AS CHARACTER  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    FIND tt-sum WHERE  tt-sum.dtype = pc-dType AND tt-sum.key = pc-key EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE tt-sum THEN CREATE tt-sum.
            
    ASSIGN
        tt-sum.dType = pc-dType
        tt-sum.key = pc-key
        tt-sum.cnt = tt-sum.cnt + 1
        tt-sum.cost = tt-sum.cost + b-query.CostOfSale
        tt-sum.rev = tt-sum.rev + b-query.Revenue. 
            
            
    RETURN TRUE.
                

		
END FUNCTION.
