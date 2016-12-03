/***********************************************************************

    Program:        crm/customer.p
    
    Purpose:        Customer Maintenance - CRM Master Page   
    
    Notes:
    
    
    When        Who         What
    01/08/2016  phoski      Initial
    15/10/2016  phoski      CRM Phase 2
   
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lr-rowid         AS ROWID     NO-UNDO.

DEFINE VARIABLE lc-title         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitsource  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode          AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-Enc-Key       AS CHARACTER NO-UNDO.  

{crm/customer-form-vars.i}

DEFINE VARIABLE lc-source        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parent        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-opt-TBAR      AS CHARACTER 
    INITIAL 'opu' NO-UNDO.
    
DEFINE VARIABLE lc-con-TBAR      AS CHARACTER 
    INITIAL 'con' NO-UNDO.
        
    



DEFINE BUFFER b-table FOR customer.




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

PROCEDURE ip-ConPage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-ToolBarID        AS CHARACTER     NO-UNDO.
    
    DEFINE VARIABLE lc-rowid AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE ll-ToolBar          AS LOG      NO-UNDO.
    
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
    DEFINE BUFFER b-query  FOR webUser.
   

 
                 
    ASSIGN
        lc-returnback="crm".


    FIND customer 
        WHERE customer.CompanyCode = pc-CompanyCode
        AND customer.AccountNumber = pc-AccountNumber
        NO-LOCK.

    lc-customer = STRING(ROWID(customer)).

    ASSIGN 
        lc-enc-key =
                 DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(customer))).

    ASSIGN 
        ll-toolbar = TRUE.
    {&out} SKIP
            tbar-BeginID(pc-ToolBarID,"") SKIP
            tbar-Link("add",?,appurl + '/crm/crmcontact.p',"crmaccount=" +
                      url-encode(lc-enc-key,"Query") + "&returnback=crm" + "&source=" + lc-source + "&parent=" + lc-parent)
            tbar-BeginOptionID(pc-ToolBarID)
            tbar-Link("update",?,"off",lc-link-otherp)
            tbar-Link("delete",?,"off",lc-link-otherp)
            
 
            tbar-EndOption()
            tbar-End() SKIP.
  
    {&out} SKIP
           REPLACE(htmlib-StartMntTable(),'width="100%"','width="100%" align="center"').
    
    {&out}
    htmlib-TableHeading(
        "User Name^left|Name^left|Position|Email^left|Telephone|Mobile|Type"
        ) SKIP.

    OPEN QUERY q FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode   = pc-CompanyCode
        AND b-query.AccountNumber = pc-AccountNumber.
        

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
                             '&crmaccount=' +  url-encode(lc-enc-key,"Query") +
                             '&returnback=' + lc-returnback +
                             '&source=' + lc-source +
                             '&parent=' + lc-parent.
                                
        
        {&out}
            SKIP
             tbar-trID(pc-ToolBarID,ROWID(b-query))
            SKIP
            
            htmlib-MntTableField(html-encode(b-query.loginid),'left')
            htmlib-MntTableField(html-encode(b-query.name),'left')
            htmlib-MntTableField(html-encode(b-query.JobTitle),'left')
            htmlib-MntTableField(html-encode(b-query.email),'left')
            htmlib-MntTableField(html-encode(b-query.Telephone),'left')
            htmlib-MntTableField(html-encode(b-query.Mobile),'left')
            htmlib-MntTableField(com-DecodeLookup(b-query.engType,lc-global-UserSubType-Code ,lc-global-UserSubType-desc),'left')
                                             
            
            
            tbar-BeginHidden(ROWID(b-query))
            
            tbar-Link("update",ROWID(b-query),appurl +  '/crm/crmcontact.p',lc-link-otherp)
            tbar-Link("delete",ROWID(b-query),appurl + '/crm/crmcontact.p',lc-link-otherp)
            
                
            tbar-EndHidden()
            '</tr>' SKIP.
            
            
        GET NEXT q NO-LOCK.
            
    END.

    {&out} SKIP 
           htmlib-EndTable()
           SKIP.
           

END PROCEDURE.

PROCEDURE ip-CRM-Page:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    {crm/customer-form-page.i}   
   

END PROCEDURE.

PROCEDURE ip-ExportJS:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    {&out} lc-global-jquery  SKIP
            
           '<script language="javascript">' SKIP
           'var appurl = "' appurl '";' SKIP
           '</script>' SKIP
           tbar-JavaScript(lc-Opt-TBAR) SKIP
           tbar-JavaScript(lc-Con-TBAR) SKIP
           
           '<script language="JavaScript" src="/asset/page/crm/customer.js?v=1.0.0"></script>' SKIP
           
    .
           
    
           

END PROCEDURE.

PROCEDURE ip-HTM-Header:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE OUTPUT PARAMETER pc-return       AS CHARACTER NO-UNDO.
    
/*
pc-return = '<script type="text/javascript" src="/scripts/js/tabber.js"></script>~n
<link rel="stylesheet" href="/style/tab.css" TYPE="text/css" MEDIA="screen">~n
<script language="JavaScript" src="/scripts/js/standard.js"></script>~n
'.
*/
   

    

