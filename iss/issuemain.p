/***********************************************************************

    Program:        iss/issuemain.p
    
    Purpose:        Issue Maintenance
    
    Notes:
    
    
    When        Who         What
    06/04/2006  phoski      SearchField populate
    06/06/2006  phoski      Category
    
    30/08/2010  DJS         3704 Amended to include new gmap & rdp buttons
    27/09/2014  phoski      Encrpyted link to custequip
    24/01/2015  phoski      Dont allow close of issue if open actions
    17/02/2015  phoski      Contract default problem
    21/02/2015  phoski      Billing flag problem and finally remove all DJS 
    29/03/2015  phoski      Complex Project Class 
    08/04/2015  phoski      Complex Project - Main work begins
    29/04/2015  phoski      Complex Project - Main info page
    14/11/2015  phoski      No adhoc issues, must be against a contract

***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

&GlOBAL-DEFINE object-class INTERNAL-ONLY

DEFINE BUFFER b-table   FOR issue.
DEFINE BUFFER b-cust    FOR Customer.
 
DEFINE BUFFER b-issue   FOR issue.
DEFINE BUFFER b-IStatus FOR IssStatus.
DEFINE BUFFER b-user    FOR WebUser.
DEFINE BUFFER b-status  FOR WebStatus.

DEFINE VARIABLE lc-error-field       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode              AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-search            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-area              AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-account           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-status            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-assign            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-label        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-icustname         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AreaCode          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-briefdescription  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-longdescription   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-currentstatus     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-currentassign     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-prj-eng           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-prj-start         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-statnote          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-planned           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-catcode           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ticket            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-category          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accountmanager    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sla-rows          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sla-selected      AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-OpenActions       AS INTEGER   NO-UNDO.
DEFINE VARIABLE ll-IsOpen            AS LOG       NO-UNDO.
DEFINE VARIABLE lc-list-area         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-aname        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-status       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-sname        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assign       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assname      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-proj-assign  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-proj-assname AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-catcode      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-cname        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-iclass            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pdf               AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitsource      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-otherp       AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-superuser         AS LOG       NO-UNDO.
DEFINE VARIABLE lc-name              AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Doc-TBAR          AS CHARACTER 
    INITIAL "doctb" NO-UNDO.
DEFINE VARIABLE lc-Action-TBAR       AS CHARACTER
    INITIAL "acttb" NO-UNDO.

/* Contract stuff  */

DEFINE VARIABLE lc-list-ctype        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-cdesc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-contract-type     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ContractCode      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-billable-flag     AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-isBillable        AS LOG       NO-UNDO.
DEFINE VARIABLE lc-ContractAccount   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Enc-Key           AS CHARACTER NO-UNDO.

DEFINE VARIABLE ll-customer          AS LOG       NO-UNDO.
DEFINE BUFFER this-user FOR WebUser.



/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fn-DescribeSLA) = 0 &THEN

FUNCTION fn-DescribeSLA RETURNS CHARACTER
    ( pr-rowid AS ROWID )  FORWARD.


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
{iss/issue.i}
{lib/ticket.i}
{lib/project.i}




 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-ActionPage) = 0 &THEN

PROCEDURE ip-ActionPage :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    {&out}
           skip
           tbar-BeginID(lc-Action-TBAR,"") SKIP.
    IF b-table.iClass <> lc-global-iclass-complex  THEN
    DO:      
        {&out} 
           tbar-Link("add",?,
                     'javascript:PopUpWindow('
                          + '~'' + appurl 
                     + '/iss/actionupdate.p?mode=add&issuerowid=' + string(ROWID(b-table))
                          + '~'' 
                          + ');'
                          ,"")
                      SKIP.
    END.
    {&out}
            tbar-BeginOptionID(lc-Action-TBAR) skip.

    IF ll-SuperUser
        THEN {&out} tbar-Link("delete",?,"off","").

    {&out}  
        tbar-Link("update",?,"off","")
        tbar-Link("multiiss",?,"off","")
        tbar-EndOption()
        tbar-End().

    {&out}
    '<div id="IDAction"></div>'.
    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-AreaCode) = 0 &THEN

PROCEDURE ip-AreaCode :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    {&out}  skip
            '<select name="areacode" class="inputfield">' skip.
    {&out}
    '<option value="' DYNAMIC-FUNCTION("htmlib-Null") '" ' 
    IF lc-AreaCode = dynamic-function("htmlib-Null") 
        THEN "selected" 
    ELSE "" '>Select Area</option>' skip
            '<option value="" ' if lc-AreaCode = ""
                then "selected" else "" '>Not Applicable/Unknown</option>' skip        
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
        IF lc-AreaCode = webIssArea.AreaCode  
            THEN "selected" 
        ELSE "" '>' html-encode(webIssArea.Description) '</option>' skip.

        IF LAST-OF(WebIssArea.GroupID) THEN {&out} '</optgroup>' skip.
    END.

    {&out} '</select>'.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-BackToIssue) = 0 &THEN

PROCEDURE ip-BackToIssue :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-link-url AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-Enc-Key  AS CHARACTER NO-UNDO.
    

    RUN outputHeader.
    {&out} htmlib-Header(lc-title) skip.
   
    ASSIGN 
        request_method = "get".

    ASSIGN 
        lc-link-url = '"' + 
                         appurl + '/iss/issue.p' + 
                        '?search=' + lc-search + 
                        '&firstrow=' + lc-firstrow + 
                        '&lastrow=' + lc-lastrow + 
                        '&navigation=refresh' +
                        '&time=' + string(TIME) + 
                        '&account=' + lc-account + 
                        '&status=' + lc-status +
                        '&assign=' + lc-assign + 
                        '&area=' + lc-area + 
                        '&category=' + lc-category +
                        '&iclass=' + lc-iclass +
                        '&accountmanager=' + lc-AccountManager +
                        '"'.
    
    IF lc-submitsource = "print" THEN
        {&out} '<script language="javascript">' skip
           'function PrintWindow(HelpPageURL) ~{' skip
           '    PrintWinHdl = window.open(HelpPageURL,"PrintWindow","width=600,height=400,scrollbars=yes,resizable")' skip
               '    PrintWinHdl.focus()' skip
           '~}' skip
           '</script>' skip.

    {&out} '<script language="javascript">' skip.

           
    IF lc-submitsource = "print" 
        THEN {&out} 
    'PrintWindow("' appurl '/iss/issueview.p?autoprint=yes&rowid=' STRING(ROWID(b-table)) '")' skip.


    IF get-value("fromcview") = "yes" THEN
    DO:
        FIND customer 
            WHERE customer.CompanyCode = b-table.CompanyCode
            AND customer.AccountNumber = b-table.AccountNumber 
            NO-LOCK NO-ERROR.
         
        ASSIGN 
            lc-enc-key =
             DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(customer))).
        
        ASSIGN
            lc-link-url = appurl + "/cust/custview.p?mode=view&source=menu&rowid=" + 
           url-encode(lc-enc-key,"Query").

        lc-link-url = '"' + lc-link-url + '"'.
        
    END.
    
    
    {&out} 'myParent = self.parent' skip
           'NewURL = ' lc-link-url  skip
           'myParent.location = NewURL' skip
            '</script>' skip.

    {&OUT} htmlib-Footer() skip.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ContractSelect) = 0 &THEN

