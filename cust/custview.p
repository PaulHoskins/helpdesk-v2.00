/***********************************************************************

    Program:        cust/custview.p
    
    Purpose:        Customer Maintenance         
    
    Notes:
    
    
    When        Who         What
    03/08/2006  phoski      Initial
    
    23/08/2010  DJS         3677 Added remote connection ability
    23/08/2010  DJS         3678 Modified map facility to use google 
                                maps instead of streetmaps
                                
    02/09/2010 DJS          3674 - Added Quickview buttons in view    
    28/04/2014 phoski       Customer Assets 
    14/06/2014 phoski       google maps fix
    27/09/2014 phoski       Encrypted rowid
    13/11/2014 phoski       CustomerViewInventory flag
    09/12/2014 phoski       Add documents
    15/08/2015 phoski       Default user - Issue/Bulk Email/Status
                            Changes
    08/11/2015 phoski       Account ref & default contract 
    23/02/2016 phoski       Decommission inventory not shown
    21/03/2016 phoski       Document Link Encrypt
    18/06/2016 phoski       Show decomissioned at end of inventory
    01/07/2016 phoski       AdminTime activity is not chargeable
                        
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.

DEFINE BUFFER b-customer FOR customer.     /* 3677 & 3678 */           
DEFINE BUFFER b-custIv   FOR custIv.         /* 3677 & 3678 */           
DEFINE BUFFER b-ivSub    FOR ivSub.           /* 3677 & 3678 */           
                                               
DEFINE VARIABLE lc-Enc-Key        AS CHARACTER NO-UNDO.                                               
DEFINE VARIABLE lc-search         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url       AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-accountnumber  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-name           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-address1       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-address2       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-city           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-county         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-country        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-postcode       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-telephone      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-contact        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-notes          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-supportticket  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-statementemail AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-doc-key        AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-sla-rows       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sla-selected   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-temp           AS CHARACTER NO-UNDO.
DEFINE VARIABLE rdpIP             AS CHARACTER NO-UNDO.              /* 3677 & 3678 */
DEFINE VARIABLE rdpUser           AS CHARACTER NO-UNDO.              /* 3677 & 3678 */
DEFINE VARIABLE rdpPWord          AS CHARACTER NO-UNDO.              /* 3677 & 3678 */
DEFINE VARIABLE rdpDomain         AS CHARACTER NO-UNDO.              /* 3677 & 3678 */
DEFINE VARIABLE first-RDP         AS LOG       INITIAL TRUE NO-UNDO. /* 3677 & 3678 */

DEFINE VARIABLE ll-Customer       AS LOG       INITIAL FALSE NO-UNDO.

DEFINE VARIABLE lc-inv-key        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-Doc-TBAR       AS CHARACTER 
    INITIAL "doctb" NO-UNDO.
DEFINE VARIABLE lc-Issue-TBAR     AS CHARACTER
    INITIAL "isstbar" NO-UNDO.
DEFINE VARIABLE lc-Invent-TBAR    AS CHARACTER
    INITIAL "ivtb" NO-UNDO.
DEFINE VARIABLE lc-Cust-TBAR      AS CHARACTER 
    INITIAL "custtb" NO-UNDO.
DEFINE VARIABLE lc-Asset-TBAR     AS CHARACTER 
    INITIAL "assettb" NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 11.54
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

&IF DEFINED(EXCLUDE-ip-Asset) = 0 &THEN

PROCEDURE ip-Asset :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-ToolBarID        AS CHARACTER     NO-UNDO.


    DEFINE VARIABLE ll-ToolBar          AS LOG      NO-UNDO.
    
    DEFINE VARIABLE lc-rowid AS CHARACTER NO-UNDO.
    
    
    DEFINE VARIABLE li-max-lines AS INTEGER INITIAL 12 NO-UNDO.
    DEFINE VARIABLE lr-first-row AS ROWID NO-UNDO.
    DEFINE VARIABLE lr-last-row  AS ROWID NO-UNDO.
    DEFINE VARIABLE li-count     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE ll-prev      AS LOG   NO-UNDO.
    DEFINE VARIABLE ll-next      AS LOG   NO-UNDO.
    DEFINE VARIABLE lc-search    AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE lc-firstrow  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE lc-lastrow   AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE lc-navigation AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-smessage     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-link-otherp  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-char         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-customer     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-returnback   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-temp         AS CHARACTER NO-UNDO.


    DEFINE BUFFER customer FOR customer.
    DEFINE BUFFER b-query  FOR CustAst.


    ASSIGN
        lc-returnback="customerview".


    FIND customer 
        WHERE customer.CompanyCode = pc-CompanyCode
        AND customer.AccountNumber = pc-AccountNumber
        NO-LOCK.

    lc-customer = STRING(ROWID(customer)).




    IF NOT DYNAMIC-FUNCTION("com-IsCustomer",lc-global-company,lc-global-user) THEN
    DO:
        ASSIGN 
            ll-toolbar = TRUE.
        {&out} SKIP
            tbar-BeginID(pc-ToolBarID,"") SKIP
            tbar-Link("add",?,appurl + '/cust/custassetmnt.p',"customer=" +
                      string(rowid(customer)) + "&returnback=customerview")
            tbar-BeginOptionID(pc-ToolBarID)

            tbar-Link("view",?,"off",lc-link-otherp)
            tbar-Link("update",?,"off",lc-link-otherp)
            tbar-Link("delete",?,"off",lc-link-otherp)

 
            tbar-EndOption()
            tbar-End() SKIP.
  
    END.

    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="95%" align="center"').
    
    {&out}
    htmlib-TableHeading(
        "ID|Description|Type|Manufacturer|Model|Serial|Location|Status|Purchase|Cost^right"
        ) skip.

    OPEN QUERY q FOR EACH b-query NO-LOCK
        OF customer.

    GET FIRST q NO-LOCK.

    REPEAT WHILE AVAILABLE b-query:
   
        
        ASSIGN 
            lc-rowid = STRING(ROWID(b-query)).
        
        ASSIGN 
            li-count = li-count + 1.
        IF lr-first-row = ?
            THEN ASSIGN lr-first-row = ROWID(b-query).
        ASSIGN 
            lr-last-row = ROWID(b-query).
        
        ASSIGN 
            lc-link-otherp = 'search=' + lc-search +
                                '&firstrow=' + string(lr-first-row) +
                                '&customer=' + lc-customer + 
                                '&returnback=' + lc-returnback.

      

        {&out}
            skip
             tbar-trID(pc-ToolBarID,rowid(b-query))
            skip

            
            htmlib-MntTableField(html-encode(b-query.AssetID),'left')
            htmlib-MntTableField(html-encode(b-query.descr),'left')
            htmlib-MntTableField(html-encode(b-query.AType + " " +
                                 DYNAMIC-FUNCTION("com-GenTabDesc",
                         b-query.CompanyCode, "Asset.Type", 
                         b-query.AType))
                                 ,'left')
            htmlib-MntTableField(html-encode(b-query.Amanu + " " +
                                 DYNAMIC-FUNCTION("com-GenTabDesc",
                         b-query.CompanyCode, "Asset.Manu", 
                         b-query.AManu))
                                 ,'left')
            htmlib-MntTableField(html-encode(b-query.model),'left')
            htmlib-MntTableField(html-encode(b-query.serial),'left')
            htmlib-MntTableField(html-encode(b-query.location),'left')
            htmlib-MntTableField(html-encode(b-query.Astatus + " " +
                                 DYNAMIC-FUNCTION("com-GenTabDesc",
                         b-query.CompanyCode, "Asset.Status", 
                         b-query.AStatus))
                                 ,'left')

            htmlib-MntTableField(html-encode(IF b-query.purchased = ? THEN '' ELSE STRING(b-query.purchased,"99/99/9999")),'left')

            htmlib-MntTableField(html-encode(string(b-query.cost,">>>>>>>>9.99-")),'right') SKIP
            SKIP



            tbar-BeginHidden(rowid(b-query))
            tbar-Link("view",rowid(b-query),appurl + '/cust/custassetmnt.p',lc-link-otherp)
            tbar-Link("update",rowid(b-query),appurl + '/cust/custassetmnt.p',lc-link-otherp)
            tbar-Link("delete",rowid(b-query),appurl + '/cust/custassetmnt.p',lc-link-otherp)
                
            tbar-EndHidden()
            '</tr>' skip.

       

        GET NEXT q NO-LOCK.
            
    END.

    {&out} skip 
           htmlib-EndTable()
           skip.

    
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-CustomerDocuments) = 0 &THEN

