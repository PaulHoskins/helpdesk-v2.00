/***********************************************************************

    Program:        iss/ajax/action.p
    
    Purpose:        Issue Actions    
    
    Notes:
    
    
    When        Who         What
    03/05/2006  phoski      Initial
    21/03/2007  phoski      Sort Activity by DATE/CREATE TIME desc
    03/04/2015  phoski      ActionID = ? - its from a project task so 
                            use actDescription
    05/05/2015  phoski      Complex project     
    12/03/2016  phoski      Click on action + symbol will expand/shrink
                            the action boxes also    
    02/07/2016  phoski      Show activityType if not blank and totals 
                            for admin etc.

***********************************************************************/
CREATE WIDGET-POOL.


DEFINE VARIABLE lc-rowid          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-toolbarid      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-info           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-object         AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-tag-end        AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-dummy-return   AS CHARACTER INITIAL "MYXXX111PPP2222" NO-UNDO.
DEFINE VARIABLE li-duration       AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-total-duration AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-tduration      AS INTEGER   EXTENT 2 NO-UNDO.
DEFINE VARIABLE lc-AllowDelete    AS CHARACTER NO-UNDO.


DEFINE VARIABLE li-count          AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-start          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Action         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Audit          AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-HasClosed      AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lc-descr          AS CHARACTER NO-UNDO.

DEFINE BUFFER b-table     FOR issue.
DEFINE BUFFER b-query     FOR issAction.
DEFINE BUFFER IssActivity FOR IssActivity.   
DEFINE BUFFER issPhase    FOR issPhase.
DEFINE BUFFER esched      FOR eSched.

  

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