PROCEDURE ip-ContractSelect :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-char AS CHARACTER NO-UNDO.

    {&out}  skip
            '<select id="selectcontract" name="selectcontract" class="inputfield"  onchange=~"javascript:ChangeContract();~">' skip.
    /*
    {&out}
        '<option value="ADHOC|yes" >Ad Hoc (Billable)</option>' skip.
    */

    
    
    IF lc-ContractAccount <> ""  THEN
    DO:

        IF CAN-FIND (FIRST WebIssCont                           
            WHERE WebIssCont.CompanyCode     = lc-global-company     
            AND WebIssCont.Customer        = lc-ContractAccount     
            AND WebIssCont.ConActive       = TRUE ) 
            THEN
        DO:
            FOR EACH WebIssCont NO-LOCK                             
                WHERE WebIssCont.CompanyCode     = lc-global-company     
                AND WebIssCont.Customer        = lc-ContractAccount     
                AND WebIssCont.ConActive       = TRUE
                :                                        

                FIND FIRST ContractType  WHERE ContractType.CompanyCode = WebIssCont.CompanyCode
                    AND  ContractType.ContractNumber = WebissCont.ContractCode 
                    NO-LOCK NO-ERROR. 

                IF WebIssCont.DefCon AND lc-contract-type = ""
                    THEN ASSIGN lc-contract-type = WebIssCont.ContractCode.
                  

                {&out}
                '<option value="' WebIssCont.ContractCode "|" STRING(WebissCont.Billable) '" ' .

                IF  ENTRY(1,lc-contract-type,"|") = WebIssCont.ContractCode THEN
                DO:   
                    {&out}      " selected " .
                END.

                {&out}  '>'  html-encode(IF AVAILABLE ContractType THEN ContractType.Description + (
                    IF WebissCont.Billable THEN " (Billable)" ELSE "") ELSE "Unknown") 
                   


                '</option>' skip.
            END.
        END.
    END.
    {&out} '</select>'.




END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Documents) = 0 &THEN

PROCEDURE ip-Documents :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    {&out}
           skip
           tbar-BeginID(lc-Doc-TBAR,"")
           tbar-Link("add",?,'javascript:documentAdd();',"") skip
            tbar-BeginOptionID(lc-Doc-TBAR) skip
            tbar-Link("delete",?,"off","")
            tbar-Link("customerview",?,"off","")
            tbar-Link("documentview",?,"off","")
            tbar-EndOption()
            
           tbar-End().

    {&out}
    '<div id="IDDocument"></div>'.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-HeaderInclude-Calendar) = 0 &THEN

PROCEDURE ip-GanttPage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    
    {&out} 
    '<div id="gantt_here" style="width:100%; height:1800px"></div>' SKIP.

  
END PROCEDURE.

PROCEDURE ip-HeaderInclude-Calendar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-IssueMain) = 0 &THEN

