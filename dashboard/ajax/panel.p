/***********************************************************************

    Program:        dashboard/ajax/panel.p
    
    Purpose:        Dasboard panel.p
    
    Notes:
    
    
    When        Who         What
    16/05/2015  phoski      Initial
    27/05/2015  phoski      cater for customer users
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

DEFINE VARIABLE li-table     AS INTEGER   NO-UNDO.

DEFINE VARIABLE lh-Buffer1   AS HANDLE    NO-UNDO.
DEFINE VARIABLE lh-Buffer2   AS HANDLE    NO-UNDO.
DEFINE VARIABLE lh-Buffer3   AS HANDLE    NO-UNDO.
DEFINE VARIABLE lh-Query     AS HANDLE    NO-UNDO.
DEFINE VARIABLE lc-panelCode AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-position  AS CHARACTER NO-UNDO.

DEFINE TEMP-TABLE tt-stat NO-UNDO
    FIELD sCode  AS CHARACTER 
    FIELD descr  AS CHARACTER
    FIELD svalue AS INTEGER
    FIELD class-value AS INTEGER EXTENT 4
    INDEX scodeIDX sCode.
    
DEFINE TEMP-TABLE tt-eng NO-UNDO
    FIELD loginid AS CHARACTER 
    FIELD name    AS CHARACTER 
    
    FIELD itoday  AS INTEGER
    FIELD iweek   AS INTEGER 
    FIELD imonth  AS INTEGER 
    FIELD iinfo   AS CHARACTER 
    
    
    INDEX NAMEIDX NAME.
        
     
         



/* ********************  Preprocessor Definitions  ******************** */

FUNCTION WriteStat RETURNS ROWID 
    (pc-Code AS CHARACTER,
    pc-Description AS CHARACTER,
    pi-Count AS INTEGER,
     pi-class AS INTEGER) FORWARD.

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
{lib/dashlib.i}



/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */


&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE ip-BuildCompanyStats:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lr-row          AS ROWID        NO-UNDO.
    DEFINE VARIABLE lc-QPhrase      AS CHARACTER    NO-UNDO.
    
    
    DEFINE BUFFER Issue FOR Issue.
    DEFINE BUFFER Customer FOR Customer.

    DEFINE BUFFER b-status  FOR WebStatus.  
    DEFINE BUFFER b-user    FOR WebUser.
    DEFINE BUFFER b-Area    FOR WebIssArea. 
    DEFINE BUFFER this-user FOR WebUser.
    
    DEFINE VARIABLE ll-Complete AS LOG NO-UNDO.
    DEFINE VARIABLE ld-this-month   AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-prev-month   AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-date         AS DATE     NO-UNDO.
    DEFINE VARIABLE li-class        AS INTEGER  NO-UNDO.
    
    ASSIGN 
        ld-date = TODAY.
    ASSIGN
        ld-this-month = ld-date - day(ld-date) + 1
        ld-date = ld-this-month - 1
        ld-prev-month = ld-date - day(ld-date) + 1.
        
       
    ASSIGN 
        lc-QPhrase = 
        "for each issue NO-LOCK where issue.CompanyCode = '" + string(lc-Global-Company) + "'".
        
    RUN ip-IssueQueryAdjust ( INPUT-OUTPUT lc-qPhrase ).
         
    
    CREATE QUERY lh-Query  
        /*
            ASSIGN 
            CACHE = 4000
            */
        .

    lh-Buffer1 = BUFFER issue:HANDLE.
   
    lh-Query:SET-BUFFERS(lh-Buffer1).
    lh-Query:QUERY-PREPARE(lc-QPhrase).
    lh-Query:QUERY-OPEN().
    
    lh-Query:GET-FIRST(NO-LOCK). 
    
    REPEAT WHILE lh-Buffer1:AVAILABLE: 
    
        li-class = LOOKUP(Issue.iClass,lc-global-iclass-code,"|").
        IF li-class < 1
        OR li-class > extent(tt-stat.class-value)
        OR li-class = ? 
        THEN li-class = 1.
        
        lr-row =  DYNAMIC-FUNCTION("WriteStat","001:001","Number of Issues",1,li-class).
        
        FIND b-status OF Issue NO-LOCK NO-ERROR.
        IF AVAILABLE b-status AND b-status.CompletedStatus
            THEN ll-complete = b-status.CompletedStatus.
        ELSE ll-Complete = FALSE.
        
        lr-row =  DYNAMIC-FUNCTION("WriteStat","001:002","Closed Issues", IF ll-complete THEN 1 ELSE 0,li-class).
        lr-row =  DYNAMIC-FUNCTION("WriteStat","001:003","Open Issues", IF ll-complete THEN 0 ELSE 1,li-class).
        
        IF Issue.CreateDate = TODAY THEN
        DO:
            lr-row =  DYNAMIC-FUNCTION("WriteStat","002:001","Today - Number of Issues",1,li-class).
       
            lr-row =  DYNAMIC-FUNCTION("WriteStat","002:002","Today - Closed Issues",IF ll-complete THEN 1 ELSE 0,li-class).
            lr-row =  DYNAMIC-FUNCTION("WriteStat","002:003","Today  - Open Issues",IF ll-complete THEN 0 ELSE 1,li-class).
        END.
        
        IF Issue.CreateDate >= TODAY - 7 THEN
        DO:
            lr-row =  DYNAMIC-FUNCTION("WriteStat","003:001","Week - Number of Issues",1,li-class).
       
            lr-row =  DYNAMIC-FUNCTION("WriteStat","003:002","Week - Closed Issues",IF ll-complete THEN 1 ELSE 0,li-class).
            lr-row =  DYNAMIC-FUNCTION("WriteStat","003:003","Week - Open Issues",IF ll-complete THEN 0 ELSE 1,li-class).
        END.
        
        IF Issue.CreateDate >= ld-this-Month THEN
        DO:
            lr-row =  DYNAMIC-FUNCTION("WriteStat","004:001","Month - Number of Issues" ,1,li-class).
       
            lr-row =  DYNAMIC-FUNCTION("WriteStat","004:002","Month - Closed Issues",IF ll-complete THEN 1 ELSE 0,li-class).
            lr-row =  DYNAMIC-FUNCTION("WriteStat","004:003","Month - Open Issues",IF ll-complete THEN 0 ELSE 1,li-class).
        END.
        
        IF Issue.CreateDate >= ld-prev-Month 
            AND Issue.CreateDate < ld-this-month THEN
        DO:
            lr-row =  DYNAMIC-FUNCTION("WriteStat","005:001","Prev Month - Number of Issues",1,li-class).
       
            lr-row =  DYNAMIC-FUNCTION("WriteStat","005:002","Prev Month - Closed Issues",IF ll-complete THEN 1 ELSE 0,li-class).
            lr-row =  DYNAMIC-FUNCTION("WriteStat","005:003","Prev Month - Open Issues",IF ll-complete THEN 0 ELSE 1,li-class).
        END.
        
    
        lh-Query:GET-NEXT(NO-LOCK). 
         
    END.   
    
    lh-Query:QUERY-CLOSE ().
     
    DELETE OBJECT lh-Query NO-ERROR. 
    

END PROCEDURE.

