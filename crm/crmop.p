/***********************************************************************

    Program:        crm/crmop.p
    
    Purpose:        CRM Opportunity Maintainance
    
    Notes:
    
    
    When        Who         What
    06/08/2016  phoski      Initial
    15/10/2016  phoski      Phase 2 changes
    26/11/2016  phoski      Change to submit on account selection and
                            build relevant page etc
    28/11/2016  phoski      Default on add to existing to main sales
                            contact
                            Show customer name on page title    
    15/12/2016  phoski      Use "." in created contact name                                            
    15/12/2016  phoski      Event Processing
    15/12/2016  phoski      Passthru link
    22/12/2016  phoski      Marketing fields
    24/12/2016  phoski      Disabled display of opno on change page
                            and marketing fields on view page
    22/02/2017  phoski      Recurring Cost & Revenue
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE lc-error-field     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitSource    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-mode            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crmAccount      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lr-customer        AS ROWID     NO-UNDO.
DEFINE VARIABLE lc-title           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Enc-Key         AS CHARACTER NO-UNDO.  
DEFINE VARIABLE lc-search          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-source          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parent          AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-sela-Code       AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE lc-sela-Name       AS LONGCHAR  NO-UNDO.

DEFINE VARIABLE lc-link-label      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-descr           AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-op-salescontact AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-scont-code      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-scont-desc      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-department      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-nextStep        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CloseDate       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-currentProv     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-opType          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ServReq         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-opNote          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rating          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-opStatus        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-prob            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cos             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-recrev          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-reccos          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rev             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lost            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sType           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-dbase           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-camp            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ops             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-opno            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lr-val-rowid       AS ROWID     NO-UNDO.
DEFINE VARIABLE lc-lostd           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-loginid         AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop            AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-next            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Data            AS CHARACTER EXTENT 10 NO-UNDO.
DEFINE VARIABLE lc-Options         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-part            AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-Action-TBar     AS CHARACTER INITIAL 'tim' NO-UNDO.
DEFINE VARIABLE lc-doc-tbar        AS CHARACTER INITIAL 'doc' NO-UNDO.

/* Stuff for call from crmview.p */
DEFINE VARIABLE lc-FilterOptions   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-mkformType      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mkkeyword       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mkcontactTime   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mkamPM          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mktimeOnSite    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mkpageViews     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mklandingPage   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mkexitPage      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mkLongestPage   AS CHARACTER NO-UNDO.
  

{crm/customer-form-vars.i}

DEFINE BUFFER b-valid  FOR op_master.
DEFINE BUFFER b-table  FOR op_master.
DEFINE BUFFER Customer FOR Customer.
DEFINE BUFFER b-user   FOR webuser.

DEFINE TEMP-TABLE tt-old-table NO-UNDO LIKE op_master.


{src/web2/wrap-cgi.i}

    {lib/htmlib.i}



RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

PROCEDURE ip-ActionPage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    {&out}
        SKIP
        tbar-BeginID(lc-Action-TBAR,"") SKIP.
     
    {&out} 
        tbar-Link("add",?,
        'javascript:PopUpWindow('
        + '~'' + appurl 
        + '/crm/actionupdate.p?mode=add&oprowid=' + string(ROWID(b-table))
        + '~'' 
        + ');'
        ,"")
        SKIP.

    {&out}
        tbar-BeginOptionID(lc-Action-TBAR) SKIP.

    {&out} tbar-Link("delete",?,"off","").

    {&out}  
        tbar-Link("update",?,"off","")
        tbar-Link("multiiss",?,"off","")
        tbar-EndOption()
        tbar-End().

    {&out}
        '<div id="IDAction"></div>'.
    
    

END PROCEDURE.