PROCEDURE ip-ComplexProjectTable:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-PhaseID      LIKE issPhase.PhaseID       NO-UNDO.
    DEFINE VARIABLE lc-eng-list     AS CHARACTER                NO-UNDO.
    
    
    {&out} skip
          replace(htmlib-StartMntTable(),'width="100%"','width="100%" align="center"').
    {&out}
    htmlib-TableHeading(
        "Phase|Date|Assigned To|Created|Action|Date|Activity|Site Visit|By|Start/End|Duration<br>(H:MM)^right"
        ) skip.

    li-PhaseID = ?.
    
    
    FOR EACH issPhase NO-LOCK
        WHERE issPhase.CompanyCode = b-table.CompanyCode
        AND issPhase.IssueNumber = b-table.IssueNumber
        ,
        EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = b-table.CompanyCode
        AND b-query.IssueNumber = b-table.IssueNumber
        AND b-query.PhaseID = issPhase.PhaseID
        BY issPhase.DisplayOrder
        BY b-query.DisplayOrder
            
        :

        
        IF b-query.ActionID <> ? THEN 
        DO:
            FIND WebAction 
                WHERE WebAction.ActionID = b-query.ActionID
                NO-LOCK NO-ERROR.
            ASSIGN 
                lc-descr = WebAction.Description.
        END.
        ELSE  ASSIGN lc-descr = b-query.ActDescription.
        

        ASSIGN
            li-duration = 0.
        FOR EACH IssActivity NO-LOCK
            WHERE issActivity.CompanyCode = b-table.CompanyCode
            AND issActivity.IssueNumber = b-table.IssueNumber
            AND IssActivity.IssActionId = b-query.IssActionID:
            ASSIGN
                li-duration = li-duration + IssActivity.Duration
                li-count    = li-count + 1.
                
           
            IF com-IsActivityChargeable(IssActivity.IssActivityID) = FALSE
            THEN ASSIGN li-tduration[1] = li-tduration[1] + issActivity.Duration.
            ELSE ASSIGN li-tduration[2] = li-tduration[2] + issActivity.Duration.
            
        END.
        ASSIGN
            li-total-duration = li-total-duration + li-duration.

        ASSIGN
            li-count = li-count + 1.

        ASSIGN
            lc-Action = STRING(b-Query.ActionDate,"99/99/9999").
        IF b-query.ActionStatus = "CLOSED"
            THEN ASSIGN lc-Action = '<span style="color: green;">' + lc-Action + "**</span>"
                ll-HasClosed = TRUE.

        ASSIGN
            lc-Audit = STRING(b-Query.CreateDate,"99/99/9999") + " " + 
                       string(b-Query.CreateTime,"hh:mm") + " " + 
                       dynamic-function("com-UserName",b-query.CreatedBy)
            lc-eng-list = DYNAMIC-FUNCTION("com-UserName",b-query.AssignTo).
             
        /*
        ***
        *** any other engineers
        ***
        */ 
        FOR EACH eSched NO-LOCK
            WHERE eSched.IssActionID = b-query.IssActionID:
            IF eSched.AssignTo = b-query.AssignTo THEN NEXT. 
            ASSIGN
                lc-eng-list = lc-eng-list + "<br />" + 
              DYNAMIC-FUNCTION("com-UserName",esched.AssignTo).
            
        END. 
                    
        {&out}
        SKIP(1)
        tbar-trID(lc-ToolBarID,ROWID(b-query))
        SKIP(1)
        /* Only display first time */
        htmlib-mntTableField(html-encode(IF li-phaseID <> issPhase.PhaseID THEN issPhase.Descr ELSE ""),'left')
        htmlib-MntTableField(lc-Action,'left')
        htmlib-MntTableField(
            lc-eng-list
            ,'left')
        htmlib-MntTableField(lc-Audit,'left').

        ASSIGN 
            li-phaseID = issPhase.PhaseID.
        
        /* 1 = 2 dummy fail this side of the condition for now PH 06/05/2015 */
        IF b-query.notes <> "" AND 1 = 2 THEN
        DO:
        
            ASSIGN 
                lc-info = 
                REPLACE(htmlib-MntTableField(html-encode(lc-descr),'left'),'</td>','')
                lc-object = "hdobj" + string(b-query.issActionID).
        
            lc-info = REPLACE(lc-info,"<td","<td colspan=6 ").

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
        REPLACE(htmlib-MntTableField(lc-descr,'left'),
            "<td","<td colspan=6 ").
        {&out}
            
        htmlib-MntTableField(
            IF li-Duration > 0 
            THEN '<strong>' + html-encode(com-TimeToString(li-duration)) + '</strong>'
            ELSE "",'right')
            
        tbar-BeginHidden(ROWID(b-query)).

        IF lc-allowDelete = "yes" 
            THEN {&out} tbar-Link("delete",ROWID(b-query),
            'javascript:ConfirmDeleteAction(' +
            "ROW" + string(ROWID(b-query)) + ','
                           
                          
            + string(b-query.issActionID) + ');',
            "").
        {&out}
            
        tbar-Link("update",?,
            'javascript:PopUpWindow('
            + '~'' + appurl 
            + '/iss/actionprojectupdate.p?mode=update&issuerowid=' + string(ROWID(b-table)) + "&rowid=" + string(ROWID(b-query))
            + '~'' 
            + ');'
            ,"")
                                                                                            
        tbar-Link("multiiss",?,
            'javascript:PopUpWindow('
            + '~'' + appurl 
            + '/iss/activityupdmain.p?mode=display&issuerowid=' + string(ROWID(b-table)) + "&rowid=" + string(ROWID(b-query)) + "&actionrowid=" + string(ROWID(b-query))
            + '~'' 
            + ');'
            ,"") skip
                         

            tbar-EndHidden()
            '</tr>' skip.

        FOR EACH IssActivity NO-LOCK
            WHERE issActivity.CompanyCode = b-query.CompanyCode
            AND issActivity.IssueNumber = b-query.IssueNumber
            AND IssActivity.IssActionId = b-query.IssActionID
            BY issActivity.ActDate DESCENDING
            BY IssActivity.CreateDate DESCENDING
            BY issActivity.CreateTime DESCENDING:

            ASSIGN
                lc-start = ""
                lc-descr = IssActivity.Description.
            IF issActivity.activityType <> ""
            THEN ASSIGN lc-descr = issactivity.activityType + " - " + IssActivity.Description.

            IF issActivity.StartDate <> ? THEN
            DO:
                ASSIGN
                    lc-start = STRING(issActivity.StartDate,"99/99/9999") + 
                               " " +
                               string(issActivity.StartTime,"hh:mm").

                IF issActivity.EndDate <> ? THEN
                    ASSIGN
                        lc-start = lc-start + " - " + 
                               string(issActivity.EndDate,"99/99/9999") + 
                               " " +
                               string(issActivity.EndTime,"hh:mm").
                                
            END.

            {&out}
            SKIP(1)
            tbar-trID(lc-ToolBarID,ROWID(IssActivity))
            SKIP(1)
            REPLACE(htmlib-MntTableField("",'left'),"<td","<td colspan=5") 
            htmlib-MntTableField(STRING(IssActivity.ActDate,'99/99/9999'),'left') skip.


            IF IssActivity.notes <> "" THEN
            DO:
            
                ASSIGN 
                    lc-info = 
                    REPLACE(htmlib-MntTableField(html-encode(lc-descr),'left'),'</td>','')
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
            htmlib-MntTableField(lc-descr,'left').

            {&out}
            htmlib-MntTableField(IF IssActivity.SiteVisit THEN "Yes" ELSE "&nbsp;",'left').

            {&out}
            htmlib-MntTableField(
                DYNAMIC-FUNCTION("com-UserName",IssActivity.ActivityBy)
                ,'left')
            htmlib-MntTableField(html-encode(lc-Start),'left')
            htmlib-MntTableField(IF IssActivity.Duration > 0 
                THEN html-encode(com-TimeToString(IssActivity.Duration))
                ELSE "",'right')
            
            tbar-BeginHidden(ROWID(IssActivity))
            
            tbar-Link("update",?,
                'javascript:PopUpWindow('
                + '~'' + appurl 
                + '/iss/actionprojectupdate.p?mode=update&issuerowid=' + string(ROWID(b-table)) + "&rowid=" + string(ROWID(b-query))
                + '~'' 
                + ');'
                ,"")
                                                                                                                 
            tbar-EndHidden()
            '</tr>' skip.


        END.

    END.
    
    IF li-total-duration <> 0 THEN
    DO:
        {&out} '<tr class="tabrow1" style="font-weight: bold; border: 1px solid black;">'
        REPLACE(htmlib-MntTableField("Total Duration","right"),"<td","<td colspan=9 ")
        htmlib-MntTableField(html-encode(com-TimeToString(li-total-duration))
            ,'right')
            '</tr>'.
            
        {&out} '<tr class="tabrow1" style="font-weight: bold; border: 1px solid black;">'
        REPLACE(htmlib-MntTableField("Total Duration (Admin)","right"),"<td","<td colspan=9 ")
        htmlib-MntTableField(html-encode(com-TimeToString(li-tduration[1]))
            ,'right')
            '</tr>'.
            
         {&out} '<tr class="tabrow1" style="font-weight: bold; border: 1px solid black;">'
        REPLACE(htmlib-MntTableField("Total Duration (Non Admin)","right"),"<td","<td colspan=9 ")
        htmlib-MntTableField(html-encode(com-TimeToString(li-tduration[2]))
            ,'right')
            '</tr>'.
            
    END.
    

    IF ll-HasClosed THEN
    DO:
        {&out} '<tr class="tabrow1" style="font-weight: bold; border: 1px solid black;">'
        REPLACE(htmlib-MntTableField("** Closed Actions","left"),"<td",'<td colspan=11 style="color:green;"')
                
        '</tr>'.
    END.
    {&out} skip 
           htmlib-EndTable()
           skip.