END PROCEDURE.

PROCEDURE ip-opPage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-ToolBarID        AS CHARACTER     NO-UNDO.
    
    DEFINE VARIABLE lc-rowid AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE ll-ToolBar          AS LOG      NO-UNDO.
    
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
    DEFINE BUFFER b-query  FOR op_master.


 
                 
    ASSIGN
        lc-returnback="crm".


    FIND customer 
        WHERE customer.CompanyCode = pc-CompanyCode
        AND customer.AccountNumber = pc-AccountNumber
        NO-LOCK.

    lc-customer = STRING(ROWID(customer)).

    ASSIGN 
        lc-enc-key =
                 DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(customer))).

    ASSIGN 
        ll-toolbar = TRUE.
    {&out} SKIP
            tbar-BeginID(pc-ToolBarID,"") SKIP
            tbar-Link("add",?,appurl + '/crm/crmop.p',"crmaccount=" +
                      url-encode(lc-enc-key,"Query") + "&returnback=crm" + "&source=" + lc-source + "&parent=" + lc-parent )
            tbar-BeginOptionID(pc-ToolBarID)
            tbar-Link("update",?,"off",lc-link-otherp)
            tbar-Link("delete",?,"off",lc-link-otherp)
            
 
            tbar-EndOption()
            tbar-End() SKIP.
  
    {&out} SKIP
           REPLACE(htmlib-StartMntTable(),'width="100%"','width="100%" align="center"').
    
    {&out}
    htmlib-TableHeading(
        "No^right|Description|Status|Type|Close Date|Customer Contact|Department|Stage|Created^right"
        ) SKIP.

    OPEN QUERY q FOR EACH b-query NO-LOCK
        OF Customer BY b-query.op_no.

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
                             '&crmaccount=' +  url-encode(lc-enc-key,"Query") +
                             '&returnback=' + lc-returnback +
                             '&source=' + lc-source +
                             '&parent=' + lc-parent.
                                
        
        {&out}
            SKIP
             tbar-trID(pc-ToolBarID,ROWID(b-query))
            SKIP
            htmlib-MntTableField(STRING(b-query.op_no),'right')
            htmlib-MntTableField(html-encode(b-query.descr),'left')
            
            htmlib-MntTableField(com-DecodeLookup(b-query.opstatus,lc-global-opStatus-Code,lc-global-opStatus-desc),'left')
            
             htmlib-MntTableField(com-DecodeLookup(b-query.opType,lc-global-opType-Code,lc-global-opType-desc),'left')
            
            htmlib-MntTableField(html-encode(IF b-query.closeDate = ? THEN '' ELSE STRING(b-query.CloseDate,"99/99/9999")),'left')
          
            htmlib-MntTableField(html-encode(com-UserName(b-query.salesContact)),'left')
            htmlib-MntTableField(html-encode(b-query.department),'left')
            htmlib-MntTableField(html-encode(
            DYNAMIC-FUNCTION("com-GenTabDesc",
                         b-query.CompanyCode, "CRM.Stage", 
                         b-query.nextStep)
            ),'left')
            htmlib-MntTableField(html-encode(IF b-query.createDate = ? THEN '' ELSE STRING(b-query.createDate,"99/99/9999 HH:MM")),'right')
            
               
            
            
            tbar-BeginHidden(ROWID(b-query))
            
            tbar-Link("update",ROWID(b-query),appurl +  '/crm/crmop.p',lc-link-otherp)
            tbar-Link("delete",ROWID(b-query),appurl + '/crm/crmop.p',lc-link-otherp)
            
                
            tbar-EndHidden()
            '</tr>' SKIP.
            
            
        GET NEXT q NO-LOCK.
            
    END.

    {&out} SKIP 
           htmlib-EndTable()
           SKIP.
           
        
    

