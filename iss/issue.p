/***********************************************************************

    Program:        iss/issue.p
    
    Purpose:        Issue Main Page
    
    Notes:
    
    
    When        Who         What
    06/04/2006  phoski      SearchField 
    06/04/2006  phoski      hidedisplay.js for issue detailed info
    06/04/2006  phoski      Sort by issue descending
    10/04/2006  phoski      CompanyCode
    11/04/2006  phoski      Common routines
    11/04/2006  phoski      htmlib-trmouse()
    13/04/2006  phoski      Handle customers user page
    
    13/09/2010  DJS         3708 Add dates to selection criteria
    14/09/2010  DJS         3708 Additional bist for above
    02/08/2012  DJS         3933 Modified to use object buffers  
    20/04/2014  phoski      fixed 3933 and customer page     
    24/04/2014  phoski      Various from specifications & fixes
    24/07/2014  phoski      Team Stuff
    01/10/2014  phoski      Account Manager (TAM/CAM)
    16/12/2014  phoski      TAM/CAM problem if not allowed ( paging problems in JS )
    07/03/2015  phoski      Default dates for customers today & today - 30
    29/03/2015  phoski      Complex Project Class 
    24/08/2015  phoski      Default to Open issues and sort by issue 
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-print     AS CHARACTER NO-UNDO.

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

DEFINE VARIABLE lc-sel-account    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sel-status     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sel-assign     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sel-area       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sel-cat        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-status         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-customer       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-issdate        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-raised         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-assigned       AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-open-status    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-closed-status  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AccountManager AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-area           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-acc       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-aname     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-acc-lo         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-acc-hi         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ass-lo         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ass-hi         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-area-lo        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-area-hi        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-srch-status    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-srch-desc      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cat-lo         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cat-hi         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-iclass         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-status    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-sname     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-assign    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assname   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-acm       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-acmname   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-list-area      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-arname    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-cat       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-cname     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-info           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-object         AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-tag-end        AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-dummy-return   AS CHARACTER INITIAL "MYXXX111PPP2222" NO-UNDO.
DEFINE VARIABLE ll-customer       AS LOG       NO-UNDO.
DEFINE VARIABLE li-search         AS INTEGER   NO-UNDO.
DEFINE VARIABLE ll-search-err     AS LOG       NO-UNDO.

DEFINE VARIABLE lc-lodate         AS CHARACTER FORMAT "99/99/9999" NO-UNDO.
DEFINE VARIABLE lc-hidate         AS CHARACTER FORMAT "99/99/9999" NO-UNDO.

DEFINE VARIABLE lc-SortField      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SortOrder      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SortOptions    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-OrderOptions   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-LastAct        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-QPhrase        AS CHARACTER NO-UNDO.
DEFINE VARIABLE vhLBuffer1        AS HANDLE    NO-UNDO.
DEFINE VARIABLE vhLBuffer2        AS HANDLE    NO-UNDO.
DEFINE VARIABLE vhLQuery          AS HANDLE    NO-UNDO.



DEFINE BUFFER b-query   FOR issue.
DEFINE BUFFER b-qcust   FOR Customer.
DEFINE BUFFER b-search  FOR issue.
DEFINE BUFFER b-cust    FOR customer.
DEFINE BUFFER b-status  FOR WebStatus.
DEFINE BUFFER b-user    FOR WebUser.
DEFINE BUFFER b-Area    FOR WebIssArea.
DEFINE BUFFER this-user FOR WebUser.






/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-Format-Select-Account) = 0 &THEN

FUNCTION Format-Select-Account RETURNS CHARACTER
    ( pc-htm AS CHARACTER )  FORWARD.


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

PROCEDURE ip-BuildIssueTable:
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
            lc-rowid = STRING(ROWID(b-query))
            lc-issdate = IF b-query.issuedate = ? THEN "" ELSE STRING(b-query.issuedate,'99/99/9999').
        ASSIGN 
            li-count = li-count + 1.
        IF lr-first-row = ?
            THEN ASSIGN lr-first-row = ROWID(b-query).
        ASSIGN 
            lr-last-row = ROWID(b-query).
        ASSIGN 
            lc-link-otherp = 'search=' + lc-search +
                                '&firstrow=' + string(lr-first-row) +
                                '&account=' + lc-sel-account + 
                                '&status=' + lc-sel-status + 
                                '&assign=' + lc-sel-assign + 
                                '&area=' + lc-sel-area + 
                                '&category=' + lc-sel-cat +
                                '&lodate=' + lc-lodate +     
                                '&hidate=' + lc-hidate +
                                '&sortfield=' + lc-SortField + 
                                '&sortorder=' + lc-SortOrder + 
                                '&iclass=' + lc-iclass +
                                '&accountmanager=' + lc-AccountManager.
        FIND b-cust OF b-query NO-LOCK NO-ERROR.
        ASSIGN 
            lc-customer = IF AVAILABLE b-cust THEN b-cust.name ELSE "".
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
                    lc-assigned = lc-assigned + "~n" + string(b-query.AssignDate,"99/99/9999") + " " +
                                                  string(b-query.AssignTime,"hh:mm am").
        END.
        FIND b-area OF b-query NO-LOCK NO-ERROR.
        ASSIGN 
            lc-area = IF AVAILABLE b-area THEN b-area.description ELSE "".
        {&out}
            skip
            tbar-tr(rowid(b-query))
            skip.

        /* SLA Traffic Light */
        IF NOT ll-Customer THEN
        DO:
            {&out} '<td valign="top" align="right">' SKIP.

            IF b-query.tlight = li-global-sla-fail
                THEN {&out} '<img src="/images/sla/fail.jpg" height="20" width="20" alt="SLA Fail">' SKIP.
            ELSE
            IF b-query.tlight = li-global-sla-amber
            THEN {&out} '<img src="/images/sla/warn.jpg" height="20" width="20" alt="SLA Amber">' SKIP.
            
            ELSE
            IF b-query.tlight = li-global-sla-ok
            THEN {&out} '<img src="/images/sla/ok.jpg" height="20" width="20" alt="SLA OK">' SKIP.
            
            ELSE {&out} '&nbsp;' SKIP.
            
            {&out} '</td>' skip.

            IF b-query.slatrip <> ? THEN
            DO:
                {&out} '<td valign="top" align="left" nowrap>' SKIP
                       STRING(b-query.slatrip,"99/99/9999 HH:MM") SKIP.


                IF b-query.slaAmber <> ? THEN
                    {&out} '<br/>' SKIP
                       STRING(b-query.slaAmber,"99/99/9999 HH:MM") SKIP.
                {&out} '</td>' SKIP.

            END.
            ELSE 
                {&out} '<td>&nbsp;</td>' SKIP.
        END.
        {&out}
        htmlib-MntTableField(html-encode(STRING(b-query.issuenumber)),'right')
        htmlib-MntTableField(html-encode(lc-issdate),'right').
        IF b-query.LongDescription <> ""
            AND b-query.LongDescription <> b-query.briefdescription THEN
        DO:
            ASSIGN 
                lc-info = 
                REPLACE(htmlib-MntTableField(html-encode(b-query.briefdescription),'left'),'</td>','')
                lc-object = "hdobj" + string(b-query.issuenumber).
            ASSIGN 
                li-tag-end = INDEX(lc-info,">").
            {&out} substr(lc-info,1,li-tag-end).
            ASSIGN 
                substr(lc-info,1,li-tag-end) = "".
            {&out} 
            '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
            lc-object '~')">':U skip.
            {&out} lc-info.
            {&out} htmlib-ExpandBox(lc-object,b-query.LongDescription).
            {&out} '</td>' skip.
        END.
        ELSE {&out} htmlib-MntTableField(html-encode(b-query.briefdescription),"left").
        {&out}
        htmlib-MntTableField(html-encode(lc-status),'left')
        htmlib-MntTableField(html-encode(lc-area),'left')
        htmlib-MntTableField(/*html-encode(b-query.iclass)*/
        com-DecodeLookup(b-query.iClass,lc-global-iclass-code,lc-global-iclass-desc)
        ,'left').
        IF NOT ll-customer THEN
        DO:
            IF b-query.lastActivity = ?
                THEN lc-lastAct = "".
            ELSE lc-lastAct = STRING(b-query.lastActivity,"99/99/9999 HH:MM").
            
            {&out}
            htmlib-MntTableField(REPLACE(html-encode(lc-assigned),"~n","<br>"),'left')
            htmlib-MntTableField(REPLACE(html-encode(lc-LastAct),"~n","<br>"),'left').

            
            IF lc-raised = "" THEN 
            DO:
                {&out} htmlib-MntTableField(html-encode(lc-customer),'left').
            END.
            ELSE
            DO:
                ASSIGN 
                    lc-info = 
                            REPLACE(htmlib-MntTableField(html-encode(lc-customer),'left'),'</td>','')
                    lc-object = "hdobjcust" + string(b-query.issuenumber).
                ASSIGN 
                    li-tag-end = INDEX(lc-info,">").
                {&out} substr(lc-info,1,li-tag-end).
                ASSIGN 
                    substr(lc-info,1,li-tag-end) = "".
                {&out} 
                '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
                lc-object '~')">':U skip.
                {&out} lc-info.
                {&out} htmlib-SimpleExpandBox(lc-object,lc-raised).
                {&out} '</td>' skip.
            END.
        END. 
    
        {&out} skip
                    tbar-BeginHidden(rowid(b-query)).
        IF NOT ll-Customer 
            THEN {&out} tbar-Link("pdf",?,
            'javascript:RepWindow('
            + '~'' + lc-link-print 
            + '~'' 
            + ');'
            ,"")
        tbar-Link("MailIssue",ROWID(this-user),appurl + '/' + "iss/issueemail.p",lc-link-otherp).


    
        IF ll-Customer
            THEN {&out} tbar-Link("statement",?,appurl + '/'
            + "cust/indivstatement.p","source=customer&accountnumber=" + this-user.AccountNumber).
        {&out}
        tbar-Link("view",ROWID(b-query),
            'javascript:HelpWindow('
            + '~'' + appurl 
            + '/iss/issueview.p?rowid=' + string(ROWID(b-query))
            + '~'' 
            + ');'
            ,lc-link-otherp).
        IF NOT ll-customer  
            THEN {&out} tbar-Link("update",ROWID(b-query),appurl + '/' + "iss/issueframe.p",lc-link-otherp).
            else {&out} tbar-Link("doclist",rowid(b-query),appurl + '/' + "iss/custissdoc.p",lc-link-otherp).
        IF DYNAMIC-FUNCTION("com-IsSuperUser",lc-global-user)
            THEN {&out} tbar-Link("moveiss",ROWID(b-query),appurl + '/' + "iss/moveissue.p",lc-link-otherp).
        {&out}
        tbar-EndHidden()
                skip
               '</tr>' skip.
        IF li-count = li-max-lines THEN LEAVE.
     
        vhLQuery:GET-NEXT(NO-LOCK). 

    END. /* BUFFER LOOP */

