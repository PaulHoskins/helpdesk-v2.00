/***********************************************************************

    Program:        mn/menupanel.p
    
    Purpose:        Left Panel Menu   
    
    Notes:
    
    
    When        Who         What
    22/04/2006  phoski      Initial - replace old leftpanel.p      
    
    03/08/2010  DJS         Changed superuseranalysis for more effective 
                            run through issues table
    10/09/2010  DJS         3671 Amended to remove inventory renewals 
                              from 'alert' box.
    30/04/2014  phoski      Custview link for customers   
    11/12/2014  phoski      Renewal user 
    08/03/2015  phoski      Issue log for customer users      
    25/04/2015  phoski      Project Schedule
    24/05/2015  phoski      Dashboard Links
    22/10/2015  phoski      Link to issue page is by trafic light/asc
    13/03/2016  phoski      Change assignment build query
                              
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-user        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pass        AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-item        AS INTEGER   NO-UNDO.
DEFINE VARIABLE ll-Alert       AS LOG       NO-UNDO.

DEFINE VARIABLE MyUUID         AS RAW       NO-UNDO.
DEFINE VARIABLE cGUID          AS CHARACTER NO-UNDO. 

DEFINE VARIABLE lc-unq         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Enc-Key     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-renew       AS CHARACTER NO-UNDO.



DEFINE TEMP-TABLE tt-menu NO-UNDO
    FIELD ItemNo      AS INTEGER
    FIELD Level       AS INTEGER
    FIELD Description AS CHARACTER 
    FIELD ObjURL      AS CHARACTER
    FIELD ObjTarget   AS CHARACTER
    FIELD ObjType     AS CHARACTER
    FIELD AltInfo     AS CHARACTER
    FIELD aTitle      AS CHARACTER 
    FIELD OverDue     AS LOG

    INDEX i-ItemNo IS PRIMARY UNIQUE
    ItemNo.

DEFINE VARIABLE lc-system    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-image     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-company   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-address   AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-cust-open AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-user-open AS INTEGER   NO-UNDO.

DEFINE VARIABLE li-total     AS INTEGER   NO-UNDO.

DEFINE TEMP-TABLE tt NO-UNDO
    FIELD ACode        AS CHARACTER
    FIELD ADescription AS CHARACTER
    FIELD ACount       AS INTEGER
    FIELD CCount       AS INTEGER   EXTENT 4
    INDEX i-ACode IS PRIMARY ACode 
    INDEX i-ACount           ACount DESCENDING ADescription.






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

&IF DEFINED(EXCLUDE-ip-InternalUser) = 0 &THEN

PROCEDURE ip-InternalUser :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-ActionCount AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-AlertCount  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-EmailCount  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-UnCount     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-Inventory   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-Random      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-OpenAction  AS INTEGER   NO-UNDO.


    li-ActionCount = com-NumberOfActions(webUser.LoginID).
    li-AlertCount  = com-NumberOfAlerts(webUser.LoginID).
    li-EmailCount  = com-NumberOfEmails(webUser.LoginID).
    li-OpenAction  = com-NumberOfOpenActions(webUser.LoginId).


    IF WebUser.SuperUser
        AND WebUser.UserClass = "INTERNAL"
        THEN li-uncount = com-NumberUnAssigned(webuser.CompanyCode).
    ASSIGN
        ll-Alert = li-ActionCount > 0 OR li-AlertCount > 0 
                   OR li-unCount > 0 OR li-EmailCount > 0
                   OR li-Inventory > 0
                   OR li-OpenAction > 0
        .

    IF WebUser.UserClass = "INTERNAL" THEN
    DO:
        {&out} 
        '<br /><a class="tlink" style="width: 100%;" href="' appurl
        '/time/diaryframe.p' lc-random '" target="mainwindow" title="Diary View">' skip
                'Your Diary' 
                '</a><br /><br />' skip.     
                
        IF DYNAMIC-FUNCTION("com-HasSchedule",webuser.CompanyCode,WebUser.LoginID) > 0 THEN
        DO:
            ASSIGN 
                lc-enc-key =
               DYNAMIC-FUNCTION("sysec-EncodeValue",WebUser.LoginID,TODAY,"ScheduleKey",STRING(ROWID(webuser))).
                 
            {&out} 
            '<br /><a class="tlink" style="width: 100%;" href="' appurl
            '/sched/yourschedule.p?engineer=' url-encode(lc-enc-key,"Query")  '" target="mainwindow" title="Project Schedule">' skip
                'Your Project Schedule' 
                    '</a><br /><br />' skip. 
        END.        
                 
    END.



    IF ll-Alert THEN
    DO:
        {&out} '<div class="menualert">'.
        ASSIGN
            lc-Random = "?random=" + string(int(TODAY)) + string(TIME) + string(ETIME) + string(ROWID(webuser)).
        IF li-ActionCount > 0
            OR li-AlertCount > 0 THEN
        DO:
            {&out} 
            '<a class="tlink" style="border:none; width: 100%;" href="' appurl
            '/mn/alertpage.p' lc-random '" target="mainwindow" title="Alerts">Your' skip.
         
            IF li-ActionCount > 0 THEN
                {&out} ' actions (' li-ActionCount ')'.
            IF li-AlertCount > 0 THEN
            DO:
                {&out} ( IF li-ActionCount > 0 THEN ' & ' ELSE ' ' ) 'SLA alerts (' li-AlertCount ')'.
            END.
            {&out} '</a><br />' skip.
        END.
        IF li-unCount > 0 
            THEN {&out} 
        '<a class="tlink" style="border: none; width: 100%;" href="' appurl
        '/iss/issue.p' lc-random '&status=allopen&assign=NotAssigned" target="mainwindow" title="Unassigned Issues">'
        li-uncount ' Unassigned Issues</a><br />'.

        IF li-EmailCount > 0 
            THEN {&out} 
        '<a class="tlink" style="border: none; width: 100%;" href="' appurl
        '/mail/mail.p' lc-random '" target="mainwindow" title="HelpDesk Emails">'
        li-EmailCount ' HelpDesk Emails</a><br />'.

        IF li-Inventory > 0 
            THEN {&out} 
        '<a class="tlink" style="border: none; width: 100%;" href="' appurl
        '/cust/ivrenewal.p' lc-random '" target="mainwindow" title="Inventory Renewals">'
        li-Inventory ' Inventory Renewals</a><br />'.
        IF li-OpenAction > 0
            THEN {&out} 
        '<a class="tlink" style="border: none; width: 100%;" href="' appurl
        '/iss/openaction.p' lc-random '" target="mainwindow" title="Open Actions">' skip
                'Open Actions (' li-OpenAction ')'
                '</a><br />' skip.

   
        {&out} '</div>'.

    END.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-NewMenu) = 0 &THEN

PROCEDURE ip-NewMenu :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
   
    DEFINE BUFFER b-tt-menu  FOR tt-menu.
    DEFINE BUFFER b-sub-menu FOR tt-menu.
    DEFINE VARIABLE lc-object AS CHARACTER NO-UNDO.

    


    DEFINE VARIABLE lc-desc   AS CHARACTER NO-UNDO.


    {&out} '<div id="menustrip" style="margin: 7px;">' htmlib-BeginCriteria("Menu").

    {&out} '<div id="menu">' skip.

    FOR EACH tt-menu NO-LOCK :
        IF tt-menu.Level > 1 THEN NEXT.
        
       
        IF tt-menu.ObjType = "WS" THEN
        DO:

            IF INDEX(tt-menu.ObjURL,"?") > 0
                THEN lc-unq = '&UniqueID='  + cGUID.
            ELSE lc-unq = '?UniqueID='  + cGUID.

            {&out} '<div class="menusub" style="margin-left: 0px;">' skip
                   '<table><tr><td nowrap>'.
            {&out} '<a href="'  appurl  '/' tt-menu.ObjURL lc-unq  '" target="' tt-menu.ObjTarget '"' skip.
              
            {&out} ' title="' + html-encode(tt-menu.description) '"'.

            {&out} '>' skip
                     html-encode(tt-menu.description) 
                    '</a></br>' skip.
            {&out} '</td></tr>'.
            {&out} '</table></div>' skip.

            NEXT.
        END.
       
        ASSIGN 
            lc-desc = html-encode(tt-menu.description).

        ASSIGN
            lc-object = "msub" + string(tt-menu.ItemNo).

        {&out}
        '<div id="mhd' tt-menu.ItemNo '" class="menuhd">'
        '<img src="/images/general/menuclosed.gif" onClick="hdexpandcontent(this, ~''
        lc-object '~')">'
        '&nbsp;'
        lc-desc
        '</div>' skip.
        
        {&out} '<div class="menusub" style="display:none;" id="' lc-Object  '">' skip.

        {&out} '<table>'.

        FOR EACH b-sub-menu WHERE b-sub-menu.ItemNo > tt-menu.ItemNo NO-LOCK   :

            IF b-sub-menu.Level = 1 THEN LEAVE.

            IF ROWID(b-sub-menu) = rowid(tt-menu) THEN NEXT.
            {&out} '<tr><td nowrap>'.

            

            IF INDEX(b-sub-menu.ObjURL,"?") > 0
                THEN lc-unq = '&UniqueID='  + cGUID.
            ELSE lc-unq = '?UniqueID='  + cGUID.
           
            {&out} '<a href="'  appurl  '/' b-sub-menu.ObjURL lc-unq  '" target="' b-sub-menu.ObjTarget '"'.
                
            {&out} ' title="' + html-encode(b-sub-menu.description) '"'.
            {&out}  '>'
            html-encode(b-sub-menu.description) 
            '</a></br>' skip.
            {&out} '</td></tr>'.
                   
            
        END.
        {&out} '</table>'.

        {&out} '</div>' skip.

    END.

    {&out} '</div>' skip.

    {&out} htmlib-EndCriteria() '</div>'.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-SuperUserAnalysis) = 0 &THEN

PROCEDURE ip-SuperUserAnalysis :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE BUFFER b-Issue     FOR Issue.
    DEFINE BUFFER Issue       FOR Issue.
    DEFINE BUFFER webUsteam   FOR webUsteam.
    DEFINE BUFFER customer    FOR customer.
    DEFINE BUFFER b-WebStatus FOR WebStatus.
    
    DEFINE VARIABLE ll-Steam AS LOG       NO-UNDO.


    DEFINE VARIABLE iloop    AS INTEGER   NO-UNDO.

    ll-Steam = DYNAMIC-FUNCTION("com-isTeamMember", lc-global-company,lc-user,?).

    FOR EACH WebStatus NO-LOCK
        WHERE WebStatus.CompanyCode = lc-global-company
          AND WebStatus.CompletedStatus = FALSE,
          EACH Issue NO-LOCK
            WHERE Issue.CompanyCode = lc-global-company
              AND Issue.StatusCode = WebStatus.StatusCode
              :
        
        IF Issue.AssignTo = "" THEN NEXT.
        
          
        IF ll-Steam THEN
        DO:
            FIND customer OF issue NO-LOCK NO-ERROR.
            IF NOT AVAILABLE customer THEN NEXT.
            IF Customer.st-num = 0 THEN NEXT.
           
    
            IF NOT CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = lc-user
                AND webusteam.st-num = customer.st-num NO-LOCK) 
            THEN NEXT.
            
            IF NOT CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = Issue.assignTo
                AND webusteam.st-num = customer.st-num NO-LOCK) 
            THEN NEXT.
        
        END.
        
        ASSIGN 
            li-total = li-total + 1.
    
        FIND tt WHERE tt.ACode = Issue.AssignTo USE-INDEX i-Acode NO-ERROR.
        IF NOT AVAILABLE tt THEN
        DO:
            CREATE tt.
            ASSIGN 
                tt.Acode = Issue.AssignTo.
            ASSIGN 
                tt.ADescription = DYNAMIC-FUNCTION("com-UserName",Issue.AssignTo).
    
        END.
        ASSIGN 
            tt.Acount = tt.ACount + 1.
        DO iloop = 1 TO NUM-ENTRIES(lc-global-iclass-code,"|"):
            IF issue.iclass = ENTRY(iloop,lc-global-iclass-code,"|")
                THEN ASSIGN tt.ccount[iloop] = tt.ccount[iloop] + 1.
        END.
    
    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-SuperUserFinal) = 0 &THEN

PROCEDURE ip-SuperUserFinal :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    RUN ip-SuperUserAnalysis.

    DEFINE VARIABLE iloop    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-class AS CHARACTER NO-UNDO.

    FIND FIRST tt NO-LOCK NO-ERROR.
    
    
    
    IF AVAILABLE tt THEN
    DO:
        {&out} '<div style="margin: 7px;">'.


        {&out} htmlib-BeginCriteria("Assignments - " + string(TIME,'hh:mm am')).

        {&out} '<table style="font-size: 10px;">'.

        IF lc-renew <> "" THEN
        DO:
            FIND FIRST tt WHERE tt.ACode = lc-renew NO-LOCK NO-ERROR.
            {&out} 
            '<tr><td nowrap  style="vertical-align:top">'
            '<a title="Inventory Renewals" target="mainwindow" class="tlink" style="border:none;' 
            IF AVAILABLE tt THEN 'color: red;' 
            ELSE ''
            '" href="' appurl '/iss/issue.p?frommenu=yes&status=allopen&assign=' lc-renew '">'
            html-encode("Renewals")
            '</a></td><td align=right class="menuinfo">' 
            IF AVAILABLE tt THEN tt.ACount 
            ELSE 0 '&nbsp;</td></tr>'.
        END.
        

        FOR EACH tt NO-LOCK WHERE tt.ACode <> lc-renew USE-INDEX i-ACount :
            lc-Class = TRIM(SUBSTR(tt.ADescription,1,15)).
            {&out} 
            '<tr><td nowrap  style="vertical-align:top">'
            '<a title="View All Issues For ' html-encode(tt.ADescription) '" target="mainwindow" class="tlink" style="border:none;" href="' 
            appurl '/iss/issue.p?frommenu=yes&status=allopen&iclass=All&sortfield=b-query.tlight&sortorder=ASC&assign=' tt.ACode '">'
            html-encode(lc-class)
            '</a></td>' SKIP.
            IF tt.Acount = 0 THEN
                {&out} '<td align=right class="menuinfo">' tt.ACount '</td></tr>'.
             ELSE
             DO:
        {&out} '<td align=right  style="vertical-align:top">' SKIP.
        DO iloop = 1 TO NUM-ENTRIES(lc-global-iclass-code,"|"):
            IF iloop > 3 THEN NEXT.
            lc-class = ENTRY(iloop,lc-global-iclass-code,"|").
            IF iloop > 1 THEN {&out} '-'.
            {&out} 
            '<a title="View Issues For ' lc-class '" target="mainwindow" class="tlink" style="border:none;" href="' 
            appurl '/iss/issue.p?frommenu=yes&status=allopen&iclass=' lc-class '&sortfield=b-query.tlight&sortorder=ASC&assign=' tt.ACode '">'
            STRING(tt.CCount[iloop]) '</a>' SKIP.


        END.

        {&out} '</td></tr>' SKIP.




    END.

            
END.
{&out} '</table>'.
{&out} htmlib-EndCriteria().
{&out} '</div>'.
END.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-mnlib-BuildIssueMenu) = 0 &THEN

PROCEDURE mnlib-BuildIssueMenu :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE INPUT PARAMETER pc-menu     AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pi-level    AS INTEGER  NO-UNDO.

    DEFINE BUFFER b-menu   FOR webmhead.
    DEFINE BUFFER b2-menu  FOR webmhead.
    DEFINE BUFFER b-line   FOR webmline.
    DEFINE BUFFER b2-line  FOR webmline.
    DEFINE BUFFER b-object FOR webobject.
    DEFINE BUFFER b-user   FOR webuser.

    DEFINE VARIABLE li-ItemNo AS INTEGER    NO-UNDO.
    DEFINE VARIABLE lc-desc   AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE ll-found  AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE li-loop   AS INTEGER    NO-UNDO.
    
    
    FIND b-user WHERE b-user.loginid = lc-user NO-LOCK NO-ERROR.
    
    ASSIGN
        ll-found = FALSE.
    IF b-user.dashbList <> "" THEN
    DO:
        DO li-loop = 1 TO NUM-ENTRIES(b-user.dashbList):
            FIND dashb WHERE dashb.CompanyCode = b-user.companyCode
                          AND dashb.dashCode = entry(li-loop,b-user.dashbList) 
                          AND dashb.isActive = TRUE
                          NO-LOCK NO-ERROR.
                          
            IF ll-found = FALSE THEN
            DO:
                FIND LAST tt-menu NO-LOCK NO-ERROR.
                ASSIGN 
                    li-itemno = IF AVAILABLE tt-menu 
                               THEN tt-menu.itemno + 1
                               ELSE 1.
                 CREATE tt-menu.
                 ASSIGN 
                        tt-menu.ItemNo      = li-itemno
                        tt-menu.Level       = pi-level
                        tt-menu.Description = "Your Dashboards"
                        ll-found = TRUE.
            END.
            FIND LAST tt-menu NO-LOCK NO-ERROR.
            ASSIGN 
                li-itemno = IF AVAILABLE tt-menu 
                               THEN tt-menu.itemno + 1
                               ELSE 1.
            CREATE tt-menu.
            ASSIGN 
                tt-menu.itemno      = li-itemno
                tt-menu.Level       = pi-level + 1
                tt-menu.Description = dashb.descr
                tt-menu.ObjType     = "WS"
                tt-menu.ObjTarget   = "mainwindow"
                tt-menu.ObjURL      = "dashboard/dashboard.p?mode=display&rowid=" + string(ROWID(dashb)).
            .                 
                             
        END.    
            
    END.

    IF CAN-DO("INTERNAL,CONTRACT",b-user.UserClass) THEN
    DO:
        FOR EACH Issue NO-LOCK
            WHERE Issue.CompanyCode = b-user.CompanyCode
            AND Issue.AssignTo = b-user.LoginID,
            FIRST WebStatus NO-LOCK
            WHERE WebStatus.CompanyCode = Issue.CompanyCode 
            AND WebStatus.StatusCode = Issue.StatusCode
            AND WebStatus.CompletedStatus = FALSE

            BREAK BY Issue.AccountNumber
            BY Issue.IssueNumber DESCENDING:

            FIND Customer OF Issue NO-LOCK NO-ERROR.
            
            ASSIGN 
                lc-enc-key =
                 DYNAMIC-FUNCTION("sysec-EncodeValue",lc-user,TODAY,"customer",STRING(ROWID(customer))).
                 
            
            ASSIGN 
                lc-desc = IF AVAILABLE customer THEN customer.name 
                             ELSE "No Customer".

            IF FIRST-OF(issue.AccountNumber) THEN
            DO:
                FIND LAST tt-menu NO-LOCK NO-ERROR.
                ASSIGN 
                    li-itemno = IF AVAILABLE tt-menu 
                               THEN tt-menu.itemno + 1
                               ELSE 1.
                CREATE tt-menu.
                ASSIGN 
                    tt-menu.ItemNo      = li-itemno
                    tt-menu.Level       = pi-level
                    tt-menu.Description = lc-desc.

                FIND FIRST CustIV OF customer NO-LOCK NO-ERROR.
                IF AVAILABLE custIV THEN
                DO:
                    FIND LAST tt-menu NO-LOCK NO-ERROR.
                    ASSIGN 
                        li-itemno = IF AVAILABLE tt-menu 
                               THEN tt-menu.itemno + 1
                               ELSE 1.
                    CREATE tt-menu.
                    ASSIGN 
                        tt-menu.itemno      = li-itemno
                        tt-menu.Level       = pi-level + 1
                        tt-menu.Description = "Inventory"
                        tt-menu.ObjType     = "WS"
                        tt-menu.ObjTarget   = "mainwindow"
                        tt-menu.ObjURL      = "cust/custequiplist.p?expand=yes&customer=" +  url-encode(lc-enc-key,"Query") 
                        .
                    ASSIGN 
                        tt-menu.aTitle = 'Inventory for ' + html-encode(customer.name).
                    
                END.
            END.
            FIND LAST tt-menu NO-LOCK NO-ERROR.
            ASSIGN 
                li-itemno = IF AVAILABLE tt-menu 
                               THEN tt-menu.itemno + 1
                               ELSE 1.
            CREATE tt-menu.
            ASSIGN 
                tt-menu.itemno      = li-itemno
                tt-menu.Level       = pi-level + 1
                tt-menu.Description = STRING(Issue.IssueNumber) + ' ' + 
                                         Issue.BriefDescription
                tt-menu.ObjType     = "WS"
                tt-menu.ObjTarget   = "mainwindow"
                tt-menu.ObjURL      = "iss/issueframe.p?mode=update&return=home&rowid=" + string(ROWID(issue)).
            .

            IF Issue.PlannedCompletion <> ?
                AND Issue.PlannedCompletion < TODAY THEN
                ASSIGN tt-menu.OverDue = TRUE.
           
        END.
    END.
    ELSE
    /*
    ***
    *** Customer 
    ***
    */
    DO:
        FOR EACH Issue NO-LOCK
            WHERE Issue.CompanyCode = b-user.CompanyCode
            AND Issue.AccountNumber = b-user.AccountNumber,
            FIRST WebStatus WHERE webStatus.CompanyCode = Issue.CompanyCode
            AND WebStatus.StatusCode = Issue.StatusCode
            AND WebStatus.CompletedStatus = FALSE

            BREAK BY Issue.AreaCode
            BY Issue.IssueNumber DESCENDING:

            FIND WebIssArea OF Issue NO-LOCK NO-ERROR.

            ASSIGN 
                lc-desc = IF AVAILABLE WebIssArea THEN WebIssArea.Description 
                             ELSE "Not Known".

            IF FIRST-OF(issue.AreaCode) THEN
            DO:
                FIND LAST tt-menu NO-LOCK NO-ERROR.
                ASSIGN 
                    li-itemno = IF AVAILABLE tt-menu 
                               THEN tt-menu.itemno + 1
                               ELSE 1.
                CREATE tt-menu.
                ASSIGN 
                    tt-menu.ItemNo      = li-itemno
                    tt-menu.Level       = pi-level
                    tt-menu.Description = lc-desc.
            END.
            FIND LAST tt-menu NO-LOCK NO-ERROR.
            ASSIGN 
                li-itemno = IF AVAILABLE tt-menu 
                               THEN tt-menu.itemno + 1
                               ELSE 1.
            CREATE tt-menu.
            ASSIGN 
                tt-menu.itemno      = li-itemno
                tt-menu.Level       = pi-level + 1
                tt-menu.Description = STRING(Issue.IssueNumber) + ' ' + 
                                         Issue.BriefDescription
                tt-menu.ObjType     = "WS"
                tt-menu.ObjTarget   = "mainwindow"
                tt-menu.ObjURL      = "iss/issueview.p?mode=update&return=home&rowid=" + string(ROWID(issue)).
            .
           
        END.
    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-mnlib-BuildMenu) = 0 &THEN