PROCEDURE ip-CustomerDocuments :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-ToolBarID        AS CHARACTER     NO-UNDO.

    
    DEFINE BUFFER Customer FOR Customer.
    DEFINE BUFFER doch     FOR doch.
    DEFINE VARIABLE lc-type         AS CHARACTER 
        INITIAL "CUSTOMER"  NO-UNDO.
    DEFINE VARIABLE lc-back AS CHARACTER NO-UNDO.
    
    FIND customer 
        WHERE customer.CompanyCode = pc-CompanyCode
        AND customer.AccountNumber = pc-AccountNumber
        NO-LOCK.

    ASSIGN
        lc-back = selfurl + "?source=" + get-value("source") + "&rowid=" + url-encode(lc-enc-key,"Query") + "&showtab=document".    
    {&out} SKIP
        '<script>' skip
        'var DocumentAddURL = "' appurl '/cust/cadddocument.p?rowid=' + string(rowid(customer)) '";' SKIP
        'var DocumentBack = "' lc-back '";' skip
        
        'function documentAdd () ~{' SKIP
        '    PopUpWindow(DocumentAddURL)' SKIP
        '~}' SKIP
        
       
        'function documentCreated () ~{' SKIP
        'ClosePopUpWindow();' SKIP
        'self.location = DocumentBack;' skip
        '~}' skip 
        '</script>'
        SKIP.
    {&out}
    tbar-BeginID(pc-ToolBarID,"").
    
    IF NOT ll-customer
        THEN {&out} tbar-Link("add",?,'javascript:documentAdd();',"") SKIP.
    
    {&out}
    tbar-BeginOptionID(pc-ToolBarID)
    tbar-Link("documentview",?,"off","")
    tbar-EndOption()
    tbar-End().

    {&out} skip
          replace(htmlib-StartMntTable(),'width="100%"','width="97%"') skip.
    {&out}
    htmlib-TableHeading(
        "Date|Time|By|Description|Type|Size (KB)^right"
        ) skip.

    FOR EACH doch NO-LOCK
        WHERE doch.CompanyCode = lc-global-company
        AND doch.RelType = "customer"
        AND doch.RelKey  = customer.AccountNumber:

        IF ll-customer THEN
        DO:
            IF NOT doch.customerView THEN NEXT.

        END.
        ASSIGN 
            lc-doc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"Document",STRING(ROWID(doch))).
            
        
        {&out}
            skip
            tbar-trID(pc-ToolBarID,rowid(doch))
            skip
            htmlib-MntTableField(string(doch.CreateDate,"99/99/9999"),'left')
            htmlib-MntTableField(string(doch.CreateTime,"hh:mm am"),'left')
            htmlib-MntTableField(html-encode(dynamic-function("com-UserName",doch.CreateBy)),'left')
            htmlib-MntTableField(doch.descr,'left')
            htmlib-MntTableField(doch.DocType,'left')
            htmlib-MntTableField(string(round(doch.InBytes / 1024,2)),'right')
            tbar-BeginHidden(rowid(doch))
                 tbar-Link("documentview",rowid(doch),
                          'javascript:OpenNewWindow('
                          + '~'' + appurl 
                          + '/sys/docview.' + lc(doch.doctype) + '?docid=' + url-encode(lc-doc-key,"Query")

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

&IF DEFINED(EXCLUDE-ip-CustomerMainInfo) = 0 &THEN

PROCEDURE ip-CustomerMainInfo :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-ToolBarID        AS CHARACTER     NO-UNDO.
    
    DEFINE BUFFER b-query  FOR Customer.
    DEFINE BUFFER b-webu   FOR WebUser.
        

    DEFINE VARIABLE lc-address      AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE lc-temp         AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE lc-tempAddress  AS CHARACTER        NO-UNDO.  
    DEFINE VARIABLE lc-cam          AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE lc-AMan         AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE lc-def-cont     AS CHARACTER        NO-UNDO.
    

    FIND b-query
        WHERE b-query.CompanyCode   = pc-CompanyCode
        AND b-query.AccountNumber = pc-AccountNumber NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-query THEN RETURN.
   
        
    FIND FIRST WebissCont 
        WHERE WebissCont.CompanyCode = b-query.companyCode
        AND WebissCont.Customer  = b-query.AccountNumber
        AND WebissCont.defcon = TRUE
        NO-LOCK NO-ERROR.
    IF AVAILABLE WebissCont
        THEN lc-def-cont = WebissCont.ContractCode.
    ELSE lc-def-cont = "<b>** None **</b>".
                    
                    
    ASSIGN
        lc-address = ""
        lc-cam = ""
        lc-AMan = "".

    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.Address1).
    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.Address2).
    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.City).
    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.County).
    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.Country).
    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.PostCode).
    
    lc-tempAddress = lc-address.  
    

    FIND b-webu WHERE b-webu.LoginID = b-query.AccountManager NO-LOCK NO-ERROR.
    IF AVAILABLE b-webu
        THEN lc-AMan = b-webu.Name.
    
    
    IF get-value("source") = "menu" THEN
    DO:
        {&out}
        tbar-BeginID(pc-ToolBarID,"")
        tbar-Link("addissue",?,appurl + '/' + "iss/addissue.p","issuesource=custenq&accountnumber=" + customer.AccountNumber)
        tbar-Link("statement",?,appurl + '/' + "cust/indivstatement.p","source=menu&accountnumber=" + customer.AccountNumber)
             SKIP.
        IF NOT ll-customer THEN
            {&out}
        tbar-Link("Gmap",?,'javascript:void(0)"onclick="goGMAP(~''                  /* 3678 */ 
            + replace(b-query.postcode," ","+")                    /* 3678 */ 
            + '~',~''                                              /* 3678 */ 
            + replace(REPLACE(TRIM(b-query.name)," ","+"),"&","")  /* 3678 */ 
            + '~',~''                                              /* 3678 */ 
            + replace(REPLACE(lc-tempAddress,"~n","+"),"&","")     /* 3678 */ 
            + '~')'  ,"")                                          /* 3678 */ 
        tbar-Link("RDP",?,'javascript:void(0)"onclick="goRDP()'  ,"")               /* 3677 */
               SKIP.

        {&out}
        tbar-BeginOptionID(pc-ToolBarID)
        tbar-EndOption()
        tbar-End().
    END.
    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="100%" align="center"').

    {&out}
    htmlib-TableHeading(
        "Account^left|Name^left|Address^left|Contact|Telephone|Support Team|Account<br>Manager|Account<br>Ref|Default<br>Contract|Notes")
            skip.

    {&out}
    '<tr>' skip
        htmlib-MntTableField(html-encode(b-query.AccountNumber),'left')
        htmlib-MntTableField(html-encode(b-query.name),'left').

    IF b-query.PostCode = "" THEN
        {&out}
    htmlib-MntTableField(REPLACE(html-encode(lc-address),"~n","<br>"),'left').
    else
    do:
ASSIGN 
    lc-temp = REPLACE(htmlib-MntTableField(REPLACE(html-encode(lc-address),"~n","<br>"),'left'),"</td>","").

{&out} lc-temp.
END.

{&out}
htmlib-MntTableField(html-encode(b-query.Contact),'left')
htmlib-MntTableField(html-encode(b-query.Telephone),'left').
FIND steam WHERE steam.companyCode = b-query.CompanyCode
    AND steam.st-num = b-query.st-num NO-LOCK NO-ERROR.
{&out} htmlib-MntTableField(IF AVAILABLE steam THEN STRING(steam.st-num) + " - " + steam.descr ELSE 'None','left').
{&out}
htmlib-MntTableField(html-encode(lc-AMan),'left')
htmlib-MntTableField(html-encode(b-query.accountRef),'left')
htmlib-MntTableField(lc-def-cont,'left').


IF b-query.notes = ""
    THEN {&out} htmlib-MntTableField("",'left').
    else {&out} replace(htmlib-TableField(replace(html-encode(b-query.notes),"~n",'<br>'),'left'),
                '<td','<th style="color: red;') skip.

{&out} '</tr>' skip.

{&out} skip 
           htmlib-EndTable().

IF NOT ll-customer THEN
    {&out} htmlib-CustomerViewable(b-query.CompanyCode,b-Query.AccountNumber) SKIP.

{&out} htmlib-CustomerDocs(b-query.CompanyCode,b-Query.AccountNumber,lc-global-user,appurl,ll-customer)    /* 3674 */

           skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-CustomerOpenIssue) = 0 &THEN