PROCEDURE ip-BuildEngineerSummary:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER WebUser FOR WebUser.
    DEFINE BUFFER issActivity FOR issActivity.
    
    DEFINE VARIABLE ll-Complete AS LOG NO-UNDO.
    DEFINE VARIABLE ld-this-month   AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-prev-month   AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-date         AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-week         AS DATE     NO-UNDO.
    
    
    ASSIGN 
        ld-date = TODAY.
    ASSIGN
        ld-this-month = ld-date - day(ld-date) + 1
        ld-date = ld-this-month - 1
        ld-prev-month = ld-date - day(ld-date) + 1
        ld-week = TODAY - 7.
        
       
    FOR EACH WebUser NO-LOCK
        WHERE CAN-DO(lc-global-internal,webuser.UserClass)
        AND webuser.CompanyCode = lc-Global-Company
        BY WebUser.Name:
       
        CREATE tt-eng.
        ASSIGN
            tt-eng.loginid = WebUser.LoginID
            tt-eng.name = WebUser.Name.
        FOR EACH issActivity NO-LOCK
            WHERE issActivity.CompanyCode = lc-global-company
            AND issActivity.ActivityBy = WebUser.LoginID
            AND issActivity.startdate >= ld-this-month
            :
                  
            IF issActivity.StartDate = ? THEN NEXT.
                  
            IF issActivity.startdate = TODAY
                THEN ASSIGN tt-eng.itoday = tt-eng.itoday + issActivity.Duration.
            
            IF issActivity.startdate >= ld-week
                THEN ASSIGN tt-eng.iweek = tt-eng.iweek + issActivity.Duration.
            
            IF issActivity.startdate >= ld-this-month
                THEN ASSIGN tt-eng.imonth = tt-eng.imonth + issActivity.Duration.
            
            ASSIGN
                tt-eng.iinfo =  STRING(issActivity.StartDate,"99/99/9999") + " " +
                                string(issActivity.StartTime,"hh:mm") + " - Issue " + 
                               STRING(issActivity.IssueNumber) 
                               + " " +
                               issActivity.ActDescription .
                
                         
        END.
                      
    END.
    
END PROCEDURE.

PROCEDURE ip-EngineerStatistics:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    
    RUN ip-BuildEngineerSummary.
    
    {&out} '<table class="easyui-datagrid"' SKIP.
       
    {&out} 'data-options="fitColumns:true,singleSelect:true,striped:true"
            xxstyle="width:250px"
    >
    <thead>
        <tr>
            <th data-options="field:~'Engineer~',sortable:false">Engineer</th>
    
            <th data-options="field:~'today~',align:~'right~',sortable:false">Today</th>
            <th data-options="field:~'week~',align:~'right~',sortable:false">Week</th>
            <th data-options="field:~'month~',align:~'right~',sortable:false">Month</th>
            <th data-options="field:~'info~',sortable:false">Last Activity</th>
            
        </tr>
    </thead>
    <tbody>' skip.
    
 
    FOR EACH tt-eng NO-LOCK:
        {&out}
        '<tr><td>' tt-eng.name 
        '</td><td>' DYNAMIC-FUNCTION("com-TimeToString",tt-eng.iToday) 
        '</td><td>' DYNAMIC-FUNCTION("com-TimeToString",tt-eng.iWeek) 
        '</td><td>' DYNAMIC-FUNCTION("com-TimeToString",tt-eng.iMonth)
        '</td><td>' tt-eng.iinfo
        '</td></tr>' SKIP.
        
    END.
    
    {&out} '</tbody></table>' SKIP.
    
    

END PROCEDURE.

PROCEDURE ip-HelpdeskStatistics:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    RUN ip-BuildCompanyStats.
    
    DEFINE VARIABLE li-loop AS INTEGER      NO-UNDO.
    
    
    {&out} '<table class="easyui-datagrid"' SKIP.
       
    {&out} 'data-options="fitColumns:true,singleSelect:true,striped:true"
            style="width:650px"
    >
    <thead>
        <tr>
            <th data-options="field:~'StatDescr~',sortable:false">Statistic</th>' SKIP.
            
    DO li-loop = 1 TO NUM-ENTRIES(lc-global-iclass-code,"|"):
        
        {&out}    
         '<th data-options="field:~'StatValue' li-loop ''~',align:~'right~',sortable:false">' ENTRY(li-loop,lc-global-iclass-desc,"|") '</th>' SKIP.     
    END.        
            
                
    {&out} ' 
    <th data-options="field:~'StatValue~',align:~'right~',sortable:false">Total</th>      
        </tr>
    </thead>
    <tbody>' skip.
    
    
    FOR EACH tt-stat NO-LOCK:
        {&out}
        '<tr><td>' tt-stat.descr '</td>' skip.
        
        DO li-loop = 1 TO NUM-ENTRIES(lc-global-iclass-code,"|"):
            {&out} '<td>' tt-stat.class-value[li-loop] '</td>'.
        END.    
        
        {&out} '<td>' tt-stat.svalue '</td></tr>' SKIP.
    END.
    
    {&out} '</tbody></table>' SKIP.
    
    
    
    