PROCEDURE mnlib-BuildMenu :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER pc-menu     AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pi-level    AS INTEGER  NO-UNDO.

    DEFINE BUFFER b-menu   FOR webmhead.
    DEFINE BUFFER b2-menu  FOR webmhead.
    DEFINE BUFFER b-line   FOR webmline.
    DEFINE BUFFER b2-line  FOR webmline.
    DEFINE BUFFER b-object FOR webobject.

    DEFINE VARIABLE li-ItemNo   AS INTEGER NO-UNDO.
    DEFINE VARIABLE ll-has-side AS LOG     NO-UNDO.

    FIND b-menu WHERE b-menu.pagename = pc-menu NO-LOCK NO-ERROR.

    IF NOT AVAILABLE b-menu THEN RETURN.

    FOR EACH b-line OF b-menu NO-LOCK:
        IF b-line.linktype = 'page' THEN
        DO:
            FIND b2-menu WHERE b2-menu.pagename = b-line.linkobject
                NO-LOCK NO-ERROR.
            IF NOT AVAILABLE b2-menu THEN NEXT.
            FIND FIRST b2-line OF b2-menu NO-LOCK NO-ERROR.
            IF NOT AVAILABLE b2-line THEN NEXT.
            ASSIGN 
                ll-has-side = FALSE.
            FOR EACH b2-line OF b2-menu NO-LOCK:
                FIND b-object WHERE b-object.objectid = b2-line.linkobject NO-LOCK NO-ERROR.
                IF NOT AVAILABLE b-object THEN NEXT.
                IF CAN-DO("l,b",b-object.menulocation) = FALSE THEN NEXT.
                ASSIGN 
                    ll-has-side = TRUE.
                LEAVE.
            END.
            IF NOT ll-has-side THEN NEXT.
        END.
        ELSE
        DO:
            FIND b-object WHERE b-object.objectid = b-line.linkobject
                NO-LOCK NO-ERROR.
            IF NOT AVAILABLE b-object THEN NEXT.
            IF CAN-DO("l,b",b-object.menulocation) = FALSE THEN NEXT.
        END.
        FIND LAST tt-menu NO-LOCK NO-ERROR.
        ASSIGN 
            li-itemno = IF AVAILABLE tt-menu 
                           THEN tt-menu.itemno + 1
                           ELSE 1.
        IF b-line.linktype = 'Page' THEN
        DO:
            CREATE tt-menu.
            ASSIGN 
                tt-menu.ItemNo      = li-itemno
                tt-menu.Level       = pi-Level
                tt-menu.Description = b2-menu.PageDesc.
            RUN mnlib-BuildMenu( b2-menu.PageName, pi-level + 1 ).

        END.
        ELSE
        DO:
            CREATE tt-menu.
            ASSIGN 
                tt-menu.ItemNo      = li-itemno
                tt-menu.Level       = pi-Level
                tt-menu.Description = b-object.Description
                tt-menu.ObjURL      = b-object.ObjURL
                tt-menu.ObjTarget   = b-object.ObjTarget
                tt-menu.ObjType     = b-object.ObjType.

        END.
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
    output-content-type("text/plain~; charset=iso-8859-1":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/


    ASSIGN 
        lc-user = get-value("user")
        MyUUID = GENERATE-UUID  
        cGUID  = GUID(MyUUID). 


    RUN outputHeader.
    
    
    FIND webuser WHERE webuser.loginid = lc-user NO-LOCK NO-ERROR.

    
    
    IF AVAILABLE webuser THEN
    DO:
        ASSIGN
            lc-global-company = webuser.Company.
        FIND Company WHERE Company.companycode = lc-global-company NO-LOCK NO-ERROR.
        lc-renew = Company.renewal-login.

        {&out} '<div class="inform"><fieldset>'
        '<span class="menuinfo">'.

        IF CAN-DO(lc-global-internal,WebUser.UserClass) THEN
        DO:
                      
            RUN ip-InternalUser.
        END.
        ELSE
        DO:
            FIND customer WHERE customer.CompanyCode = WebUser.CompanyCode
                AND Customer.AccountNumber = webUser.AccountNumber
                NO-LOCK NO-ERROR.
                
            ASSIGN 
                lc-enc-key =
                 DYNAMIC-FUNCTION("sysec-EncodeValue",lc-user,TODAY,"customer",STRING(ROWID(customer))).
            ASSIGN
                lc-address   = customer.name
                li-cust-open = com-CustomerOpenIssues(customer.companycode,
                                                      customer.AccountNumber).

            lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.Address1).
            lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.Address2).
            lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.City).
            lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.County).
            lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.Country).
            lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.PostCode).

            {&out} '<p>' REPLACE(lc-address,"~n","<br>") '</p>'.
            {&out} SKIP
                '<a title="Your Details" target="mainwindow" class="tlink" style="border:none;" href="' appurl '/cust/custview.p?source=menu&rowid=' 
                    url-encode(lc-enc-key,"Query") '">'
                "View Your Details"
                '</a>' SKIP.


        END.
        {&out} '</span>'.
        {&out}
        '</fieldset></div>'.

        IF CAN-DO(lc-global-internal,WebUser.UserClass) THEN
        DO:
        
            IF webUser.UserClass = "INTERNAL" 
                AND webUser.SuperUser THEN
            DO:
                FIND LAST tt-menu NO-LOCK NO-ERROR.
                ASSIGN 
                    li-item = IF AVAILABLE tt-menu THEN tt-menu.itemno + 1 
                             ELSE 1.
                CREATE tt-menu.
                ASSIGN 
                    tt-menu.itemno      = li-item
                    tt-menu.Level       = 1
                    tt-menu.Description = "HelpDesk Monitor"
                    tt-menu.ObjType     = "WS"
                    tt-menu.ObjTarget   = "mainwindow"
                    tt-menu.ObjURL      = 'iss/issueoverview.p?frommenu=yes'
                    tt-menu.AltInfo     = "Monitor HelpDesk issues"
                    .
            END.

            ASSIGN 
                li-user-open = com-AssignedToUser(webuser.CompanyCode,
                                                     webuser.LoginID).
            FIND LAST tt-menu NO-LOCK NO-ERROR.
            ASSIGN 
                li-item = IF AVAILABLE tt-menu THEN tt-menu.itemno + 1 
                         ELSE 1.
            CREATE tt-menu.
            ASSIGN 
                tt-menu.itemno      = li-item
                tt-menu.Level       = 1
                tt-menu.Description = "Your Issues"
                tt-menu.ObjType     = "WS"
                tt-menu.ObjTarget   = "mainwindow"
                tt-menu.ObjURL      = 'iss/issue.p?assign=' + WebUser.LoginID + 
                    '&status=AllOpen&iclass=All&lodate=01/01/1990&hidate=01/01/2050&sortfield=b-query.tlight&sortorder=ASC'
                tt-menu.AltInfo     = "View your issues"
                .
            IF li-user-open > 0 
                THEN ASSIGN tt-menu.description = tt-menu.description + ' (' + 
                        string(li-user-open) + ' open)'.

        END.
        ELSE
        DO:
            FIND LAST tt-menu NO-LOCK NO-ERROR.
            ASSIGN 
                li-item = IF AVAILABLE tt-menu THEN tt-menu.itemno + 1 
                         ELSE 1.

            CREATE tt-menu.
            ASSIGN 
                tt-menu.itemno      = li-item
                tt-menu.Level       = 1
                tt-menu.Description = "Add New Issue"
                tt-menu.ObjType     = "WS"
                tt-menu.ObjTarget   = "mainwindow"
                tt-menu.ObjURL      = 'iss/addissue.p'.
            .
            FIND LAST tt-menu NO-LOCK NO-ERROR.
            ASSIGN 
                li-item = IF AVAILABLE tt-menu THEN tt-menu.itemno + 1 
                        ELSE 1.

            CREATE tt-menu.
            ASSIGN 
                tt-menu.itemno      = li-item
                tt-menu.Level       = 1
                tt-menu.Description = "Your Issues"
                tt-menu.ObjType     = "WS"
                tt-menu.ObjTarget   = "mainwindow"
                tt-menu.ObjURL      = 'iss/issue.p?frommenu=yes&status=allopen&iclass=All'
                tt-menu.AltInfo     = "View your issues"
                .
            IF li-cust-open > 0 
                THEN ASSIGN tt-menu.description = tt-menu.description + ' (' + 
                        string(li-cust-open) + ' open)'.
            
            FIND LAST tt-menu NO-LOCK NO-ERROR.
            ASSIGN 
                li-item = IF AVAILABLE tt-menu THEN tt-menu.itemno + 1 
                        ELSE 1.

            CREATE tt-menu.
            ASSIGN 
                tt-menu.itemno      = li-item
                tt-menu.Level       = 1
                tt-menu.Description = "Issue Log"
                tt-menu.ObjType     = "WS"
                tt-menu.ObjTarget   = "mainwindow"
                tt-menu.ObjURL      = 'rep/issuelog.p'
                tt-menu.AltInfo     = "Issue Log"
                .
            
                                     
        END.

        RUN mnlib-BuildIssueMenu ( webuser.pagename, 1 ).

        RUN mnlib-BuildMenu ( webuser.pagename, 1 ).


        FIND LAST tt-menu NO-LOCK NO-ERROR.
        ASSIGN 
            li-item = IF AVAILABLE tt-menu THEN tt-menu.itemno + 1 
                         ELSE 1.

        CREATE tt-menu.
        ASSIGN 
            tt-menu.itemno      = li-item
            tt-menu.Level       = 1
            tt-menu.Description = "Preferences"
            tt-menu.ObjType     = "WS"
            tt-menu.ObjTarget   = "mainwindow"
            tt-menu.ObjURL      = 'sys/webuserpref.p'.
        .

        FIND LAST tt-menu NO-LOCK NO-ERROR.
        ASSIGN 
            li-item = IF AVAILABLE tt-menu THEN tt-menu.itemno + 1 
                         ELSE 1.

        CREATE tt-menu.
        ASSIGN 
            tt-menu.itemno      = li-item
            tt-menu.Level       = 1
            tt-menu.Description = "Change Your Password"
            tt-menu.ObjType     = "WS"
            tt-menu.ObjTarget   = "mainwindow"
            tt-menu.ObjURL      = 'mn/changepassword.p'.
        .

        RUN ip-NewMenu.
        
        IF WebUser.UserClass = "INTERNAL" 
            AND WebUser.SuperUser
            THEN RUN ip-SuperUserFinal.

    END.

    
  
END PROCEDURE.


&ENDIF

