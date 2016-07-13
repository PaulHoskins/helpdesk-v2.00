/***********************************************************************

    Program:        iss/issueview.p
    
    Purpose:        View Issue
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      CompanyCode    
    05/07/2006  phoski      Category  
    21/03/2016  phoski      Document Link Encrypt
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE BUFFER b-valid  FOR issue.
DEFINE BUFFER b-table  FOR issue.
DEFINE BUFFER b-cust   FOR Customer.
DEFINE BUFFER b-status FOR webstatus.
DEFINE BUFFER b-area   FOR webIssarea.

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-autoprint   AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-customer    AS LOG       NO-UNDO.
DEFINE VARIABLE lc-doc-key     AS CHARACTER NO-UNDO. 

DEFINE VARIABLE lc-Doc-TBAR    AS CHARACTER 
    INITIAL "doctb" NO-UNDO.




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

&IF DEFINED(EXCLUDE-ip-Action) = 0 &THEN

PROCEDURE ip-Action :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
        
    DEFINE BUFFER b-query      FOR issAction.
    DEFINE BUFFER IssActivity  FOR IssActivity.
    
    DEFINE VARIABLE lc-info             AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-object           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-tag-end          AS INTEGER NO-UNDO.
    DEFINE VARIABLE lc-dummy-return     AS CHARACTER INITIAL "MYXXX111PPP2222"   NO-UNDO.
    DEFINE VARIABLE li-duration         AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-total-duration   AS INTEGER NO-UNDO.

    FIND FIRST b-query OF b-table NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-query THEN RETURN.

    {&out} skip
          replace(htmlib-StartMntTable(),'width="100%"','width="95%" align="center"').
    {&out}
    htmlib-TableHeading(
        "Date|Action|Currently<br>Assigned To|Date|Activity|By|Duration<br>(H:MM)^right"
        ) skip.

    FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = b-table.CompanyCode
        AND b-query.IssueNumber = b-table.IssueNumber
        BY b-Query.ActionDate DESCENDING
        BY b-Query.CreateDate DESCENDING
        BY b-Query.CreateTime DESCENDING
        :

        FIND WebAction 
            WHERE WebAction.ActionID = b-query.ActionID
            NO-LOCK NO-ERROR.

        ASSIGN
            li-duration = 0.
        FOR EACH IssActivity NO-LOCK
            WHERE issActivity.CompanyCode = b-table.CompanyCode
            AND issActivity.IssueNumber = b-table.IssueNumber
            AND IssActivity.IssActionId = b-query.IssActionID:
            li-duration = li-duration + IssActivity.Duration.
        END.
        ASSIGN
            li-total-duration = li-total-duration + li-duration.

        {&out}
        SKIP(1)
        '<tr>'
        SKIP(1)
        htmlib-MntTableField(STRING(b-query.ActionDate,"99/99/9999")
            + ( IF b-query.ActionStatus = "CLOSED"
            THEN " - Closed" ELSE ""),'left') SKIP(2).

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
        {&out}
        htmlib-MntTableField(
            DYNAMIC-FUNCTION("com-UserName",b-query.AssignTo)
            ,'left')
        htmlib-MntTableField("",'left')
        htmlib-MntTableField("",'left')
        htmlib-MntTableField("",'left')
        htmlib-MntTableField(
            IF li-Duration > 0 
            THEN '<strong>' + html-encode(com-TimeToString(li-duration)) + '</strong>'
            ELSE "",'right')
            
        '</tr>' skip.

        FOR EACH IssActivity NO-LOCK
            WHERE issActivity.CompanyCode = b-query.CompanyCode
            AND issActivity.IssueNumber = b-query.IssueNumber
            AND IssActivity.IssActionId = b-query.IssActionID
            BY IssActivity.ActDate DESCENDING
            BY IssActivity.CreateDate DESCENDING
            BY IssActivity.CreateTime DESCENDING:

            {&out}
            SKIP(1)
            '<tr>'
            SKIP(1)
            htmlib-MntTableField("",'left') 
            htmlib-MntTableField("",'left')
            htmlib-MntTableField("",'left')

            htmlib-MntTableField(STRING(IssActivity.ActDate,'99/99/9999'),'left') skip.


            IF IssActivity.notes <> "" THEN
            DO:
            
                ASSIGN 
                    lc-info = 
                    REPLACE(htmlib-MntTableField(html-encode(IssActivity.Description),'left'),'</td>','')
                    lc-object = "hdobj" + string(IssActivity.issActivityID).
            
                ASSIGN 
                    li-tag-end = INDEX(lc-info,">").
    
                {&out} substr(lc-info,1,li-tag-end).
    
                ASSIGN 
                    substr(lc-info,1,li-tag-end) = "".
                
                {&out} 
                '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
                lc-object '~')">':U skip.
                {&out} lc-info.
        
                {&out} htmlib-ExpandBox(lc-object,IssActivity.Notes).
    
                {&out} '</td>' skip.
            END.
            ELSE {&out}
            htmlib-MntTableField(IssActivity.Description,'left').

                
            {&out}
            htmlib-MntTableField(
                DYNAMIC-FUNCTION("com-UserName",IssActivity.ActivityBy)
                ,'left')
            htmlib-MntTableField(IF IssActivity.Duration > 0 
                THEN html-encode(com-TimeToString(IssActivity.Duration))
                ELSE "",'right')
            
                
            '</tr>' skip.


        END.

    END.
    
    IF li-total-duration <> 0 THEN
        {&out} '<tr class="tabrow1" style="font-weight: bold; border: 1px solid black;">'
    REPLACE(htmlib-MntTableField("Total Duration","right"),"<td","<td colspan=6 ")
    htmlib-MntTableField(html-encode(com-TimeToString(li-total-duration))
        ,'right')
                
    '</tr>'.
    {&out} skip 
           htmlib-EndTable()
           skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-BuildPage) = 0 &THEN

PROCEDURE ip-BuildPage :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE BUFFER b-cust   FOR customer.
    DEFINE BUFFER b-user   FOR WebUser.
    DEFINE BUFFER b-cat    FOR WebIssCat.

    DEFINE VARIABLE lc-icustname AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-raised    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-assign    AS CHARACTER NO-UNDO.
    
    FIND b-cust OF b-table NO-LOCK NO-ERROR.
    FIND b-cat  OF b-table NO-LOCK NO-ERROR.
    
    IF AVAILABLE b-cust
        THEN ASSIGN lc-icustname = b-cust.AccountNumber + 
                               ' ' + b-cust.Name.
    ELSE ASSIGN lc-icustname = 'N/A'.

    ASSIGN
        lc-raised = com-UserName(b-table.RaisedLogin).

    
    ASSIGN
        lc-assign = com-UserName(b-table.AssignTo).

    {&out} htmlib-StartInputTable() skip.

    FIND b-area OF b-table NO-LOCK NO-ERROR.
    FIND b-status OF b-table NO-LOCK NO-ERROR.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Customer")
    '</TD>' skip
           htmlib-TableField(html-encode(lc-icustname),'left') skip
           '<TR><TD VALIGN="TOP" ALIGN="right">' 
           htmlib-SideLabel("Date")
           '</TD>' skip
           htmlib-TableField(if b-table.IssueDate = ? then "" else 
               string(b-table.IssueDate,'99/99/9999') + " " + 
               string(b-table.IssueTime,'hh:mm am'),'left') skip
           '<TR><TD VALIGN="TOP" ALIGN="right">' 
           htmlib-SideLabel("Raised By")
           '</TD>' skip
           htmlib-TableField(html-encode(lc-raised),'left') skip

    .

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Description")
    '</TD>'
    htmlib-TableField(b-table.briefdescription,"") 
    '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Notes")
    '</TD>'
    htmlib-TableField(REPLACE(b-table.longdescription,'~n','<BR>'),"") 
    '</TR>' skip.


    IF AVAILABLE b-area THEN
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Area")
    '</TD>'
    htmlib-TableField(b-area.description,"") 
    '</TR>' skip.
    
    IF AVAILABLE b-status THEN
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Status")
    '</TD>'
    htmlib-TableField(b-status.description,"") 
    '</TR>' skip.

    IF AVAILABLE b-cat THEN
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Category")
    '</TD>'
    htmlib-TableField(b-cat.description,"") 
    '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Class")
    '</TD>'
    htmlib-TableField(b-table.iClass,"") 
    '</TR>' skip.

    IF NOT ll-Customer THEN
    DO:
        IF lc-assign <> "" THEN
            {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Assigned To")
        '</TD>'
        htmlib-TableField(lc-assign,"") 
        '</TR>' skip.
    
        
        IF b-table.PlannedCompletion <> ?  THEN
            {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Planned Completion")
        '</TD>'
        htmlib-TableField(STRING(b-table.PlannedCompletion,'99/99/9999'),"") 
        '</TR>' skip.
    
         
   
    END.
    {&out} htmlib-EndTable() skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-CustomerViewAction) = 0 &THEN

PROCEDURE ip-CustomerViewAction :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
   
    DEFINE INPUT PARAMETER pc-user AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-query      FOR issAction.
    DEFINE BUFFER IssActivity  FOR IssActivity.
    DEFINE BUFFER webuser      FOR webuser.
    DEFINE BUFFER customer     FOR customer.

   

    DEFINE VARIABLE lc-info             AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-object           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-tag-end          AS INTEGER NO-UNDO.
    DEFINE VARIABLE lc-dummy-return     AS CHARACTER INITIAL "MYXXX111PPP2222"   NO-UNDO.
    DEFINE VARIABLE lc-desc             AS CHARACTER NO-UNDO.

   
    FIND WebUser
        WHERE WebUser.LoginID = pc-user
        NO-LOCK NO-ERROR.

    IF NOT AVAILABLE webuser THEN RETURN.

    FIND customer
        WHERE customer.CompanyCode = webuser.CompanyCode
        AND customer.AccountNumber = webuser.AccountNumber
        NO-LOCK.


    IF NOT customer.viewAction THEN RETURN.

    FIND FIRST b-query OF b-table
        WHERE b-query.CustomerView NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-query THEN RETURN.

    {&out} skip
         replace(htmlib-StartMntTable(),'width="100%"','width="95%" align="center"').
    {&out}
    htmlib-TableHeading(
        "Date|Action|Currently<br>Assigned To|Date|Activity|Site Visit?|By"
        ) skip.

    FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = b-table.CompanyCode
        AND b-query.IssueNumber = b-table.IssueNumber
        AND b-query.CustomerView
        BY b-Query.ActionDate DESCENDING
        BY b-Query.CreateDate DESCENDING
        BY b-Query.CreateTime DESCENDING
        :

        FIND WebAction 
            WHERE WebAction.ActionID = b-query.ActionID
            NO-LOCK NO-ERROR.

       
        ASSIGN 
            lc-desc = html-encode(WebAction.Description).

        IF b-query.notes <> "" THEN
        DO:
            ASSIGN 
                lc-desc = lc-desc + " - " + 
                  replace(html-encode(b-query.notes),"~n","<br>").
        END.
        {&out}
        SKIP(1)
        '<tr>'
        SKIP(1)
        htmlib-MntTableField(STRING(b-query.ActionDate,"99/99/9999")
            + ( IF b-query.ActionStatus = "CLOSED"
            THEN " - Closed" ELSE ""),'left') SKIP(2).

        {&out}
        htmlib-MntTableField(lc-desc,'left').
        {&out}
        htmlib-MntTableField(
            DYNAMIC-FUNCTION("com-UserName",b-query.AssignTo)
            ,'left')
        htmlib-MntTableField("",'left')
        htmlib-MntTableField("",'left')
        htmlib-MntTableField("",'left')
        '</tr>' skip.

        IF customer.viewActivity THEN
            FOR EACH IssActivity NO-LOCK
                WHERE issActivity.CompanyCode = b-query.CompanyCode
                AND issActivity.IssueNumber = b-query.IssueNumber
                AND IssActivity.IssActionId = b-query.IssActionID
                AND IssActivity.CustomerView
                BY IssActivity.ActDate DESCENDING
                BY IssActivity.CreateDate DESCENDING
                BY IssActivity.CreateTime DESCENDING:

                {&out}
                SKIP(1)
                '<tr>'
                SKIP(1)
                htmlib-MntTableField("",'left') 
                htmlib-MntTableField("",'left')
                htmlib-MntTableField("",'left')

                htmlib-MntTableField(STRING(IssActivity.ActDate,'99/99/9999'),'left') skip.


                ASSIGN
                    lc-desc = html-encode(IssActivity.Description).

                IF IssActivity.notes <> "" THEN
                DO:
                    ASSIGN 
                        lc-desc = lc-desc + " - " + 
                      replace(html-encode(IssActivity.notes),"~n","<br>").
                END.

                {&out}
                htmlib-MntTableField(lc-desc,'left')
                htmlib-MntTableField(IF IssActivity.SiteVisit THEN "Yes" ELSE "No",'left').


                {&out}
                htmlib-MntTableField(
                    DYNAMIC-FUNCTION("com-UserName",IssActivity.ActivityBy)
                    ,'left')
               
                '</tr>' skip.


            END.

    END.

   
    {&out} skip 
          htmlib-EndTable()
          skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Document) = 0 &THEN

PROCEDURE ip-Document :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE INPUT PARAMETER pr-rowid        AS ROWID        NO-UNDO.
    DEFINE INPUT PARAMETER pc-ToolBarID    AS CHARACTER         NO-UNDO.


    DEFINE BUFFER this-user FOR WebUser.
    DEFINE VARIABLE ll-Customer  AS LOG NO-UNDO.

    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.

    ASSIGN
        ll-customer = this-user.UserClass = "CUSTOMER".

    DEFINE BUFFER b-query  FOR doch.
    DEFINE BUFFER b-table  FOR Issue.

    FIND b-table WHERE ROWID(b-table) = pr-rowid NO-LOCK NO-ERROR.

    FIND FIRST b-query 
        WHERE b-query.CompanyCode = b-table.CompanyCode
        AND b-query.RelType = "issue"
        AND b-query.RelKey  = string(b-table.IssueNumber) NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-query THEN RETURN.

    IF ll-customer THEN
    DO:
        FIND FIRST b-query 
            WHERE b-query.CompanyCode = b-table.CompanyCode
            AND b-query.RelType = "issue"
            AND b-query.RelKey  = string(b-table.IssueNumber)
            AND b-query.CustomerView = TRUE NO-LOCK NO-ERROR.

        IF NOT AVAILABLE b-query
            THEN RETURN.
    END.
    {&out}
    tbar-BeginID(pc-ToolBarID,"")
    tbar-BeginOptionID(pc-ToolBarID) 
    tbar-Link("documentview",?,"off","")
    tbar-EndOption()
    tbar-End().

    {&out} skip
          replace(htmlib-StartMntTable(),'width="100%"','width="95%" align="center"').
    {&out}
    htmlib-TableHeading(
        "Date|Time|By|Description|Type|Size (KB)^right"
        ) skip.

    FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = b-table.CompanyCode
        AND b-query.RelType = "issue"
        AND b-query.RelKey  = string(b-table.IssueNumber):

        IF ll-customer AND b-query.CustomerView = FALSE THEN NEXT.
        

        ASSIGN 
            lc-doc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"Document",STRING(ROWID(b-query))).
            
        {&out}
        SKIP(1)
        tbar-trID(pc-ToolBarID,ROWID(b-query))
        SKIP(1)
        htmlib-MntTableField(STRING(b-query.CreateDate,"99/99/9999"),'left')
        htmlib-MntTableField(STRING(b-query.CreateTime,"hh:mm am"),'left')
        htmlib-MntTableField(html-encode(DYNAMIC-FUNCTION("com-UserName",b-query.CreateBy)),'left')
        htmlib-MntTableField(b-query.descr,'left')
        htmlib-MntTableField(b-query.DocType,'left')
        htmlib-MntTableField(STRING(ROUND(b-query.InBytes / 1024,2)),'right')
        tbar-BeginHidden(ROWID(b-query))
        tbar-Link("documentview",ROWID(b-query),
            'javascript:OpenNewWindow('
            + '~'' + appurl 
            + '/sys/docview.' + lc(b-query.doctype) + '?docid=' + url-encode(lc-doc-key,"Query")
            + '~'' 
            + ');'
            ,"")
        tbar-EndHidden()
        '</tr>' skip.

    END.

    {&out} skip 
           htmlib-EndTable()
           skip.

   

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-NoteList) = 0 &THEN

PROCEDURE ip-NoteList :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pi-Issue AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER pc-user  AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-note FOR IssNote.
    DEFINE BUFFER b-user FOR WebUser.
    DEFINE BUFFER b-type FOR WebNote.
    DEFINE BUFFER b-iss  FOR Issue.

    DEFINE VARIABLE lc-name AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-status AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ll-showprivate AS LOG NO-UNDO.
    DEFINE VARIABLE li-count AS INTEGER NO-UNDO.

    FIND b-iss 
        WHERE b-iss.companycode = lc-global-company
        AND b-iss.IssueNumber = pi-Issue
        NO-LOCK NO-ERROR.


    FOR EACH b-note NO-LOCK
        WHERE b-note.CompanyCode = lc-global-company
        AND b-note.IssueNumber = pi-Issue:

        FIND b-type WHERE b-type.CompanyCode = b-note.CompanyCode
            AND b-type.NoteCode = b-note.NoteCode NO-LOCK NO-ERROR.
        IF AVAILABLE b-type THEN
        DO:
            IF b-type.CustomerCanView = FALSE AND ll-customer THEN NEXT.
               
        END.

        ASSIGN 
            li-count = li-count + 1.
        IF li-count = 1 THEN 
            {&out}
        htmlib-StartMntTable()
        htmlib-TableHeading(
            "Date^right|Time^right|Details|By"
            ) skip.

        FIND b-type OF b-note NO-LOCK NO-ERROR.

        ASSIGN 
            lc-status = IF AVAILABLE b-type THEN b-type.description ELSE "".

        ASSIGN 
            lc-status = lc-status + '<br>' + replace(b-note.Contents,'~n','<BR>').

        FIND b-user WHERE b-user.LoginID = b-note.LoginID NO-LOCK NO-ERROR.

        ASSIGN
            lc-name = com-UserName(b-note.LoginID).
          
        {&out} '<tr>' skip
               htmlib-TableField(string(b-note.CreateDate,'99/99/9999'),'right')
               htmlib-TableField(string(b-note.CreateTime,'hh:mm am'),'right')
               htmlib-TableField(lc-status,'left')
               htmlib-TableField(html-encode(lc-name),'left')
               '</tr>' skip.
    END.
    IF li-count > 0 THEN
        {&out} skip 
        htmlib-EndTable()
        skip.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-StatusList) = 0 &THEN

PROCEDURE ip-StatusList :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pi-Issue AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER pc-user  AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-table FOR IssStatus.
    DEFINE BUFFER b-status FOR WebStatus.
    DEFINE BUFFER b-user FOR WebUser.
    
    

    DEFINE VARIABLE lc-name AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-status AS CHARACTER NO-UNDO.
    
    {&out}
    htmlib-StartMntTable()
    htmlib-TableHeading(
        "Date^right|Time^right|Status|By"
        ) skip.

    FOR EACH b-table NO-LOCK
        WHERE b-table.CompanyCode = lc-global-company
        AND b-table.IssueNumber = pi-issue
        BY b-table.ChangeDate DESCENDING
        BY b-table.ChangeTime DESCENDING:

        FIND b-status WHERE b-status.CompanyCode = lc-global-company
            AND b-status.StatusCode = b-table.NewStatusCode NO-LOCK NO-ERROR.
            
        ASSIGN 
            lc-status = IF AVAILABLE b-status THEN b-status.description ELSE "".

        FIND b-user WHERE b-user.LoginID = b-table.LoginID NO-LOCK NO-ERROR.
        ASSIGN 
            lc-name = IF AVAILABLE b-user THEN b-user.name ELSE "".

        {&out} '<tr>' skip
                htmlib-TableField(string(b-table.ChangeDate,'99/99/9999'),'right')
                htmlib-TableField(string(b-table.ChangeTime,'hh:mm am'),'right')
                htmlib-TableField(html-encode(lc-status),'left')
                htmlib-TableField(html-encode(lc-name),'left')
                '</tr>' skip.
    END.
    {&out} skip 
           htmlib-EndTable()
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
        ll-Customer = com-IsCustomer(lc-global-company,lc-user).

   
    ASSIGN 
        lc-rowid = get-value("rowid")
        lc-autoprint = get-value("autoprint").
    IF lc-rowid = ""
        THEN ASSIGN lc-rowid = get-value("saverowid").

    ASSIGN 
        lc-title = 'View'.

    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.

    ASSIGN 
        lc-title = lc-title + ' Issue ' + string(b-table.issuenumber).
    

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
          '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' skip.

    {&out} tbar-JavaScript(lc-Doc-TBAR) skip.

    {&out}
    htmlib-StartForm("mainform","post", appurl + '/iss/issueview.p' )
    htmlib-ProgramTitle(lc-title).
    {&out} htmlib-Hidden ("saverowid", lc-rowid) skip.

    {&out} '<a href="javascript:window.print()"><img src="/images/general/print.gif" border=0 style="padding: 5px;"></a>' skip.

    
    RUN ip-BuildPage.

    RUN ip-NoteList ( b-table.IssueNumber , lc-user ).

    RUN ip-StatusList ( b-table.IssueNumber , lc-user ).

    IF NOT ll-Customer
        THEN RUN ip-Action.
    ELSE RUN ip-CustomerViewAction ( lc-user ).

    RUN ip-Document ( ROWID(b-table), lc-Doc-TBAR ).


    {&OUT} htmlib-EndForm() skip 
           htmlib-Footer() skip.
    
    IF lc-autoprint = "yes" THEN
    DO:
        {&out} '<script language="javascript">' skip
               'window.print()' skip
               '</script>' skip.

    END.
END PROCEDURE.


&ENDIF