PROCEDURE ip-IssueMain :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER b-cust  FOR customer.
    DEFINE BUFFER b-user  FOR WebUser.
    DEFINE BUFFER WebAttr FOR WebAttr.

    DEFINE VARIABLE lc-SLA-Describe AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-icustname    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-raised       AS CHARACTER NO-UNDO.


    FIND b-cust WHERE b-cust.CompanyCode = b-table.CompanyCode
        AND b-cust.AccountNumber = b-table.AccountNumber
        NO-LOCK NO-ERROR.

    IF AVAILABLE b-cust
        THEN ASSIGN lc-icustname = b-cust.AccountNumber + 
                               ' ' + b-cust.Name.
    ELSE ASSIGN lc-icustname = 'N/A'.

    ASSIGN 
        lc-SLA-Describe = DYNAMIC-FUNCTION("fn-DescribeSLA",ROWID(b-table)).

    FIND b-user WHERE b-user.LoginId = b-table.RaisedLogin 
        NO-LOCK NO-ERROR.
    ASSIGN 
        lc-raised = IF AVAILABLE b-user THEN b-user.name ELSE "".
    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Customer")
    '</TD>' skip
           htmlib-TableField(html-encode(lc-icustname),'left') skip
           '<TR><TD VALIGN="TOP" ALIGN="right">' 
           htmlib-SideLabel("Date")
           '</TD>' skip
           htmlib-TableField(
               ( if b-table.IssueDate = ? then "" else string(b-table.IssueDate,'99/99/9999')) + 
               " " + string(b-table.IssueTime,"hh:mm am")
                   ,'left') skip
           '</tr>'
           '<TR><TD VALIGN="TOP" ALIGN="right">' 
           htmlib-SideLabel("SLA")
           '</TD>' skip
           htmlib-TableField(
                    replace(if lc-sla-describe = "" then "&nbsp" else lc-sla-describe,
                        "~n","<br>")
                   ,'left') skip
           '</tr>'.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Contract")
    '</TD><td>' skip .

    RUN ip-ContractSelect.

    {&out} '</TD></tr> ' skip.  


    {&out} '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("Billable?")
    '</td><td valign="top" align="left">'
    REPLACE(htmlib-CheckBox("billcheck", IF ll-isBillable THEN TRUE ELSE FALSE),
        '>',' onClick="ChangeBilling(this);">')
    '</td></tr>' skip.


    {&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Raised By")
    '</TD>' skip
           htmlib-TableField(html-encode(lc-raised),'left') skip
          '</tr>'

    .

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("briefdescription",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Brief Description")
        ELSE htmlib-SideLabel("Brief Description"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("briefdescription",60,lc-briefdescription) 
    '</TD>' skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("longdescription",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Details")
        ELSE htmlib-SideLabel("Details"))
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-TextArea("longdescription",lc-longdescription,5,60)
          '</TD>' skip
           skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("areacode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Area")
        ELSE htmlib-SideLabel("Area"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">' skip.

    RUN ip-AreaCode.         
    {&out}        '</TD></TR>' skip. 

    {&out} '<TR><TD VALIGN="BOTTOM" ALIGN="right">' 
        (IF LOOKUP("currentstatus",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Status")
        ELSE htmlib-SideLabel("Status"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left"><div id="actionbox1">'.
    IF li-OpenActions <> 0  THEN
    DO:
        {&out} '<div class="infobox" style="font-size: 10px;">This issue has open actions ('
        li-openActions 
        ') and can not be closed.</div>'
            SKIP.
    END.
    ELSE
        IF ll-IsOpen THEN
        DO:
            FIND WebAttr WHERE WebAttr.SystemID = "SYSTEM"
                AND   WebAttr.AttrID   = "ISSCLOSEWARNING" NO-LOCK NO-ERROR.
             
            IF AVAILABLE webattr THEN
            DO:
                {&out} '<div class="infobox" style="font-size: 10px;">' REPLACE(webattr.attrValue,'~n','<br/>')
                '</div>'
                SKIP.
            END.
        END.
     
    
    {&out} htmlib-Select("currentstatus",lc-list-status,lc-list-sname,
        lc-currentstatus)
    '</div></TD></TR>' skip. 

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("statnote",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("New Status Note")
        ELSE htmlib-SideLabel("New Status Note"))
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-TextArea("statnote",lc-statnote,3,60)
          '</TD>' skip
           skip.

    IF lc-list-catcode <> "" THEN
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("catcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Category")
        ELSE htmlib-SideLabel("Category"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("catcode",lc-list-catcode,lc-list-cname,
        lc-catcode)
    '</TD></TR>' skip. 
    /*
    ***
    *** Complex Project 
    ***
    */
    IF b-table.iClass = lc-global-iclass-complex THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("iclass",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Class")
            ELSE htmlib-SideLabel("Class"))
        '<TD VALIGN="TOP" ALIGN="left">'
                        
        htmlib-hidden("iclass",lc-global-iclass-complex)
        htmlib-BeginCriteria("Complex Project")
        htmlib-StartMntTable().
    
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("prj-start",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Project Start")
            ELSE htmlib-SideLabel("Project Start"))
        '</TD>'
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("prj-start",10,lc-prj-start) 
        htmlib-CalendarLink("prj-start")
        '</TD>' SKIP
            '</TR>' skip.
    
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("currentassign",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Senior Engineer")
            ELSE htmlib-SideLabel("Senior Engineer"))
        '</TD>' 
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-Select("currentassign",lc-list-proj-assign,lc-list-proj-assname,
            lc-currentassign)
        '</TD></TR>' SKIP
            '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("prj-eng",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Project Engineer")
            ELSE htmlib-SideLabel("Project Engineer"))
            '</TD>' 
                '<TD VALIGN="TOP" ALIGN="left">'
                htmlib-Select("prj-eng",lc-list-proj-assign,lc-list-proj-assname,
                lc-prj-eng)
            '</TD></TR>' SKIP.
            
        {&out} skip 
            htmlib-EndTable()
            htmlib-EndCriteria() skip.
             
            
        {&out} '</TD></TR>' skip. /* End row of standard */
               
 
    END.
    /*
    ***
    *** all other issue classes
    ***
    */
    ELSE
    DO:
            
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("iclass",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Class")
            ELSE htmlib-SideLabel("Class"))
        '</TD>' 
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-Select("iclass",lc-global-iclass-add-code,lc-global-iclass-add-desc,
            lc-iclass)
        '</TD></TR>' skip. 
    END.
    
    IF lc-sla-rows <> "" THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("sla",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("SLA")
            ELSE htmlib-SideLabel("SLA"))
        '</TD>'
        '<TD VALIGN="TOP" ALIGN="left">' skip.
        RUN ip-SLATable.
        {&out}
        '</TD>' skip.
        {&out} '</TR>' skip.

    END.
        
    IF b-table.iClass <> lc-global-iclass-complex THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("currentassign",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Assigned To")
            ELSE htmlib-SideLabel("Assigned To"))
        '</TD>' 
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-Select("currentassign",lc-list-assign,lc-list-assname,
            lc-currentassign)
        '</TD></TR>' skip. 
    END.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("planned",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Planned Completion")
        ELSE htmlib-SideLabel("Planned Completion"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("planned",10,lc-planned) 
    htmlib-CalendarLink("planned")
    '</TD>' skip.
    {&out} '</TR>' skip.

    

    IF com-AskTicket(lc-global-company,b-cust.AccountNumber) THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("ticket",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Ticketed Issue?")
            ELSE htmlib-SideLabel("Ticketed Issue?"))
        '</TD>'
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-CheckBox("ticket", IF lc-ticket = 'on'
            THEN TRUE ELSE FALSE) 
        '</TD></TR>' skip.
    END.

    {&out} htmlib-EndTable() skip.

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    {&out} '<center>' htmlib-SubmitButton("submitform","Update Issue") 
    '&nbsp;'
    '<input class="submitbutton" type=button name=print value="Update & Print" onclick="SubmitThePage(~'print~')">'
    '</center>' skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-IssueStatusHistory) = 0 &THEN

PROCEDURE ip-IssueStatusHistory :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pr-rowid        AS ROWID        NO-UNDO.

    DEFINE VARIABLE lc-name   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-status AS CHARACTER NO-UNDO.



    FIND b-issue WHERE ROWID(b-issue) = pr-rowid NO-LOCK NO-ERROR.

    IF AVAILABLE b-issue THEN
    DO:
        {&out}
        REPLACE(htmlib-StartMntTable(),'width="100%"','width="95%" align="center"')
        htmlib-tableHeading(
            "Date^right|Time^right|Status|By"
            ) skip.

        FOR EACH b-IStatus NO-LOCK
            WHERE b-IStatus.CompanyCode = b-issue.CompanyCode
            AND b-IStatus.IssueNumber = b-issue.IssueNumber:

            FIND b-status WHERE b-status.CompanyCode = b-issue.CompanyCode
                AND b-status.StatusCode = b-IStatus.NewStatusCode NO-LOCK NO-ERROR.
            
            ASSIGN 
                lc-status = IF AVAILABLE b-status THEN b-status.description ELSE "".

            FIND b-user WHERE b-user.LoginID = b-IStatus.LoginID NO-LOCK NO-ERROR.
            ASSIGN 
                lc-name = IF AVAILABLE b-user THEN b-user.name ELSE "".

            {&out} 
            htmlib-trmouse()
            htmlib-tableField(STRING(b-IStatus.ChangeDate,'99/99/9999'),'right')
            htmlib-tableField(STRING(b-IStatus.ChangeTime,'hh:mm am'),'right')
            htmlib-tableField(html-encode(lc-status),'left')
            htmlib-tableField(html-encode(lc-name),'left')
            '</tr>' skip.
        END.
        {&out} skip 
           htmlib-EndTable()
           skip.


    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-NotePage) = 0 &THEN

PROCEDURE ip-Javascript:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    {&out}  
    '<script>'
    'var NoteAjax = "' appurl '/iss/ajax/note.p?rowid=' STRING(ROWID(b-table)) '"' skip
           'var CustomerAjax = "' appurl '/cust/custequiplist.p?expand=yes&ajaxsubwindow=yes&customer=' url-encode(lc-enc-key,"Query")  '"' skip
           'var DocumentAjax = "' appurl '/iss/ajax/document.p?rowid=' string(rowid(b-table)) 
                    '&toolbarid=' lc-Doc-TBAR 
                    '"' skip
           'var ActionAjax = "' appurl '/iss/ajax/action.p?allowdelete=' if ll-SuperUser then "yes" else "no" '&rowid=' string(rowid(b-table)) 
                    '&toolbarid=' lc-Action-TBAR 
                    '"' skip
           'var NoteAddURL = "' appurl '/iss/addnote.p?rowid=' + lc-rowid '"' skip
           'var DocumentAddURL = "' appurl '/iss/adddocument.p?rowid=' + lc-rowid '"' SKIP
           'var ActionBox1URL = "' appurl '/iss/ajax/actionbox.p?box=1&rowid=' + lc-rowid '"' SKIP
           'var ActionBox2URL = "' appurl '/iss/ajax/actionbox.p?box=2&rowid=' + lc-rowid '"' skip
           'var IssueROWID = "' string(rowid(b-table)) '"' SKIP
           'var ganttURL = "' appurl '/iss/ajax/ganttupd.p?mode=build&rowid=' + lc-rowid '"' SKIP
           'var ganttupdURL = "' appurl '/iss/ajax/ganttupd.p?rowid=' + lc-rowid '"' SKIP
           
       '</script>' skip.



    {&out} 
    '<script type="text/javascript" src="/scripts/js/issue/custom.js?v=1.0.0"></script>' skip
        '<script language="JavaScript" src="/scripts/js/tree.js?v=1.0.0"></script>' skip
        '<script language="JavaScript" src="/scripts/js/prototype.js?v=1.0.0"></script>' skip
        '<script language="JavaScript" src="/scripts/js/scriptaculous.js?v=1.0.0"></script>' SKIP
        lc-global-jquery skip
        '<script type="text/javascript" src="/scripts/js/tabber.js?v=1.0.0"></script>' skip
        '<link rel="stylesheet" href="/style/tab.css" TYPE="text/css" MEDIA="screen">' skip
        '<script language="JavaScript" src="/scripts/js/standard.js?v=1.0.0"></script>' SKIP
        '<script src="/asset/gantt/codebase/dhtmlxgantt.js" type="text/javascript" charset="utf-8"></script>' SKIP
        '<link rel="stylesheet" href="/asset/gantt/codebase/dhtmlxgantt.css" type="text/css" media="screen" title="no title" charset="utf-8">' SKIP
         DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.

    
    {&out} tbar-JavaScript(lc-Doc-TBAR) skip.
    {&out} tbar-JavaScript(lc-Action-TBAR) skip.


    /* 3678 ----------------------> */ 
    {&out}  '<script type="text/javascript" >~n'
    'var pIP =  window.location.host; ~n'
    'function goGMAP(pCODE, pNAME, pADD) ~{~n'
    'var pOPEN = "http://www.google.co.uk/maps/preview?q=";' SKIP
            'pOPEN = pOPEN + pCODE;~n' SKIP
            'window.open(pOPEN, ~'WinName~' , ~'width=645,height=720,left=0,top=0~');~n'
            ' ~}~n'
            '</script>'  skip.
    /* ----------------------- 3678 */ 

    /* 3677 ----------------------> */ 
    {&out}  '<script type="text/javascript" >~n'
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
    '</script>'  skip.
    /* ------------------------ 3677 */ 
    {&out} 
    '<script>' skip
        'function ConfirmDeleteAttachment(ObjectID,DocID) ~{' skip
        '   var DocumentAjax = "' appurl '/iss/ajax/deldocument.p?docid=" + DocID' skip
        '   if (confirm("Are you sure you want to delete this document?")) ~{' skip
        "       ObjectID.style.display = 'none';" skip
        "       ahah(DocumentAjax,'placeholder');" skip
        '       var objtoolBarOption = document.getElementById("doctbtboption");' skip
        '       objtoolBarOption.innerHTML = doctbobjRowDefault;' skip
        '   ~}' skip
        '~}' skip
        '</script>' skip.

    {&out} 
    '<script>' skip
        'function CustomerView(ObjectID,DocID) ~{' skip
        'var NewDocumentAjax = "' appurl '/iss/ajax/document.p?rowid=' string(rowid(b-table)) 
                    '&toolbarid=' lc-Doc-TBAR '&toggle='
                    '" + DocID;' skip
        'var objtoolBarOption = document.getElementById("doctbtboption");' skip
        'objtoolBarOption.innerHTML = doctbobjRowDefault;' skip
        "ahah(NewDocumentAjax,'IDDocument');"
        '~}' skip
        '</script>' skip.

    {&out} 
    '<script>' skip
        'function ConfirmDeleteAction(ObjectID,ActionID) ~{' skip
        '   var DocumentAjax = "' appurl '/iss/ajax/delaction.p?actionid=" + ActionID' skip
        '   if (confirm("Are you sure you want to delete this action?")) ~{' skip
        "       ObjectID.style.display = 'none';" skip
        "       ahah(DocumentAjax,'placeholder');" skip
        '       var objtoolBarOption = document.getElementById("acttbtboption");' skip
        '       objtoolBarOption.innerHTML = acttbobjRowDefault;' skip
        '       actionTableBuild();' skip
        '   ~}' skip
        '~}' skip
        '</script>'.
END PROCEDURE.

PROCEDURE ip-NotePage :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
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


&ENDIF

&IF DEFINED(EXCLUDE-ip-SLATable) = 0 &THEN

PROCEDURE ip-SLATable :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER slahead FOR slahead.
    DEFINE VARIABLE li-loop   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-object AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-rowid  AS CHARACTER NO-UNDO.


    {&out}
    htmlib-StartMntTable()
    htmlib-TableHeading(
        "Select?^left|SLA"
        ) skip.

    IF lc-global-company = "MICAR" THEN
    DO:
        {&out}
        htmlib-trmouse()
        '<td>'
        htmlib-Radio("sla", "slanone" , IF lc-sla-selected = "slanone" THEN TRUE ELSE FALSE)
        '</td>'
        htmlib-TableField(html-encode("None"),'left')

        '</tr>' skip.
    END.

    DO li-loop = 1 TO NUM-ENTRIES(lc-sla-rows,"|"):
        ASSIGN
            lc-rowid = ENTRY(li-loop,lc-sla-rows,"|").

        FIND slahead WHERE ROWID(slahead) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.
        IF NOT AVAILABLE slahead THEN NEXT.
        ASSIGN
            lc-object = "sla" + lc-rowid.
        {&out}
        htmlib-trmouse()
        '<td>'
        htmlib-Radio("sla" , lc-object, IF lc-sla-selected = lc-object THEN TRUE ELSE FALSE) 
        '</td>'
        htmlib-TableField(html-encode(slahead.description),'left')
                
        '</tr>' skip.

    END.
    
        
    {&out} skip 
       htmlib-EndTable()
       skip.



END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Update) = 0 &THEN

PROCEDURE ip-Update :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pr-rowid        AS ROWID         NO-UNDO.
    DEFINE INPUT PARAMETER pc-user         AS CHARACTER     NO-UNDO.

    DEFINE VARIABLE lc-old-status     AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE lc-old-assign     AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE ll-old-ticket     AS LOG        NO-UNDO.
    DEFINE VARIABLE lc-old-AreaCode   AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE ld-prj-start      AS DATE       NO-UNDO.
    DEFINE VARIABLE li-prj-diff       AS INTEGER    NO-UNDO.
    
    

    DEFINE VARIABLE lf-old-link-SLAID LIKE Issue.link-SLAID NO-UNDO.


    DEFINE BUFFER Issue     FOR Issue.
    DEFINE BUFFER WebStatus FOR WebStatus.

    FIND Issue WHERE ROWID(Issue) = pr-rowid EXCLUSIVE-LOCK.

    ASSIGN 
        lc-old-Status     = Issue.StatusCode
        lc-old-assign     = Issue.AssignTo
        lf-old-link-SLAID = Issue.link-SLAID
        ll-old-ticket     = Issue.Ticket
        lc-old-AreaCode   = Issue.AreaCode.

    ASSIGN 
        Issue.briefdescription = lc-briefdescription
        Issue.longdescription  = lc-longdescription
        Issue.AreaCode         = lc-AreaCode
        Issue.CatCode          = lc-CatCode
        Issue.StatusCode       = lc-currentstatus
        Issue.Ticket           = lc-ticket = "on"
        Issue.ContractType     = ENTRY(1,lc-contract-type,"|")  
        Issue.Billable         = lc-billable-flag  = "on"
        ll-isBillable            = Issue.Billable
        Issue.SearchField      = Issue.briefdescription + " " + 
                                      Issue.LongDescription
        Issue.iClass           = lc-iclass
        .
        
    IF Issue.iClass = lc-global-iclass-complex THEN
    DO:
        ASSIGN
            ld-prj-start = DATE(lc-prj-start)
            li-prj-diff  = ld-prj-start -  Issue.prj-Start.
       
        /*
        ***
        *** need to adjust project/engineer schedule
        ***
        */ 
        IF li-prj-diff <> 0 THEN
        DO:
            RUN prjlib-MoveProjectStart (
                lc-global-user,
                Issue.CompanyCode,
                Issue.IssueNumber,
                li-prj-diff 
            ).
            
            RUN islib-CreateNote( Issue.CompanyCode,
                    Issue.IssueNumber,
                    lc-global-user,
                    "SYS.INFO",
                    "Project Start adjusted by " + string(li-prj-diff) + " days... Schedule/Plan adjusted").
                    
            
        END.
        IF lc-currentassign <>  Issue.AssignTo THEN
        DO:
                               
            RUN prjlib-ChangeProjectEngineer 
                (
                lc-global-user,
                Issue.CompanyCode,
                Issue.IssueNumber,
                Issue.AssignTo,
                lc-currentAssign
                ).
                
        END.
             
        ASSIGN
            Issue.prj-Start = ld-prj-start.
  
                  
    END.

    IF lc-old-status <> lc-currentstatus THEN
    DO:
        IF lc-statnote <> "" THEN
        DO:
            FIND WebStatus WHERE WebStatus.companycode = Issue.CompanyCode
                AND WebStatus.StatusCode = lc-currentstatus 
                NO-LOCK NO-ERROR. 
            IF AVAILABLE WebStatus
                AND WebStatus.NoteCode <> "" 
                THEN RUN islib-CreateNote( Issue.CompanyCode,
                    Issue.IssueNumber,
                    pc-user,
                    WebStatus.NoteCode,
                    lc-statnote).
        END.
    END.

    IF ll-old-ticket <> Issue.Ticket THEN
    DO:
        RUN tlib-IssueChanged
            ( ROWID(Issue),
            pc-user,
            ll-old-ticket,
            Issue.Ticket ).
    END.
    IF lc-currentassign <>  Issue.AssignTo THEN
    DO:
        IF lc-currentassign = "" 
            THEN ASSIGN Issue.AssignDate = ?
                Issue.AssignTime = 0.
        ELSE ASSIGN Issue.AssignDate = TODAY
                Issue.AssignTime = TIME.

        islib-AssignChanged(ROWID(issue),
            pc-user,
            Issue.AssignTo,
            lc-currentAssign).
        ASSIGN 
            Issue.AssignTo = lc-currentassign.
    END.


    IF lc-sla-selected = "slanone" 
        OR lc-sla-rows = "" THEN 
    DO:
        ASSIGN 
            Issue.link-SLAID = 0
            Issue.SLAStatus  = "OFF".
    END.
    ELSE
    DO:
        FIND slahead WHERE ROWID(slahead) = to-rowid(substr(lc-sla-selected,4)) NO-LOCK NO-ERROR.
        IF AVAILABLE slahead
            THEN ASSIGN Issue.link-SLAID = slahead.SLAID.
    END.
    
    IF lc-planned = ""
        THEN ASSIGN Issue.PlannedCompletion = ?.
    ELSE ASSIGN Issue.PlannedCompletion = DATE(lc-planned).


    IF lc-old-status <> lc-currentstatus THEN
    DO:
        RELEASE issue.
        FIND Issue WHERE ROWID(Issue) = pr-rowid EXCLUSIVE-LOCK.
        RUN islib-StatusHistory(
            Issue.CompanyCode,
            Issue.IssueNumber,
            pc-user,
            lc-old-status,
            lc-currentStatus ).
        RELEASE issue.
        FIND Issue WHERE ROWID(Issue) = pr-rowid EXCLUSIVE-LOCK.
        
    END.

    IF lf-old-link-SLAID <> Issue.link-SLAID THEN
    DO:
        RELEASE issue.
        FIND Issue WHERE ROWID(Issue) = pr-rowid EXCLUSIVE-LOCK.
        DYNAMIC-FUNCTION("islib-RemoveAlerts",ROWID(Issue)).
        islib-SLAChanged(
            ROWID(Issue),
            pc-user,
            lf-old-link-SLAID,
            Issue.link-SLAID ).
        RELEASE issue.
        FIND Issue WHERE ROWID(Issue) = pr-rowid EXCLUSIVE-LOCK.
        IF Issue.link-SLAID = 0 THEN
        DO:
            ASSIGN 
                Issue.link-SLAID = 0.
        END.
        ELSE
        DO:
            EMPTY TEMP-TABLE tt-sla-sched.
            RUN lib/slacalc.p
                ( Issue.IssueDate,
                Issue.IssueTime,
                Issue.link-SLAID,
                OUTPUT table tt-sla-sched ).
            ASSIGN
                Issue.SLADate   = ?
                Issue.SLALevel  = 0
                Issue.SLAStatus = "OFF"
                Issue.SLATime   = 0
                issue.SLATrip   = ?
                issue.SLAAmber  = ?.

            FOR EACH tt-sla-sched NO-LOCK
                WHERE tt-sla-sched.Level > 0:

                ASSIGN
                    Issue.SLADate[tt-sla-sched.Level] = tt-sla-sched.sDate
                    Issue.SLATime[tt-sla-sched.Level] = tt-sla-sched.sTime.
                ASSIGN
                    Issue.SLAStatus = "ON".
            END.
            IF issue.slaDate[2] <> ? 
                THEN ASSIGN issue.SLATrip = DATETIME(STRING(Issue.SLADate[2],"99/99/9999") + " " 
                + STRING(Issue.SLATime[2],"HH:MM")).


        END.

    END.

    RELEASE issue.
    FIND Issue WHERE ROWID(Issue) = pr-rowid EXCLUSIVE-LOCK.
    IF Issue.AreaCode <> lc-old-AreaCode 
        AND Issue.AreaCode <> "" 
        THEN DYNAMIC-FUNCTION("islib-DefaultActions",Issue.CompanyCode,
            Issue.IssueNumber).
    IF DYNAMIC-FUNCTION("islib-StatusIsClosed",
        Issue.CompanyCode,
        Issue.StatusCode)
        THEN DYNAMIC-FUNCTION("islib-RemoveAlerts",ROWID(Issue)).


    
    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE li-OpenActions AS INTEGER NO-UNDO.
    
    DEFINE VARIABLE ld-date AS DATE    NO-UNDO.
    DEFINE VARIABLE lf-dec  AS DECIMAL NO-UNDO.
    
    IF lc-briefdescription = "" 
        THEN RUN htmlib-AddErrorMessage(
            'briefdescription', 
            'You must enter the brief description',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-longdescription = ""
        THEN RUN htmlib-AddErrorMessage(
            'longdescription', 
            'You must enter the details',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-currentstatus <> b-table.StatusCode THEN
    DO:
        FIND b-status WHERE b-status.CompanyCode = lc-global-company
            AND b-status.StatusCode = lc-currentstatus
            NO-LOCK NO-ERROR.
        IF b-status.NoteCode <> "" 
            AND lc-statnote = "" THEN
            RUN htmlib-AddErrorMessage(
                'statnote', 
                'You must enter a status note when changing to this status',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        
        IF b-status.NoteCode = "" 
            AND TRIM(lc-statnote) <> "" THEN
            RUN htmlib-AddErrorMessage(
                'statnote', 
                'A status note is not required for this status',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    END.
    ELSE
    DO:
        IF TRIM(lc-statnote) <> "" THEN
            RUN htmlib-AddErrorMessage(
                'statnote', 
                'A status note is not required unless you change the status',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).    
    END.
    
    li-OpenActions = com-IssueActionsStatus(b-table.companyCode,b-table.issueNumber,'Open').
    
    IF li-openActions > 0 THEN
    DO:
        FIND b-status WHERE b-status.CompanyCode = lc-global-company
            AND b-status.StatusCode = lc-currentstatus
            NO-LOCK NO-ERROR.
        IF b-status.CompletedStatus = YES
            THEN
            RUN htmlib-AddErrorMessage(
                'currentstatus', 
                'There are open actions, you can not close the issue',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
                
    END.
    IF b-table.iClass = lc-global-iclass-complex THEN
    DO:
        ASSIGN 
            ld-date = ?.
        ASSIGN 
            ld-date = DATE(lc-prj-start) no-error.
        IF ERROR-STATUS:ERROR
            OR ld-date = ?
            THEN RUN htmlib-AddErrorMessage(
                'prj-start', 
                'The project start date is invalid',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
                
    END.
    
    IF lc-planned <> "" THEN
    DO:
        ASSIGN 
            ld-date = ?.
        ASSIGN 
            ld-date = DATE(lc-planned) no-error.
        IF ERROR-STATUS:ERROR
            OR ld-date = ?
            THEN RUN htmlib-AddErrorMessage(
                'planned', 
                'The planned completion date is invalid',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
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



    ASSIGN 
        ll-superuser = DYNAMIC-FUNCTION("com-IsSuperUser",lc-global-user).
        
    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.
    
    ASSIGN
        ll-customer = this-user.UserClass = "CUSTOMER".
        

    ASSIGN 
        lc-mode          = get-value("mode")
        lc-rowid         = get-value("rowid")
        lc-search        = get-value("search")
        lc-firstrow      = get-value("firstrow")
        lc-lastrow       = get-value("lastrow")
        lc-accountmanager = get-value("accountmanager")
        lc-navigation    = get-value("navigation")
        lc-account       = get-value("account")
        lc-status        = get-value("status")
        lc-assign        = get-value("assign")
        lc-area          = get-value("area")
        lc-category      = get-value("category")
        lc-submitsource  = get-value("submitsource")
        lc-contract-type = get-value("contract")
        lc-billable-flag = get-value("billcheck")
        ll-isBillable      = NO
        lc-iclass        = get-value("iclass")
        lc-prj-start     = get-value("prj-start").

    .
    IF lc-iclass = ""
        THEN lc-iclass = ENTRY(1,lc-global-iclass-code,"|").


    IF lc-mode = "" 
        THEN ASSIGN 
            lc-mode          = get-field("savemode")
            lc-rowid         = get-field("saverowid")
            lc-search        = get-value("savesearch")
            lc-firstrow      = get-value("savefirstrow")
            lc-accountmanager = get-value("saveaccountmanager")
            lc-lastrow       = get-value("savelastrow")
            lc-navigation    = get-value("savenavigation")
            lc-account       = get-value("saveaccount")
            lc-status        = get-value("savestatus")
            lc-assign        = get-value("saveassign")
            lc-area          = get-value("savearea")
            lc-category      = get-value("savecategory")
            lc-contract-type = get-value("savecontract")  
            /*lc-billable-flag = get-value("savebillable") 
            */
            .

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                               "&firstrow=" + lc-firstrow + 
                               "&lastrow=" + lc-lastrow.


    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title        = 'Add'
                lc-link-label   = "Cancel addition"
                lc-submit-label = "Add Issue".
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
                lc-submit-label = 'Delete Issue'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title        = 'Update'
                lc-link-label   = 'Cancel update'
                lc-submit-label = 'Update Issue'.
    END CASE.
    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.
    FIND customer OF b-table NO-LOCK NO-ERROR.
    
    IF ll-customer AND Customer.AccountNumber <> this-user.AccountNumber THEN
    DO:
        com-SystemLog("ERROR:PageDeniedWrongAccount",lc-user,THIS-PROCEDURE:FILE-NAME).
        set-user-field("ObjectName",THIS-PROCEDURE:FILE-NAME + " (Incorrect Account)").
        RUN run-web-object IN web-utilities-hdl ("mn/secure.p").
        RETURN.
   
    END.
    
    
    li-OpenActions = com-IssueActionsStatus(b-table.companyCode,b-table.issueNumber,'Open').

    IF li-OpenActions = 0 
        THEN RUN com-GetStatusIssue ( lc-global-company , OUTPUT lc-list-status, OUTPUT lc-list-sname ).
    ELSE RUN com-GetStatusIssueOpen ( lc-global-company , OUTPUT lc-list-status, OUTPUT lc-list-sname ).
   
    IF DYNAMIC-FUNCTION("islib-StatusIsClosed",
        b-table.CompanyCode,
        b-table.StatusCode) 
        THEN ll-IsOpen = FALSE.
    ELSE ll-isOpen = TRUE.

    RUN com-GetAreaIssue ( lc-global-company , OUTPUT lc-list-area , OUTPUT lc-list-aname ).
    RUN com-GetAssignIssue ( lc-global-company , OUTPUT lc-list-assign , OUTPUT lc-list-assname ).
    RUN com-GetAssignList ( lc-global-company , OUTPUT lc-list-proj-assign , OUTPUT lc-list-proj-assname ).
    RUN com-GetCategoryIssue( lc-global-company, OUTPUT lc-list-catcode, OUTPUT lc-list-cname ).
    

    ASSIGN 
        lc-title           = lc-title + ' Issue ' + string(b-table.issuenumber) + ' - ' +
           html-encode(customer.accountNumber + " - " + customer.name)
        lc-ContractAccount = customer.accountNumber
        lc-enc-key =
        DYNAMIC-FUNCTION("sysec-EncodeValue",lc-user,TODAY,"customer",STRING(ROWID(customer))).
    
    ASSIGN
        lc-sla-rows = com-CustomerAvailableSLA(lc-global-company,b-table.AccountNumber).

    IF request_method = "post" THEN
    DO:
        ASSIGN 
            lc-areacode         = get-value("areacode")
            lc-briefdescription = get-value("briefdescription")
            lc-longdescription  = get-value("longdescription")
            lc-currentstatus    = get-value("currentstatus")
            lc-currentassign    = get-value("currentassign")
            lc-prj-eng          = get-value("prj-eng")
            lc-planned          = get-value("planned")
            lc-statnote         = get-value("statnote")
            lc-sla-selected     = get-value("sla")
            lc-catcode          = get-value("catcode")
            lc-ticket           = get-value("ticket")
            lc-contract-type    = get-value("selectcontract")
            lc-billable-flag    = get-value("billcheck")
            ll-isBillable       = lc-billable-flag = "on"
            lc-prj-start        = get-value("prj-start")
            lc-iclass           = get-value("iclass").
          
          
        IF com-TicketOnly(lc-global-company,
            b-table.AccountNumber)
            THEN ASSIGN lc-ticket = "on".

        
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).
        IF lc-error-field = "" THEN
        DO:
            RUN ip-Update ( ROWID(b-table), lc-user ).
            RUN ip-BackToIssue.
            RETURN.

        END.


    END.
    ELSE
    DO:
        ASSIGN 
            lc-areacode         = b-table.AreaCode
            lc-briefdescription = b-table.briefdescription
            lc-longdescription  = b-table.longdescription
            lc-currentstatus    = b-table.StatusCode
            lc-currentassign    = b-table.AssignTo
            lc-prj-eng          = b-table.prj-eng
            lc-catcode          = b-table.CatCode
            lc-ticket           = IF b-table.Ticket THEN "on" ELSE ""
            lc-contract-type    = b-table.ContractType   
            lc-billable-flag    = IF b-table.Billable THEN "on" ELSE ""
            ll-isBillable       = b-table.Billable
            lc-iclass           = b-table.iclass
            lc-prj-start        = STRING(b-table.prj-start,"99/99/9999")
            .

        IF b-Table.PlannedCompletion = ?
            THEN lc-planned = "".
        ELSE lc-planned = STRING(b-table.plannedCompletion,'99/99/9999').

        ASSIGN
            lc-sla-selected = "slanone".
        IF b-table.link-SLAID <> 0 THEN
        DO:
            FIND slahead 
                WHERE slahead.SLAID = b-table.link-SLAID NO-LOCK NO-ERROR.
            IF AVAILABLE slahead
                THEN ASSIGN lc-sla-selected = "sla" + string(ROWID(slahead)).

        END.
              
    END.
   
    RUN outputHeader.
    
    {&out}
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' skip 
         '<HTML>' skip
         '<HEAD>' skip
         '<meta http-equiv="Cache-Control" content="No-Cache">' skip
         '<meta http-equiv="Pragma"        content="No-Cache">' skip
         '<meta http-equiv="Expires"       content="0">' skip
         '<TITLE>' lc-title '</TITLE>' skip
         DYNAMIC-FUNCTION('htmlib-StyleSheet':U) skip.

    RUN ip-Javascript.
    

    {&out}
    '</HEAD>' skip
        '<body class="normaltext" onUnload="ClosePage()">' skip
        htmlib-StartForm("mainform","post", appurl + '/iss/issuemain.p') skip
        htmlib-ProgramTitle(lc-title) skip.


    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) SKIP
           htmlib-hidden ("saveaccountmanager",lc-accountmanager) SKIP
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("saveaccount", lc-account) skip
           htmlib-Hidden ("savestatus", lc-status) skip
           htmlib-Hidden ("saveassign", lc-assign) skip
           htmlib-Hidden ("savearea", lc-area) skip
           htmlib-Hidden ("savecategory", lc-category ) skip
           htmlib-Hidden ("savecontract", lc-contract-type  ) skip
           htmlib-Hidden ("savebillable", lc-billable-flag   ) skip
    .

   
    {&out}
    '<div class="tabber">' skip.

    /*
    *** Main Issue Details
    */
    
    IF b-table.iClass = lc-global-iclass-complex THEN
    {&out} '<div class="tabbertab" title="Project Details">' skip.
    else
    {&out} '<div class="tabbertab" title="Issue Details">' skip.
    RUN ip-IssueMain.
    {&out}
    '</div>' skip.  

    /*
    *** Actions
    */
    {&out} 
    '<div class="tabbertab" title="Actions & Activities">' skip.
    RUN ip-ActionPage.
    {&out} 
    '</div>'.

    /*
    *** Notes
    */
    {&out} 
    '<div class="tabbertab" title="Notes">' skip.
    RUN ip-NotePage.
    {&out} 
    '</div>'.

    /*
    *** Attachments
    */
    {&out} 
    '<div class="tabbertab" title="Attachments">' skip.
    RUN ip-Documents.
    {&out} 
    '</div>'.


    /*
    *** Status Changes
    */
    {&out} 
    '<div class="tabbertab" title="Status Changes">' skip.
    RUN ip-IssueStatusHistory ( ROWID(b-table)).
    {&out} 
    '</div>'.
    /*
    *** Customer Details
    */
    {&out} 
    '<div class="tabbertab" title="Customer Details">' skip.
    {&out}
    '<div id="IDCustomerAjax">Loading Notes</div>'.
    {&out} 
    '</div>'.
    /*
    *** Complex Project Gannt
    */
    
    IF b-table.iClass = lc-global-iclass-complex THEN
    DO:
        {&out}
        '<div class="tabbertab" title="Project Plan">' SKIP.
        RUN ip-GanttPage.   
        {&out} 
        '</div>' SKIP.
             
    END.
    


    {&out} '</div>' skip.           /* tabber */
    

    {&out} '<div id="placeholder" style="display: none;"></div>' skip.

    {&out} htmlib-Hidden("submitsource","null")
    htmlib-Hidden("fromcview",get-value("fromcview"))
    htmlib-Hidden("contract",lc-contract-type) skip
        /*
           htmlib-Hidden("billcheck",lc-billable-flag) */
        skip.

    
    {&OUT} htmlib-EndForm() skip.

    {&out}
    htmlib-CalendarScript("planned") skip.
    
    IF b-table.iClass = lc-global-iclass-complex 
        THEN {&out} htmlib-CalendarScript("prj-start") skip.

    {&out} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fn-DescribeSLA) = 0 &THEN

FUNCTION fn-DescribeSLA RETURNS CHARACTER
    ( pr-rowid AS ROWID ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/


    DEFINE BUFFER issue   FOR issue.
    DEFINE BUFFER slahead FOR slahead.

    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-line   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ll-table  AS LOG       NO-UNDO.


    FIND issue
        WHERE ROWID(issue) = pr-rowid NO-LOCK NO-ERROR.

    IF NOT AVAILABLE issue THEN RETURN "".


    IF issue.link-SLAID = 0 
        OR issue.link-SLAID = ?
        OR NOT CAN-FIND(slahead WHERE slahead.slaid = issue.link-slaid NO-LOCK)
        THEN RETURN "No SLA".

    FIND slahead WHERE slahead.slaid = issue.link-slaid NO-LOCK NO-ERROR.

    ASSIGN 
        lc-return = slahead.description.

    IF DYNAMIC-FUNCTION('islib-IssueIsOpen':U,pr-rowid) THEN
    DO:
        DO li-loop = 1 TO 10:
            IF Issue.SLADate[li-loop] = ?
                OR slahead.RespDesc[li-loop] = "" THEN NEXT.

            IF ll-table = FALSE THEN
            DO:
                ASSIGN 
                    lc-return = lc-return + 
                    htmlib-StartMntTable() +
                    htmlib-TableHeading(
                    "Level^right|Description|Date").
                ASSIGN 
                    ll-table = TRUE.
            END.
            ASSIGN 
                lc-line = '<tr class="tabrow1">'.
            
            ASSIGN
                lc-line = lc-line + 
                          htmlib-TableField(STRING(li-loop) + 
                                            IF li-loop = Issue.SLALevel THEN "*" ELSE "",'right') +
                          htmlib-TableField(html-encode(
                              slahead.RespDesc[li-loop] + ' (' + 
                               slahead.RespUnit[li-loop] + ' ' + string(slahead.RespTime[li-loop])
                               + ')'
                              
                              ),'left')
                         + 
                         htmlib-TableField(html-encode(
                              STRING(issue.SLADate[li-loop],"99/99/9999") + " " + 
                              string(issue.SLATime[li-loop],"hh:mm am")
                              
                              ),'left')
                         + '</tr>'.
            /*
            assign lc-line = "Level " + string(li-loop) + ": " + 
                               slahead.RespDesc[li-loop] + ' (' + 
                               slahead.RespUnit[li-loop] + ' ' + string(slahead.RespTime[li-loop])
                               + ')'.
            assign lc-line = lc-line + " at " + 
                        string(issue.SLADate[li-loop],"99/99/9999") + " " + 
                        string(issue.SLATime[li-loop],"hh:mm am").
            */

            ASSIGN 
                lc-return = lc-return + lc-line.

            
        END.
        IF ll-table
            THEN ASSIGN lc-return = lc-return + htmlib-EndTable().
        
    END.
    
    RETURN lc-return.


END FUNCTION.


&ENDIF