END PROCEDURE.

PROCEDURE ip-IssueGridHeader:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-title         AS CHARACTER NO-UNDO.
    
    
    ASSIGN
        li-table = li-table + 1.
            
    {&out} '<table class="easyui-datagrid" ' SKIP
            ' id="table' li-table '" ' SKIP.
    
    IF pc-title <> "" THEN
        {&out} ' title="' pc-title ' "' SKIP.
    
    {&out} 'data-options="fitColumns:true,singleSelect:true,striped:true"
    >
    <thead>
        <tr>
            <th data-options="field:~'sla~',sortable:false">SLA</th>
            <th data-options="field:~'sladate~',sortable:false">SLA Date</th>
            <th data-options="field:~'slawarn~',sortable:false">SLA Warning</th>
            <th data-options="field:~'issue~',align:~'right~',sortable:false">Issue</th>
            <th data-options="field:~'dt~',align:~'right~',sortable:false">Date</th>
            <th data-options="field:~'bdesc~',sortable:false">Brief Description</th>
            <th data-options="field:~'stat~',sortable:false">Status</th>
            <th data-options="field:~'area~',sortable:false">Area</th>
            <th data-options="field:~'class~',sortable:false">Class</th>
            <th data-options="field:~'assigned~',sortable:false">Assigned</th>
            <th data-options="field:~'cname~',sortable:false">Customer</th>
        </tr>
    </thead>
    <tbody>' skip.
    

END PROCEDURE.


PROCEDURE ip-IssueGridRow:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pr-issue    AS ROWID        NO-UNDO.
    
    DEFINE BUFFER Customer FOR Customer.
    DEFINE BUFFER b-query   FOR issue.
    DEFINE BUFFER b-qcust   FOR Customer.
    DEFINE BUFFER b-search  FOR issue.
    DEFINE BUFFER b-cust    FOR customer.
    DEFINE BUFFER b-status  FOR WebStatus.  
    DEFINE BUFFER b-user    FOR WebUser.
    DEFINE BUFFER b-Area    FOR WebIssArea. 
    DEFINE BUFFER this-user FOR WebUser.

    DEFINE VARIABLE lc-status         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-customer       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-issdate        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-raised         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-assigned       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-area           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-open-status    AS CHARACTER NO-UNDO.

    
    FIND b-query WHERE ROWID(b-query) = pr-issue NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-query THEN RETURN.
    
    FIND Customer OF b-query NO-LOCK NO-ERROR.
    
    FIND b-status OF b-query NO-LOCK NO-ERROR.
    IF AVAILABLE b-status THEN
    DO:
        ASSIGN 
            lc-status = b-status.Description.
        IF b-status.CompletedStatus
            THEN lc-status = lc-status + ' (closed)'.
        ELSE lc-status = lc-status + ' (open)'.
    END.
    ELSE lc-status = "".
    
    FIND b-user WHERE b-user.LoginID = b-query.RaisedLogin NO-LOCK NO-ERROR.
    ASSIGN 
        lc-raised = IF AVAILABLE b-user THEN b-user.name ELSE "".
    ASSIGN 
        lc-assigned = "".
    FIND b-user WHERE b-user.LoginID = b-query.AssignTo NO-LOCK NO-ERROR.
    IF AVAILABLE b-user THEN
    DO:
        ASSIGN 
            lc-assigned = b-user.name.
            
        IF b-query.AssignDate <> ? THEN
            ASSIGN
                lc-assigned = lc-assigned + " " + string(b-query.AssignDate,"99/99/9999") + " " +
                                                  string(b-query.AssignTime,"hh:mm am").
                                                  
    END.
    FIND b-area OF b-query NO-LOCK NO-ERROR.
    ASSIGN 
        lc-area = IF AVAILABLE b-area THEN b-area.description ELSE "None".
      
      
    {&out}  '<tr><td>'.
          
    IF b-query.tlight = li-global-sla-fail
        THEN {&out} '<img src="/images/sla/fail.jpg" height="20" width="20" alt="SLA Fail">' SKIP.
    ELSE
    IF b-query.tlight = li-global-sla-amber
    THEN {&out} '<img src="/images/sla/warn.jpg" height="20" width="20" alt="SLA Amber">' SKIP.
    ELSE
    IF b-query.tlight = li-global-sla-ok
    THEN {&out} '<img src="/images/sla/ok.jpg" height="20" width="20" alt="SLA OK">' SKIP.

    ELSE {&out} '&nbsp;' SKIP.

    {&out} '</td><td>' 
    IF b-query.slaTrip <> ? THEN       
        STRING(b-query.slatrip,"99/99/9999 HH:MM") 
    ELSE '&nbsp;'.
    
    {&out} '</td><td>' 
    IF b-query.slaAmber <> ? THEN       
        STRING(b-query.slaAmber,"99/99/9999 HH:MM") 
    ELSE '&nbsp;'.
    
    {&out} '</td><td>' b-query.IssueNumber 
    '</td><td>' STRING(b-query.IssueDate,"99/99/9999") 
    '</td><td>' TRIM(substr(b-query.BriefDescription,1,40)) 
    '</td><td>' lc-status 
    '</td><td>' TRIM(substr(lc-area,1,40))
    '</td><td>' com-DecodeLookup(b-query.iClass,lc-global-iclass-code,lc-global-iclass-desc)
    '</td><td>' lc-assigned
    '</td><td>' Customer.Name 
    '</td></tr>' SKIP.    
                  
        