END PROCEDURE.

PROCEDURE ip-StandardActionTable:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-this-class   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-class-count  AS INTEGER NO-UNDO.
    
    
    {&out} skip
          replace(htmlib-StartMntTable(),'width="100%"','width="100%" align="center"').
    {&out}
    htmlib-TableHeading(
        "Date|Assigned To|Created|Action|Date|Activity|Site Visit|By|Start/End|Duration<br>(H:MM)^right"
        ) skip.

    FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = b-table.CompanyCode
        AND b-query.IssueNumber = b-table.IssueNumber
        BY b-Query.ActionDate DESCENDING
        BY b-Query.CreateDate DESCENDING
        BY b-Query.CreateTime DESCENDING
        :

        IF b-query.ActionID <> ? THEN 
        DO:
            FIND WebAction 
                WHERE WebAction.ActionID = b-query.ActionID
                NO-LOCK NO-ERROR.
            ASSIGN 
                lc-descr = WebAction.Description.
        END.
        ELSE  ASSIGN lc-descr = b-query.ActDescription.
        
        ASSIGN
           li-class-count = li-class-count + 1 
           lc-this-class = "cl" + STRING(li-class-count).
        
        ASSIGN
            li-duration = 0.
        FOR EACH IssActivity NO-LOCK
            WHERE issActivity.CompanyCode = b-table.CompanyCode
            AND issActivity.IssueNumber = b-table.IssueNumber
            AND IssActivity.IssActionId = b-query.IssActionID:
            ASSIGN
                li-duration = li-duration + IssActivity.Duration
                li-count    = li-count + 1.
            
            IF com-IsActivityChargeable(IssActivity.IssActivityID) = FALSE
            THEN ASSIGN li-tduration[1] = li-tduration[1] + issActivity.Duration.
            ELSE ASSIGN li-tduration[2] = li-tduration[2] + issActivity.Duration.
            
        END.
        ASSIGN
            li-total-duration = li-total-duration + li-duration.

        ASSIGN
            li-count = li-count + 1.

        ASSIGN
            lc-Action = STRING(b-Query.ActionDate,"99/99/9999").
        IF b-query.ActionStatus = "CLOSED"
            THEN ASSIGN lc-Action = '<span style="color: green;">' + lc-Action + "**</span>"
                ll-HasClosed = TRUE.

        ASSIGN
            lc-Audit = STRING(b-Query.CreateDate,"99/99/9999") + " " + 
                       string(b-Query.CreateTime,"hh:mm") + " " + 
                       dynamic-function("com-UserName",b-query.CreatedBy).
                       
        {&out}
        SKIP(1)
        tbar-trID(lc-ToolBarID,ROWID(b-query))
        SKIP(1)
        htmlib-MntTableField(lc-Action,'left')
        htmlib-MntTableField(
            DYNAMIC-FUNCTION("com-UserName",b-query.AssignTo)
            ,'left')
        htmlib-MntTableField(lc-Audit,'left').

        IF b-query.notes <> "" OR 1 = 1 THEN
        DO:
        
            ASSIGN 
                lc-info = 
                REPLACE(htmlib-MntTableField(html-encode(lc-descr),'left'),'</td>','')
                lc-object = "hdobj" + string(b-query.issActionID).
        
            lc-info = REPLACE(lc-info,"<td","<td colspan=6 ").

            ASSIGN 
                li-tag-end = INDEX(lc-info,">").

            {&out} substr(lc-info,1,li-tag-end).

            ASSIGN 
                substr(lc-info,1,li-tag-end) = "".
            /*
            {&out} 
            '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
            lc-object 
            
            '~')">':U skip.
            */
            
            {&out} 
            '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
            lc-object 
            
            '~')' SKIP
            ";actionExpand(this,~'" lc-this-class "~')"
            '">':U skip.
            
            {&out} lc-info.
    
            {&out} htmlib-ExpandBox(lc-object,b-query.Notes).

            {&out} '</td>' skip.
        END.
        ELSE {&out}
        REPLACE(htmlib-MntTableField(lc-descr,'left'),
            "<td","<td colspan=6 ").
        {&out}
            
        htmlib-MntTableField(
            IF li-Duration > 0 
            THEN '<strong>' + html-encode(com-TimeToString(li-duration)) + '</strong>'
            ELSE "",'right')
            
        tbar-BeginHidden(ROWID(b-query)).

        IF lc-allowDelete = "yes" 
            THEN {&out} tbar-Link("delete",ROWID(b-query),
            'javascript:ConfirmDeleteAction(' +
            "ROW" + string(ROWID(b-query)) + ','
                           
                          
            + string(b-query.issActionID) + ');',
            "").
        {&out}
            
        tbar-Link("update",?,
            'javascript:PopUpWindow('
            + '~'' + appurl 
            + '/iss/actionupdate.p?mode=update&issuerowid=' + string(ROWID(b-table)) + "&rowid=" + string(ROWID(b-query))
            + '~'' 
            + ');'
            ,"")
                                                                                            
        tbar-Link("multiiss",?,
            'javascript:PopUpWindow('
            + '~'' + appurl 
            + '/iss/activityupdmain.p?mode=display&issuerowid=' + string(ROWID(b-table)) + "&rowid=" + string(ROWID(b-query)) + "&actionrowid=" + string(ROWID(b-query))
            + '~'' 
            + ');'
            ,"") skip
                         

            tbar-EndHidden()
            '</tr>' skip.

        FOR EACH IssActivity NO-LOCK
            WHERE issActivity.CompanyCode = b-query.CompanyCode
            AND issActivity.IssueNumber = b-query.IssueNumber
            AND IssActivity.IssActionId = b-query.IssActionID
            BY issActivity.ActDate DESCENDING
            BY IssActivity.CreateDate DESCENDING
            BY issActivity.CreateTime DESCENDING:

            ASSIGN
                lc-start = ""
                lc-descr = IssActivity.Description.
            IF issActivity.activityType <> ""
            THEN ASSIGN lc-descr = issactivity.activityType + " - " + IssActivity.Description.
            
            IF com-IsActivityChargeable(IssActivity.IssActivityID) = FALSE 
            THEN ASSIGN lc-descr = "** " + lc-descr.
            

            IF issActivity.StartDate <> ? THEN
            DO:
                ASSIGN
                    lc-start = STRING(issActivity.StartDate,"99/99/9999") + 
                               " " +
                               string(issActivity.StartTime,"hh:mm").

                IF issActivity.EndDate <> ? THEN
                    ASSIGN
                        lc-start = lc-start + " - " + 
                               string(issActivity.EndDate,"99/99/9999") + 
                               " " +
                               string(issActivity.EndTime,"hh:mm").
                                
            END.

            {&out}
            SKIP(1)
            tbar-trID(lc-ToolBarID,ROWID(IssActivity))
            SKIP(1)
            REPLACE(htmlib-MntTableField("",'left'),"<td","<td colspan=4") 
            htmlib-MntTableField(STRING(IssActivity.ActDate,'99/99/9999'),'left') skip.


            IF IssActivity.notes <> "" THEN
            DO:
            
                ASSIGN 
                    lc-info = 
                    REPLACE(htmlib-MntTableField(html-encode(lc-descr),'left'),'</td>','')
                    lc-object = "hdobj" + string(IssActivity.issActivityID).
            
                ASSIGN 
                    li-tag-end = INDEX(lc-info,">").
    
                {&out} substr(lc-info,1,li-tag-end).
    
                ASSIGN 
                    substr(lc-info,1,li-tag-end) = "".
                
                {&out} 
                '<img class="expandboxi i' lc-this-class '" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
                lc-object '~')">':U skip.
                {&out} lc-info.
        
                {&out} REPLACE(htmlib-ExpandBox(lc-object,IssActivity.Notes),
                        'class="','class="' + lc-this-class + " ").
    
                {&out} '</td>' skip.
            END.
            ELSE {&out}
            htmlib-MntTableField(lc-descr,'left').

            {&out}
            htmlib-MntTableField(IF IssActivity.SiteVisit THEN "Yes" ELSE "&nbsp;",'left').

            {&out}
            htmlib-MntTableField(
                DYNAMIC-FUNCTION("com-UserName",IssActivity.ActivityBy)
                ,'left')
            htmlib-MntTableField(html-encode(lc-Start),'left')
            htmlib-MntTableField(IF IssActivity.Duration > 0 
                THEN html-encode(com-TimeToString(IssActivity.Duration))
                ELSE "",'right')
            
            tbar-BeginHidden(ROWID(IssActivity))
           
            tbar-Link("update",?,
                'javascript:PopUpWindow('
                + '~'' + appurl 
                + '/iss/actionupdate.p?mode=update&issuerowid=' + string(ROWID(b-table)) + "&rowid=" + string(ROWID(b-query))
                + '~'' 
                + ');'
                ,"")
                                                                                                            
            tbar-EndHidden()
            '</tr>' skip.


        END.

    END.
    
    IF li-total-duration <> 0 THEN
    DO:
        {&out} '<tr class="tabrow1" style="font-weight: bold; border: 1px solid black;">'
        REPLACE(htmlib-MntTableField("Total Duration","right"),"<td","<td colspan=9 ")
        htmlib-MntTableField(html-encode(com-TimeToString(li-total-duration))
            ,'right')
            '</tr>'.
            
        {&out} '<tr class="tabrow1" style="font-weight: bold; border: 1px solid black;">'
        REPLACE(htmlib-MntTableField("Total Duration (Admin)","right"),"<td","<td colspan=9 ")
        htmlib-MntTableField(html-encode(com-TimeToString(li-tduration[1]))
            ,'right')
            '</tr>'.
            
         {&out} '<tr class="tabrow1" style="font-weight: bold; border: 1px solid black;">'
        REPLACE(htmlib-MntTableField("Total Duration (Non Admin)","right"),"<td","<td colspan=9 ")
        htmlib-MntTableField(html-encode(com-TimeToString(li-tduration[2]))
            ,'right')
            '</tr>'.
            
    END.
    
    IF ll-HasClosed THEN
    DO:
        {&out} '<tr class="tabrow1" style="font-weight: bold; border: 1px solid black;">'
        REPLACE(htmlib-MntTableField("** Closed Actions","left"),"<td",'<td colspan=10 style="color:green;"')
                
        '</tr>'.
    END.
    {&out} skip 
           htmlib-EndTable()
           skip.

  
  


END PROCEDURE.

PROCEDURE outputHeader :
    /*------------------------------------------------------------------------------
      Purpose:     Output the MIME header, and any "cookie" information needed 
                   by this procedure.  
      Parameters:  <none>
      objtargets:       In the event that this Web object is state-aware, this is
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
      objtargets:       
    ------------------------------------------------------------------------------*/
    
    
     

    ASSIGN
        lc-rowid = get-value("rowid")
        lc-toolbarid = get-value("toolbarid")
        lc-AllowDelete = get-value("allowdelete").
    

    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.

    
    RUN outputHeader.
    
    {&out}
    htmlib-CustomerViewable(b-table.CompanyCode,b-table.AccountNumber).
    
    IF b-table.iClass <> lc-global-iclass-complex
        THEN RUN ip-StandardActionTable.
    ELSE RUN ip-ComplexProjectTable.

    
END PROCEDURE.


&ENDIF

