/***********************************************************************

    Program:        crm/customer.p
    
    Purpose:        Customer Maintenance - CRM Master Page   
    
    Notes:
    
    
    When        Who         What
    01/08/2016  phoski      Initial
   
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

DEFINE VARIABLE lc-Enc-Key        AS CHARACTER NO-UNDO.  

DEFINE VARIABLE lc-accountnumber AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-name          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-address1      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-address2      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-city          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-county        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-country       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-postcode      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-telephone     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-contact       AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-ct-code       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ct-desc       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cu-code       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cu-desc       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AccStatus     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SalesManager  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sm-code       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sm-desc       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SalesContact  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Website       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-noEmp         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-turn          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SalesNote     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-indsector     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ind-code      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ind-desc      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accountref    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-opt-TBAR      AS CHARACTER 
    INITIAL 'opu' NO-UNDO.
    



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

PROCEDURE ip-CRM-Page:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    {&out} htmlib-StartTable("mnt",
        100,
        0,
        0,
        0,
        "center").
        
    {&out} '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("accountnumber",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Account Number")
        ELSE htmlib-SideLabel("Account Number"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("accountnumber",8,lc-accountnumber) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-accountnumber),'left')
           skip.

    {&out} '<td valign="top" align="right" >' skip
           '<div id="contracts" name="contracts" style="position:absolute;float:right;width:450px;right:20px;">&nbsp;' skip
           '</div>'
           '</td>' skip.



    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("name",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Name")
        ELSE htmlib-SideLabel("Name"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("name",40,lc-name) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-name),'left')
           skip.

    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("address1",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Address")
        ELSE htmlib-SideLabel("Address"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("address1",40,lc-address1) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-address1),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("address2",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("")
        ELSE htmlib-SideLabel(""))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("address2",40,lc-address2) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-address2),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("city",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("City/Town")
        ELSE htmlib-SideLabel("City/Town"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("city",40,lc-city) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-city),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("county",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("County")
        ELSE htmlib-SideLabel("County"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("county",40,lc-county) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-county),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("country",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Country")
        ELSE htmlib-SideLabel("Country"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("country",40,lc-country) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-country),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("postcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Post Code")
        ELSE htmlib-SideLabel("Post Code"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("postcode",20,lc-postcode) 
    '</TD>' skip.
    
    {&out} '</TR>' skip.
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("website",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Web Site")
        ELSE htmlib-SideLabel("Web Site"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("website",40,lc-website) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-website),'left')
           skip.
    {&out} '</TR>' skip.
    

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("contact",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Contact")
        ELSE htmlib-SideLabel("Contact"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("contact",40,lc-contact) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-contact),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("telephone",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Telephone")
        ELSE htmlib-SideLabel("Telephone"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("telephone",20,lc-telephone) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-telephone),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Account Status")
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("accstatus",lc-global-accStatus-code,lc-global-accStatus-code,lc-accstatus)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-accStatus,'left')
           skip.
    {&out} '</TR>' skip.
    
   
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("accountref",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Account Reference")
        ELSE htmlib-SideLabel("Account Reference"))
    '</TD>'.
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("accountref",15,lc-accountref) 
    '</TD>' skip.
    else 
 {&out} htmlib-TableField(html-encode(lc-accountref),'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("SalesManager",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Sales Manager")
        ELSE htmlib-SideLabel("Sales Manager"))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("salesmanager",lc-sm-Code,lc-sm-desc,lc-SalesManager)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-SalesManager,'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Sales Contact")
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("salescontact",lc-cu-Code,lc-cu-desc,lc-salescontact)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-salescontact,'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("noemp",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("No Of Employees")
        ELSE htmlib-SideLabel("No Of Employees"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("noemp",6,lc-noemp) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-noemp),'left')
           skip.

    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("turn",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Annual Turnover")
        ELSE htmlib-SideLabel("Annual Turnover"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("turn",8,lc-turn) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-turn),'left')
           skip.

    {&out} '</TR>' skip.
        
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("indsector",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Industry Sector")
        ELSE htmlib-SideLabel("Industry Sector"))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("indsector",lc-ind-Code,lc-ind-desc,lc-indsector)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-indsector,'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("salesnote",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Sales Note")
        ELSE htmlib-SideLabel("Sales Note"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-TextArea("salesnote",lc-salesnote,5,60)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(replace(html-encode(lc-salesnote),"~n",'<br>'),'left')
           skip.
    {&out} '</TR>' skip.
        
   
    
    
    {&out} htmlib-EndTable() skip.
   
   

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
           tbar-JavaScript(lc-Opt-TBAR) skip
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
                      url-encode(lc-enc-key,"Query") + "&returnback=crm")
            tbar-BeginOptionID(pc-ToolBarID)

            tbar-Link("view",?,"off",lc-link-otherp)
            tbar-Link("update",?,"off",lc-link-otherp)
            tbar-Link("delete",?,"off",lc-link-otherp)

 
            tbar-EndOption()
            tbar-End() SKIP.
  
        {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="95%" align="center"').
    
    {&out}
    htmlib-TableHeading(
        "Description|Sales Manager|Customer Contact|Department|Next Step"
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
                             '&crmaccount=' +  url-encode(lc-enc-key,"Query") +
                             '&returnback=' + lc-returnback.
                                
        
        {&out}
            skip
             tbar-trID(pc-ToolBarID,rowid(b-query))
            skip
            
            htmlib-MntTableField(html-encode(b-query.descr),'left')
            htmlib-MntTableField(html-encode(com-UserName(b-query.salesmanager)),'left')
            htmlib-MntTableField(html-encode(com-UserName(b-query.salesContact)),'left')
            htmlib-MntTableField(html-encode(b-query.department),'left')
            htmlib-MntTableField(html-encode(b-query.nextStep),'left')
               
            
            
            tbar-BeginHidden(rowid(b-query))
            tbar-Link("view",rowid(b-query),appurl + '/crm/crmop.p',lc-link-otherp)
            tbar-Link("update",rowid(b-query),appurl +  '/crm/crmop.p',lc-link-otherp)
            tbar-Link("delete",rowid(b-query),appurl + '/crm/crmop.p',lc-link-otherp)
                
            tbar-EndHidden()
            '</tr>' skip.
            
            
        GET NEXT q NO-LOCK.
            
    END.

    {&out} skip 
           htmlib-EndTable()
           skip.
           
        
    

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
        lc-mode = get-value("mode").
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
                b-table.accountref       = lc-accountref
                b-table.SalesManager    = lc-SalesManager
                b-table.salesContact    = lc-SalesContact
                b-table.NoOfEmployees   = int(lc-noemp)
                b-table.AnnualTurnover = int(lc-turn)
                b-table.salesnote       = lc-salesnote
                b-table.industrySector = lc-indsector
                .
                
            IF b-table.salesContact = lc-global-selcode
            THEN b-table.salesContact = "".
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
    
    
    {&out} htmlib-Header("Customer CRM") skip.
 
    RUN ip-ExportJS.
    
    {&out} htmlib-StartForm("mainform","post", appurl + '/crm/customer.p' ) SKIP
           htmlib-ProgramTitle(lc-title) skip.

    
    IF get-value("source") <> "menu"
        THEN {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<br>' skip.
        
    RUN ip-CRM-Page.
    
    IF  lc-error-msg = "OK:Update" THEN
    DO:
        {&out} '<div class="infobox">CRM Details Updated</div>' SKIP.  
    END.
    ELSE
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
    
     
    {&out}
    '<div class="tabber">' skip.
         
    {&out}
    '<div class="tabbertab" title="Opportunities">' SKIP.
    RUN ip-opPage ( b-table.companyCode , b-table.AccountNumber ,lc-opt-TBAR).
    {&out} '</div>' SKIP.
           
    {&out}
    '<div class="tabbertab" title="Oppurtunities2">' skip 
        '</div>' SKIP.
              
    {&out}
    '<div class="tabbertab" title="Oppurtunities3">' skip 
        '</div>' SKIP.
                   
 
    {&out} '</div>' SKIP.
    
    {&out} skip
           htmlib-Hidden("crmaccount", get-value("crmaccount")) SKIP
           htmlib-Hidden("submitsource", "") SKIP
           htmlib-Hidden("mode", lc-mode) SKIP
           htmlib-EndForm() skip.
           
    
    
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