PROCEDURE ip-MarketingPage:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    IF lc-mode = "ADD" THEN {&out} '<br />'.
    
    
    {&out} 
        '<div class="infobox" style="font-size:10px;">Marketing</div>' SKIP.
    
    
    {&out} 
        htmlib-StartTable("mnt",
        100,
        0,
        0,
        0,
        "center").
                        
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Form Type")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("mkformtype",lc-global-FormType-Code ,lc-global-FormType-desc,lc-mkFormType)
        '</TD></TR>' SKIP.
                            
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("mkkeyword",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Keyword")
        ELSE htmlib-SideLabel("Keyword"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("mkkeyword",40,lc-mkkeyword) SKIP
        '</TD></tr>' SKIP.
        
      
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("mkcontacttime",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Contact Time (HHMM)")
        ELSE htmlib-SideLabel("Contact Time (HHMM)"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("mkcontacttime",4,lc-mkcontacttime) SKIP
        '</TD></tr>' SKIP.
          
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("AM/PM")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("mkampm","AM|PM" ,"AM|PM",lc-mkamPm)
        '</TD></TR>' SKIP.
        
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("mktimeonsite",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Time On Site (Mins)")
        ELSE htmlib-SideLabel("Time On Site (Mins)"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("mktimeonsite",6,lc-mktimeonsite) SKIP
        '</TD></tr>' SKIP.
             
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("mkpageviews",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Page Views")
        ELSE htmlib-SideLabel("Page Views"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("mkpageviews",6,lc-mkpageviews) SKIP
        '</TD></tr>' SKIP.
        
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("mklandingpage",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Landing Page")
        ELSE htmlib-SideLabel("Landing Page"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("mklandingpage",40,lc-mklandingpage) SKIP
        '</TD></tr>' SKIP.
            
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("mkexitpage",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Exit Page")
        ELSE htmlib-SideLabel("Exit Page"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("mkexitpage",40,lc-mkexitpage) SKIP
        '</TD></tr>' SKIP.
      
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("mklongestpage",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Longest Page")
        ELSE htmlib-SideLabel("Longest Page"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("mklongestpage",40,lc-mklongestpage) SKIP
        '</TD></tr>' SKIP.
        
        
        
                           
                           
    {&out} htmlib-EndTable() SKIP.
    
    

END PROCEDURE.

PROCEDURE ip-StatusTable:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    {&out} SKIP
        REPLACE(htmlib-StartMntTable(),'width="100%"','width="100%"') SKIP
        htmlib-TableHeading(
        "Date|By|From|To"
        ) SKIP.
       
       
    FOR EACH op_status NO-LOCK OF b-table
        BY op_status.ChangeDate:
            
        {&out}
            '<tr>'
            htmlib-MntTableField(html-encode(STRING(op_status.ChangeDate,"99/99/9999 HH:MM")),'left')
            htmlib-MntTableField(html-encode(com-userName(op_status.Loginid)),'left')
            htmlib-MntTableField(html-encode(IF op_status.FromOpStatus = "" THEN "" ELSE com-DecodeLookup(op_status.FromOpStatus,lc-global-opStatus-Code,lc-global-opStatus-Desc )),'left') 
            htmlib-MntTableField(html-encode(com-DecodeLookup(op_status.ToOpStatus,lc-global-opStatus-Code,lc-global-opStatus-Desc )),'left')  
            '</tr>' SKIP. 
            
             
    END.   
  
    {&out} SKIP 
        htmlib-EndTable()
        SKIP.
                       

END PROCEDURE.

PROCEDURE ip-ViewActionPage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

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
    DEFINE VARIABLE lc-this-class     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-class-count    AS INTEGER   NO-UNDO.
    
    
    {&out} SKIP
        REPLACE(htmlib-StartMntTable(),'width="100%"','width="100%" align="center"').
    {&out}
        htmlib-TableHeading(
        "Date|Assigned To|Created|Action|Date|Activity|Site Visit|By|Start/End|Duration<br>(H:MM)^right"
        ) SKIP.

    FOR EACH op_action NO-LOCK
        WHERE op_action.CompanyCode = b-table.CompanyCode
        AND op_action.op_id = b-table.op_id
        BY op_action.ActionDate DESCENDING
        BY op_action.CreateDt DESCENDING
       
        :

    
        FIND WebAction 
            WHERE WebAction.CompanyCode = op_Action.CompanyCode
            AND WebAction.ActionCode = op_Action.ActionCode
            NO-LOCK NO-ERROR.
                   
            
        ASSIGN 
            lc-descr = IF AVAILABLE WebAction THEN WebAction.Description ELSE op_Action.ActionCode.
      
         
            
        ASSIGN
            li-class-count = li-class-count + 1 
            lc-this-class  = "cl" + STRING(li-class-count).
        
        ASSIGN
            li-duration = 0.
        FOR EACH op_activity NO-LOCK
            WHERE op_activity.CompanyCode = b-table.CompanyCode
            AND op_activity.op_id = b-table.op_id
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
            THEN ASSIGN lc-Action    = '<span style="color: green;">' + lc-Action + "**</span>"
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
                lc-info   = REPLACE(htmlib-MntTableField(html-encode(lc-descr),'left'),'</td>','')
                lc-object = "hdobj" + string(op_action.opActionID).
        
            lc-info = REPLACE(lc-info,"<td","<td colspan=6 ").

            ASSIGN 
                li-tag-end = INDEX(lc-info,">").

            {&out} substr(lc-info,1,li-tag-end).

            ASSIGN 
                substr(lc-info,1,li-tag-end) = "".
          
            {&out} lc-info.
    
            {&out} htmlib-ExpandBox(lc-object,op_action.Notes).

            {&out} 
                '</td>' SKIP.
        END.
        ELSE {&out}
                REPLACE(htmlib-MntTableField(lc-descr,'left'),
                "<td","<td colspan=6 ").
        {&out}
            
            htmlib-MntTableField(
            IF li-Duration > 0 
            THEN '<strong>' + html-encode(com-TimeToString(li-duration)) + '</strong>'
            ELSE "",'right').
  
        {&out}   
            '</tr>' SKIP.

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
                REPLACE(htmlib-MntTableField("",'left'),"<td","<td colspan=4") 
                htmlib-MntTableField(STRING(op_activity.ActDate,'99/99/9999'),'left') SKIP.


            IF op_activity.notes <> "" THEN
            DO:
            
                ASSIGN 
                    lc-info   = REPLACE(htmlib-MntTableField(html-encode(lc-descr),'left'),'</td>','')
                    lc-object = "hdobj" + string(op_activity.opactivityID).
            
                ASSIGN 
                    li-tag-end = INDEX(lc-info,">").
    
                {&out} substr(lc-info,1,li-tag-end).
    
                ASSIGN 
                    substr(lc-info,1,li-tag-end) = "".
              
                {&out} lc-info.
        
                {&out} REPLACE(htmlib-ExpandBox(lc-object,op_activity.Notes),
                    'class="','class="' + lc-this-class + " ").
    
                {&out} 
                    '</td>' SKIP.
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
                + '/crm/actionupdate.p?mode=update&oprowid=' + string(ROWID(op_master)) + "&rowid=" + string(ROWID(op_action))
                + '~'' 
                + ');'
                ,"")
                                                                                                            
                tbar-EndHidden()
                '</tr>' SKIP.


        END.

    END.
    
    IF li-total-duration <> 0 THEN
    DO:
        {&out} 
            '<tr class="tabrow1" style="font-weight: bold; border: 1px solid black;">'
            REPLACE(htmlib-MntTableField("Total Duration","right"),"<td","<td colspan=9 ")
            htmlib-MntTableField(html-encode(com-TimeToString(li-total-duration))
            ,'right')
            '</tr>'.
            
            
    END.
    
    IF ll-HasClosed THEN
    DO:
        {&out} 
            '<tr class="tabrow1" style="font-weight: bold; border: 1px solid black;">'
            REPLACE(htmlib-MntTableField("** Closed Actions","left"),"<td",'<td colspan=10 style="color:green;"')
                
            '</tr>'.
    END.
    {&out} SKIP 
        htmlib-EndTable()
        SKIP.

  
  



END PROCEDURE.

PROCEDURE ip-ViewDocumentPage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-rowid     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-toolbarid AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-toggle    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-doc-key   AS CHARACTER NO-UNDO. 


    DEFINE BUFFER b-query FOR doch.

    DEFINE VARIABLE lc-type AS CHARACTER 
        INITIAL "CRMOP" NO-UNDO.
    
    {&out} SKIP
        REPLACE(htmlib-StartMntTable(),'width="100%"','width="100%" align="center"').

    {&out}
        htmlib-TableHeading(
        "Date|Time|By|Description|Type|Size (KB)^right"
        ) SKIP.

    FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = b-table.CompanyCode
        AND b-query.RelType = lc-Type
        AND b-query.RelKey  = string(b-table.op_id):



                
        {&out}
            '<tr>'
            htmlib-MntTableField(STRING(b-query.CreateDate,"99/99/9999"),'left')
            htmlib-MntTableField(STRING(b-query.CreateTime,"hh:mm am"),'left')
            htmlib-MntTableField(html-encode(DYNAMIC-FUNCTION("com-UserName",b-query.CreateBy)),'left')
            htmlib-MntTableField(b-query.descr,'left').


       
        {&out}
            htmlib-MntTableField(b-query.DocType,'left')
            htmlib-MntTableField(STRING(ROUND(b-query.InBytes / 1024,2)),'right')
            '</tr>' SKIP.

    END.

    {&out} SKIP 
        htmlib-EndTable()
        SKIP.
    
    
END PROCEDURE.

PROCEDURE ip-ViewNotePage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    {&out}
        REPLACE(htmlib-StartMntTable(),'width="100%"','width="100%" align="center"')
        htmlib-TableHeading(
        "Date & Time^right|Details|By"
        ) SKIP.


    
    DEFINE BUFFER b-note   FOR op_Note.
    DEFINE BUFFER b-status FOR WebNote.
    DEFINE BUFFER b-user   FOR WebUser.

 
    DEFINE VARIABLE lc-status AS CHARACTER NO-UNDO.



    FOR EACH b-note NO-LOCK
        WHERE b-note.CompanyCode =  b-table.CompanyCode
        AND b-note.op_id = b-table.op_id:

        FIND b-status WHERE b-status.CompanyCode = b-table.CompanyCode
            AND b-status.NoteCode = b-note.NoteCode NO-LOCK NO-ERROR.

        ASSIGN 
            lc-status = IF AVAILABLE b-status THEN b-status.description ELSE "".

        ASSIGN 
            lc-status = lc-status + '<br>' + replace(b-note.Contents,'~n','<BR>').

        {&out} 
            '<tr>'
            htmlib-TableField(STRING(b-note.CreateDate,'99/99/9999') + " " + STRING(b-note.CreateTime,'hh:mm am') ,'right')
           
            htmlib-TableField(lc-status,'left')
            htmlib-TableField(html-encode(com-UserName(b-note.LoginID)),'left')
            '</tr>' SKIP.
    END.
    {&out} SKIP 
        htmlib-EndTable()
        SKIP.
             

END PROCEDURE.

PROCEDURE ip-ViewPage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    IF lc-mode = "VIEW"
        THEN {&out} '<a href="javascript:window.print()"><img src="/images/general/print.gif" border=0 style="padding: 5px;"></a>' SKIP.
       
       
    {&out} 
        '<br />' htmlib-StartTable("mnt",
        100,
        0,
        0,
        0,
        "center").
        
    {&out} 
        '<tr><TD VALIGN="TOP" ALIGN="left">' SKIP.
                
                  
                
                
       
    {&out} htmlib-StartTable("mnt",
        100,
        0,
        0,
        0,
        "center").
        


    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Opportunity No")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' b-table.op_no '</td></tr>' SKIP.

              
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Description")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' b-table.descr '</td></tr>' SKIP.
          
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Sales Contact")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' b-table.salesContact '</td></tr>' SKIP.
          
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Department")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' b-table.Department '</td></tr>' SKIP.
     
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Stage")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' com-GenTabDesc(b-table.companyCode,"CRM.Stage",b-table.NextStep) '</td></tr>' SKIP.
               
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Close Date")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' IF b-table.CloseDate = ? THEN "&nbsp;" ELSE STRING(b-table.CloseDate,"99/99/9999") '</td></tr>' SKIP.
                       
                       
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Current Provider")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' b-table.CurrentProvider '</td></tr>' SKIP.
          
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Opportuntity Type")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  com-DecodeLookup(b-table.opType,lc-global-opType-Code,lc-global-opType-Desc ) '</td></tr>' SKIP.
          
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Service Required")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  com-GenTabDesc(b-table.companyCode,"CRM.ServiceRequired",b-table.servRequired) '</td></tr>' SKIP.
          
    {&out} 
        '<TR align="left"><TD vaLIGN="TOP" ALIGN="right" width="25%">' 
        htmlib-SideLabel("Note")        '</TD>' SKIP
        '<TD vaLIGN="TOP" ALIGN="left" style="font-size: 12px;padding-left: 15px;">' REPLACE(b-table.opNote,"~n","<br />") '</td></tr>' SKIP.
                
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Rating")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  com-DecodeLookup(b-table.Rating,lc-global-Rating-Code,lc-global-Rating-Desc ) '</td></tr>' SKIP.
                     
                     
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Status")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  com-DecodeLookup(b-table.OpStatus,lc-global-opStatus-Code,lc-global-opStatus-Desc ) '</td></tr>' SKIP.
          
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Probability")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' b-table.Probability '%</td></tr>' SKIP.
          
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Revenue")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' "&pound" + com-money(b-table.Revenue) '</td></tr>' SKIP.
               
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Cost Of Sale")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' "&pound" + com-money(b-table.CostOfSale) '</td></tr>' SKIP.
               
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("GP Profit")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' "&pound" + com-money(b-table.Revenue - b-table.CostOfSale) '</td></tr>' SKIP.
          
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Deal Lost Reason")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' com-GenTabDesc(b-table.companyCode,"CRM.DealLostReason",b-table.DealLostReason) '</td></tr>' SKIP.
               
    {&out} 
        '<TR align="left"><TD vaLIGN="TOP" ALIGN="right" width="25%">' 
        htmlib-SideLabel("Lost Description")        '</TD>' SKIP
        '<TD vaLIGN="TOP" ALIGN="left" style="font-size: 12px;padding-left: 15px;">' REPLACE(b-table.LostDescription,"~n","<br />") '</td></tr>' SKIP.
                                             
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Source Type")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' com-GenTabDesc(b-table.companyCode,"CRM.SourceType",b-table.SourceType) '</td></tr>' SKIP.
          
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Source")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' b-table.opSource '</td></tr>' SKIP.
     
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Database")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' com-GenTabDesc(b-table.companyCode,"CRM.Database",b-table.dBase) '</td></tr>' SKIP.
    {&out} 
        '<TR align="left" style="font-size: 12px;padding-left: 15px;"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Campaign")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">' com-GenTabDesc(b-table.companyCode,"CRM.Campaign",b-table.Campaign) '</td></tr>' SKIP.
        
        
    {&out} 
        '<TR align="left"><TD ALIGN="left" colspan=2><div class="infobox" style="font-size:10px;">Marketing</div></td></tr>' SKIP
        .
        
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Form Type")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  com-DecodeLookup(b-table.mk_formType,lc-global-FormType-Code,lc-global-FormType-Desc ) '</td></tr>' SKIP.
        
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Keyword")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  b-table.mk_keyword '</td></tr>' SKIP.
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Contact Time")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  b-table.mk_contactTime '</td></tr>' SKIP.
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("AM/PM")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  b-table.mk_amPM '</td></tr>' SKIP.
        
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Time On Site")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  b-table.mk_timeOnSite '</td></tr>' SKIP.
        
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Page Views")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  b-table.mk_pageViews '</td></tr>' SKIP.
        
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Landing Page")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  b-table.mk_landingPage '</td></tr>' SKIP.
    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Exit Page")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  b-table.mk_exitPage '</td></tr>' SKIP.

    {&out} 
        '<TR align="left"><TD ALIGN="right" width="25%">' 
        htmlib-SideLabel("Longest Page")        '</TD>' SKIP
        '<TD ALIGN="left" style="font-size: 12px;padding-left: 15px;">'  b-table.mk_longestPage '</td></tr>' SKIP.
                
          
        
        
        
        
        
        
    {&out} htmlib-EndTable() SKIP. 
          
    {&out} 
        '</td><TD VALIGN="TOP" ALIGN="left"><div class="infobox" style="font-size:10px;">Status Changes</div>' SKIP.
    RUN ip-StatusTable.
               
    {&out} 
        '</tr>' SKIP.
                   
    {&out} htmlib-EndTable() SKIP.                
                

              
   
    
   
    IF lc-mode = "DELETE" THEN RETURN.
    
    RUN ip-ViewActionPage.
    RUN ip-ViewDocumentPage.
    RUN ip-ViewNotePage.
    
    
    
    
END PROCEDURE.

PROCEDURE ip-Documents:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    {&out}
        SKIP
        tbar-BeginID(lc-Doc-TBAR,"")
        tbar-Link("add",?,'javascript:documentAdd();',"") SKIP
        tbar-BeginOptionID(lc-Doc-TBAR) SKIP
        tbar-Link("delete",?,"off","")
        tbar-Link("documentview",?,"off","")
        tbar-EndOption()
            
        tbar-End().

    {&out}
        '<div id="IDDocument"></div>'.
    

END PROCEDURE.

PROCEDURE ip-ExportJS:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    {&out} lc-global-jquery  SKIP
        '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' SKIP
        tbar-JavaScript(lc-Action-TBar) SKIP
        tbar-JavaScript(lc-Doc-TBAR) SKIP
        '<script language="javascript">' SKIP
        'var appurl = "' appurl '";' SKIP
        'var appMode = "' lc-mode '";' SKIP
        'var CustomerAjax = "' appurl '/cust/custequiplist.p?expand=yes&ajaxsubwindow=yes&customer=' url-encode(lc-enc-key,"Query")  '"' SKIP
        'var NoteAddURL = "' appurl '/crm/addnote.p?rowid=' + lc-rowid '"' SKIP
        'var NoteAjax = "' appurl '/crm/ajax/note.p?rowid=' STRING(ROWID(b-table)) '"' SKIP
                       
        'var ActionAjax = "' appurl '/crm/ajax/action.p?allowdelete=yes&rowid=' STRING(ROWID(b-table)) 
        '&toolbarid=' lc-Action-TBar  
        '"' SKIP
        'var DocumentAjax = "' appurl '/crm/ajax/document.p?rowid=' STRING(ROWID(b-table)) 
        '&toolbarid=' lc-Doc-TBAR 
        '"' SKIP
        'var DocumentAddURL = "' appurl '/crm/adddocument.p?rowid=' + lc-rowid '"' SKIP
                    
        '</script>' SKIP
          
           
           
        '<script language="JavaScript" src="/asset/page/crm/crmop.js?v=1.0.0"></script>' SKIP.
           
    /* 3678 ----------------------> */ 
    {&out}  
        '<script type="text/javascript" >~n'
        'var pIP =  window.location.host; ~n'
        'function goGMAP(pCODE, pNAME, pADD) ~{~n'
        'var pOPEN = "http://www.google.co.uk/maps/preview?q=";' SKIP
        'pOPEN = pOPEN + pCODE;~n' SKIP
        'window.open(pOPEN, ~'WinName~' , ~'width=645,height=720,left=0,top=0~');~n'
        ' ~}~n'
        '</script>'  SKIP.
    /* ----------------------- 3678 */ 

    /* 3677 ----------------------> */ 
    {&out}  
        '<script type="text/javascript" >~n'
        'function newRDP(rdpI, rdpU, rdpD) ~{~n'
        'var sIP =  window.location.host; ~n'
        'var sHTML="<div style:visibility=~'hidden~' >Connect to customer</div>";~n'
        'var sScript="<SCRIPT DEFER>  ";~n'
        'sScript = sScript +  "function goRDP()~{ window.open("~n'
        'sScript = sScript +  "~'";~n'
        'sScript = sScript + "http://";~n'
        'sScript = sScript + sIP;~n'
        'sScript = sScript + ":8090/TSweb.html?server=";~n'
        'sScript = sScript + rdpI;~n'
        'sScript = sScript + "&username=";~n'
        'sScript = sScript + rdpU;~n'
        'sScript = sScript + "&domain=";~n'
        'sScript = sScript + rdpD;~n'
        'sScript = sScript + "~'";~n'
        'sScript = sScript + ", ~'WinName~', ~'width=655,height=420,left=0,top=0~'); ~} ";~n'
        'sScript = sScript + " </SCRIPT" + ">";~n'
        'ScriptDiv.innerHTML = sHTML + sScript;~n'
        'document.getElementById(~'ScriptDiv~').style.visibility=~'hidden~';~n'
        ' ~}~n'
        '</script>'  SKIP.
          
           
    {&out}
        '<script>' SKIP
        'function ConfirmDeleteAction(ObjectID,ActionID) ~{' SKIP
        '   var DocumentAjax = "' appurl '/crm/ajax/delaction.p?actionid=" + ActionID' SKIP
        '   if (confirm("Are you sure you want to delete this action?")) ~{' SKIP
        "       ObjectID.style.display = 'none';" SKIP
        "       ahah(DocumentAjax,'placeholder');" SKIP
        '       var objtoolBarOption = document.getElementById("acttbtboption");' SKIP
        '       objtoolBarOption.innerHTML = acttbobjRowDefault;' SKIP
        '       actionTableBuild();' SKIP
        '   ~}' SKIP
        '~}' SKIP
        '</script>'.
        
    {&out} 
        '<script>' SKIP
        'function ConfirmDeleteAttachment(ObjectID,DocID) ~{' SKIP
        '   var DocumentAjax = "' appurl '/crm/ajax/deldocument.p?docid=" + DocID' SKIP
        '   if (confirm("Are you sure you want to delete this document?")) ~{' SKIP
        "       ObjectID.style.display = 'none';" SKIP
        "       ahah(DocumentAjax,'placeholder');" SKIP
        '       var objtoolBarOption = document.getElementById("doctbtboption");' SKIP
        '       objtoolBarOption.innerHTML = doctbobjRowDefault;' SKIP
        '   ~}' SKIP
        '~}' SKIP
        '</script>' SKIP.

             
    

END PROCEDURE.

PROCEDURE ip-ExportJS-Add:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/


    {&out} lc-global-jquery  SKIP
        '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>'  SKIP
        '<script language="javascript">' SKIP
        'var appurl = "' appurl '";' SKIP
        '</script>' SKIP
                   
        '<script language="JavaScript" src="/asset/page/crm/crmop.js?v=1.0.0"></script>' SKIP
           
        .
           
           
END PROCEDURE.

PROCEDURE ip-NewAccountPage:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/

    {crm/customer-form-page.i}  
    

END PROCEDURE.

PROCEDURE ip-NotePage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    {&out}
        SKIP(5)
        tbar-Begin("")
        tbar-Link("addnote",?,'javascript:noteAdd();',"")
        tbar-End().

    {&out}
        '<div id="IDNoteAjax"></div>'.
    
END PROCEDURE.

PROCEDURE ip-UpdatePage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    
    DEFINE VARIABLE lc-code AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-desc AS CHARACTER NO-UNDO.
    
   
    {&out} 
        htmlib-StartTable("mnt",
        100,
        0,
        0,
        0,
        "center").
   
    IF lc-source = "crmview" AND lc-mode = "ADD" THEN
    DO:   
        {&out} 
            '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">'
            ( IF LOOKUP("account",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Customer")
            ELSE htmlib-SideLabel("Customer"))
            '</TD>' SKIP
            '<TD VALIGN="TOP" ALIGN="left">'.
        {&out-long}               
            htmlib-SelectJSLong(
            "account",
            'ChangeAccount()',
            "ADD|" + lc-sela-code,
            "Add New|" + lc-sela-name,
            get-value("account")
            )
            '</td><tr>' SKIP.
        
        IF lc-AccountNumber = "ADD" THEN
        DO:
        
            {&out} 
                '<tr><td colspan="2" id="box1"><div class="infobox" style="font-size:10px;">New CRM Customer Details</div>' SKIP.
        
        
            RUN ip-NewAccountPage.
       
        
            {&out} 
                '</td></tr>' SKIP. 
        
            {&out} 
                '<tr><td colspan="2" id="box2"><div class="infobox" style="font-size:10px;">Opportunity Details</div></td></tr>' SKIP.
        END.
        
    END.
       
    IF lc-opno <> "" THEN
    DO:
        {&out} 
            '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
            ( IF LOOKUP("opno",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Opportunity No")
            ELSE htmlib-SideLabel("Opportunity No"))
            '</TD>' SKIP
            '<TD VALIGN="TOP" ALIGN="left" class="sidelabel">' REPLACE(htmlib-InputField("lcopno",8,lc-opno),">"," disabled>") SKIP
            '</TD></tr>'.
    END.
              
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("descr",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("descr",40,lc-descr) SKIP
        '</TD></tr>' SKIP.
    
    
           
    
    IF lc-AddMode <> "SimpleContact" OR lc-AccountNumber <> "ADD" THEN
        {&out} 
            '<TR><TD VALIGN="TOP" ALIGN="right">' 
            htmlib-SideLabel("Sales Contact")
            '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
            htmlib-Select("opsalescontact",lc-scont-code,lc-scont-desc,lc-op-salescontact)
            '</TD></TR>' SKIP.
    
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("department",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Department")
        ELSE htmlib-SideLabel("Department"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("department",40,lc-department) SKIP
        '</TD></tr>'.
   
    RUN com-GenTabSelect ( lc-global-company, "CRM.Stage", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Stage")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("nextstep",lc-Code ,lc-desc,lc-nextStep)
        '</TD></TR>' SKIP.
                                
    {&out} 
        '<TR align="left"><td valign="top" align="right">' 
        (IF LOOKUP("closedate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Close Date")
        ELSE htmlib-SideLabel("Close Date"))
        '</td>'
        '<td valign="top" align="left">'
        htmlib-CalendarInputField("closedate",10,lc-closedate) 
        htmlib-CalendarLink("closedate")
        '</td></tr>' SKIP.
    
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("currentprov",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Current Provider")
        ELSE htmlib-SideLabel("Current Provider"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("currentprov",40,lc-currentProv) SKIP
        '</TD></tr>'.
           
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Opportunity Type")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("optype",lc-global-opType-Code ,lc-global-opType-desc,lc-opType)
        '</TD></TR>' SKIP.
    
    RUN com-GenTabSelect ( lc-global-company, "CRM.ServiceRequired", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Service Required")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("servreq",lc-Code ,lc-desc,lc-servreq)
        '</TD></TR>' SKIP. 
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("opnote",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Note")
        ELSE htmlib-SideLabel("Note"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-TextArea("opnote",lc-Opnote,5,60)
        '</TD></tr>' SKIP.
   
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Rating")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("rating",lc-global-rating-Code ,lc-global-Rating-desc,lc-Rating)
        '</TD></TR>' SKIP.

          
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Opportunity Status")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("opstatus",lc-global-opstatus-Code ,lc-global-opStatus-desc,lc-opstatus)
        '</TD></TR>' SKIP.
    
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Probability")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("prob",lc-global-opProb-Code ,lc-global-opProb-desc,lc-Prob)
        '</TD></TR>' SKIP.
    
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("cos",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Cost Of Sale")
        ELSE htmlib-SideLabel("Cost Of Sale"))
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("cos",8,lc-cos) 
        '</TD>' SKIP.
    
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("rev",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Revenue")
        ELSE htmlib-SideLabel("Revenue"))
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("rev",8,lc-rev) 
        '</TD>' SKIP.
    
     
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("rcos",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Recurring Cost Of Sale")
        ELSE htmlib-SideLabel("Recurring Cost Of Sale"))
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("rcos",8,lc-reccos) 
        '</TD>' SKIP.
    
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("rrev",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Recurring Revenue")
        ELSE htmlib-SideLabel("Recurring Revenue"))
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("rrev",8,lc-recrev) 
        '</TD>' SKIP.
        
    RUN com-GenTabSelect ( lc-global-company, "CRM.DealLostReason", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Deal Lost Reason")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("lost",lc-Code ,lc-desc,lc-lost)
        '</TD></TR>' SKIP. 
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("lostd",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Lost Description")
        ELSE htmlib-SideLabel("Lost Description"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-TextArea("lostd",lc-lostd,5,60)
        '</TD></tr>' SKIP.
    
         
    RUN com-GenTabSelect ( lc-global-company, "CRM.SourceType", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Source Type")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("stype",lc-Code ,lc-desc,lc-sType)
        '</TD></TR>' SKIP.
    
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("ops",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Opportunity Source")
        ELSE htmlib-SideLabel("Opportunity Source"))
        '</TD>' SKIP
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("ops",40,lc-ops) SKIP
        '</TD></tr>'.
           
    RUN com-GenTabSelect ( lc-global-company, "CRM.Database", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Database")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("dbase",lc-Code ,lc-desc,lc-dbase)
        '</TD></TR>' SKIP.
    
    RUN com-GenTabSelect ( lc-global-company, "CRM.Campaign", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Campaign")
        '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
        htmlib-Select("camp",lc-Code ,lc-desc,lc-camp)
        '</TD></TR>' SKIP.
    
    
              
    
    {&out} htmlib-EndTable() SKIP.
  

END PROCEDURE.

PROCEDURE ip-Validate:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg    AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-customer FOR Customer.
    
    DEFINE VARIABLE ld-date AS DATE    NO-UNDO.
    DEFINE VARIABLE li-int  AS INTEGER NO-UNDO.
    
    IF lc-descr = ""
        OR lc-descr = ?
        THEN RUN htmlib-AddErrorMessage(
            'descr', 
            'You must enter the description',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
 
    IF lc-closeDate <> "" THEN
    DO:
        ASSIGN
            ld-date = DATE(lc-closedate) no-error.
        IF ERROR-STATUS:ERROR 
            OR ld-date = ?
            THEN RUN htmlib-AddErrorMessage(
                'closedate', 
                'The close date is invalid',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
    END.
     
    ASSIGN 
        li-int = int(lc-cos) NO-ERROR.
    IF ERROR-STATUS:ERROR
        OR li-int < 0 THEN RUN htmlib-AddErrorMessage(
            'cos', 
            'The cost of sale is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    ASSIGN 
        li-int = int(lc-rev) NO-ERROR.
    IF ERROR-STATUS:ERROR
        OR li-int < 0 THEN RUN htmlib-AddErrorMessage(
            'rev', 
            'The revenue is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    ASSIGN 
        li-int = int(lc-reccos) NO-ERROR.
    IF ERROR-STATUS:ERROR
        OR li-int < 0 THEN RUN htmlib-AddErrorMessage(
            'rcos', 
            'The recurring cost of sale is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    ASSIGN 
        li-int = int(lc-recrev) NO-ERROR.
    IF ERROR-STATUS:ERROR
    OR li-int < 0 THEN RUN htmlib-AddErrorMessage(
            'rrev', 
            'The recurring revenue is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
                
    ASSIGN 
        li-int = int(lc-mkcontacttime) NO-ERROR.
    IF ERROR-STATUS:ERROR
        OR li-int < 0 THEN RUN htmlib-AddErrorMessage(
            'mkcontacttime', 
            'The contact time is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    ASSIGN 
        li-int = int(lc-mktimeonSite) NO-ERROR.
    IF ERROR-STATUS:ERROR
        OR li-int < 0 THEN RUN htmlib-AddErrorMessage(
            'mktimeonSite', 
            'The time on site is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    ASSIGN 
        li-int = int(lc-mkpageviews) NO-ERROR.
    IF ERROR-STATUS:ERROR
        OR li-int < 0 THEN RUN htmlib-AddErrorMessage(
            'mkpageviews', 
            'The page views is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
                 
            
                     
    IF lc-source = "crmview" AND lc-mode = "Add" AND lc-accountNumber = "ADD" THEN
    DO:
        
        IF lc-name = ""
            OR lc-name = ?
            THEN RUN htmlib-AddErrorMessage(
                'name', 
                'You must enter the name',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
            
        IF lc-accountref <> "" THEN
        DO:
            FIND FIRST b-customer 
                WHERE b-customer.companyCode = lc-global-company
                AND b-customer.accountref = lc-accountRef
                NO-LOCK NO-ERROR. 
            IF AVAILABLE b-customer THEN
            DO:
                IF lc-mode = "ADD"
                    OR b-table.AccountNumber <> b-customer.AccountNumber THEN
                DO:
                    RUN htmlib-AddErrorMessage(
                        'accountref', 
                        'This account reference already exists on account ' + b-customer.accountnumber + ' ' + b-customer.name,
                        INPUT-OUTPUT pc-error-field,
                        INPUT-OUTPUT pc-error-msg ).
                
                END.
            END.
              
        END.
        
        IF lc-SalesContact = "" 
            THEN RUN htmlib-AddErrorMessage(
                'salescontact', 
                'You must enter the sales contact name',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        IF lc-AddEmail = "" 
            THEN RUN htmlib-AddErrorMessage(
                'addemail', 
                'You must enter the sales contact email address',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        IF lc-AddMobile = "" 
            THEN RUN htmlib-AddErrorMessage(
                'addmobile', 
                'You must enter the sales contact mobile/telephone',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
                
            
        ASSIGN 
            li-int = int(lc-noemp) NO-ERROR.
        IF ERROR-STATUS:ERROR
            OR li-int < 0 THEN RUN htmlib-AddErrorMessage(
                'noemp', 
                'The number of employees is invalid',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
    
        ASSIGN 
            li-int = int(lc-turn) NO-ERROR.
        IF ERROR-STATUS:ERROR
            OR li-int < 0 THEN RUN htmlib-AddErrorMessage(
                'turn', 
                'The annual turnover is invalid',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
            
            
    END.

END PROCEDURE.

PROCEDURE outputHeader:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    output-content-type ("text/html":U).


END PROCEDURE.

PROCEDURE process-web-request:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/
    {lib/checkloggedin.i}
    
    ASSIGN 
        lc-mode          = get-value("mode")
        lc-rowid         = get-value("rowid")
        lc-enc-key       = get-value("crmaccount")
        lc-source        = get-value("source")
        lc-parent        = get-value("parent")
        lc-filterOptions = get-value("filteroptions")
        lc-submitSource  = get-value("submitsource")
        .
    IF lc-source = "crmview" AND lc-mode = "ADD" THEN
    DO:
        ASSIGN
            lc-AddMode = "SimpleContact".
            
        RUN crm/lib/getCustomerList.p ( lc-global-company, lc-global-user, OUTPUT lc-sela-Code, OUTPUT lc-sela-Name).
        RUN com-GetUserListByClass ( lc-global-company, "INTERNAL", REPLACE(lc-global-SalType-Code,'|',",") ,OUTPUT lc-sm-code, OUTPUT lc-sm-desc).
    
        RUN com-GenTabSelect ( lc-global-company, "CRM.IndustrySector", 
            OUTPUT lc-ind-code,
            OUTPUT lc-ind-desc ).
       
        IF lc-ind-code = ""
            THEN lc-ind-desc = "None".
        ELSE 
            ASSIGN lc-ind-code = "|" + lc-ind-code
                lc-ind-desc = "None|" + lc-ind-desc.
            
        ASSIGN
            lc-sm-code = "|" + lc-sm-code
            lc-sm-desc = "None Selected|" + lc-sm-desc
            .

        ASSIGN 
            lc-AccountNumber = "ADD".
        
        IF lc-submitsource = "ACCOUNT" AND request_method = "POST" THEN
        DO:
            ASSIGN 
                lc-accountnumber = get-value("account").
        
        END.
        
        IF lc-AccountNumber <> "ADD" THEN
            FIND Customer WHERE Customer.CompanyCode = lc-global-company
                AND Customer.AccountNumber = lc-accountNumber NO-LOCK NO-ERROR.
                        
        
    
    END.
    ELSE
    DO:
        ASSIGN
            lc-CRMAccount = DYNAMIC-FUNCTION("sysec-DecodeValue",lc-user,TODAY,"Customer",lc-enc-key).
        
        ASSIGN 
            lr-customer = TO-ROWID(lc-crmAccount).
        
        
        FIND Customer WHERE ROWID(Customer) = lr-customer NO-LOCK.
    END.
    
    
    

    IF AVAILABLE Customer THEN    
        RUN com-GetUserListForAccount (lc-global-company,customer.AccountNumber,OUTPUT lc-scont-code, OUTPUT lc-scont-desc).
    IF lc-scont-code = ""
        THEN ASSIGN lc-scont-code = lc-global-selcode
            lc-scont-desc = "None".
    
    ELSE 
        ASSIGN
            lc-scont-code = lc-global-selcode + "|" + lc-scont-code
            lc-scont-desc = "None|" + lc-scont-desc.
            
            
            
    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title        = 'Add'
                lc-link-label   = "Cancel addition"
                lc-submit-label = "Add Opportunity".
        WHEN 'view'
        THEN 
            ASSIGN 
                lc-title        = 'View'
                lc-link-label   = "Back"
                lc-submit-label = "".
        WHEN 'delete'
        THEN 
            ASSIGN 
                lc-title        = 'Delete'
                lc-link-label   = 'Cancel deletion'
                lc-submit-label = 'Delete Opportunity'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title        = 'Update'
                lc-link-label   = 'Back'
                lc-submit-label = 'Update Opportunity'.
    END CASE.
    
    
        
                 
    ASSIGN 
        lc-title = lc-title + ' Opportunity'.
        
    IF AVAILABLE Customer THEN
    DO:
        ASSIGN 
            lc-title = lc-title + " - Customer: " + Customer.Name.
        
        IF lc-mode = "ADD" AND  lc-submitsource = "ACCOUNT" AND request_method = "POST" THEN
        DO:
            ASSIGN 
                lc-op-salescontact = Customer.SalesContact.
          
        END.
        
        
    END.
    
    IF lc-source = "passthru" THEN
    DO:
        
        ASSIGN
            lc-link-url = appurl + '/crm/view.p?navigation=initial&reason=passthru'.
            
 
       
    END.
    ELSE
        IF lc-source = "crmview" THEN
        DO:
        
            ASSIGN
                lc-link-url = appurl + '/crm/view.p?navigation=refresh&' + 
            replace(REPLACE(lc-filterOptions,"|","&"),"^","=").
       
        END.
        ELSE
        DO:   
            ASSIGN 
                lc-link-url = appurl + '/crm/customer.p' + 
            '?crmaccount=' + url-encode(lc-enc-key,"Query") +
            '&navigation=refresh&mode=CRM' +
            "&source=" + lc-source + "&parent=" + lc-parent +
            '&time=' + string(TIME).
                                  
              
            ASSIGN
                lc-title = "Account: " + Customer.Name + " - " + lc-title.
        END.
        
    IF AVAILABLE Customer THEN
        ASSIGN 
            lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-user,TODAY,"customer",STRING(ROWID(customer))).                              
    IF request_method = "POST" AND  lc-submitSource <> "Account" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            IF lc-mode = 'update' THEN
            DO:
                FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                    NO-LOCK NO-ERROR.
                ASSIGN 
                    lr-val-rowid = ROWID(b-table).
            END.
            ELSE lr-val-rowid = ?.
            
            
            ASSIGN
                lc-opno            = get-value("opno")
                lc-descr           = get-value("descr")
                lc-op-salescontact = get-value("opsalescontact")
                lc-department      = get-value("department")
                lc-nextstep        = get-value("nextstep")
                lc-closedate       = get-value("closedate")
                lc-currentProv     = get-value("currentprov")
                lc-opType          = get-value("optype")
                lc-servReq         = get-value("servreq")
                lc-opnote          = get-value("opnote")
                lc-rating          = get-value("rating")
                lc-opstatus        = get-value("opstatus")
                lc-prob            = get-value("prob")
                lc-cos             = get-value("cos")
                lc-rev             = get-value("rev")
                lc-reccos          = get-value("rcos")
                lc-recrev          = get-value("rrev")
                lc-lost            = get-value("lost")
                lc-stype           = get-value("stype")
                lc-dbase           = get-value("dbase")
                lc-camp            = get-value("camp")
                lc-ops             = get-value("ops")
                lc-lostd           = get-value("lostd")
                
                lc-mkformType      = get-value("mkformType")
                lc-mkkeyword       = get-value("mkkeyword")
                lc-mkcontacttime   = get-value("mkcontacttime")
                lc-mkampm          = get-value("mkampm")
                lc-mktimeonsite    = get-value("mktimeonsite")
                lc-mkpageviews     = get-value("mkpageviews")
                lc-mklandingpage   = get-value("mklandingpage")
                lc-mkexitpage      = get-value("mkexitpage")
                lc-mklongestpage   = get-value("mklongestpage")
                
                .
            IF lc-source = "crmview" AND lc-mode = "Add" THEN
            DO:
                ASSIGN 
                    lc-accountnumber = get-value("account").
                ASSIGN
                    lc-name         = get-value("name")
                    lc-address1     = get-value("address1")
                    lc-address2     = get-value("address2")
                    lc-city         = get-value("city")
                    lc-county       = get-value("county")
                    lc-country      = get-value("country")
                    lc-postcode     = get-value("postcode")
                    lc-telephone    = get-value("telephone")
                    lc-contact      = get-value("contact")
                    lc-accStatus    = get-value("accstatus")
                    lc-accountref   = get-value("accountref")
                    lc-SalesManager = get-value("salesmanager")
                    lc-SalesContact = get-value("salescontact")
                    lc-website      = get-value("website")
                    lc-noemp        = get-value("noemp")
                    lc-turn         = get-value("turn")
                    lc-salesnote    = get-value("salesnote")
                    lc-indsector    = get-value("indsector")
                    lc-addEmail     = get-value("addemail")
                    lc-AddMobile    = get-value("addMobile").
            
                    
            END.
                        
            RUN ip-Validate( OUTPUT lc-error-field,
                OUTPUT lc-error-msg ).

            IF lc-error-msg = "" THEN
            DO:
                
                IF lc-mode = 'update' THEN
                DO:
                    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                        EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                    IF LOCKED b-table 
                        THEN  RUN htmlib-AddErrorMessage(
                            'none', 
                            'This record is locked by another user',
                            INPUT-OUTPUT lc-error-field,
                            INPUT-OUTPUT lc-error-msg ).
                END.
                ELSE
                DO:
                    IF lc-source = "crmview" AND lc-accountNumber = "ADD" THEN
                    DO:
                        RUN lib/autogenAccount.p ( lc-global-company, OUTPUT lc-accountNumber).
                        CREATE Customer.
                        ASSIGN 
                            Customer.CompanyCode    = lc-global-company
                            Customer.AccountNumber  = lc-AccountNumber
                            Customer.Name           = lc-name
                            Customer.Address1       = lc-address1
                            Customer.Address2       = lc-address2
                            Customer.City           = lc-city
                            Customer.County         = lc-county
                            Customer.Country        = "UK"
                            Customer.Postcode       = lc-Postcode
                            Customer.Telephone      = lc-Telephone
                            Customer.Contact        = lc-contact
                            Customer.accStatus      = lc-accStatus
                            customer.website        = lc-WebSite
                            customer.accountref     = lc-accountref
                            customer.SalesManager   = lc-SalesManager
                            customer.salesContact   = lc-SalesContact
                            customer.NoOfEmployees  = int(lc-noemp)
                            customer.AnnualTurnover = int(lc-turn)
                            customer.salesnote      = lc-salesnote
                            customer.industrySector = lc-indsector.
                        
                        ASSIGN
                            customer.isActive = customer.accStatus = "Active".
                            
                        ASSIGN
                            lc-SalesContact = TRIM(lc-salesContact).
                        lc-loginid = TRIM(REPLACE(lc-SalesContact," ",".")).
                        IF CAN-FIND(FIRST b-user WHERE b-user.loginid = lc-loginid NO-LOCK) THEN
                        REPEAT:
                            li-loop = li-loop + 1.
                            lc-next = lc-loginid + "_" + string(li-loop).
                            IF CAN-FIND(FIRST b-user WHERE b-user.loginid = lc-next NO-LOCK) THEN NEXT.
                            lc-loginid = lc-next.
                            LEAVE.
                        
                        END.
                        CREATE b-user.
                        ASSIGN 
                            customer.salesContact = lc-loginid
                            b-user.loginid        = lc-loginid
                            b-user.CompanyCode    = lc-global-company
                            b-user.UserClass      = "CUSTOMER"
                            b-user.engType        = "custSal".
                  
                        ASSIGN 
                            
                            b-user.surname       = lc-SalesContact
                            b-user.accountnumber = lc-accountnumber
                            b-user.name          = lc-SalesContact
                            b-user.Mobile        = lc-addmobile
                            b-user.Telephone     = lc-addMobile
                            b-user.email         = lc-addEmail
                            .
                            
                                          
                        ASSIGN
                            lc-op-salescontact = Customer.SalesContact.
                       
                            
                    END.
                     
                    IF lc-source = "crmview" THEN
                        FIND Customer WHERE Customer.CompanyCode = lc-global-company
                            AND Customer.AccountNumber = lc-accountNumber NO-LOCK NO-ERROR.
                                    
            
          
                    CREATE b-table.
                    ASSIGN 
                        b-table.accountnumber = Customer.AccountNumber
                        b-table.CompanyCode   = lc-global-company
                        b-table.op_id         = NEXT-VALUE(op_master)
                        b-table.createDate    = NOW
                        b-table.createLoginid = lc-global-user
                        lc-firstrow           = STRING(ROWID(b-table)).
                   
                END.
                
                IF b-table.op_no = 0 THEN
                DO:
                    FIND LAST b-valid 
                        WHERE b-valid.CompanyCode = lc-global-company
                        AND b-valid.op_no > 0 NO-LOCK NO-ERROR.
                    ASSIGN 
                        b-table.op_no = IF AVAILABLE b-valid THEN b-valid.op_no + 1 ELSE 1.        
                END.
                
                EMPTY TEMP-TABLE tt-old-table.
                CREATE tt-old-table.
                BUFFER-COPY b-table TO tt-old-table.
               
                
                ASSIGN
                    b-table.descr           = lc-descr
                    b-table.salesContact    = lc-op-salescontact
                    b-table.Department      = lc-department
                    b-table.NextStep        = lc-nextstep
                    b-table.closeDate       = IF lc-closedate = "" THEN ? ELSE DATE(lc-closedate)
                    b-table.CurrentProvider = lc-currentProv
                    b-table.optype          = lc-optype
                    b-table.servRequired    = lc-servreq
                    b-table.opnote          = lc-opnote
                    b-table.Rating          = lc-rating
                    b-table.OpStatus        = lc-opstatus
                    b-table.Probability     = INTEGER(lc-prob)
                    b-table.CostOfSale      = INTEGER(lc-cos)
                    b-table.Revenue         = INTEGER(lc-rev)
                    b-table.RecCostOfSale    = INTEGER(lc-reccos)
                    b-table.RecRevenue       = INTEGER(lc-recrev)
                    b-table.DealLostReason  = lc-lost
                    b-table.SourceType      = lc-stype
                    b-table.dbase           = lc-dbase
                    b-table.Campaign        = lc-camp
                    b-table.opSource        = lc-ops
                    b-table.lostdescription = lc-lostd
                    
                    b-table.mk_formtype     = lc-mkformtype
                    b-table.mk_keyword      = lc-mkkeyword
                    b-table.mk_contactTime  = INTEGER(lc-mkcontactTime)
                    b-table.mk_ampm         = lc-mkampm
                    b-table.mk_TimeOnSite   = INTEGER(lc-mkTimeOnSite)
                    b-table.mk_PageViews    = INTEGER(lc-mkPageViews)
                    b-table.mk_landingPage  = lc-mkLandingPage  
                    b-table.mk_exitPage     = lc-mkexitPage  
                    b-table.mk_longestPage  = lc-mkLongestPage  

                    
                    .
                    
                IF b-table.salesContact = lc-global-selcode
                    THEN b-table.salesContact = "".
            
                
                RUN crm/lib/final-op.p ( ROWID(b-table)).
                ASSIGN
                    lc-data = "".
                    
                RUN crm/lib/process-event.p (
                    ROWID(b-table),
                    lc-global-user,
                    lc-mode,
                    lc-data,
                    INPUT TABLE tt-old-table
                    ).
                        
                 
                    
               
          
                
            END.
                
        END.
        ELSE
        DO:
            FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF LOCKED b-table 
                THEN  RUN htmlib-AddErrorMessage(
                    'none', 
                    'This record is locked by another user',
                    INPUT-OUTPUT lc-error-field,
                    INPUT-OUTPUT lc-error-msg ).
            ELSE 
            DO:
                FOR EACH op_Activity OF b-table EXCLUSIVE-LOCK:
                    DELETE op_Activity.
                END.
                FOR EACH op_Action OF b-table EXCLUSIVE-LOCK:
                    DELETE op_action.
                END.
                
                DELETE b-table.
            END.
            
        END.
        IF lc-source = "crmview" AND lc-error-Field = "" THEN
        DO:
           
            
            lc-Options =  REPLACE(REPLACE(lc-filterOptions,"|","&"),"^","=").
            DO li-loop = 1 TO NUM-ENTRIES(lc-options,"&"):
                lc-part = ENTRY(li-loop,lc-options,"&").
                set-user-field(ENTRY(1,lc-part,"="),ENTRY(2,lc-part,"=")).
                
            END.
            set-user-field("navigation",'refresh').
            request_method = "GET".
            RUN run-web-object IN web-utilities-hdl ("crm/view.p").
            RETURN.
            
        END.
        ELSE
            IF lc-source = "passthru" AND lc-error-Field = "" THEN
            DO:
           
                set-user-field("navigation",'initial').
                request_method = "GET".
                RUN run-web-object IN web-utilities-hdl ("crm/view.p").
                RETURN.
            
            END.
        
            ELSE
                IF lc-error-field = "" THEN
                DO:
                    /*RUN outputHeader.*/
                    set-user-field("navigation",'refresh').
                    set-user-field("firstrow",lc-firstrow).
                    set-user-field("search",lc-search).
                    set-user-field("mode","CRM").
                    set-user-field("crmaccount" , get-value("crmaccount")).
                    set-user-field("source",lc-source).
                    set-user-field("parent",lc-parent).
                    request_method = "GET".
                    RUN run-web-object IN web-utilities-hdl ("crm/customer.p").
                    RETURN.
                END.
        
    END.
    
    IF lc-mode <> 'add' AND request_method = "GET" THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        
        ASSIGN
            lc-opno            = STRING(b-table.op_no)
            lc-descr           = b-table.descr
            lc-op-salescontact = b-table.Salescontact
            lc-department      = b-table.department
            lc-nextstep        = b-table.nextstep
            lc-CloseDate       = IF b-table.CloseDate = ? THEN "" ELSE STRING(b-table.CloseDate,"99/99/9999")
            lc-currentProv     = b-table.CurrentProvider
            lc-optype          = b-table.optype
            lc-servreq         = b-table.servRequired
            lc-opnote          = b-table.opnote
            lc-rating          = b-table.rating
            lc-opstatus        = b-table.OpStatus
            lc-prob            = STRING(b-table.Probability)
            lc-cos             = STRING(b-table.CostOfSale)
            lc-rev             = STRING(b-table.Revenue)
            lc-reccos          = STRING(b-table.RecCostOfSale)
            lc-recrev          = STRING(b-table.RecRevenue)
            lc-lost            = b-table.DealLostReason
            lc-stype           = b-table.SourceType
            lc-dbase           = b-table.dBase
            lc-camp            = b-table.Campaign
            lc-ops             = b-table.opSource
            lc-lostd           = b-table.lostdescription
            
            lc-mkformType      = b-table.mk_formType
            lc-mkkeyword       = b-table.mk_keyword
            lc-mkcontactTime   = STRING(b-table.mk_contactTime,"9999")
            lc-mkampm          = b-table.mk_ampm
            lc-mkTimeonSite    = STRING(b-table.mk_TimeOnSite)
            lc-mkPageViews     = STRING(b-table.mk_PageViews)
            lc-mkLandingPage   = b-table.mk_LandingPage
            lc-mkExitPage      = b-table.mk_exitPage
            lc-mkLongestPage   = b-table.mk_LongestPage

                        
            .
            
       
    END.  
                                        
    RUN outputHeader.
    
    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) SKIP.
    
    IF lc-mode = "UPDATE" 
        THEN RUN ip-ExportJS.
    
    ELSE 
        IF lc-mode = "ADD" THEN
            RUN ip-ExportJS-Add.
    
    
    {&out} htmlib-Header("Opportunity CRM") SKIP.
 
   
    
    {&out} htmlib-StartForm("mainform","post", appurl + '/crm/crmop.p' ) SKIP
        htmlib-ProgramTitle(lc-title) SKIP.
    
     
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' SKIP.


    IF lc-mode = "DELETE" 
        OR lc-mode = "VIEW" THEN
    DO:
        RUN ip-ViewPage.
    END.
    ELSE
        IF lc-mode = "ADD" THEN
        DO:
            {&out} 
                '<br />' htmlib-StartTable("mnt",
                100,
                0,
                0,
                0,
                "center").
                        
            {&out} 
                '<tr><TD VALIGN="TOP" ALIGN="left">' SKIP.
                            
            RUN ip-UpdatePage.
            {&out} 
                '</td><TD VALIGN="TOP" ALIGN="left">' SKIP.
            RUN ip-MarketingPage.
                
            {&out} 
                '</tr>' SKIP.
                   
            {&out} htmlib-EndTable() SKIP.
                
            
            {&out} htmlib-CalendarScript("closedate") SKIP.
        END.
        ELSE 
            IF lc-mode = "UPDATE" THEN
            DO:
                {&out}
                    '<div class="tabber">' SKIP.
         
                {&out} 
                    '<div class="tabbertab" title="Opportunity">' SKIP.
                {&out} 
                    '<br />' htmlib-StartTable("mnt",
                    100,
                    0,
                    0,
                    0,
                    "center").
        
                {&out} 
                    '<tr><TD VALIGN="TOP" ALIGN="left">' SKIP.
                
                RUN ip-UpdatePage.
                
                {&out} 
                    '</td><TD VALIGN="TOP" ALIGN="left"><div class="infobox" style="font-size:10px;">Status Changes</div>' SKIP.
                RUN ip-StatusTable.
                RUN ip-MarketingPage.
                
                {&out} 
                    '</tr>' SKIP.
                   
                {&out} htmlib-EndTable() SKIP.
         
                {&out} htmlib-CalendarScript("closedate") SKIP.
                
                
        
                IF lc-error-msg <> "" THEN
                DO:
                    {&out} 
                        '<BR><BR><CENTER>' 
                        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' SKIP.
                END.

                IF lc-submit-label <> "" THEN
                DO:
                    {&out} 
                        '<br><center>' htmlib-SubmitButton("submitform",lc-submit-label) 
                        '</center>' SKIP.
                END.
    
                {&out} 
                    '</div>' SKIP.
        
        
        
                {&out} 
                    '<div class="tabbertab" title="Action & Activities">' SKIP.
            
                RUN ip-ActionPage.
                {&out} 
                    '</div>' SKIP.
        
                {&out} 
                    '<div class="tabbertab" title="Notes">' SKIP.
                RUN ip-NotePage.
                {&out} 
                    '</div>'.
    
                {&out} 
                    '<div class="tabbertab" title="Attachments">' SKIP.
                RUN ip-Documents.
                {&out} 
                    '</div>' SKIP.
        
        
                {&out} 
                    '<div class="tabbertab" title="Customer Details">' SKIP.
                {&out}
                    '<div id="IDCustomerAjax">Loading Notes</div>'.
    
                {&out} 
                    '</div>' SKIP.
        
         
                {&out} 
                    '</div>' SKIP.
            END.
    
    {&out} htmlib-Hidden ("mode", lc-mode) SKIP
        htmlib-Hidden ("rowid", lc-rowid) SKIP
        htmlib-Hidden ("savesearch", lc-search) SKIP
        htmlib-hidden ("crmaccount", get-value("crmaccount"))
        htmlib-Hidden ("savefirstrow", lc-firstrow) SKIP
        htmlib-Hidden ("savelastrow", lc-lastrow) SKIP
        htmlib-Hidden ("savenavigation", lc-navigation) SKIP
        htmlib-hidden("source",lc-source) SKIP
        htmlib-hidden("parent",lc-parent) SKIP
        htmlib-hidden("submitsource","") SKIP
        htmlib-hidden("filteroptions", lc-filteroptions)
        .
       
       
    {&out} 
        '<div id="placeholder" style="display: none;"></div>' SKIP.
       
    IF lc-mode <> "UPDATE" THEN
    DO:      
        IF lc-error-msg <> "" THEN
        DO:
            {&out} 
                '<BR><BR><CENTER>' 
                htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' SKIP.
        END.

        IF lc-submit-label <> "" THEN
        DO:
            {&out} 
                '<br><center>' htmlib-SubmitButton("submitform",lc-submit-label) 
                '</center>' SKIP.
        END.
    
    END.
    


    {&out} htmlib-EndForm() SKIP
        htmlib-Footer() SKIP.
    
              
END PROCEDURE.