PROCEDURE ip-CustomerOpenIssue :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-ToolBarID        AS CHARACTER     NO-UNDO.


    DEFINE VARIABLE lc-status       AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE lc-issdate      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-raised       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-assigned     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-count        AS INTEGER NO-UNDO.
    
    
    DEFINE VARIABLE lc-open-status  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-closed-status AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER b-query  FOR issue.
    DEFINE BUFFER b-search FOR issue.
    DEFINE BUFFER b-status FOR WebStatus.
    DEFINE BUFFER b-user   FOR WebUser.
    DEFINE BUFFER b-Area   FOR WebIssArea.
      
    DEFINE QUERY q FOR b-query SCROLLING.
    
    DEFINE VARIABLE lc-area         AS CHARACTER NO-UNDO.
   
    DEFINE VARIABLE lc-info         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-object       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-tag-end      AS INTEGER NO-UNDO.
    DEFINE VARIABLE lc-dummy-return AS CHARACTER INITIAL "CTMYXXX111PPP2222"   NO-UNDO.
    
    DEFINE BUFFER Customer FOR Customer.
    

    FIND customer 
        WHERE customer.CompanyCode = pc-CompanyCode
        AND customer.AccountNumber = pc-AccountNumber
        NO-LOCK.

    RUN com-StatusType ( pc-CompanyCode , OUTPUT lc-open-status , OUTPUT lc-closed-status ).

    {&out}
    tbar-BeginID(pc-ToolBarID,"")
    tbar-Link("addissue",?,appurl + '/' + "iss/addissue.p","issuesource=custenq&accountnumber=" + customer.AccountNumber)
            
    tbar-BeginOptionID(pc-ToolBarID)
            
    tbar-Link("view",?,"off","")
    tbar-Link("update",?,"off","")
    tbar-EndOption()
    tbar-End().

    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="97%"') skip
           htmlib-TableHeading(
            "Issue Number^right|Date^right|Brief Description^left|Status^left|Area|Assigned To|By^left"
            ) skip.


    OPEN QUERY q FOR EACH b-query NO-LOCK
        WHERE b-query.Company = pc-companyCode
        AND b-query.AccountNumber = pc-AccountNumber
        AND can-do(lc-open-status,b-query.StatusCode)
        BY b-query.IssueNumber DESCENDING.

    GET FIRST q NO-LOCK.
    REPEAT WHILE AVAILABLE b-query:
   
        
        ASSIGN 
            lc-rowid = STRING(ROWID(b-query))
            lc-issdate = IF b-query.issuedate = ? THEN "" ELSE STRING(b-query.issuedate,'99/99/9999').
        

        ASSIGN 
            li-count = li-count + 1.
       
        

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

        FIND b-user WHERE b-user.LoginID = b-query.AssignTo NO-LOCK NO-ERROR.
        ASSIGN 
            lc-assigned = IF AVAILABLE b-user THEN b-user.name ELSE "".

        FIND b-area OF b-query NO-LOCK NO-ERROR.
        ASSIGN 
            lc-area = IF AVAILABLE b-area THEN b-area.description ELSE "".

        {&out}
            skip
            tbar-trID(pc-ToolBarID,rowid(b-query))
            skip
            htmlib-MntTableField(html-encode(string(b-query.issuenumber)),'right')
            htmlib-MntTableField(html-encode(lc-issdate),'right') skip.

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
        htmlib-MntTableField(html-encode(lc-assigned),'left').

        {&out} htmlib-MntTableField(html-encode(lc-raised),'left').
        

        {&out} skip
                tbar-BeginHidden(rowid(b-query))
                tbar-Link("view",rowid(b-query),
                          'javascript:HelpWindow('
                          + '~'' + appurl 
                          + '/iss/issueview.p?rowid=' + string(rowid(b-query))
                          + '~'' 
                          + ');'
                          ,"")
                tbar-Link("update",rowid(b-query),appurl + '/' + "iss/issueframe.p","fromcview=yes")
                
            tbar-EndHidden() skip.

        {&out}
        '</tr>' skip.

       

        GET NEXT q NO-LOCK.
            
    END.


    {&out} skip 
           htmlib-EndTable()
           skip.



END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-CustomerSecondary) = 0 &THEN

PROCEDURE ip-CustomerSecondary :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
 
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    
    DEFINE BUFFER b-query  FOR Customer.
    

    FIND b-query
        WHERE b-query.CompanyCode   = pc-CompanyCode
        AND b-query.AccountNumber = pc-AccountNumber NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-query THEN RETURN.
   

    
    
    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="95%" align="center"').

    {&out}
    htmlib-TableHeading(
        "Default SLA^left|Other SLA|Support Type^left|Ticket Balance^right|Statement Email")
            skip.

    {&out}
    '<tr>' skip.

    IF b-query.DefaultSLAID = 0
        THEN {&out} htmlib-MntTableField(html-encode("None"),'left').
    else
    do:
FIND slahead WHERE slahead.SLAID = b-query.DefaultSLAID NO-LOCK NO-ERROR.
{&out} htmlib-MntTableField(html-encode(slahead.description),'left').
END.

{&out} '<td>' skip.
RUN ip-SLA.
{&out}
'</td>'.
{&out} htmlib-MntTableField(DYNAMIC-FUNCTION("com-DecodeLookup",b-query.supportticket,
    lc-global-SupportTicket-Code,
    lc-global-SupportTicket-Desc
    ),'left') skip.

{&out} htmlib-MntTableField(IF DYNAMIC-FUNCTION('com-AllowTicketSupport':U,ROWID(b-query))
    THEN DYNAMIC-FUNCTION("com-TimeToString",com-GetTicketBalance(lc-global-company,pc-accountnumber))
    ELSE "&nbsp;",'right') skip
          htmlib-MntTableField(html-encode(b-query.statementemail),'left').
           
    
{&out}
     
'</tr>' skip.

    


{&out} skip 
           htmlib-EndTable()
           
           skip.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-CustomerUsers) = 0 &THEN

PROCEDURE ip-CustomerUsers :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    
    DEFINE BUFFER b-query  FOR webUser.
    DEFINE VARIABLE lc-nopass   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-main     AS CHARACTER NO-UNDO.


    DEFINE VARIABLE lc-Last     AS CHARACTER NO-UNDO.

    IF NOT CAN-FIND(FIRST b-query
        WHERE b-query.CompanyCode   = pc-CompanyCode
        AND b-query.AccountNumber = pc-AccountNumber NO-LOCK) 
        THEN RETURN.
   
    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="97%"') skip.

    {&out}
    htmlib-TableHeading(
        "User Name^left|Name^left|Last Login|Email^left|Telephone|Mobile|Track?|Disabled?"
        ) skip.


    FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode   = pc-CompanyCode
        AND b-query.AccountNumber = pc-AccountNumber
        :
    
          

        ASSIGN 
            lc-nopass = IF b-query.passwd = ""
                           OR b-query.passwd = ?
                           THEN " (No password)"
                           ELSE "".
        
        IF b-query.LastDate = ?
            THEN ASSIGN lc-last = "".
        ELSE ASSIGN lc-last = STRING(b-query.LastDate,"99/99/9999") + " " + string(b-query.LastTime,"hh:mm am").

        {&out}
        '<tr>' skip
            htmlib-MntTableField(html-encode(b-query.loginid),'left')
            htmlib-MntTableField(html-encode(b-query.name),'left')
            htmlib-MntTableField(html-encode(lc-last),'left')
            htmlib-MntTableField(html-encode(b-query.email),'left')
            htmlib-MntTableField(html-encode(b-query.Telephone),'left')
            htmlib-MntTableField(html-encode(b-query.Mobile),'left')
            htmlib-MntTableField(html-encode(if b-query.CustomerTrack = true
                                          then 'Yes' else 'No'),'left')
            htmlib-MntTableField(html-encode((if b-query.disabled = true
                                          then 'Yes' else 'No') + lc-nopass),'left')

        .
            
        {&out}
            
        '</tr>' skip.
     
    END.


    {&out} skip 
           htmlib-EndTable()
           skip.

    DO:
        {&out} '<div class="infobox">'.
        
        IF Customer.def-iss-loginid <> ""
            THEN {&out} 'Default Issue User - ' DYNAMIC-FUNCTION("com-UserName",Customer.def-iss-loginid) '</br>' SKIP.
        IF Customer.def-bulk-loginid <> ""
            THEN {&out} 'Bulk Email User - ' DYNAMIC-FUNCTION("com-UserName",Customer.def-bulk-loginid) '</br>' SKIP.
        IF Customer.def-stat-loginid <> ""
            THEN {&out} 'Status Change User - ' DYNAMIC-FUNCTION("com-UserName",Customer.def-iss-loginid) '</br>' SKIP.
        
        
        {&out} '</div>' .
                
    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Inventory) = 0 &THEN

