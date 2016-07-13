/***********************************************************************

    Program:        mn/alertpage.p
    
    Purpose:        Alert Info    
    
    Notes:
    
    
    When        Who         What
    08/05/2006  phoski      Initial
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

{iss/issue.i}

DEFINE BUFFER customer     FOR Customer.
DEFINE BUFFER WebAction    FOR WebAction.
DEFINE BUFFER Issue        FOR Issue.

DEFINE VARIABLE lc-info             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-object           AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-tag-end          AS INTEGER NO-UNDO.
DEFINE VARIABLE lc-dummy-return     AS CHARACTER INITIAL "MYXXX111PPP2222"   NO-UNDO.

DEFINE VARIABLE lc-Action-TBAR      AS CHARACTER
    INITIAL "actiontb"      NO-UNDO.
DEFINE VARIABLE lc-Alert-TBAR      AS CHARACTER
    INITIAL "alerttb"      NO-UNDO.


&GlOBAL-DEFINE object-class INTERNAL-ONLY

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

&IF DEFINED(EXCLUDE-ip-ActionTable) = 0 &THEN

PROCEDURE ip-ActionTable :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER b-query      FOR IssAction.

    DEFINE VARIABLE lc-assign-info      AS CHARACTER NO-UNDO.
    

    {&out} skip
           htmlib-StartFieldSet("Actions Assigned To You") 
           
    .

    {&out}
    tbar-BeginID(lc-Action-TBAR,"")
    tbar-BeginOptionID(lc-Action-TBAR) SKIP(2)
    tbar-Link("view",?,"off","")
    tbar-Link("update",?,"off","")
    tbar-EndOption()
            
    tbar-End().

    {&out} htmlib-StartMntTable()
    htmlib-TableHeading(
        "Customer|Issue^right|Details|Action Date^left|Action Details^left|Assigned By"
        ) skip.
    FOR EACH b-query NO-LOCK
        WHERE b-query.AssignTo = lc-global-user
        AND b-query.ActionStatus = "OPEN",
        EACH Issue NO-LOCK
        WHERE Issue.CompanyCode = b-Query.CompanyCode
        AND Issue.IssueNumber = b-Query.IssueNumber,
        EACH Customer NO-LOCK
        WHERE Customer.CompanyCode = Issue.CompanyCode
        AND Customer.AccountNumber = Issue.AccountNumber

        BREAK BY b-query.AssignDate 
        BY b-query.AssignTime
                    
        :


        
        FIND WebAction 
            WHERE WebAction.ActionID = b-query.ActionID
            NO-LOCK NO-ERROR.

       
        {&out}
        SKIP(1)
        tbar-trID(lc-Action-TBAR,ROWID(b-query))
        SKIP(1)
        htmlib-MntTableField(
            html-encode(customer.AccountNumber + ' ' + customer.name),'left')
        htmlib-MntTableField(STRING(b-query.IssueNumber),'right') 
        htmlib-MntTableField(html-encode(issue.BriefDescription),'left')
        htmlib-MntTableField(STRING(b-query.ActionDate,"99/99/9999"),'left') skip
        .

        IF b-query.notes <> "" THEN
        DO:
        
            ASSIGN 
                lc-info = 
                REPLACE(htmlib-MntTableField(html-encode(WebAction.Description),'left'),'</td>','')
                lc-object = "hdobj" + string(b-query.issActionID).
        
            ASSIGN 
                li-tag-end = INDEX(lc-info,">").

            {&out} substr(lc-info,1,li-tag-end).

            ASSIGN 
                substr(lc-info,1,li-tag-end) = "".
            
            {&out} 
            '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
            lc-object '~')">':U skip.
            {&out} lc-info.
    
            {&out} htmlib-ExpandBox(lc-object,b-query.Notes).

            {&out} '</td>' skip.
        END.
        ELSE {&out}
        htmlib-MntTableField(WebAction.Description,'left').
        
        ASSIGN 
            lc-assign-info = com-userName(b-query.AssignBy).

        IF lc-assign-info <> "" AND b-query.AssignDate <> ? 
            THEN ASSIGN lc-assign-info = lc-assign-info + ' ' + 
                                     string(b-query.AssignDate,'99/99/9999') + ' ' + 
                                     string(b-query.AssignTime,'hh:mm am').

        {&out}
        htmlib-MntTableField(lc-Assign-Info,'left').

        {&out} skip
                tbar-BeginHidden(rowid(b-query))
                tbar-Link("view",rowid(b-query),
                          'javascript:HelpWindow('
                          + '~'' + appurl 
                          + '/iss/issueview.p?rowid=' + string(rowid(Issue))
                          + '~'' 
                          + ');'
                          ,"")
                tbar-Link("update",rowid(issue),appurl + '/' + "iss/issueframe.p","")
                
            tbar-EndHidden()

            skip.

        {&out}
        '</tr>' skip.

       

    END.


    {&out} htmlib-EndTable() skip.

    {&out} skip 
           htmlib-EndFieldSet() 
           skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-AlertTable) = 0 &THEN

PROCEDURE ip-AlertTable :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER b-query      FOR IssAlert.

    DEFINE VARIABLE lc-sla-info     AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE ll-missed       AS LOG NO-UNDO.
        
    {&out} skip
           htmlib-StartFieldSet("SLA Alerts") 
    .

    {&out}
    tbar-BeginID(lc-Alert-TBAR,"")
    tbar-BeginOptionID(lc-Alert-TBAR) SKIP(2)
    tbar-Link("view",?,"off","")
    tbar-Link("update",?,"off","")
    tbar-EndOption()
            
    tbar-End().

    {&out} htmlib-StartMntTable()
    htmlib-TableHeading(
        "Date/Time|Customer|Issue^right|Details^left|SLA^left|SLA Details^left"
        ) skip.
    FOR EACH b-query NO-LOCK
        WHERE b-query.LoginID = lc-global-user
        ,
        EACH Issue NO-LOCK
        WHERE Issue.CompanyCode = b-Query.CompanyCode
        AND Issue.IssueNumber = b-Query.IssueNumber,
        EACH Customer NO-LOCK
        WHERE Customer.CompanyCode = Issue.CompanyCode
        AND Customer.AccountNumber = Issue.AccountNumber

        BREAK BY b-Query.CreateDate 
        BY b-Query.CreateTime 
        BY b-Query.IssueNumber
                  
        :


        FIND slahead WHERE slahead.SLAID = Issue.link-SLAID NO-LOCK NO-ERROR.
        IF NOT AVAILABLE slahead THEN NEXT.

        {&out}
        SKIP(1)
        tbar-trID(lc-Alert-TBAR,ROWID(b-query))
        SKIP(1)
        htmlib-MntTableField(
            html-encode(
            STRING(b-query.CreateDate,"99/99/9999") 
            + " " + string(b-query.CreateTime,"hh:mm am")
            ),'left'
            )
        htmlib-MntTableField(
            html-encode(customer.AccountNumber + ' ' + customer.name),'left')
        htmlib-MntTableField(STRING(b-query.IssueNumber),'right') 
            
            .

        IF Issue.LongDescription <> "" THEN
        DO:
        
            ASSIGN 
                lc-info = 
                REPLACE(htmlib-MntTableField(html-encode(Issue.BriefDescription),'left'),'</td>','')
                lc-object = "hdobj" + string(issue.IssueNumber).
        
            ASSIGN 
                li-tag-end = INDEX(lc-info,">").

            {&out} substr(lc-info,1,li-tag-end).

            ASSIGN 
                substr(lc-info,1,li-tag-end) = "".
            
            {&out} 
            '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
            lc-object '~')">':U skip.
            {&out} lc-info.
    
            {&out} htmlib-ExpandBox(lc-object,Issue.LongDescription).

            {&out} '</td>' skip.
        END.
        ELSE {&out}
        htmlib-MntTableField(Issue.BriefDescription,'left').
        
        IF b-query.SLALevel > 0 THEN
        DO:
            ASSIGN 
                lc-sla-info = STRING(b-query.SLALevel) + " - " + 
                                 slahead.RespDesc[b-query.SLALevel] + 
                                 ' ' + string(Issue.SLADate[b-query.SLALevel],'99/99/9999') +
                                 ' ' + string(Issue.SLATime[b-query.SLALevel],'hh:mm am').
            IF b-query.SLALevel = 10
                OR Issue.SLADate[b-Query.SLALevel + 1] = ?
                THEN ASSIGN ll-missed = TRUE
                    lc-sla-info = '<span style="color: red";>' +
                                      lc-sla-info + '</span>'.
        END.

        {&out}
        htmlib-MntTableField(slahead.description,'left')
        htmlib-MntTableField(lc-sla-info,'left').

        {&out} skip
                tbar-BeginHidden(rowid(b-query))
                tbar-Link("view",rowid(b-query),
                          'javascript:HelpWindow('
                          + '~'' + appurl 
                          + '/iss/issueview.p?rowid=' + string(rowid(Issue))
                          + '~'' 
                          + ');'
                          ,"")
                tbar-Link("update",rowid(issue),appurl + '/' + "iss/issueframe.p","")
                
            tbar-EndHidden()

            skip.

        {&out}
        '</tr>' skip.

       

    END.


    {&out} htmlib-EndTable() skip.

    IF ll-missed THEN
        {&out} '<div style="border: 2px solid red; padding: 4px;"><span style="color: red;"><center>** SLA details shown in red are outside their SLA **</center></span></div>'.

    {&out} skip 
           htmlib-EndFieldSet() 
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

   
    RUN outputHeader.
    
    {&out} htmlib-Header("Alerts") skip.

    {&out} htmlib-JScript-Maintenance() skip.

   
    {&out} htmlib-StartForm("mainform","post", appurl + '/mn/alertpage.p' ) skip.

    {&out} htmlib-ProgramTitle("Your Actions & Alerts") skip.
    
    {&out} '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' skip.


    {&out} tbar-JavaScript(lc-Action-TBAR) skip
           tbar-JavaScript(lc-Alert-TBAR).

    IF com-NumberOfAlerts(lc-global-user) > 0
        THEN RUN ip-AlertTable.
    IF com-NumberOfActions(lc-global-user) > 0 
        THEN RUN ip-ActionTable.
   
    {&out} htmlib-EndForm().

    
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

