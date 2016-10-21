/***********************************************************************

    Program:        crm/crmop.p
    
    Purpose:        CRM Opportunity Maintanenace
    
    Notes:
    
    
    When        Who         What
    06/08/2016  phoski      Initial
    15/10/2016  phoski      Phase 2 changes
   
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE lc-error-field  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg    AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crmAccount   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lr-customer     AS ROWID     NO-UNDO.


DEFINE VARIABLE lc-title        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-Enc-Key      AS CHARACTER NO-UNDO.  

DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-source       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parent       AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-descr        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sm-code      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sm-desc      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-SalesContact AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cu-code      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cu-desc      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-department   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-nextStep     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CloseDate    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-currentProv  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-opType       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ServReq      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-opNote       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rating       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-opStatus     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-prob         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cos          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rev          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lost         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sType        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-dbase        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-camp         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ops          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-opno         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lr-val-rowid    AS ROWID     NO-UNDO.
DEFINE VARIABLE lc-lostd        AS CHARACTER NO-UNDO.




DEFINE VARIABLE lc-Action-TBar  AS CHARACTER INITIAL 'tim' NO-UNDO.
DEFINE VARIABLE lc-doc-tbar     AS CHARACTER INITIAL 'doc' NO-UNDO.


DEFINE BUFFER b-valid  FOR op_master.
DEFINE BUFFER b-table  FOR op_master.
DEFINE BUFFER Customer FOR Customer.


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
           skip
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
    tbar-BeginOptionID(lc-Action-TBAR) skip.

    {&out} tbar-Link("delete",?,"off","").

    {&out}  
    tbar-Link("update",?,"off","")
    tbar-Link("multiiss",?,"off","")
    tbar-EndOption()
    tbar-End().

    {&out}
    '<div id="IDAction"></div>'.
    
    

END PROCEDURE.

PROCEDURE ip-Documents:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    {&out}
           skip
           tbar-BeginID(lc-Doc-TBAR,"")
           tbar-Link("add",?,'javascript:documentAdd();',"") skip
            tbar-BeginOptionID(lc-Doc-TBAR) skip
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
        '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' skip
           tbar-JavaScript(lc-Action-TBar) SKIP
           tbar-JavaScript(lc-Doc-TBAR) SKIP
           '<script language="javascript">' SKIP
           'var appurl = "' appurl '";' SKIP
           'var appMode = "' lc-mode '";' SKIP
           'var CustomerAjax = "' appurl '/cust/custequiplist.p?expand=yes&ajaxsubwindow=yes&customer=' url-encode(lc-enc-key,"Query")  '"' skip
            'var NoteAddURL = "' appurl '/crm/addnote.p?rowid=' + lc-rowid '"' SKIP
            'var NoteAjax = "' appurl '/crm/ajax/note.p?rowid=' STRING(ROWID(b-table)) '"' skip
                       
           'var ActionAjax = "' appurl '/crm/ajax/action.p?allowdelete=yes&rowid=' string(rowid(b-table)) 
                    '&toolbarid=' lc-Action-TBar  
                    '"' SKIP
            'var DocumentAjax = "' appurl '/crm/ajax/document.p?rowid=' string(rowid(b-table)) 
                    '&toolbarid=' lc-Doc-TBAR 
                    '"' SKIP
            'var DocumentAddURL = "' appurl '/crm/adddocument.p?rowid=' + lc-rowid '"' SKIP
                    
           '</script>' SKIP
          
           
           
           '<script language="JavaScript" src="/asset/page/crm/crmop.js?v=1.0.0"></script>' SKIP.
           
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
          
           
    {&out}
    '<script>' skip
        'function ConfirmDeleteAction(ObjectID,ActionID) ~{' skip
        '   var DocumentAjax = "' appurl '/crm/ajax/delaction.p?actionid=" + ActionID' skip
        '   if (confirm("Are you sure you want to delete this action?")) ~{' skip
        "       ObjectID.style.display = 'none';" skip
        "       ahah(DocumentAjax,'placeholder');" skip
        '       var objtoolBarOption = document.getElementById("acttbtboption");' skip
        '       objtoolBarOption.innerHTML = acttbobjRowDefault;' skip
        '       actionTableBuild();' skip
        '   ~}' skip
        '~}' skip
        '</script>'.
        
    {&out} 
    '<script>' skip
        'function ConfirmDeleteAttachment(ObjectID,DocID) ~{' skip
        '   var DocumentAjax = "' appurl '/crm/ajax/deldocument.p?docid=" + DocID' skip
        '   if (confirm("Are you sure you want to delete this document?")) ~{' skip
        "       ObjectID.style.display = 'none';" skip
        "       ahah(DocumentAjax,'placeholder');" skip
        '       var objtoolBarOption = document.getElementById("doctbtboption");' skip
        '       objtoolBarOption.innerHTML = doctbobjRowDefault;' skip
        '   ~}' skip
        '~}' skip
        '</script>' skip.

             
    

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
    
    {&out} htmlib-StartTable("mnt",
        100,
        0,
        0,
        0,
        "center").
        
    IF lc-opno <> "" THEN
    DO:
    {&out} '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("opno",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Opportunity No")
        ELSE htmlib-SideLabel("Opportunity No"))
    '</TD>' skip
            '<TD VALIGN="TOP" ALIGN="left">'            lc-opno
           '</TD></tr>'.
    END.
              
    {&out} '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("descr",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</TD>' skip
            '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("descr",40,lc-descr) skip
           '</TD></tr>' SKIP.
    
    
           
    
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Sales Contact")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("salescontact",lc-cu-Code,lc-cu-desc,lc-salescontact)
    '</TD></TR>' skip.
    
    {&out} '<TR align="left"><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("department",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Department")
        ELSE htmlib-SideLabel("Department"))
    '</TD>' skip
            '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("department",40,lc-department) skip
           '</TD></tr>'.
   
    RUN com-GenTabSelect ( lc-global-company, "CRM.NextStep", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Next Step")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("nextstep",lc-Code ,lc-desc,lc-nextStep)
    '</TD></TR>' skip.
                                
    {&out} '<TR align="left"><td valign="top" align="right">' 
        (IF LOOKUP("closedate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Close Date")
        ELSE htmlib-SideLabel("Close Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("closedate",10,lc-closedate) 
    htmlib-CalendarLink("closedate")
    '</td></tr>' SKIP.
    
    {&out} '<TR align="left"><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("currentprov",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Current Provider")
        ELSE htmlib-SideLabel("Current Provider"))
    '</TD>' skip
            '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("currentprov",40,lc-currentProv) skip
           '</TD></tr>'.
           
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Opportunity Type")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("optype",lc-global-opType-Code ,lc-global-opType-desc,lc-opType)
    '</TD></TR>' skip.
    
    RUN com-GenTabSelect ( lc-global-company, "CRM.ServiceRequired", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Service Required")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("servreq",lc-Code ,lc-desc,lc-servreq)
    '</TD></TR>' skip. 
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("opnote",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Note")
        ELSE htmlib-SideLabel("Note"))
    '</TD>' skip
    '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-TextArea("opnote",lc-Opnote,5,60)
    '</TD></tr>' SKIP.
   
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Rating")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("rating",lc-global-rating-Code ,lc-global-Rating-desc,lc-Rating)
    '</TD></TR>' skip.

          
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Opportunity Status")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("opstatus",lc-global-opstatus-Code ,lc-global-opStatus-desc,lc-opstatus)
    '</TD></TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Probability")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("prob",lc-global-opProb-Code ,lc-global-opProb-desc,lc-Prob)
    '</TD></TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("cos",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Cost Of Sale")
        ELSE htmlib-SideLabel("Cost Of Sale"))
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("cos",8,lc-cos) 
    '</TD>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("rev",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Revenue")
        ELSE htmlib-SideLabel("Revenue"))
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("rev",8,lc-rev) 
    '</TD>' skip.
    
    RUN com-GenTabSelect ( lc-global-company, "CRM.DealLostReason", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Deal Lost Reason")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("lost",lc-Code ,lc-desc,lc-lost)
    '</TD></TR>' skip. 
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("lostd",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Lost Description")
        ELSE htmlib-SideLabel("Lost Description"))
    '</TD>' skip
    '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-TextArea("lostd",lc-lostd,5,60)
    '</TD></tr>' SKIP.
    
         
    RUN com-GenTabSelect ( lc-global-company, "CRM.SourceType", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Source Type")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("stype",lc-Code ,lc-desc,lc-sType)
    '</TD></TR>' skip.
    
    {&out} '<TR align="left"><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("ops",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Opportunity Source")
        ELSE htmlib-SideLabel("Opportunity Source"))
    '</TD>' skip
            '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("ops",40,lc-ops) skip
           '</TD></tr>'.
           
    RUN com-GenTabSelect ( lc-global-company, "CRM.Database", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Database")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("dbase",lc-Code ,lc-desc,lc-dbase)
    '</TD></TR>' skip.
    
    RUN com-GenTabSelect ( lc-global-company, "CRM.Campaign", 
        OUTPUT lc-code,
        OUTPUT lc-desc ).
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Campaign")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("camp",lc-Code ,lc-desc,lc-camp)
    '</TD></TR>' skip.
    
    
              
    
    {&out} htmlib-EndTable() skip.
  

END PROCEDURE.

PROCEDURE ip-Validate:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg    AS CHARACTER NO-UNDO.

    DEFINE VARIABLE ld-date AS DATE         NO-UNDO.
    DEFINE VARIABLE li-int  AS INT          NO-UNDO.
    
       IF lc-descr = ""
        OR lc-descr = ?
        THEN RUN htmlib-AddErrorMessage(
            'name', 
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
        lc-mode = get-value("mode")
        lc-rowid = get-value("rowid")
        lc-enc-key = get-value("crmaccount")
        lc-source = get-value("source")
        lc-parent = get-value("parent").
    .
    
    ASSIGN
        lc-CRMAccount = DYNAMIC-FUNCTION("sysec-DecodeValue",lc-user,TODAY,"Customer",lc-enc-key).
        
    ASSIGN 
        lr-customer = TO-ROWID(lc-crmAccount).
        
        
    FIND Customer WHERE ROWID(Customer) = lr-customer NO-LOCK.
    
    RUN com-GetUserListByClass ( lc-global-company, "INTERNAL", REPLACE(lc-global-SalType-Code,'|',",") ,OUTPUT lc-sm-code, OUTPUT lc-sm-desc).
    
    
    ASSIGN
        lc-sm-code = "|" + lc-sm-code
        lc-sm-desc = "None Selected|" + lc-sm-desc
        .
        
    RUN com-GetUserListForAccount (lc-global-company,customer.AccountNumber,OUTPUT lc-cu-code, OUTPUT lc-cu-desc).
    IF lc-cu-code = ""
        THEN ASSIGN lc-cu-code = lc-global-selcode
            lc-cu-desc = "None".
    
    ELSE 
        ASSIGN
            lc-cu-code = lc-global-selcode + "|" + lc-cu-code
            lc-cu-desc = "None|" + lc-cu-desc.
            
            
            
    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title = 'Add'
                lc-link-label = "Cancel addition"
                lc-submit-label = "Add Opportunity".
        WHEN 'view'
        THEN 
            ASSIGN 
                lc-title = 'View'
                lc-link-label = "Back"
                lc-submit-label = "".
        WHEN 'delete'
        THEN 
            ASSIGN 
                lc-title = 'Delete'
                lc-link-label = 'Cancel deletion'
                lc-submit-label = 'Delete Opportunity'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Back'
                lc-submit-label = 'Update Opportunity'.
    END CASE.
    
    ASSIGN 
        lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-user,TODAY,"customer",STRING(ROWID(customer))).
        
                 
    ASSIGN 
        lc-title = lc-title + ' Opportunity'
        lc-link-url = appurl + '/crm/customer.p' + 
                                  '?crmaccount=' + url-encode(lc-enc-key,"Query") +
                                  '&navigation=refresh&mode=CRM' +
                                  "&source=" + lc-source + "&parent=" + lc-parent +
                                  '&time=' + string(TIME).
                                  
              
    ASSIGN
        lc-title = "Account: " + Customer.Name + " - " + lc-title.
                                      
    IF request_method = "POST" THEN
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
                lc-opno              = get-value("opno")
                lc-descr             = get-value("descr")
                lc-SalesContact      = get-value("salescontact")
                lc-department        = get-value("department")
                lc-nextstep          = get-value("nextstep")
                lc-closedate         = get-value("closedate")
                lc-currentProv       = get-value("currentprov")
                lc-opType            = get-value("optype")
                lc-servReq           = get-value("servreq")
                lc-opnote            = get-value("opnote")
                lc-rating            = get-value("rating")
                lc-opstatus          = get-value("opstatus")
                lc-prob              = get-value("prob")
                lc-cos               = get-value("cos")
                lc-rev               = get-value("rev")
                lc-lost              = get-value("lost")
                lc-stype             = get-value("stype")
                lc-dbase             = get-value("dbase")
                lc-camp              = get-value("camp")
                lc-ops               = get-value("ops")
                lc-lostd             = get-value("lostd")
                  
                .
                        
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
                    CREATE b-table.
                    ASSIGN 
                        b-table.accountnumber = Customer.AccountNumber
                        b-table.CompanyCode   = lc-global-company
                        b-table.op_id         = NEXT-VALUE(op_master)
                        b-table.createDate    = NOW
                        b-table.createLoginid = lc-global-user
                        lc-firstrow      = STRING(ROWID(b-table)).
                   
                END.
                
                IF b-table.op_no = 0 THEN
                DO:
                    FIND LAST b-valid 
                        WHERE b-valid.CompanyCode = lc-global-company
                          AND b-valid.op_no > 0 NO-LOCK NO-ERROR.
                    ASSIGN 
                        b-table.op_no = IF AVAILABLE b-valid THEN b-valid.op_no + 1 ELSE 1.        
                END.
                
                ASSIGN
                                        b-table.descr           = lc-descr
                    b-table.salesContact    = lc-SalesContact
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
                    b-table.DealLostReason  = lc-lost
                    b-table.SourceType      = lc-stype
                    b-table.dbase           = lc-dbase
                    b-table.Campaign        = lc-camp
                    b-table.opSource        = lc-ops
                    b-table.lostdescription = lc-lostd
                    .
                    
                IF b-table.salesContact = lc-global-selcode
                    THEN b-table.salesContact = "".
            
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
                
                DELETE b-table.
            END.
            
        END.
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
            lc-opno         = STRING(b-table.op_no)
            lc-descr        = b-table.descr
            lc-SalesContact = b-table.Salescontact
            lc-department   = b-table.department
            lc-nextstep     = b-table.nextstep
            lc-CloseDate    = IF b-table.CloseDate = ? THEN "" ELSE STRING(b-table.CloseDate,"99/99/9999")
            lc-currentProv  = b-table.CurrentProvider
            lc-optype       = b-table.optype
            lc-servreq      = b-table.servRequired
            lc-opnote       = b-table.opnote
            lc-rating       = b-table.rating
            lc-opstatus     = b-table.OpStatus
            lc-prob         = STRING(b-table.Probability)
            lc-cos          = STRING(b-table.CostOfSale)
            lc-rev          = STRING(b-table.Revenue)
            lc-lost         = b-table.DealLostReason
            lc-stype        = b-table.SourceType
            lc-dbase        = b-table.dBase
            lc-camp         = b-table.Campaign
            lc-ops          = b-table.opSource
            lc-lostd        = b-table.lostdescription
            .
            
       
    END.  
                                        
    RUN outputHeader.
    
    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.
    
    IF lc-mode = "UPDATE"
        THEN RUN ip-ExportJS.
    
    
    {&out} htmlib-Header("Opportunity CRM") skip.
 
   
    
    {&out} htmlib-StartForm("mainform","post", appurl + '/crm/crmop.p' ) SKIP
           htmlib-ProgramTitle(lc-title) skip.
    
     
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.


    IF lc-mode = "ADD" THEN
    DO:
        RUN ip-UpdatePage.
        {&out} htmlib-CalendarScript("closedate") SKIP.
    END.
    ELSE 
        IF lc-mode = "UPDATE" THEN
        DO:
            {&out}
            '<div class="tabber">' skip.
         
            {&out} '<div class="tabbertab" title="Opportunity">' SKIP.
            RUN ip-UpdatePage.
            {&out} htmlib-CalendarScript("closedate") SKIP.
        
            IF lc-error-msg <> "" THEN
            DO:
                {&out} '<BR><BR><CENTER>' 
                htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
            END.

            IF lc-submit-label <> "" THEN
            DO:
                {&out} '<br><center>' htmlib-SubmitButton("submitform",lc-submit-label) 
                '</center>' skip.
            END.
    
            {&out} '</div>' SKIP.
        
        
        
            {&out} '<div class="tabbertab" title="Action & Activities">' SKIP.
            
            RUN ip-ActionPage.
            {&out} '</div>' SKIP.
        
            {&out} 
            '<div class="tabbertab" title="Notes">' skip.
            RUN ip-NotePage.
            {&out} 
            '</div>'.
    
            {&out} '<div class="tabbertab" title="Attachments">' SKIP.
            RUN ip-Documents.
            {&out} '</div>' SKIP.
        
        
            {&out} '<div class="tabbertab" title="Customer Details">' SKIP.
            {&out}
            '<div id="IDCustomerAjax">Loading Notes</div>'.
    
            {&out} '</div>' SKIP.
        
         
            {&out} '</div>' SKIP.
        END.
    
    {&out} htmlib-Hidden ("mode", lc-mode) skip
           htmlib-Hidden ("rowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) SKIP
           htmlib-hidden ("crmaccount", get-value("crmaccount"))
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) SKIP
           htmlib-hidden("source",lc-source) skip
           htmlib-hidden("parent",lc-parent) SKIP
    .
       
       
    {&out} '<div id="placeholder" style="display: none;"></div>' skip.
       
    IF lc-mode <> "UPDATE" THEN
    DO:      
        IF lc-error-msg <> "" THEN
        DO:
            {&out} '<BR><BR><CENTER>' 
            htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
        END.

        IF lc-submit-label <> "" THEN
        DO:
            {&out} '<br><center>' htmlib-SubmitButton("submitform",lc-submit-label) 
            '</center>' skip.
        END.
    
    END.
    


    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
              
END PROCEDURE.