END PROCEDURE.

PROCEDURE ip-Validate:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE OUTPUT PARAMETER pc-error-field  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg    AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-Customer FOR Customer.
    DEFINE VARIABLE li-int  AS INT  NO-UNDO.
    
    
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
            
            
END PROCEDURE.

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
        lc-title = 'View'
        lc-link-label = "Back"
        lc-submit-label = "Update CRM Details".
                    
        

    ASSIGN 
        lc-link-url = appurl + '/cust/cust.p' + 
                                  '?search=' +
                                  '&navigation=initial' +
                                  '&time=' + string(TIME).
                                  
   
    ASSIGN 
        lc-rowid = get-value("crmaccount")
        lc-mode = get-value("mode")
        lc-source = get-value("source")
        lc-parent = get-value("parent").
        
    IF lc-source = "dataset"
    THEN lc-link-url = appurl + '/crm/crmloadmnt.p' + 
                                  '?mode=view&rowid=' + lc-parent +
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME).    
    IF lc-mode = "CRM"
        THEN lc-mode = "UPDATE".
        
    ASSIGN 
        lc-enc-key = lc-rowid.
    
    ASSIGN
        lc-rowid = DYNAMIC-FUNCTION("sysec-DecodeValue",lc-user,TODAY,"Customer",lc-rowid).
        
    ASSIGN 
        lr-rowid = TO-ROWID(lc-rowid).
            
    

    FIND b-table WHERE ROWID(b-table) = lr-rowid
        NO-LOCK NO-ERROR.
        
    IF request_method = "POST" THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = lr-rowid
            EXCLUSIVE-LOCK NO-ERROR.
        ASSIGN
            lc-name              = get-value("name")
            lc-address1          = get-value("address1")
            lc-address2          = get-value("address2")
            lc-city              = get-value("city")
            lc-county            = get-value("county")
            lc-country           = get-value("country")
            lc-postcode          = get-value("postcode")
            lc-telephone         = get-value("telephone")
            lc-contact           = get-value("contact")
            lc-accStatus         = get-value("accstatus")
            lc-accountref        = get-value("accountref")
            lc-SalesManager      = get-value("salesmanager")
            lc-SalesContact      = get-value("salescontact")
            lc-website           = get-value("website")
            lc-noemp             = get-value("noemp")
            lc-turn              = get-value("turn")
            lc-salesnote         = get-value("salesnote")
            lc-indsector        =  get-value("indsector").
            
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            ASSIGN
                b-table.name         = lc-name
                b-table.address1       = lc-address1
                b-table.address2       = lc-address2
                b-table.city           = lc-city
                b-table.county         = lc-county
                b-table.country        = lc-country
                b-table.postcode       = lc-postcode
                b-table.contact        = lc-contact
                b-table.telephone      = lc-telephone
                b-table.accStatus       = lc-accStatus
                b-table.website         = lc-WebSite
                b-table.accountref      = lc-accountref
                b-table.SalesManager    = lc-SalesManager
                b-table.salesContact    = lc-SalesContact
                b-table.NoOfEmployees   = int(lc-noemp)
                b-table.AnnualTurnover = int(lc-turn)
                b-table.salesnote       = lc-salesnote
                b-table.industrySector = lc-indsector
                .
             /* Active now means active on the help desk only */
            ASSIGN
               b-table.isActive = b-table.accStatus = "Active".
                              
            IF b-table.salesContact = lc-global-selcode
                THEN b-table.salesContact = "".
            FOR EACH op_master EXCLUSIVE-LOCK
                WHERE op_master.CompanyCode = b-table.CompanyCode
                  AND op_master.AccountNumber = b-table.AccountNumber:
                 
                 RUN crm/lib/final-op.p ( ROWID(op_master)).
                 
            END.
             
            lc-error-msg = "OK:Update".
            
        END.
                                
                        
    END.
        
    IF request_method = "GET" THEN
    DO:
        ASSIGN
            lc-name      = b-table.name
            lc-address1  = b-table.address1
            lc-address2  = b-table.address2
            lc-city      = b-table.city
            lc-county    = b-table.county
            lc-country   = b-table.country
            lc-postcode  = b-table.postcode
            lc-telephone = b-table.telephone
            lc-contact   = b-table.contact
            lc-accstatus = b-table.accStatus
            lc-accountref   = b-table.accountRef
            lc-accstatus    = b-table.accStatus
            lc-SalesManager = b-table.SalesManager
            lc-SalesContact = b-table.salescontact
            lc-website      = b-table.website
            lc-noemp        = STRING(b-table.NoOfEmployees)
            lc-turn         = STRING(b-table.AnnualTurnover)
            lc-salesnote    = b-table.SalesNote
            lc-indsector    = b-table.industrySector.
            
        
    END.
        
    ASSIGN
        lc-AccountNumber = b-table.AccountNumber.
    
    RUN com-GetUserListForAccount (lc-global-company,b-table.AccountNumber,OUTPUT lc-cu-code, OUTPUT lc-cu-desc).
    IF lc-cu-code = ""
        THEN ASSIGN lc-cu-code = lc-global-selcode
            lc-cu-desc = "None".
    
    ELSE 
        ASSIGN
            lc-cu-code = lc-global-selcode + "|" + lc-cu-code
            lc-cu-desc = "None|" + lc-cu-desc.
            
    RUN com-GetUserListByClass ( lc-global-company, "INTERNAL", REPLACE(lc-global-EngType-Code,'|',",") ,OUTPUT lc-ct-code, OUTPUT lc-ct-desc).
    
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
        lc-ct-code = "|" + lc-ct-code
        lc-ct-desc = "None Selected|" + lc-ct-desc
        lc-sm-code = "|" + lc-sm-code
        lc-sm-desc = "None Selected|" + lc-sm-desc
        .
   
    ASSIGN
        lc-title = "Account - "  + b-table.name.
 
    RUN outputHeader.
    
    
    {&out} htmlib-Header("Customer CRM") SKIP.
 
    RUN ip-ExportJS.
    
    {&out} htmlib-StartForm("mainform","post", appurl + '/crm/customer.p' ) SKIP
           htmlib-ProgramTitle(lc-title) SKIP.

    
    IF lc-source <> "menu"
        THEN {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<br>' SKIP.
        
    RUN ip-CRM-Page.
    
    IF  lc-error-msg = "OK:Update" THEN
    DO:
        {&out} '<div class="infobox">CRM Details Updated</div>' SKIP.  
    END.
    ELSE
        IF lc-error-msg <> "" THEN
        DO:
            {&out} '<BR><BR><CENTER>' 
            htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' SKIP.
        END.

    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<br><center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' SKIP.
    END.
    
     
    {&out}
    '<div class="tabber">' SKIP.
         
    {&out}
    '<div class="tabbertab" title="Opportunities">' SKIP.
    RUN ip-opPage ( b-table.companyCode , b-table.AccountNumber ,lc-opt-TBAR).
    {&out} '</div>' SKIP.
        
    IF get-value("showtab") = "contact" 
    THEN {&out}
    '<div class="tabbertab tabbertabdefault" title="Contacts">' SKIP. 
    ELSE {&out}
    '<div class="tabbertab" title="Contacts">' SKIP.
    RUN ip-ConPage ( b-table.companyCode , b-table.AccountNumber ,lc-Con-TBAR).   
    {&out} '</div>' SKIP.
              
    
                   
 
    {&out} '</div>' SKIP.
    
    {&out} SKIP
           htmlib-Hidden("crmaccount", get-value("crmaccount")) SKIP
           htmlib-Hidden("submitsource", "") SKIP
           htmlib-Hidden("mode", lc-mode) SKIP
           htmlib-hidden("source",lc-source) SKIP
           htmlib-hidden("parent",lc-parent) SKIP
           htmlib-EndForm() SKIP.
           
    
    
    {&OUT} htmlib-Footer() SKIP.
    
  
END PROCEDURE.


&ENDIF