END PROCEDURE.

PROCEDURE ip-BuildQueryPhrase:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    ASSIGN
        lc-QPhrase = 
        "for each b-query NO-LOCK where b-query.CompanyCode = '" + string(lc-Global-Company) + "'".

    IF lc-sel-account <> htmlib-Null() THEN 
    DO:
        ASSIGN 
            lc-QPhrase =  lc-QPhrase + " and b-query.AccountNumber = '" + lc-acc-lo + "'".
    END.  
    ELSE
        IF DYNAMIC-FUNCTION("com-isTeamMember", lc-global-company,lc-global-user,?) THEN
        DO:
            lc-QPhrase =  lc-QPhrase + " and can-do('" + replace(lc-list-acc,"|",",") + "',b-query.AccountNumber)".
        END.
 
    
    IF lc-accountManager <> 'on' THEN
    DO:
        
        IF lc-sel-assign = htmlib-null() 
            AND DYNAMIC-FUNCTION("com-isTeamMember", lc-global-company,lc-global-user,?) THEN
        DO:
            lc-QPhrase =  lc-QPhrase + " and can-do('" + lc-ass-lo + "',b-query.AssignTo)".
        END.
        ELSE
            IF lc-sel-assign <> htmlib-null() 
                THEN ASSIGN lc-QPhrase =  lc-QPhrase + " and b-query.AssignTo = '" + lc-ass-lo + "'".
    END.

    

    IF lc-sel-area <> htmlib-null() 
        THEN ASSIGN lc-QPhrase =  lc-QPhrase + " and b-query.AreaCode = '" + lc-area-lo + "'".
    
    IF lc-sel-cat <> htmlib-null() 
        THEN ASSIGN lc-QPhrase =  lc-QPhrase + " and b-query.CatCode = '" + lc-cat-lo + "'".

    ASSIGN 
        lc-QPhrase = lc-QPhrase + 
            " and b-query.CreateDate >= '" + string(DATE(lc-lodate)) + "' " + 
            " and b-query.CreateDate <= '" + string(DATE(lc-hidate)) + "' ".

    IF lc-srch-status <> "*" 
        THEN ASSIGN lc-QPhrase = lc-QPhrase + " and index('" + string(lc-srch-status) + "',b-query.StatusCode) <> 0 ".
    IF li-search > 0 
        THEN ASSIGN lc-QPhrase = lc-QPhrase + " and b-query.IssueNumber = '" + string(li-Search) + "'".
    ELSE 
        IF lc-search <> "" 
            THEN ASSIGN lc-QPhrase = lc-QPhrase  + " and b-query.searchField contains '" + lc-search + "'".
    
    IF lc-iClass <> "ALL" 
        THEN ASSIGN lc-QPhrase = lc-QPhrase  + " and b-query.iclass = '" + lc-iclass + "'".
    
    ASSIGN 
        lc-QPhrase = lc-QPhrase  + " , first b-qcust NO-LOCK where b-qcust.companyCode = b-query.companycode and b-qcust.accountnumber = b-query.accountnumber".
        
    IF lc-accountManager = 'on' THEN
    DO:
        ASSIGN 
            lc-QPhrase =  lc-QPhrase + " and b-qcust.AccountManager = '" + lc-ass-lo + "'".
    END.    
                

    IF lc-SortField <> "" THEN
    DO:
        ASSIGN 
            lc-QPhrase = lc-QPhrase  
                + " by " + lc-sortfield + " " + ( IF lc-sortOrder = "ASC" THEN "" ELSE lc-SortOrder ).
        IF lc-SortField <> "b-query.tlight"
            THEN 
        DO: 
            ASSIGN 
                lc-QPhrase = lc-QPhrase + " by b-query.tlight".
            IF lc-SortField <> "b-query.issueNumber"
                THEN ASSIGN lc-QPhrase = lc-QPhrase + " by b-query.issueNumber DESC".

        END.
        ELSE ASSIGN lc-QPhrase = lc-QPhrase + " by b-query.issueNumber DESC".

    END.

    
    lc-QPhrase = lc-QPhrase + ' INDEXED-REPOSITION'.

