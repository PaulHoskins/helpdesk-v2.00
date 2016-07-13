/***********************************************************************

    Program:        iss/issueemail.p
    
    Purpose:        Issue Email Page
    
    Notes:
    
    
    When        Who         What
    07/06/2014  phoski      Initial
    24/01/2015  phoski      email default always 'no email'
    15/08/2015  phoski      customer bulk email alert
    20/10/2015  phoski      com-GetHelpDeskEmail for email sender
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-print   AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-max-lines    AS INTEGER   INITIAL 12 NO-UNDO.
DEFINE VARIABLE lr-first-row    AS ROWID     NO-UNDO.
DEFINE VARIABLE lr-last-row     AS ROWID     NO-UNDO.
DEFINE VARIABLE li-count        AS INTEGER   NO-UNDO.

DEFINE VARIABLE lc-status       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-customer     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-issdate      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-raised       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-assigned     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitsource AS CHARACTER NO-UNDO.

DEFINE BUFFER issue      FOR issue.
DEFINE BUFFER customer   FOR customer.
DEFINE BUFFER WebStatus  FOR WebStatus.
DEFINE BUFFER WebUser    FOR WebUser.
DEFINE BUFFER WebIssArea FOR WebIssArea.
DEFINE BUFFER this-user  FOR WebUser.
DEFINE BUFFER b-tmp      FOR iemailtmp.
DEFINE BUFFER iemailtmp  FOR iemailtmp.

  

DEFINE VARIABLE lc-IPref        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-iField       AS CHARACTER NO-UNDO.


DEFINE VARIABLE li-col          AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-area         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-info         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-object       AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-tag-end      AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-dummy-return AS CHARACTER INITIAL "MYXXX111PPP2222" NO-UNDO.


DEFINE VARIABLE lc-seltmpcode   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-seltmpdesc   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-selActcode   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-selActdesc   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-QPhrase      AS CHARACTER NO-UNDO.
DEFINE VARIABLE vhLBuffer       AS HANDLE    NO-UNDO.
DEFINE VARIABLE vhLQuery        AS HANDLE    NO-UNDO.


{iss/issue.i}




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

&IF DEFINED(EXCLUDE-ip-EmailHTML) = 0 &THEN

PROCEDURE ip-EmailHTML :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
  
    DEFINE VARIABLE lc-descr   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-tmpcode AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-tmptxt  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-convtxt AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-action  AS CHARACTER NO-UNDO.


    {&out}
    '<tr><td colspan=' li-col '>' SKIP
       htmlib-BeginCriteria("Email Details " + STRING(issue.IssueNumber))
       htmlib-StartMntTable().

  
    
    ASSIGN 
        lc-IField = lc-iPref + 'Send'.
    lc-TmpCode = get-value(lc-IField).

    IF lc-tmpCode <> "" THEN
    DO:
        {&out} '<tr><td colspan=6><div class="infobox">Email sent to '
        lc-tmpCode
        '</div></td></tr>' SKIP.

    END.
    ASSIGN 
        lc-IField = lc-iPref + 'tmpsel'.

    IF request_method = "GET"
    THEN ASSIGN lc-tmpCode = "".
    ELSE ASSIGN
        lc-TmpCode = get-value(lc-IField).
   
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Email Template") '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">' SKIP
        htmlib-SelectJS(
            lc-iField,
            'ChangeTemplate(this)',
            lc-seltmpcode,
            lc-seltmpdesc,
            lc-tmpCode
            ) SKIP
           
            '</TD>' skip. 

    ASSIGN
        lc-IField = lc-iPref + 'act'.
    lc-action = get-value(lc-iField).

    {&out} '<TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Action") '</TD>' SKIP
          '<TD VALIGN="TOP" ALIGN="left">' SKIP
          htmlib-Select(
              lc-iField,
              lc-selActcode,
              lc-selActdesc,
              lc-Action
              ) SKIP

              '</TD>' skip. 



    ASSIGN
        lc-IField = lc-iPref + 'tmped'.
    lc-convtxt = get-value(lc-iField).

    {&out}
    '<TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Email") '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">' SKIP
        htmlib-textArea(lc-IField,lc-convtxt,20,100) 
        '</td>' SKIP.

    {&out}
    '</tr>' SKIP
        htmlib-EndTable()
        htmlib-EndCriteria()
        '</td></tr>' SKIP.

END PROCEDURE.


&ENDIF

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
        'function ChangeTemplate(obj) ~{' skip
        '   var selfld =  obj.name;' skip
        '   var tmpcode = obj.value;' SKIP
        '   var tmpedit = selfld.replace("tmpsel","tmped");' SKIP
        '   var TemplateAjax = "' 
           appurl '/iss/ajax/buildemail.p?company=' lc-global-company 
           '";' SKIP
        '   TemplateAjax += "&reference=" + selfld;' SKIP
        '   TemplateAjax += "&template=" + tmpcode;' SKIP
        '   TemplateAjax += "&edit=" + tmpedit;' SKIP
        "   new Ajax.Updater(tmpedit, TemplateAjax, ~{ method: 'get',evalScripts: true }~);" SKIP

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

    RUN com-getTemplateSelect ( lc-global-company,OUTPUT lc-seltmpcode, OUTPUT lc-seltmpdesc ).

    ASSIGN
        lc-seltmpcode = "|" + lc-seltmpCode
        lc-seltmpdesc = "No email|" + lc-seltmpdesc.


    RUN com-getAction ( lc-global-company,OUTPUT lc-selActCode, OUTPUT lc-selActdesc ).



END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ipGetMethodProcess) = 0 &THEN

PROCEDURE ipGetMethodProcess :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
   
    DEFINE BUFFER iemailtmp FOR iemailtmp.
    DEFINE BUFFER issue     FOR issue.
    DEFINE BUFFER WebStatus FOR WebStatus.

    DEFINE VARIABLE lc-descr   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-tmpcode AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-tmptxt  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-convtxt AS CHARACTER NO-UNDO.

    FOR EACH issue NO-LOCK WHERE issue.CompanyCode = lc-global-company
        AND issue.assignto = lc-global-user,
        FIRST WebStatus OF issue WHERE WebStatus.CompletedStatus = NO NO-LOCK:

        ASSIGN
            lc-ipref   = "I" + STRING(issue.IssueNumber)
            lc-IField  = lc-iPref + 'tmpsel'
            lc-TmpCode = issue.LastTmpCode.
       
        set-user-field(lc-iField,lc-TmpCode).

        IF lc-tmpCode = "" THEN NEXT.

        FIND iemailtmp
            WHERE iemailtmp.companyCode = lc-global-company
            AND iemailtmp.tmpCode = lc-tmpCode
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE iemailtmp THEN NEXT.
        
        RUN lib/translatetemplate.p 
            (
            lc-global-company,
            iemailtmp.tmpCode,
            issue.issueNumber,
            NO,
            iemailtmp.tmptxt,
            OUTPUT lc-convtxt,
            OUTPUT lc-descr
            ).
        
        
        lc-IField = lc-iPref + 'tmped'.
        set-user-field(lc-iField,lc-convtxt).
        





    END.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ipProcessEmail) = 0 &THEN

PROCEDURE ipProcessEmail :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/


    DEFINE BUFFER iemailtmp FOR iemailtmp.
    DEFINE BUFFER issue     FOR issue.
    DEFINE BUFFER WebStatus FOR WebStatus.
    DEFINE BUFFER b-table   FOR IssAction.
    DEFINE BUFFER u         FOR webuser.
    DEFINE BUFFER customer  FOR Customer.
    DEFINE BUFFER company   FOR Company.
    

    DEFINE VARIABLE lc-descr   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-tmpcode AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-convtxt AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-Action  AS CHARACTER NO-UNDO.


    DEFINE VARIABLE lf-Audit   AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE lc-temp    AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lr-temp    AS ROWID     NO-UNDO.
    DEFINE VARIABLE lc-emailTo AS CHARACTER NO-UNDO.


    FIND Company WHERE Company.CompanyCode = lc-global-company NO-LOCK.
    
    FOR EACH issue EXCLUSIVE-LOCK WHERE issue.CompanyCode = lc-global-company
        AND issue.assignto = lc-global-user,
        FIRST WebStatus OF issue WHERE WebStatus.CompletedStatus = NO NO-LOCK:


        FIND Customer WHERE Customer.CompanyCode = Issue.CompanyCode
                        AND Customer.AccountNumber = Issue.AccountNumber
                        NO-LOCK NO-ERROR.
                        
        ASSIGN
            lc-ipref = "I" + STRING(issue.IssueNumber).
            
        ASSIGN 
            lc-IField  = lc-iPref + 'tmpsel'
            lc-TmpCode = get-value(lc-IField).

        ASSIGN
            lc-IField = lc-iPref + 'act'.
        lc-action = get-value(lc-iField).


        ASSIGN
            lc-IField = lc-iPref + 'tmped'.
        lc-convtxt = get-value(lc-iField).


        IF lc-tmpCode = "" THEN NEXT.

        issue.LastTmpCode = lc-tmpCode.


        FIND WebAction
            WHERE WebAction.CompanyCode = lc-global-company
            AND WebAction.ActionCode  = lc-Action
            NO-LOCK NO-ERROR.
        
        CREATE b-table.
        ASSIGN 
            b-table.actionID     = WebAction.ActionID
            b-table.CompanyCode  = lc-global-company
            b-table.IssueNumber  = issue.IssueNumber
            b-table.CreateDate   = TODAY
            b-table.CreateTime   = TIME
            b-table.CreatedBy    = lc-global-user
            b-table.customerview = YES
            .

        DO WHILE TRUE:
            RUN lib/makeaudit.p (
                "",
                OUTPUT lf-audit
                ).
            IF CAN-FIND(FIRST IssAction
                WHERE IssAction.IssActionID = lf-audit NO-LOCK)
                THEN NEXT.
            ASSIGN
                b-table.IssActionID = lf-audit.
            LEAVE.
        END.

        ASSIGN 
            b-table.notes        = lc-convtxt
            b-table.ActionStatus = "CLOSED"
            b-table.ActionDate   = TODAY
            .

        ASSIGN 
            b-table.AssignDate = TODAY
            b-table.AssignTime = TIME
            b-table.AssignBy   = lc-global-user
            b-table.assignto   = lc-global-user.

        ASSIGN 
            lr-temp = ROWID(b-table).
        RELEASE b-table.

        FIND b-table WHERE ROWID(b-table) = lr-temp EXCLUSIVE-LOCK.
    
        DYNAMIC-FUNCTION("islib-CreateAutoAction",
            b-table.IssActionID).

        lc-emailTo = /* "Support@ouritdept.co.uk" */ Company.bulkemail.

        lc-emailTo = DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",issue.company,Issue.AccountNumber).
        FIND u WHERE u.loginid = issue.RaisedLogin NO-LOCK NO-ERROR.
        IF AVAILABLE u THEN lc-emailto = lc-emailto + "," + u.email.

        /*
        *** Bulk email notification alert 
        */
        
        IF Issue.RaisedLoginID <> Customer.def-bulk-loginid
        AND Customer.def-bulk-loginid <> "" THEN
        DO:   
            FIND FIRST u WHERE u.loginid = Customer.def-bulk-loginid NO-LOCK NO-ERROR.
            IF AVAILABLE u THEN lc-emailto = lc-emailto + "," + u.email.
        END.
       

        ASSIGN
            
            lc-IField = lc-iPref + 'Send'.
            
       
        set-user-field(lc-iField,lc-emailto).

        DYNAMIC-FUNCTION("mlib-SendEmail",
            lc-global-company,
            DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",issue.company,Issue.AccountNumber),
            "Issue " + 
            string(Issue.IssueNumber) + " - " + issue.BriefDescription,
            lc-convtxt,
            lc-emailto).






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
  
    {lib/checkloggedin.i}

    DEFINE VARIABLE iloop      AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cPart      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCode      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cDesc      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-LastAct AS CHARACTER NO-UNDO.
   
    
    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.
    

    RUN ip-InitialProcess.

    IF REQUEST_method = "GET" THEN
    DO:
        RUN ipGetMethodProcess.
    END.
    ELSE
    DO:
        RUN ipProcessEmail.

        
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header("Issue Email") skip.
    RUN ip-ExportJScript.
    {&out} htmlib-JScript-Maintenance() skip.
    {&out} htmlib-StartForm("mainform","post", appurl + '/iss/issueemail.p' ) skip.
    {&out} htmlib-ProgramTitle("Issue Email -" + this-user.NAME + " Open Issues ") 
    htmlib-hidden("submitsource","") skip.
    
   
  
    {&out}
    tbar-Begin("")
           
    tbar-BeginOption().
    {&out}
    tbar-Link("view",?,"off","").
    {&out}
    tbar-EndOption()
    tbar-End().


    {&out} skip
          replace(htmlib-StartMntTable(),'width="100%"','width="100%"') skip
          htmlib-TableHeading(
           "|SLA Date<br/>SLA Warning|Issue Number^right|Date^right|Brief Description^left|Status^left|Area|Class|Assigned To|Last Contact|Customer^left"
           ) skip.
    ASSIGN 
        li-col = 11.


    ASSIGN 
        li-count     = 0
        lr-first-row = ?
        lr-last-row  = ?.

    FOR EACH issue NO-LOCK WHERE issue.CompanyCode = lc-global-company
        AND issue.assignto = lc-global-user,
        FIRST WebStatus OF issue WHERE WebStatus.CompletedStatus = NO NO-LOCK
        BY issue.issuenumber DESCENDING:

 
        ASSIGN 
            lc-rowid   = STRING(ROWID(issue))
            lc-ipref   = "I" + STRING(issue.IssueNumber)
            lc-issdate = IF issue.issuedate = ? THEN "" ELSE STRING(issue.issuedate,'99/99/9999').
        ASSIGN 
            li-count = li-count + 1.
        IF lr-first-row = ?
            THEN ASSIGN lr-first-row = ROWID(issue).
        ASSIGN 
            lr-last-row = ROWID(issue).
       
        FIND customer OF issue NO-LOCK NO-ERROR.
        ASSIGN 
            lc-customer = IF AVAILABLE customer THEN customer.name ELSE "".

        ASSIGN 
            lc-status = WebStatus.Description.
        IF WebStatus.CompletedStatus
            THEN lc-status = lc-status + ' (closed)'.
        ELSE lc-status = lc-status + ' (open)'.
        
        
        FIND WebUser WHERE WebUser.LoginID = issue.AssignTo NO-LOCK NO-ERROR.
        ASSIGN 
            lc-assigned = "".
        IF AVAILABLE WebUser THEN
        DO:
            ASSIGN 
                lc-assigned = WebUser.name.
            IF issue.AssignDate <> ? THEN
                ASSIGN
                    lc-assigned = lc-assigned + "~n" + string(issue.AssignDate,"99/99/9999") + " " +
                                                  string(issue.AssignTime,"hh:mm am").
        END.

        FIND WebUser WHERE WebUser.LoginID = issue.RaisedLogin NO-LOCK NO-ERROR.
        
        ASSIGN 
            lc-raised = IF AVAILABLE WebUser THEN WebUser.name ELSE "".
        


        FIND WebIssArea OF issue NO-LOCK NO-ERROR.
        
        ASSIGN 
            lc-area = IF AVAILABLE WebIssArea THEN WebIssArea.description ELSE "".
        {&out}
            skip
            tbar-tr(rowid(issue))
            skip.

        /* SLA Traffic Light */
   
        {&out} '<td valign="top" align="right">' SKIP.

        IF issue.tlight = li-global-sla-fail
            THEN {&out} '<img src="/images/sla/fail.jpg" height="20" width="20" alt="SLA Fail">' SKIP.
        ELSE
        IF issue.tlight = li-global-sla-amber
        THEN {&out} '<img src="/images/sla/warn.jpg" height="20" width="20" alt="SLA Amber">' SKIP.
        
        ELSE
        IF issue.tlight = li-global-sla-ok
        THEN {&out} '<img src="/images/sla/ok.jpg" height="20" width="20" alt="SLA OK">' SKIP.
        
        ELSE {&out} '&nbsp;' SKIP.
        
        {&out} '</td>' skip.

        IF issue.slatrip <> ? THEN
        DO:
            {&out} '<td valign="top" align="left" nowrap>' SKIP
                   STRING(issue.slatrip,"99/99/9999 HH:MM") SKIP.


            IF issue.slaAmber <> ? THEN
                {&out} '<br/>' SKIP
                   STRING(issue.slaAmber,"99/99/9999 HH:MM") SKIP.
            {&out} '</td>' SKIP.

        END.
        ELSE {&out} '<td>&nbsp;</td>' SKIP.

        {&out}
        htmlib-MntTableField(html-encode(STRING(issue.issuenumber)),'right')
        htmlib-MntTableField(html-encode(lc-issdate),'right').
        IF issue.LongDescription <> ""
            AND issue.LongDescription <> issue.briefdescription THEN
        DO:
            ASSIGN 
                lc-info   = REPLACE(htmlib-MntTableField(html-encode(issue.briefdescription),'left'),'</td>','')
                lc-object = "hdobj" + string(issue.issuenumber).
            ASSIGN 
                li-tag-end = INDEX(lc-info,">").
            {&out} substr(lc-info,1,li-tag-end).
            ASSIGN 
                substr(lc-info,1,li-tag-end) = "".
            {&out} 
            '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
            lc-object '~')">':U skip.
            {&out} lc-info.
            {&out} htmlib-ExpandBox(lc-object,issue.LongDescription).
            {&out} '</td>' skip.
        END.
        ELSE {&out} htmlib-MntTableField(html-encode(issue.briefdescription),"left").
        {&out}
        htmlib-MntTableField(html-encode(lc-status),'left')
        htmlib-MntTableField(html-encode(lc-area),'left')
        htmlib-MntTableField(html-encode(issue.iclass),'left').
      
        IF issue.lastActivity = ?
            THEN lc-lastAct = "".
        ELSE lc-lastAct = STRING(issue.lastActivity,"99/99/9999 HH:MM").
        
        {&out}
        htmlib-MntTableField(REPLACE(html-encode(lc-assigned),"~n","<br>"),'left')
        htmlib-MntTableField(REPLACE(html-encode(lc-LastAct),"~n","<br>"),'left').

        
        IF lc-raised = ""
            THEN {&out} htmlib-MntTableField(html-encode(lc-customer),'left').
        else
        do:
    ASSIGN 
        lc-info   = REPLACE(htmlib-MntTableField(html-encode(lc-customer),'left'),'</td>','')
        lc-object = "hdobjcust" + string(issue.issuenumber).
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
    
        
{&out} skip
                tbar-BeginHidden(rowid(issue)).
        
{&out}
tbar-Link("view",ROWID(issue),
    'javascript:HelpWindow('
    + '~'' + appurl 
    + '/iss/issueview.p?rowid=' + string(ROWID(issue))
    + '~'' 
    + ');'
    ,"").
        
{&out}
tbar-EndHidden()
            SKIP.
          
{&out}
'</tr>' skip.

RUN ip-EmailHTML.
 
       
END.
 
    
{&out} skip 
           htmlib-EndTable()
           skip.

{&out} '<center>' htmlib-SubmitButton("submitform","Generate Emails") 
'</center>' skip.
    

{&out} htmlib-EndForm() skip.

   

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