PROCEDURE ip-Inventory :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    
    DEFINE BUFFER Customer FOR Customer.
    DEFINE BUFFER ivClass  FOR ivClass.
    DEFINE BUFFER ivSub    FOR ivSub.
    DEFINE BUFFER b-query FOR CustIv.
    DEFINE BUFFER b-search FOR CustIv.

    DEFINE VARIABLE iPass AS INTEGER NO-UNDO.
    DEFINE VARIABLE lPass AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lTitle AS LOGICAL NO-UNDO.
    DEFINE VARIABLE cPass AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE lc-object           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-subobject        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-ajaxSubWindow    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-expand           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ll-toolbar          AS LOG  NO-UNDO.
    DEFINE VARIABLE lc-update-id        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-htmlreturn       AS CHARACTER NO-UNDO.   /* 3677 */ 
    DEFINE VARIABLE ll-htmltrue         AS LOG  NO-UNDO.   /* 3677 */ 


    lc-expand = "yes".

    FIND customer 
        WHERE customer.CompanyCode = pc-CompanyCode
        AND customer.AccountNumber = pc-AccountNumber
        NO-LOCK.

    
    /*
    *** Link to maintain inventory info
    */

    IF DYNAMIC-FUNCTION("com-IsContractor",lc-global-company,lc-global-user) THEN
    DO:
    /*         assign ll-toolbar = true.                                           */
    /*         {&out}                                                              */
    /*             tbar-BeginID(lc-invent-TBAR,"")                                 */
    /*             tbar-Link("add",?,appurl + '/cust/custequipmnt.p',"customer=" + */
    /*                       string(rowid(customer)) + "&returnback=customerview") */
    /*             tbar-BeginOptionID(lc-invent-TBAR)                              */
    /*                                                                             */
    /*             tbar-Link("update",?,"off","")                                  */
    /*             tbar-Link("delete",?,"off","")                                  */
    /*             tbar-EndOption()                                                */
    /*             tbar-End().                                                     */
    END.
    ELSE
        IF NOT DYNAMIC-FUNCTION("com-IsCustomer",lc-global-company,lc-global-user) THEN
        DO:
            ASSIGN 
                ll-toolbar = TRUE.
            {&out}
            tbar-BeginID(lc-invent-TBAR,"")
            tbar-Link("add",?,appurl + '/cust/custequipmnt.p',"customer=" +
                string(ROWID(customer)) + "&returnback=customerview")
            tbar-BeginOptionID(lc-invent-TBAR)

            tbar-Link("update",?,"off","")
 
            tbar-EndOption()
            tbar-End().
  
        END.
   
    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="95%" align="center"').

    {&out}
    htmlib-TableHeading(
        "Select Inventory|"
        ) skip.

    
    {&out}
    '<tr class="tabrow1">'
    '<td valign="top" nowrap class="tree">' skip.
    
   
    
    
    DO iPass = 1 TO 2:
        
       
        ASSIGN 
            lPass = IF iPass = 1 THEN NO ELSE TRUE
            cPass = IF iPass = 1 THEN "L" ELSE "D"
            lTitle = NO.
        
        FOR EACH b-query NO-LOCK OF Customer
            WHERE b-query.isDecom = lpass ,
            FIRST ivSub NO-LOCK OF b-query,
            FIRST ivClass NO-LOCK OF ivSub
            BREAK 
            BY ivClass.DisplayPriority DESCENDING
            BY ivClass.name
            BY ivSub.DisplayPriority DESCENDING
            BY ivSub.name
            BY b-query.Ref:
    
            IF lPass AND NOT lTitle THEN
            DO:
                {&out} '<div class="infobox">Decomissioned Inventory</div>' SKIP.
                lTitle = TRUE.
                
            END.
            
            ASSIGN 
                lc-object = "CLASS" + string(ROWID(ivClass)) + cPass
                lc-subobject = "SUB" + string(ROWID(ivSub)) + cPass.
            IF FIRST-OF(ivClass.name) THEN
            DO:
                IF lc-expand = "yes" 
                    THEN {&out} '<img src="/images/general/menuopen.gif" onClick="hdexpandcontent(this, ~''
                lc-object '~')">'
                '&nbsp;' '<span style="' ivClass.Style '">' html-encode(ivClass.name) '</span><br>'
                '<div id="' lc-object '" style="padding-left: 15px; display: block;">' skip.
                else {&out}
                    '<img src="/images/general/menuclosed.gif" onClick="hdexpandcontent(this, ~''
                            lc-object '~')">'
                    '&nbsp;' '<span style="' ivClass.Style '">' html-encode(ivClass.name) '</span><br>'
                    '<div id="' lc-object '" style="padding-left: 15px; display: none;">' skip.
            END.
    
            IF FIRST-OF(ivSub.name) THEN
            DO:
                
                IF lc-expand = "yes"
                    THEN {&out} 
                '<img src="/images/general/menuopen.gif" onClick="hdexpandcontent(this, ~''
                lc-subobject '~')">'
                '&nbsp;'
                '<span style="' ivSub.Style '">'
                html-encode(ivSub.name) '</span><br>' skip
                    '<div id="' lc-subobject '" style="padding-left: 15px; display: block;">' skip.
                    
                else {&out} 
                    '<img src="/images/general/menuclosed.gif" onClick="hdexpandcontent(this, ~''
                            lc-subobject '~')">'
                    '&nbsp;'
                    '<span style="' ivSub.Style '">'
                    html-encode(ivSub.name) '</span><br>' skip
                    '<div id="' lc-subobject '" style="padding-left: 15px; display: none;">' skip.
            END.
           
            ll-htmltrue = FALSE.
            
            {&out} '<a '.
    
            IF b-query.ivSubID = 52 THEN
            DO:
                RUN ip-SetRDP-O( RECID(b-query),
                    OUTPUT lc-htmlreturn,
                    OUTPUT ll-htmltrue).
            END.
            ELSE
                IF b-query.ivSubID = 73928 THEN
                DO:
                    RUN ip-SetRDP-M( RECID(b-query),
                        OUTPUT lc-htmlreturn,
                        OUTPUT ll-htmltrue).
                END.
              
            IF ll-htmltrue THEN {&out} ' onclick="javascript:newRDP(~'' + lc-htmlreturn + '~')"  '.
              
            ASSIGN 
                lc-inv-key = DYNAMIC-FUNCTION("sysec-EncodeValue","Inventory",TODAY,"Inventory",STRING(ROWID(b-query))).
            
            {&out} 'href="'
            "javascript:ahah('" 
            appurl "/cust/custequiptable.p?rowid=" url-encode(lc-inv-key,"Query") "&customer=" url-encode(lc-enc-key,"Query")
            "&sec=" url-encode(lc-global-secure,"Query")
            "','inventory');".
    
            IF ll-toolbar THEN
            DO:
                ASSIGN 
                    lc-update-id = "clx" + string(ROWID(b-query)).
    
                {&out} 'ivtbrowSelect (' lc-update-id ',~'' lc-update-id '~');'. 
            END.
            {&out}
            '">' html-encode(b-query.ref) '</a><br>' skip.
    
            IF first-RDP THEN
            DO:
                IF ll-htmltrue THEN
                DO:
                    ASSIGN 
                        first-RDP = FALSE.
                    {&out} '<div id="ScriptDiv" style="visibility:hidden; position:absolute; top:-1px; left:-1px " ></div>'.
                    {&out} '<div id="ScriptSet" style="visibility:hidden; position:absolute; top:-1px; left:-1px " > ~n'
                    '<script defer > ~n'
                    '<!-- hide script from old browsers ~n'
                    '   newRDP(~'' + lc-htmlreturn + '~'); ~n'
                    ' --> ~n'
                    '</script></div>~n'.
                END.
            END.
    
            IF ll-toolbar THEN
            DO:
                
    
                {&out}
                '<div id="' lc-update-id '" style="display: none;">'
                tbar-Link("update",ROWID(b-query),appurl + '/cust/custequipmnt.p',"customer=" + string(ROWID(customer)) + "&returnback=customerview")
                /*                 tbar-Link("delete",rowid(b-query),appurl + '/cust/custequipmnt.p',"customer=" + string(rowid(customer)) + "&returnback=customerview")  */
                '</div>'
                    .
            END.
            
            IF LAST-OF(ivSub.name) THEN
            DO:
                {&out} '</div>' skip.
            END.
    
            IF LAST-OF(ivClass.name) THEN
            DO:
                {&out} '</div>' skip.
            END.
        END.
    END. /* iPass */
    {&out} '</td>' skip.
    {&out} '<td valign="top" rowspan="100" ><div id="inventory">&nbsp;</div></td>'.
    {&out} '</tr>' skip.
    {&out} skip 
           htmlib-EndTable()
           skip.

    IF  first-RDP THEN
    DO:
        {&out} '<div id="ScriptSet" style="visibility:hidden; position:absolute; top:-1px; left:-1px " > ~n'
        '<script defer > ~n'
        '<!-- hide script from old browsers   ~n'
        '   function goRDP() ~{ ~n'
        '     alert("No connection information found"); ~n'
        '   ~}   ~n'
        ' --> ~n'
        '</script></div>~n'.
    END.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-SetRDP-M) = 0 &THEN