END PROCEDURE.

PROCEDURE ip-ExportJScript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out} skip
            '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' skip.

    {&out} skip 
          '<script language="JavaScript">' skip.

    {&out} skip
        'function ChangeAccount() ~{' skip
        '   SubmitThePage("AccountChange")' skip
        '~}' skip

        'function ChangeStatus() ~{' skip
        '   SubmitThePage("StatusChange")' skip
        '~}' skip

            'function ChangeDates() ~{' skip
        '   SubmitThePage("DatesChange")' skip
        '~}' skip.

    {&out} skip
           '</script>' skip.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-InitialProcess) = 0 &THEN

PROCEDURE ip-InitialProcess :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    IF ll-customer THEN
    DO:
        ASSIGN 
            lc-sel-account = this-user.AccountNumber
            lc-sel-assign  = htmlib-Null().
        set-user-field("account",this-user.AccountNumber).

        ASSIGN 
            lc-SortOptions = "b-query.IssueNumber|Issue Number,b-query.IssueDate|Date,b-query.briefDescription|Brief Description,b-query.StatusCode|Status,b-query.AreaCode|Area,b-query.iclass|Class".

    END.
    ELSE
    DO:
        ASSIGN 
            lc-SortOptions = 
               "b-query.tlight|Traffic Light,"  +
               "b-query.SLATrip|SLA Date,"  +
               "b-query.SLAAmber|SLA Warning,"  +
               "b-query.IssueNumber|Issue Number,b-query.IssueDate|Date,b-query.briefDescription|Brief Description,b-query.StatusCode|Status,"
             + "b-query.AreaCode|Area,b-query.iclass|Class,b-query.AssignTo|Assigned To," 
             + "b-query.LastActivity|Last Contact,"
             + "b-query.AccountNumber|Customer".

    END.

    ASSIGN
        lc-OrderOptions = "DESC|Descending,ASC|Ascending".


    
    ASSIGN 
        lc-search      = get-value("search")
        lc-firstrow    = get-value("firstrow")
        lc-lastrow     = get-value("lastrow")
        lc-navigation  = get-value("navigation")
        lc-sel-account = get-value("account")
        lc-sel-status  = get-value("status")
        lc-sel-assign  = get-value("assign")
        lc-sel-area    = get-value("area")
        lc-sel-cat     = get-value("category")
        lc-lodate      = get-value("lodate")         
        lc-hidate      = get-value("hidate")
        lc-SortField   = get-value("sortfield")
        lc-SortOrder   = get-value("sortorder")
        lc-iclass      = get-value("iclass")
        lc-AccountManager = get-value("accountmanager").
            
    
 
    IF lc-SortField = "" THEN
        ASSIGN lc-SortField = /* ENTRY(1,lc-SortOptions,"|") */ "b-query.IssueNumber".
   
    IF lc-SortOrder = ""
        THEN lc-SortOrder = ENTRY(1,lc-OrderOptions,"|").

    IF lc-iclass = "" 
        THEN lc-iclass = ENTRY(1,lc-global-iclass-code,"|").
 
    IF NOT ll-customer THEN
    DO:
    
        IF lc-lodate = ""
            THEN ASSIGN lc-lodate = STRING(TODAY - 365, "99/99/9999").

        IF lc-hidate = ""
            THEN ASSIGN lc-hidate = STRING(TODAY, "99/99/9999").
    END.
    ELSE
    DO:
        IF lc-lodate = ""
            THEN ASSIGN lc-lodate = STRING(TODAY - 30 , "99/99/9999").

        IF lc-hidate = ""
            THEN ASSIGN lc-hidate = STRING(TODAY, "99/99/9999").


    END.
   
    IF lc-sel-account = ""
        THEN ASSIGN lc-sel-account = htmlib-Null().

    IF lc-sel-status = ""
        THEN ASSIGN lc-sel-status = /* htmlib-Null() */ "AllOpen".

    IF lc-sel-assign = ""
        THEN ASSIGN lc-sel-assign = htmlib-Null().

    IF lc-sel-area = ""
        THEN ASSIGN lc-sel-area = htmlib-Null().

    IF lc-sel-cat = ""
        THEN ASSIGN lc-sel-cat = htmlib-Null().

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    
    
    ASSIGN 
        lc-char = htmlib-GetAttr('system','MNTNoLinesDown').
    
    IF lc-search <> "" THEN
    DO:
        ASSIGN 
            li-search = int(lc-search) no-error.
        IF ERROR-STATUS:ERROR
            OR li-search < 1 THEN ASSIGN ll-search-err = TRUE
                li-search = 0.
    END.

    ASSIGN 
        li-max-lines = int(lc-char) no-error.
    IF ERROR-STATUS:ERROR
        OR li-max-lines < 1
        OR li-max-lines = ? THEN li-max-lines = 12.

    RUN com-GetCustomer ( lc-global-company , lc-global-user, OUTPUT lc-list-acc, OUTPUT lc-list-aname ).

    RUN com-GetStatus ( lc-global-company , OUTPUT lc-list-status, OUTPUT lc-list-sname ).

    RUN com-StatusType ( lc-global-company , OUTPUT lc-open-status , OUTPUT lc-closed-status ).

    FIND webuser WHERE webuser.companycode = lc-global-company
        AND webuser.loginid = lc-global-user NO-LOCK.
    IF webuser.UserClass = "CONTRACT" 
        THEN ASSIGN lc-list-assign = webuser.loginid
            lc-list-assname = webuser.name
            lc-sel-assign   = webuser.loginid.

    ELSE 
    DO:
        RUN com-GetAssignRoot ( lc-global-company , lc-global-user, 
            OUTPUT lc-list-assign , OUTPUT lc-list-assname ).
        /* here */
        RUN com-GetAccountManagerList ( lc-global-company ,  OUTPUT lc-list-acm , OUTPUT lc-list-acmname ).
             
        IF lc-accountmanager = "on"
            AND LOOKUP(lc-sel-assign,lc-list-acm,"|") = 0
            THEN lc-sel-assign = ENTRY(1,lc-list-acm,"|").
          
         
    END. 
    RUN com-GetArea ( lc-global-company , OUTPUT lc-list-area , OUTPUT lc-list-arname ).

    RUN com-GetCatSelect ( lc-global-company, OUTPUT lc-list-cat, OUTPUT lc-list-cname ).
    
    

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