END PROCEDURE.

PROCEDURE ip-IssueQueryAdjust:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/
    DEFINE INPUT-OUTPUT PARAMETER pc-q     AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER Webuser FOR WebUser.

    FIND WebUser
        WHERE WebUser.LoginID = lc-global-user
        NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE WebUser THEN RETURN.
    
    IF WebUser.UserClass = "customer" THEN
    DO:
        ASSIGN pc-q = pc-q + "  and issue.AccountNumber = '" + WebUser.AccountNumber + "'".  

    END.
    



END PROCEDURE.

PROCEDURE ip-LatestIssue:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-count        AS INTEGER      NO-UNDO.
    DEFINE VARIABLE li-max          AS INTEGER      NO-UNDO.
    
    DEFINE VARIABLE lc-QPhrase   AS CHARACTER    NO-UNDO.
    
    
    DEFINE BUFFER Issue FOR Issue.
       
    ASSIGN 
        li-max = 20
        lc-QPhrase = 
        "for each issue NO-LOCK where issue.CompanyCode = '" + string(lc-Global-Company) + "' ".
        
    RUN ip-IssueQueryAdjust ( INPUT-OUTPUT lc-qPhrase ).
    
    ASSIGN lc-QPhrase = lc-QPhrase + " by issue.IssueNumber DESCENDING".
    
    RUN ip-IssueGridHeader ( "").
    CREATE QUERY lh-Query  
        ASSIGN 
        CACHE = 100 .

    lh-Buffer1 = BUFFER issue:HANDLE.
   
    lh-Query:SET-BUFFERS(lh-Buffer1).
    lh-Query:QUERY-PREPARE(lc-QPhrase).
    lh-Query:QUERY-OPEN().
    
    lh-Query:GET-FIRST(NO-LOCK). 
    
    REPEAT WHILE lh-Buffer1:AVAILABLE: 
        
        ASSIGN 
            li-count = li-count + 1.
        RUN ip-IssueGridRow ( ROWID(issue)).
        
        
        IF li-count >= li-max THEN LEAVE.
        
        
        lh-Query:GET-NEXT(NO-LOCK). 
         
    END.   
    
    lh-Query:QUERY-CLOSE ().
     
    DELETE OBJECT lh-Query NO-ERROR. 
    
    
    {&out} '</tbody></table>' SKIP.