PROCEDURE ip-SetRDP-M :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER p-recid AS RECID NO-UNDO.
    DEFINE OUTPUT PARAMETER p-html         AS CHARACTER INITIAL "~',~'~',~'"  NO-UNDO.
    DEFINE OUTPUT PARAMETER  p-ok          AS LOG  INITIAL FALSE NO-UNDO.
    DEFINE VARIABLE ou                      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ip                      AS CHARACTER NO-UNDO.

    FIND b-custIv WHERE RECID(b-custIv) = p-recid NO-LOCK NO-ERROR.
    FIND FIRST b-ivSub OF b-custIv NO-LOCK NO-ERROR.
  
    FIND FIRST ivField OF b-ivSub
        WHERE ivField.ivFieldID = 73932 NO-LOCK NO-ERROR.

    FIND FIRST CustField
        WHERE CustField.CustIvID = b-custIv.CustIvId
        AND CustField.ivFieldId = ivField.ivFieldId
        NO-LOCK NO-ERROR.

    IF AVAILABLE CustField THEN 
    DO:
        ASSIGN
            ip = TRIM(CustField.FieldData)
            ou = substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou = ou + substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou = ou + substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou =  ou + TRIM(substr(ip,1,3), "~/,.;:!? ~"~ '[]()abcdefghijklmnopqrstuvwxyz").
        
        IF NUM-ENTRIES(ou,".") <> 4 THEN RETURN.
        ELSE 
        DO:
            ASSIGN 
                rdpIP = TRIM(ou)
                p-ok  = TRUE.
      
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 73934 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpUser = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
                                     
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 73935 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpPWord  = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
                                     
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 73933 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpDomain  = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
  
            p-html =  rdpIP + '~',~'' + rdpUser + '~',~'' + rdpDomain.

        END.

    END.
 
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-SetRDP-O) = 0 &THEN