&IF DEFINED(EXCLUDE-ip-Selection) = 0 &THEN

PROCEDURE ip-Selection :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE iloop       AS INTEGER      NO-UNDO.
    DEFINE VARIABLE cPart       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cCode       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cDesc       AS CHARACTER     NO-UNDO.
    
    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.

    IF NOT ll-customer
        THEN {&out}
    '<td align=right valign=top>' htmlib-SideLabel("Customer") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("account",lc-list-acc,lc-list-aname,lc-sel-account)) '</td>'.

    {&out}
    '<td align=right valign=top>' htmlib-SideLabel("Status") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("status",lc-list-status,lc-list-sname,lc-sel-status)) '</td>' skip.
    {&out} 
    '<td valign="top" align="right">' 
        (IF LOOKUP("lodate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("From Date")
        ELSE htmlib-SideLabel("From Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("lodate",10,lc-lodate) 
    htmlib-CalendarLink("lodate")
    '</td>' skip
    .
    IF ll-Customer THEN
        {&out} '<td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To Date")
        ELSE htmlib-SideLabel("To Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("hidate",10,lc-hidate) 
    htmlib-CalendarLink("hidate")
    '</td>' skip.

    
    
    {&out} 
    '</tr><tr>'.
    IF lc-accountmanager = 'on' THEN
        {&out} 
    '<td align=right valign=top>' htmlib-SideLabel("TAM/CAM") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("assign",lc-list-acm,lc-list-acmname,lc-sel-assign)).
    else
    {&out} 
    '<td align=right valign=top>' htmlib-SideLabel("Assigned") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("assign",lc-list-assign,lc-list-assname,lc-sel-assign)).
    
    IF this-user.accountManager
        THEN {&out} REPLACE(htmlib-CheckBox("accountmanager", lc-accountManager = "on"),
        '>',' onclick="ChangeAccount()">')
    REPLACE(htmlib-SideLabel("TAM/CAM"),":","") SKIP.
    
    {&out}   
    '</td>' skip.
   
    
    {&out} '<td align=right valign=top>' htmlib-SideLabel("Area") '</td>'
    '<td align=left valign=top>'
    '<select name="area" class="inputfield" onChange="ChangeAccount()">' 
    '<option value="' DYNAMIC-FUNCTION("htmlib-Null") '" ' 
    IF lc-sel-area = dynamic-function("htmlib-Null") 
        THEN "selected" 
    ELSE "" '>All Areas</option>' skip
            '<option value="NOTASSIGNED" ' if lc-sel-area = "NOTASSIGNED"
                then "selected" else "" '>Not Assigned</option>' skip   
    .
    FOR EACH webIssArea NO-LOCK
        WHERE webIssArea.CompanyCode = lc-Global-Company 
        BREAK BY webIssArea.GroupID
        BY webIssArea.AreaCode:
        IF FIRST-OF(webissArea.GroupID) THEN
        DO:
            FIND webissagrp
                WHERE webissagrp.companycode = webissArea.CompanyCode
                AND webissagrp.Groupid     = webissArea.GroupID NO-LOCK NO-ERROR.
            {&out}
            '<optgroup label="' html-encode(IF AVAILABLE webissagrp THEN webissagrp.description ELSE "Unknown") '">' skip.
        END.
        {&out}
        '<option value="' webIssArea.AreaCode '" ' 
        IF lc-sel-area = webIssArea.AreaCode  
            THEN "selected" 
        ELSE "" '>' html-encode(webIssArea.Description) '</option>' skip.
        IF LAST-OF(WebIssArea.GroupID) THEN {&out} '</optgroup>' skip.
    END.
    {&out} '</select></td>'.

    IF NOT ll-customer THEN
        {&out} '<td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To Date")
        ELSE htmlib-SideLabel("To Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("hidate",10,lc-hidate) 
    htmlib-CalendarLink("hidate")
    '</td>' skip.
    IF NOT ll-customer THEN
    DO:
        {&out} '</tr><tr>'
        '<td align=right valign=top>' htmlib-SideLabel("Category") '</td>'
        '<td align=left valign=top>' 
        format-Select-Account(htmlib-Select("category",lc-list-cat,lc-list-cname,lc-sel-cat)) '</td>' skip.
    END.

    {&out} /*'</tr><tr>' */
    '<td align=right valign=top>' htmlib-SideLabel("Class") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("iclass","All|" + lc-global-iclass-code,"All|" + lc-global-iclass-desc,lc-iclass)) '</td>' skip.

    /*
    ** SortField
    **
    */
    IF lc-SortOptions <> "" THEN
    DO:
        {&out}
        '<td align=right valign=top>' htmlib-SideLabel("Sort By") '</td>'
        '<td align=left valign=top>'
        '<select name="sortfield" class="inputfield" onChange="ChangeAccount()">' 
             SKIP.
        DO iloop = 1 TO NUM-ENTRIES(lc-SortOptions):
            cPart = ENTRY(iloop,lc-SortOptions).
            cCode = ENTRY(1,cPart,"|").
            cDesc = ENTRY(2,cPart,"|").

            {&out}
            '<option value="' cCode '" ' 
            IF lc-SortField = cCode
                THEN "selected" 
            ELSE "" '>' html-encode(cDesc) '</option>' skip.

             
  
        END.
        {&out} '</select>'.

        {&out} '<br/>' 
        '<select name="sortorder" class="inputfield" onChange="ChangeAccount()">' 
             SKIP.
        DO iloop = 1 TO NUM-ENTRIES(lc-orderOptions):
            cPart = ENTRY(iloop,lc-OrderOptions).
            cCode = ENTRY(1,cPart,"|").
            cDesc = ENTRY(2,cPart,"|").

            {&out}
            '<option value="' cCode '" ' 
            IF lc-SortOrder = cCode
                THEN "selected" 
            ELSE "" '>' html-encode(cDesc) '</option>' skip.

              
  
        END.
        {&out} '</select></td>'.



    END.
    {&out} '</tr></table>' skip.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-SelectionCustomer:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE iloop       AS INTEGER      NO-UNDO.
    DEFINE VARIABLE cPart       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cCode       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cDesc       AS CHARACTER     NO-UNDO.
    
    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.

    IF NOT ll-customer
        THEN {&out}
    '<td align=right valign=top>' htmlib-SideLabel("Customer") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("account",lc-list-acc,lc-list-aname,lc-sel-account)) '</td>'.

    {&out}
    '<td align=right valign=top>' htmlib-SideLabel("Status") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("status",lc-list-status,lc-list-sname,lc-sel-status)) '</td>' skip.
    {&out} 
    '<td valign="top" align="right">' 
        (IF LOOKUP("lodate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("From Date")
        ELSE htmlib-SideLabel("From Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("lodate",10,lc-lodate) 
    htmlib-CalendarLink("lodate")
    '</td>' skip
    .
    IF ll-Customer THEN
        {&out} '<td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To Date")
        ELSE htmlib-SideLabel("To Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("hidate",10,lc-hidate) 
    htmlib-CalendarLink("hidate")
    '</td>' skip.

    
    IF NOT ll-customer 
        THEN 
        {&out} 
    '</tr><tr>' 
    '<td align=right valign=top>' htmlib-SideLabel("Assigned") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("assign",lc-list-assign,lc-list-assname,lc-sel-assign)) '</td>' skip.

    {&out} '<td align=right valign=top>' htmlib-SideLabel("Area") '</td>'
    '<td align=left valign=top>'
    '<select name="area" class="inputfield" onChange="ChangeAccount()">' 
    '<option value="' DYNAMIC-FUNCTION("htmlib-Null") '" ' 
    IF lc-sel-area = dynamic-function("htmlib-Null") 
        THEN "selected" 
    ELSE "" '>All Areas</option>' skip
            '<option value="NOTASSIGNED" ' if lc-sel-area = "NOTASSIGNED"
                then "selected" else "" '>Not Assigned</option>' skip   
    .
    FOR EACH webIssArea NO-LOCK
        WHERE webIssArea.CompanyCode = lc-Global-Company 
        BREAK BY webIssArea.GroupID
        BY webIssArea.AreaCode:
        IF FIRST-OF(webissArea.GroupID) THEN
        DO:
            FIND webissagrp
                WHERE webissagrp.companycode = webissArea.CompanyCode
                AND webissagrp.Groupid     = webissArea.GroupID NO-LOCK NO-ERROR.
            {&out}
            '<optgroup label="' html-encode(IF AVAILABLE webissagrp THEN webissagrp.description ELSE "Unknown") '">' skip.
        END.
        {&out}
        '<option value="' webIssArea.AreaCode '" ' 
        IF lc-sel-area = webIssArea.AreaCode  
            THEN "selected" 
        ELSE "" '>' html-encode(webIssArea.Description) '</option>' skip.
        IF LAST-OF(WebIssArea.GroupID) THEN {&out} '</optgroup>' skip.
    END.
    {&out} '</select></td>'.

    IF NOT ll-customer THEN
        {&out} '<td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To Date")
        ELSE htmlib-SideLabel("To Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("hidate",10,lc-hidate) 
    htmlib-CalendarLink("hidate")
    '</td>' skip.
    IF NOT ll-customer THEN
    DO:
        {&out} '</tr><tr>'
        '<td align=right valign=top>' htmlib-SideLabel("Category") '</td>'
        '<td align=left valign=top>' 
        format-Select-Account(htmlib-Select("category",lc-list-cat,lc-list-cname,lc-sel-cat)) '</td>' skip.
    END.

    {&out} /*'</tr><tr>' */
    '<td align=right valign=top>' htmlib-SideLabel("Class") '</td>'
    '<td align=left valign=top>' 
    format-Select-Account(htmlib-Select("iclass","All|" + lc-global-iclass-code,"All|" + lc-global-iclass-code,lc-iclass)) '</td>' skip.

    /*
    ** SortField
    **
    */
    IF lc-SortOptions <> "" THEN
    DO:
        {&out}
        '<td align=right valign=top>' htmlib-SideLabel("Sort By") '</td>'
        '<td align=left valign=top>'
        '<select name="sortfield" class="inputfield" onChange="ChangeAccount()">' 
             SKIP.
        DO iloop = 1 TO NUM-ENTRIES(lc-SortOptions):
            cPart = ENTRY(iloop,lc-SortOptions).
            cCode = ENTRY(1,cPart,"|").
            cDesc = ENTRY(2,cPart,"|").

            {&out}
            '<option value="' cCode '" ' 
            IF lc-SortField = cCode
                THEN "selected" 
            ELSE "" '>' html-encode(cDesc) '</option>' skip.

             
  
        END.
        {&out} '</select>'.

        {&out} '<br/>' 
        '<select name="sortorder" class="inputfield" onChange="ChangeAccount()">' 
             SKIP.
        DO iloop = 1 TO NUM-ENTRIES(lc-orderOptions):
            cPart = ENTRY(iloop,lc-OrderOptions).
            cCode = ENTRY(1,cPart,"|").
            cDesc = ENTRY(2,cPart,"|").

            {&out}
            '<option value="' cCode '" ' 
            IF lc-SortOrder = cCode
                THEN "selected" 
            ELSE "" '>' html-encode(cDesc) '</option>' skip.

              
  
        END.
        {&out} '</select></td>'.



    END.
    {&out} '</tr></table>' skip.
    

END PROCEDURE.

PROCEDURE ip-SetQueryRanges:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    IF ll-customer THEN
    DO:
        ASSIGN 
            lc-sel-account = this-user.AccountNumber
            lc-sel-assign  = htmlib-Null().
    END.
    IF lc-sel-account = htmlib-Null()
        THEN ASSIGN lc-acc-lo = ""
            lc-acc-hi = "ZZZZZZZZZZZZZZZZZZZZZZZZ".
    ELSE ASSIGN lc-acc-lo = lc-sel-account
            lc-acc-hi = lc-sel-account.

    IF lc-sel-status = htmlib-Null() 
        THEN ASSIGN lc-srch-status = "*".
    ELSE
        IF lc-sel-status = "AllOpen" 
            THEN ASSIGN lc-srch-status = lc-open-status.
        ELSE 
            IF lc-sel-status = "AllClosed"
                THEN ASSIGN lc-srch-status = lc-closed-status.
            ELSE ASSIGN lc-srch-status = lc-sel-status.
         
    IF lc-sel-assign = htmlib-null() 
        AND DYNAMIC-FUNCTION("com-isTeamMember", lc-global-company,lc-global-user,?) THEN
    DO:
        RUN com-GetTeamMembers ( lc-global-company, lc-global-user,OUTPUT lc-ass-lo).
    
    END.
    ELSE
        IF lc-sel-assign = htmlib-null() 
            THEN ASSIGN lc-ass-lo = ""
                lc-ass-hi = "ZZZZZZZZZZZZZZZZ".
        ELSE
            IF lc-sel-assign = "NotAssigned" 
                THEN ASSIGN lc-ass-lo = ""
                    lc-ass-hi = "".
            ELSE ASSIGN lc-ass-lo = lc-sel-assign
                    lc-ass-hi = lc-sel-assign.

    IF lc-sel-area = htmlib-null() 
        THEN ASSIGN lc-area-lo = ""
            lc-area-hi = "ZZZZZZZZZZZZZZZZ".
    ELSE
        IF lc-sel-area = "NotAssigned" 
            THEN ASSIGN lc-area-lo = ""
                lc-area-hi = "".
        ELSE ASSIGN lc-area-lo = lc-sel-area
                lc-area-hi = lc-sel-area.
    IF lc-sel-cat = htmlib-null() 
        THEN ASSIGN lc-cat-lo = ""
            lc-cat-hi = "ZZZZZZZZZZZZZZZZZZZ".
    ELSE ASSIGN lc-cat-lo = lc-sel-cat
            lc-cat-hi = lc-sel-cat.


END PROCEDURE.

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    DEFINE VARIABLE ld-lodate   AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-hidate   AS DATE     NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-rowid    AS CHARACTER     NO-UNDO.

    ASSIGN
        ld-lodate = DATE(lc-lodate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-lodate = ?
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The from date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    ASSIGN
        ld-hidate = DATE(lc-hidate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-hidate = ?
        THEN RUN htmlib-AddErrorMessage(
            'hidate', 
            'The to date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF ld-lodate > ld-hidate 
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The date range is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

   


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

    
    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.
    
    ASSIGN
        ll-customer = this-user.UserClass = "CUSTOMER".
        
    RUN ip-InitialProcess.
    RUN outputHeader.
    
    {&out} htmlib-Header("Maintain Issue") skip.
    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.
    RUN ip-ExportJScript.
    {&out} htmlib-JScript-Maintenance() skip.
    {&out} htmlib-StartForm("mainform","post", appurl + '/iss/issue.p' ) skip.
    {&out} htmlib-ProgramTitle(IF ll-Customer THEN "Your Issues" ELSE "Maintain Issue") 
    htmlib-hidden("submitsource","") skip.
    {&out} htmlib-BeginCriteria("Search Issues").
    
    IF ll-customer AND get-value("statementsent") = "yes" THEN
    DO:
        {&out} '<div class="infobox">A statement for your account has been sent to your email address.</div>' skip.
    END.
    {&out} '<table align=center><tr>' skip.
    
    IF ll-customer 
        THEN RUN ip-SelectionCustomer.
    ELSE RUN ip-Selection.

    {&out} htmlib-EndCriteria().
    ASSIGN 
        lc-link-print = appurl + '/iss/issueprint.p?account=' 
                         + html-encode(lc-sel-account) 
                         + '&area=' + lc-sel-area 
                         + '&assign=' + lc-sel-assign 
                         + '&status=' + lc-sel-status 
                         + '&category=' + lc-sel-cat
                         + '&lodate=' + lc-lodate       
                         + '&hidate=' + lc-hidate       
                         + '&sortfield=' + lc-SortField 
                         + '&sortorder=' + lc-SortOrder 
                         + '&iclass=' + lc-iclass 
                         + '&accountmanager=' + lc-accountmanager
                         
        .
    {&out}
    tbar-Begin(
        tbar-FindLabelIssue(appurl + "/iss/issue.p","Search Issue Number/Description")
        )
    tbar-BeginOption().
    IF NOT ll-Customer 
        THEN {&out}
    tbar-Link("pdf",?,
        'javascript:RepWindow('
        + '~'' + lc-link-print 
        + '~'' 
        + ');'
        ,"")
    tbar-Link("MailIssue",ROWID(this-user),appurl + '/' + "iss/issueemail.p",lc-link-otherp).

    IF ll-Customer
        THEN {&out} tbar-Link("statement",?,appurl + '/'
        + "cust/indivstatement.p","source=customer&accountnumber=" + this-user.AccountNumber).
    {&out}
    tbar-Link("view",?,"off",lc-link-otherp).
    IF NOT ll-Customer THEN
    DO:
        {&out} tbar-Link("update",?,"off",lc-link-otherp).
    END.
    ELSE 
    DO:
        {&out} tbar-Link("doclist",?,"off",lc-link-otherp).
    END.
    IF DYNAMIC-FUNCTION("com-IsSuperUser",lc-user)
        THEN {&out} tbar-Link("moveiss",?,"off",lc-link-otherp).
    
    {&out} tbar-EndOption() tbar-End().
    IF NOT ll-customer
        THEN {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="100%"') skip
           htmlib-TableHeading(
            "|SLA Date<br/>SLA Warning|Issue Number^right|Date^right|Brief Description^left|Status^left|Area|Class|Assigned To|Last Contact|Customer^left"
            ) skip.
    else {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="97%"') skip
           htmlib-TableHeading(
            "Issue Number^right|Date^right|Brief Description^left|Status^left|Area|Class"
            ) skip.

    RUN ip-SetQueryRanges.
            

    RUN ip-BuildQueryPhrase.

 
    CREATE QUERY vhLQuery  
        ASSIGN 
        CACHE = 100 .

    vhLBuffer1 = BUFFER b-query:HANDLE.
    vhLBuffer2 = BUFFER b-qcust:HANDLE.

    vhLQuery:SET-BUFFERS(vhLBuffer1,vhLBuffer2).
    vhLQuery:QUERY-PREPARE(lc-QPhrase).
    vhLQuery:QUERY-OPEN().

    /*
    DYNAMIC-FUNCTION("com-WriteQueryInfo",vhlQuery).
    */
 
    vhLQuery:GET-FIRST(NO-LOCK).

    RUN ip-navigate.

    RUN ip-BuildIssueTable.

    
    IF li-count < li-max-lines THEN
    DO:
        {&out} skip htmlib-BlankTableLines(li-max-lines - li-count) skip.
    END.
    
    {&out} skip 
           htmlib-EndTable()
           skip.
    {lib/issnavpanel3.i "iss/issue.p"}
    {&out} skip
           htmlib-Hidden("firstrow", string(lr-first-row)) skip
           htmlib-Hidden("lastrow", string(lr-last-row)) skip
           skip.
    /*
    ***
    *** Dummy fields that are in selection for internal users but not customers
    *** so need them as get looked at in javascript
    ***
    */
    IF ll-customer THEN
    DO:
        {&out} 
            skip
            '<div style="display: none;">'
                format-Select-Account(htmlib-Select("account",lc-sel-account,lc-sel-account,lc-sel-account)) 
                format-Select-Account(htmlib-Select("assign",htmlib-Null(),htmlib-Null(),htmlib-Null())) 
                               
            '</div>'
            skip.
    END.
    /*
    *** Dummy field as chk box is required in JS 
    */
    IF  ll-customer
    OR this-user.accountManager = FALSE
    THEN {&out} skip
            '<div style="display: none;">'
                REPLACE(htmlib-CheckBox("accountmanager",false),
        '>',' onclick="ChangeAccount()">') '</div>' SKIP.
        
        

    IF ll-customer THEN
    DO:
        {&out} htmlib-mBanner(lc-global-Company).
    END.

    {&out} htmlib-EndForm() skip.
    {&out} htmlib-CalendarScript("lodate") skip
           htmlib-CalendarScript("hidate") skip.
    IF ll-customer AND get-value("showpdf") <> "" THEN
    DO:
        {&out} '<script>' skip
            "OpenNewWindow('"
                    appurl "/rep/viewpdf3.pdf?PDF=" 
                    url-encode(get-value("showpdf"),"query") "')" skip
            '</script>' skip.
    END.
    

    {&OUT} htmlib-Footer() skip.


END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-Format-Select-Account) = 0 &THEN

FUNCTION Format-Select-Account RETURNS CHARACTER
    ( pc-htm AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<select',
        '<select onChange="ChangeAccount()"')
        . 


    RETURN lc-htm.


END FUNCTION.


&ENDIF

