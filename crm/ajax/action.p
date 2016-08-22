/***********************************************************************

    Program:        crm/ajax/action.p
    
    Purpose:        CRM Actions    
    
    Notes:
    
    
    When        Who         What
    14/08/2016  phoski      Initial
   
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

DEFINE BUFFER op_master     FOR op_master.
DEFINE BUFFER op_action     FOR op_action.
DEFINE BUFFER op_activity FOR op_Activity.   


  

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

    FOR EACH op_action NO-LOCK
        WHERE op_action.CompanyCode = op_master.CompanyCode
        AND op_action.op_id = op_master.op_id
        BY op_action.ActionDate DESCENDING
        BY op_action.CreateDt DESCENDING
       
        :

        IF op_Action.ActionCode <> "" THEN 
        DO:
            FIND WebAction 
                WHERE WebAction.CompanyCode = op_Action.CompanyCode
                   AND WebAction.ActionCode = op_Action.ActionCode
                  
                NO-LOCK NO-ERROR.
            ASSIGN 
                lc-descr = WebAction.Description.
        END.
       
        
        ASSIGN
           li-class-count = li-class-count + 1 
           lc-this-class = "cl" + STRING(li-class-count).
        
        ASSIGN
            li-duration = 0.
        FOR EACH op_activity NO-LOCK
            WHERE op_activity.CompanyCode = op_master.CompanyCode
            AND op_activity.op_id = op_master.op_id
            AND op_activity.opActionId = op_action.opActionID:
            ASSIGN
                li-duration = li-duration + op_activity.Duration
                li-count    = li-count + 1.
            
           
        END.
        ASSIGN
            li-total-duration = li-total-duration + li-duration.

        ASSIGN
            li-count = li-count + 1.

        ASSIGN
            lc-Action = STRING(op_action.ActionDate,"99/99/9999").
        IF op_action.ActionStatus = "CLOSED"
            THEN ASSIGN lc-Action = '<span style="color: green;">' + lc-Action + "**</span>"
                ll-HasClosed = TRUE.

        ASSIGN
            lc-Audit = STRING(op_action.CreateDt,"99/99/9999 hh:mm") + " " + 
                       dynamic-function("com-UserName",op_action.CreatedBy).
                       
        {&out}
        SKIP(1)
        tbar-trID(lc-ToolBarID,ROWID(op_action))
        SKIP(1)
        htmlib-MntTableField(lc-Action,'left')
        htmlib-MntTableField(
            DYNAMIC-FUNCTION("com-UserName",op_action.AssignTo)
            ,'left')
        htmlib-MntTableField(lc-Audit,'left').

        IF op_action.notes <> "" OR 1 = 1 THEN
        DO:
        
            ASSIGN 
                lc-info = 
                REPLACE(htmlib-MntTableField(html-encode(lc-descr),'left'),'</td>','')
                lc-object = "hdobj" + string(op_action.opActionID).
        
            lc-info = REPLACE(lc-info,"<td","<td colspan=6 ").

            ASSIGN 
                li-tag-end = INDEX(lc-info,">").

            {&out} substr(lc-info,1,li-tag-end).

            ASSIGN 
                substr(lc-info,1,li-tag-end) = "".
           
            {&out} 
            '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
            lc-object 
            
            '~')' SKIP
            ";actionExpand(this,~'" lc-this-class "~')"
            '">':U skip.
            
            {&out} lc-info.
    
            {&out} htmlib-ExpandBox(lc-object,op_action.Notes).

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
            
        tbar-BeginHidden(ROWID(op_action)).

        IF lc-allowDelete = "yes" 
            THEN {&out} tbar-Link("delete",ROWID(op_action),
            'javascript:ConfirmDeleteAction(' +
            "ROW" + string(ROWID(op_action)) + ','
                           
                          
            + string(op_action.opActionID) + ');',
            "").
        {&out}
            
        tbar-Link("update",?,
            'javascript:PopUpWindow('
            + '~'' + appurl 
            + '/iss/actionupdate.p?mode=update&issuerowid=' + string(ROWID(op_master)) + "&rowid=" + string(ROWID(op_action))
            + '~'' 
            + ');'
            ,"")
                                                                                            
        tbar-Link("multiiss",?,
            'javascript:PopUpWindow('
            + '~'' + appurl 
            + '/iss/activityupdmain.p?mode=display&issuerowid=' + string(ROWID(op_master)) + "&rowid=" + string(ROWID(op_action)) + "&actionrowid=" + string(ROWID(op_action))
            + '~'' 
            + ');'
            ,"") skip
                         

            tbar-EndHidden()
            '</tr>' skip.

        FOR EACH op_activity NO-LOCK
            WHERE op_activity.CompanyCode = op_action.CompanyCode
            AND op_activity.op_id = op_action.op_id
            AND op_activity.opActionId = op_action.opActionID
            BY op_activity.ActDate DESCENDING
            BY op_activity.CreateDate DESCENDING
            BY op_activity.CreateTime DESCENDING:

            ASSIGN
                lc-start = ""
                lc-descr = op_activity.Description.
            IF op_activity.activityType <> ""
            THEN ASSIGN lc-descr = op_activity.activityType + " - " + op_activity.Description.
            
            
            

            IF op_activity.StartDate <> ? THEN
            DO:
                ASSIGN
                    lc-start = STRING(op_activity.StartDate,"99/99/9999") + 
                               " " +
                               string(op_activity.StartTime,"hh:mm").

                IF op_activity.EndDate <> ? THEN
                ASSIGN
                    lc-start = lc-start + " - " + STRING(op_activity.endDate,"99/99/9999") + 
                               " " +
                               string(op_activity.EndTime,"hh:mm").
                                
            END.

            {&out}
            SKIP(1)
            tbar-trID(lc-ToolBarID,ROWID(op_activity))
            SKIP(1)
            REPLACE(htmlib-MntTableField("",'left'),"<td","<td colspan=4") 
            htmlib-MntTableField(STRING(op_activity.ActDate,'99/99/9999'),'left') skip.


            IF op_activity.notes <> "" THEN
            DO:
            
                ASSIGN 
                    lc-info = 
                    REPLACE(htmlib-MntTableField(html-encode(lc-descr),'left'),'</td>','')
                    lc-object = "hdobj" + string(op_activity.opactivityID).
            
                ASSIGN 
                    li-tag-end = INDEX(lc-info,">").
    
                {&out} substr(lc-info,1,li-tag-end).
    
                ASSIGN 
                    substr(lc-info,1,li-tag-end) = "".
                
                {&out} 
                '<img class="expandboxi i' lc-this-class '" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
                lc-object '~')">':U skip.
                {&out} lc-info.
        
                {&out} REPLACE(htmlib-ExpandBox(lc-object,op_activity.Notes),
                        'class="','class="' + lc-this-class + " ").
    
                {&out} '</td>' skip.
            END.
            ELSE {&out}
            htmlib-MntTableField(lc-descr,'left').

            {&out}
            htmlib-MntTableField(IF op_activity.SiteVisit THEN "Yes" ELSE "&nbsp;",'left').

            {&out}
            htmlib-MntTableField(
                DYNAMIC-FUNCTION("com-UserName",op_activity.ActivityBy)
                ,'left')
            htmlib-MntTableField(html-encode(lc-Start),'left')
            htmlib-MntTableField(IF op_activity.Duration > 0 
                THEN html-encode(com-TimeToString(op_activity.Duration))
                ELSE "",'right')
            
            tbar-BeginHidden(ROWID(op_activity))
           
            tbar-Link("update",?,
                'javascript:PopUpWindow('
                + '~'' + appurl 
                + '/iss/actionupdate.p?mode=update&issuerowid=' + string(ROWID(op_master)) + "&rowid=" + string(ROWID(op_action))
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
    

    FIND op_master WHERE ROWID(op_master) = to-rowid(lc-rowid) NO-LOCK.

    
    RUN outputHeader.
    
    
    RUN ip-StandardActionTable.
    
    
END PROCEDURE.


&ENDIF