PROCEDURE ip-SetRDP-O :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER p-recid AS RECID NO-UNDO.
    DEFINE OUTPUT PARAMETER p-html         AS CHARACTER INITIAL "~',~'~',~'"  NO-UNDO.
    DEFINE OUTPUT PARAMETER  p-ok          AS LOG  INITIAL FALSE NO-UNDO.
    DEFINE VARIABLE ou                      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ip                      AS CHARACTER NO-UNDO.


    FIND b-custIv WHERE RECID(b-custIv) = p-recid NO-LOCK NO-ERROR.
    FIND FIRST b-ivSub OF b-custIv NO-LOCK NO-ERROR.
  
    FIND FIRST ivField OF b-ivSub
        WHERE ivField.ivFieldID = 53 NO-LOCK NO-ERROR.
    /*   where ivField.ivFieldID = 74870 no-lock no-error.  */

    FIND FIRST CustField
        WHERE CustField.CustIvID = b-custIv.CustIvId
        AND CustField.ivFieldId = ivField.ivFieldId
        NO-LOCK NO-ERROR.

    IF AVAILABLE CustField THEN 
    DO:
        ASSIGN
            ip = TRIM(CustField.FieldData)
            ou = substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou = ou + substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou = ou + substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou =  ou + TRIM(substr(ip,1,3), "~/,.;:!? ~"~ '[]()abcdefghijklmnopqrstuvwxyz").
        
        IF NUM-ENTRIES(ou,".") <> 4 THEN RETURN.
        ELSE 
        DO:
            ASSIGN 
                rdpIP = TRIM(ou)
                p-ok  = TRUE. 
      
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 54 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpUser = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
                                     
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 55 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpPWord  = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
                                     
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 45619 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpDomain  = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
  
            p-html =  rdpIP + '~',~'' + rdpUser + '~',~'' + rdpDomain.

        END.

    END.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-SLA) = 0 &THEN

PROCEDURE ip-SLA :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE BUFFER slahead  FOR slahead.
    DEFINE VARIABLE li-loop     AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-rowid    AS CHARACTER     NO-UNDO.


    {&out}
    htmlib-StartMntTable()
        .

    DO li-loop = 1 TO NUM-ENTRIES(lc-sla-rows,"|"):
        ASSIGN
            lc-rowid = ENTRY(li-loop,lc-sla-rows,"|").

        FIND slahead WHERE ROWID(slahead) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.
        IF NOT AVAILABLE slahead THEN NEXT.
        {&out}
        '<tr>' skip
                replace(htmlib-TableField(html-encode(slahead.description),'left'),
                        '<td',
                        '<td nowrap ')
                htmlib-TableField(replace(slahead.notes,"~n",'<br>') + '<br>','left')
                        
            '</tr>' skip.

    END.
    
        
    {&out} skip 
       htmlib-EndTable()
       skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Tickets) = 0 &THEN