END PROCEDURE.

PROCEDURE ip-OldestIssue:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-count        AS INTEGER      NO-UNDO.
    DEFINE VARIABLE li-max          AS INTEGER      NO-UNDO.
    
    DEFINE VARIABLE lc-QPhrase   AS CHARACTER    NO-UNDO.
    
    
    DEFINE BUFFER Issue FOR Issue.
    DEFINE BUFFER WebStatus FOR WebStatus.
    
    
       
    ASSIGN 
        li-max = 20
        lc-QPhrase = 
        "for each issue NO-LOCK where issue.CompanyCode = '" + string(lc-Global-Company) + "' ".
        
    RUN ip-IssueQueryAdjust ( INPUT-OUTPUT lc-qPhrase ).
    ASSIGN 
        lc-QPhrase = lc-QPhrase + 
        ", first webstatus NO-LOCK where webstatus.CompanyCode = issue.CompanyCode and webstatus.statusCode = issue.StatusCode and webstatus.CompletedStatus = false "
        lc-qPhrase = lc-qPhrase +  " by issue.IssueNumber".
        
    
        
    RUN ip-IssueGridHeader ("").
    CREATE QUERY lh-Query  
        ASSIGN 
        CACHE = 100 .

    lh-Buffer1 = BUFFER issue:HANDLE.
    lh-Buffer2 = BUFFER webStatus:HANDLE.
   
    lh-Query:SET-BUFFERS(lh-Buffer1,lh-Buffer2).
    lh-Query:QUERY-PREPARE(lc-QPhrase).
    lh-Query:QUERY-OPEN().
    
    lh-Query:GET-FIRST(NO-LOCK). 
    
    REPEAT WHILE lh-Buffer1:AVAILABLE: 
        
        ASSIGN 
            li-count = li-count + 1.
        RUN ip-IssueGridRow ( ROWID(issue)).
        
        
        IF li-count >= li-max THEN LEAVE.
        
        
        lh-Query:GET-NEXT(NO-LOCK). 
         
    END.   
    
    lh-Query:QUERY-CLOSE ().
     
    DELETE OBJECT lh-Query NO-ERROR. 
    
    
    {&out} '</tbody></table>' SKIP.



END PROCEDURE.

PROCEDURE ip-TodayIssue:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-count        AS INTEGER      NO-UNDO.
    
    DEFINE VARIABLE lc-QPhrase   AS CHARACTER    NO-UNDO.
    
    
    DEFINE BUFFER Issue FOR Issue.
       
    ASSIGN 
        lc-QPhrase = 
        "for each issue NO-LOCK where issue.CompanyCode = '" + string(lc-Global-Company) + "' and issue.createDate = today".
    RUN ip-IssueQueryAdjust ( INPUT-OUTPUT lc-qPhrase ).
      
    RUN ip-IssueGridHeader ( "").
    CREATE QUERY lh-Query  
        ASSIGN 
        CACHE = 100 .

    lh-Buffer1 = BUFFER issue:HANDLE.
   
    lh-Query:SET-BUFFERS(lh-Buffer1).
    lh-Query:QUERY-PREPARE(lc-QPhrase).
    lh-Query:QUERY-OPEN().
    
    lh-Query:GET-FIRST(NO-LOCK). 
    
    REPEAT WHILE lh-Buffer1:AVAILABLE: 
        
        ASSIGN 
            li-count = li-count + 1.
        RUN ip-IssueGridRow ( ROWID(issue)).
        
       
        
        lh-Query:GET-NEXT(NO-LOCK). 
         
    END.   
    
    lh-Query:QUERY-CLOSE ().
     
    DELETE OBJECT lh-Query NO-ERROR. 
    
    
    {&out} '</tbody></table>' SKIP.
    

END PROCEDURE.