PROCEDURE ip-Tickets :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    
    DEFINE BUFFER b-query      FOR ticket.
    DEFINE BUFFER IssActivity  FOR IssActivity.
    DEFINE BUFFER issue        FOR issue.
        
    DEFINE VARIABLE lc-Issue        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE lc-Activity     AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE li-cf           AS INTEGER      NO-UNDO.
    DEFINE VARIABLE ll-Chargeable   AS LOGICAL      NO-UNDO.


    IF NOT CAN-FIND(FIRST b-query
        WHERE b-query.CompanyCode   = pc-CompanyCode
        AND b-query.AccountNumber = pc-AccountNumber NO-LOCK) 
        THEN RETURN.

    {&out} '<div class="infobox">Activities marked ** are administration and are not charged</div>' SKIP.
    
    
    
    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="97%"') skip.

    {&out}
    htmlib-TableHeading(
        "Date^right|Type|Reference|Issue Number^right||Activity|Time^right|Carried Forward^right"
        ) skip.


    FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode   = pc-CompanyCode
        AND b-query.AccountNumber = pc-AccountNumber
        :

        ASSIGN
            lc-issue = ""
            lc-Activity = ""
            ll-chargeable = TRUE.
            
        IF b-query.IssActivityID <> 0 
        THEN ll-chargeable = com-IsActivityChargeable(b-query.IssActivityID).
        
        IF ll-chargeable
        THEN li-cf = li-cf + b-query.Amount.

        IF b-query.IssueNumber > 0 THEN
        DO:
            FIND Issue OF b-query NO-LOCK NO-ERROR.

            IF AVAILABLE Issue 
                THEN ASSIGN lc-issue = Issue.BriefDescription.
        END.

        IF b-query.IssActivityID > 0 THEN
        DO:
            FIND issActivity WHERE issActivity.issActivityID = 
                b-query.IssActivityID NO-LOCK NO-ERROR.
            IF AVAILABLE issActivity THEN
            DO:
                /* Pre 07.2106 - activity type was not recorded */
                IF issActivity.activityType <> ""
                THEN ASSIGN lc-Activity = issActivity.activityType + " - " + issActivity.description.
                ELSE ASSIGN lc-Activity = issActivity.description.
             END.
                
        END.
        IF NOT ll-chargeable
        THEN lc-activity = "** " + lc-activity.
        
        {&out}
        '<tr>' skip
            htmlib-MntTableField(string(b-query.txndate,'99/99/9999'),'right')
            htmlib-MntTableField(html-encode(dynamic-function("com-DescribeTicket",b-query.TxnType)),'left')
            htmlib-MntTableField(html-encode(b-query.Reference),'left')
            htmlib-MntTableField(if b-query.IssueNumber = 0
                                 then "&nbsp;" else string(b-query.IssueNumber),'right')
            htmlib-MntTableField(html-encode(lc-issue),'left')
            htmlib-MntTableField(lc-Activity,'left')
            htmlib-MntTableField(dynamic-function("com-TimeToString",b-query.Amount) + 
                IF ll-chargeable THEN " " ELSE "**"
             ,'right')
            htmlib-MntTableField(dynamic-function("com-TimeToString",li-cf),'right')

        .
            
        {&out}
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
    output-content-type ("text/html":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
  Purpose:     Process the web request.
  Parameters:  <none>
  objtargets:       
------------------------------------------------------------------------------*/
    
    {lib/checkloggedin.i} 

    DEFINE BUFFER this-user FOR WebUser.
    
    ASSIGN 
        lc-mode = get-value("mode")
        lc-rowid = get-value("rowid")
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation").
   
    ASSIGN 
        lc-enc-key = lc-rowid.
    
    ASSIGN
        lc-rowid = DYNAMIC-FUNCTION("sysec-DecodeValue",lc-user,TODAY,"Customer",lc-rowid).
        

    ASSIGN 
        lc-mode = "view".

    IF lc-mode = "" 
        THEN ASSIGN lc-mode = get-field("savemode")
            lc-rowid = get-field("saverowid")
            lc-search = get-value("savesearch")
            lc-firstrow = get-value("savefirstrow")
            lc-lastrow  = get-value("savelastrow")
            lc-navigation = get-value("savenavigation").

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    ASSIGN 
        lc-title = 'View'
        lc-link-label = "Back".
                    
        

    ASSIGN 
        lc-title = lc-title + ' Customer'
        lc-link-url = appurl + '/cust/cust.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME)
        .

    FIND customer WHERE ROWID(customer) = to-rowid(lc-rowid)
        NO-LOCK NO-ERROR.
    IF NOT AVAILABLE customer THEN
    DO:
        MESSAGE "missing " lc-enc-key " --> " lc-rowid.
        set-user-field("mode",lc-mode).
        set-user-field("title",lc-title).
        set-user-field("linkinfo","custview.p with " + lc-enc-key).
        
        RUN run-web-object IN web-utilities-hdl ("mn/secure-fail.p").
        RETURN.
    END.


    FIND this-user WHERE this-user.LoginID = lc-user NO-LOCK NO-ERROR.
    
    ASSIGN
        ll-customer = com-IsCustomer(lc-global-company,lc-user).
    
   
    FIND customer WHERE ROWID(customer) = to-rowid(lc-rowid) NO-LOCK.
    
    ASSIGN 
        lc-sla-rows = com-CustomerAvailableSLA(lc-global-company,customer.AccountNumber).
   
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

    {&out} 
    '<script language="JavaScript" src="/scripts/js/tree.js"></script>' skip
        '<script language="JavaScript" src="/scripts/js/prototype.js"></script>' skip
        '<script language="JavaScript" src="/scripts/js/scriptaculous.js"></script>' skip.


    {&out}
    '<script type="text/javascript" src="/scripts/js/tabber.js"></script>' skip
         '<link rel="stylesheet" href="/style/tab.css" TYPE="text/css" MEDIA="screen">' skip
         '<script language="JavaScript" src="/scripts/js/standard.js"></script>' skip
    .

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

    {&out} tbar-JavaScript(lc-Doc-TBAR) skip.
    
    {&out} tbar-JavaScript(lc-Issue-TBAR) skip.

    {&out} tbar-JavaScript(lc-invent-TBAR) skip.

    {&out} tbar-JavaScript(lc-cust-TBAR) skip.
    
    {&out} tbar-JavaScript(lc-Asset-TBAR) skip.


    {&out}
    '</HEAD>' skip
         '<body class="normaltext" onUnload="ClosePage()">' skip.

    {&out}
    htmlib-StartForm("mainform","post", selfurl )
    htmlib-ProgramTitle(lc-title) skip.

    IF get-value("statementsent") = "yes" THEN
    DO:
        {&out} '<div class="infobox">A statement for this customer has been sent to your email address.</div>' skip.
    END.
    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip.
        
    IF get-value("source") <> "menu"
        THEN {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<br>' skip.

    RUN ip-CustomerMainInfo ( customer.CompanyCode, customer.AccountNumber, lc-cust-TBAR ) .
    
    {&out}
    '<div class="tabber">' skip.

    
    IF NOT ll-customer 
        OR ( ll-customer AND this-user.CustomerViewInventory )THEN
    DO:
        
        {&out}
        '<div class="tabbertab" title="Inventory">' skip
        .
        RUN ip-Inventory ( customer.CompanyCode, customer.AccountNumber ).
    
        {&out} 
        '</div>'.
    END.
    
    {&out}
    '<div class="tabbertab" title="Open Issues">' skip.
    RUN ip-CustomerOpenIssue ( customer.CompanyCode, customer.AccountNumber, lc-Issue-TBAR ).
    {&out} 
    '</div>'.

    IF get-value("showtab") = "document" THEN
        {&out}
    '<div class="tabbertab tabbertabdefault" title="Documents">' skip
    .
    ELSE
    {&out}
    '<div class="tabbertab" title="Documents">' skip
    .
    RUN ip-CustomerDocuments ( customer.CompanyCode, customer.AccountNumber, lc-Doc-TBAR ).

    {&out} 
    '</div>'.

    {&out}
    '<div class="tabbertab" title="Other Details">' skip
    .
    RUN ip-CustomerSecondary ( customer.CompanyCode, customer.AccountNumber ) .
    {&out} 
    '</div>'.


    IF DYNAMIC-FUNCTION('com-AllowTicketSupport':U,ROWID(customer)) THEN
    DO:
        {&out}
        '<div class="tabbertab" title="Tickets">' skip.
        RUN ip-Tickets ( customer.CompanyCode, customer.AccountNumber ).
        {&out} 
        '</div>'.
    END.

    {&out}
    '<div class="tabbertab" title="Users">' skip.
    RUN ip-CustomerUsers ( customer.CompanyCode, customer.AccountNumber ).
    {&out} 
    '</div>'.

    IF get-value("showtab") = "ASSET" THEN
        {&out}
    '<div class="tabbertab tabbertabdefault" title="Asset">' skip
    .
    ELSE
        {&out}
        '<div class="tabbertab" title="Asset">' skip
    .

    RUN ip-Asset ( customer.CompanyCode, customer.AccountNumber, lc-Asset-TBAR ).
    
    {&out} 
    '</div>'.

    {&out} 
    '</div>' skip.          /* end tabber */


    {&out} htmlib-Hidden("source", get-value("source")) skip.

    IF get-value("showpdf") <> "" THEN
    DO:
        {&out} '<script>' skip
            "OpenNewWindow('"
                    appurl "/rep/viewpdf3.pdf?PDF=" 
                    url-encode(get-value("showpdf"),"query") "')" skip
            '</script>' skip.
    END.

    IF ll-customer THEN
    DO:
        {&out} htmlib-mBanner(customer.CompanyCode).
            
    END.
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