PROCEDURE outputHeader :
    /*------------------------------------------------------------------------------
      Purpose:     Output the MIME header, and any "cookie" information needed 
                   by this procedure.  
      Parameters:  <none>
      emails:       In the event that this Web object is state-aware, this is
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

PROCEDURE ip-TodayIssueClass:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-count        AS INTEGER      NO-UNDO.
    
    DEFINE VARIABLE lc-QPhrase      AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE li-loop         AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-iclass       AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE lc-tab          AS CHARACTER    NO-UNDO.
    
    
    
    DEFINE BUFFER Issue FOR Issue.

       
    DO li-loop = 1 TO NUM-ENTRIES(lc-global-iclass-code,"|").
    
        ASSIGN 
            lc-iclass = ENTRY(li-loop,lc-global-iclass-code,"|")
            lc-tab = ENTRY(li-loop,lc-global-iclass-desc,"|")
            .        
    
    
    
          
        ASSIGN 
            lc-QPhrase = 
        "for each issue NO-LOCK where issue.CompanyCode = '" + string(lc-Global-Company) + "' and issue.createDate = today" 
        +
         " and issue.iclass = '" + lc-iclass + "'".
          
       RUN ip-IssueQueryAdjust ( INPUT-OUTPUT lc-qPhrase ).
          
        
        CREATE QUERY lh-Query  
            ASSIGN 
            CACHE = 100 .

        ASSIGN li-count = 0.
        
        lh-Buffer1 = BUFFER issue:HANDLE.
   
        lh-Query:SET-BUFFERS(lh-Buffer1).
        lh-Query:QUERY-PREPARE(lc-QPhrase).
        lh-Query:QUERY-OPEN().
    
        lh-Query:GET-FIRST(NO-LOCK). 
    
        RUN ip-IssueGridHeader("Class - " + lc-tab).
    
        REPEAT WHILE lh-Buffer1:AVAILABLE: 
        
            
            ASSIGN 
                li-count = li-count + 1.
            RUN ip-IssueGridRow ( ROWID(issue)).
        
       
        
            lh-Query:GET-NEXT(NO-LOCK). 
         
        END.   
    
        lh-Query:QUERY-CLOSE ().
     
        DELETE OBJECT lh-Query NO-ERROR. 
   
        {&out} '</tbody></table><p>Count - ' li-count '</p>' SKIP.
   
        
       
         
    END.
   
    

END PROCEDURE.

PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
  Purpose:     Process the web request.
  Parameters:  <none>
  emails:       
------------------------------------------------------------------------------*/

    {lib/checkloggedin.i}

    ASSIGN
        lc-panelCode = get-value("panelcode").
    
    RUN outputHeader.
    
    
    FIND tt-dashlib 
        WHERE tt-dashlib.panelCode = lc-panelCode NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE tt-dashlib THEN
    DO:
        {&out} '<p>Dashboard panel not found: Code = ' lc-panelCode '</p>' SKIP.
        
    END.
    ELSE
    DO: 
        RUN value(tt-dashlib.iprun) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN
        DO:
            {&out} '<p>Dashboard Panel Run Code not found: PanelCode = ' lc-panelCode ' RUN=' tt-dashlib.iprun '</p>' SKIP.
        END.    
        
    END.
    
   
    
  
END PROCEDURE.


&ENDIF



/* ************************  Function Implementations ***************** */
FUNCTION WriteStat RETURNS ROWID 
    ( pc-Code AS CHARACTER ,
    pc-Description AS CHARACTER ,
    pi-Count AS INTEGER,
    pi-class AS INTEGER  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    
		
    FIND tt-stat WHERE tt-stat.Scode = pc-code NO-ERROR.
    IF NOT AVAILABLE tt-stat THEN CREATE tt-stat.
    ASSIGN
        tt-stat.scode = pc-code
        tt-stat.descr = pc-description
        tt-stat.svalue = tt-stat.svalue + pi-count
        tt-stat.class-value[pi-class] =  tt-stat.class-value[pi-class] + pi-Count.
		  
		
    RETURN ROWID(tt-stat).
		

		
END FUNCTION.
