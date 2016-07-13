/***********************************************************************

    Program:        rep/custprofit.p
    
    Purpose:        Customer Profit Report
    
    Notes:
    
    
    When        Who         What
    15/06/2015  phoski      Initial
    26/11/2015  phoski      Account Status
    12/03/2016  phoski      Change page to shrink width
    15/03/2016  phoski      Selection of contract status and show it
    02/07/2016  phoski      Admin Time option
    
   
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */



DEFINE VARIABLE lc-error-field    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-temp           AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop           AS INTEGER   NO-UNDO.


DEFINE VARIABLE lc-lodate         AS CHARACTER FORMAT "99/99/9999" NO-UNDO.
DEFINE VARIABLE lc-hidate         AS CHARACTER FORMAT "99/99/9999" NO-UNDO.
DEFINE VARIABLE lc-selectcustomer AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-output         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cs             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-co             AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-output-code    AS CHARACTER INITIAL 'WEB|CSV' NO-UNDO.
DEFINE VARIABLE lc-output-desc    AS CHARACTER INITIAL 'Web Page|Email CSV' NO-UNDO.
DEFINE VARIABLE lc-cs-code        AS CHARACTER INITIAL "ALL|ACT|INACT" NO-UNDO.
DEFINE VARIABLE lc-cs-desc        AS CHARACTER INITIAL 'All Customers|Active Customers|Inactive Customers' NO-UNDO.

DEFINE VARIABLE lc-co-code        AS CHARACTER INITIAL "ALL|ACT|INACT" NO-UNDO.
DEFINE VARIABLE lc-co-desc        AS CHARACTER INITIAL 'All Contracts|Active Contracts|Inactive Contracts' NO-UNDO.
DEFINE VARIABLE lc-admin          AS CHARACTER NO-UNDO.



{rep/custprofit-tt.i}
{src/web2/wrap-cgi.i}
{lib/htmlib.i}
{lib/maillib.i}
{lib/replib.i}

/* ************************  Main Code Block  *********************** */


/* Process the latest Web event. */
RUN process-web-request.




/* **********************  Internal Procedures  *********************** */


PROCEDURE ip-EmailCSV:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-GenKey       AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lc-filename     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-pass         AS INT  NO-UNDO.
    DEFINE VARIABLE lc-dates        AS CHARACTER    NO-UNDO.
    
    DEFINE BUFFER this-user FOR WebUser.
    
    ASSIGN
        lc-genkey = STRING(NEXT-VALUE(ReportNumber)).
    
    
    DO li-pass = 1 TO 2:  
        IF li-pass = 1
        THEN ASSIGN lc-filename = SESSION:TEMP-DIR + "/CustProfDetail-" + lc-GenKey + ".csv".
        ELSE ASSIGN lc-filename = SESSION:TEMP-DIR + "/CustProfSummary-" + lc-GenKey + ".csv".

        OUTPUT TO VALUE(lc-filename).
    
        PUT UNFORMATTED
            '"Customer","Contract","Active","Contact Period","Contract Days","Revenue Days","Daily Rate","Gross Profit %","Contract Value","Billable","NonBillable","Total","Revenue","Cost","Gross Profit"' SKIP.
     
        FOR EACH tt-custp NO-LOCK 
            BY tt-custp.SortField:
                
            IF li-pass = 1 AND tt-custp.ContractCode = cc-TotalKey THEN NEXT.
            ELSE
            IF li-pass = 2 AND ( tt-custp.ContractCode <> cc-TotalKey OR tt-custp.AccountNumber = cc-TotalKey ) THEN NEXT.
            
            IF tt-custp.cbegin <> ? 
            THEN lc-dates = STRING(tt-custp.cbegin,'99/99/9999') + ' - ' +  string(tt-custp.cend,'99/99/9999').
            ELSE lc-dates = "".
            
            EXPORT DELIMITER ','
                tt-custp.name
                IF tt-custp.ContractCode = cc-TotalKey THEN "" ELSE tt-custp.ContractCode
                IF tt-custp.ContractCode = cc-TotalKey THEN "" ELSE STRING(tt-custp.ConActive)
                lc-dates
                tt-custp.ndays[1]
                tt-custp.rdays[1]
                tt-custp.drate[1]
                tt-custp.GrossProfit%
                tt-custp.cValue
                tt-custp.hBill-Time[1]
                tt-custp.hNonB-Time[1]
                tt-custp.hBill-Time[1] + tt-custp.hNonB-Time[1]
                tt-custp.Revenue[1]
                tt-custp.Cost[1]
                tt-custp.GrossProfitV
                
                .   
        END.
        OUTPUT CLOSE.
    
        FIND this-user
            WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.
    
    
        mlib-SendAttEmail 
            ( lc-global-company,
            "",
            "Customer Profit Report ( " + IF li-pass = 1 THEN "Detail )" ELSE "Summary )" ,
            "Please find attached your report covering the period "
            + string(DATE(lc-lodate),"99/99/9999") + " to " +
            string(DATE(lc-hidate),'99/99/9999'),
            this-user.email,
            "",
            "",
            lc-filename).
        OS-DELETE value(lc-filename).

    END. 
    {&out} '<div class="infobox" style="font-size: 10px;">Your report has been emailed to '
    this-user.email
    '</div>'.
        

END PROCEDURE.

PROCEDURE ip-HTM-Header:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-return       AS CHARACTER NO-UNDO.

    pc-return = 
        lc-global-jquery +
        '<script language="JavaScript" src="/asset/page/custprofit.js?v=1.0.0"></script>~n' 
        
        .
    



END PROCEDURE.

PROCEDURE ip-ReportSelectionHTML:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE BUFFER Customer FOR Customer.
     
    DEFINE VARIABLE lc-desc  AS CHARACTER  INITIAL "January,February,March,April,May,June,July,August,September,October,November,December" NO-UNDO.
    

    {&out} htmlib-StartTable("mnt",
        0,
        0,
        5,
        0,
        "center") skip.
    
    {&out} 
    '<tr>'
    '<td valign="top" align="right">' 
        (IF LOOKUP("lodate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("From Date")
        ELSE htmlib-SideLabel("From Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("lodate",10,lc-lodate) 
    htmlib-CalendarLink("lodate")
    '</td>' SKIP
    '<td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To Date")
        ELSE htmlib-SideLabel("To Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("hidate",10,lc-hidate) 
    htmlib-CalendarLink("hiodate")
    '</td>'
    '<td valign="top" align="left">'
    htmlib-SideLabel("Customer Status") htmlib-Select("cs",lc-cs-code,lc-cs-desc,get-value("cs")) 
    '</td>'
    '<td valign="top" align="left">'
    htmlib-SideLabel("Output To") htmlib-Select("output",lc-output-code,lc-output-desc,get-value("output")) 
    '</td>'
    '</tr><tr>'
    '<td valign="top" align="right">'
    htmlib-SideLabel("Contract Status") 
    '</td><td valign="top" align="left">'
    htmlib-Select("co",lc-co-code,lc-co-desc,get-value("co")) 
    '</td>'
    '</tr><tr><TD VALIGN="TOP"  ALIGN="right">' 
            htmlib-SideLabel("Exclude Administration Time?")
     
             '</td><TD VALIGN="TOP" ALIGN="left">'
                htmlib-CheckBox("admin", IF lc-admin = 'on'
                                        THEN TRUE ELSE FALSE) 
            '</TD>'
    '</tr><tr>'
    '<td valign="top" align="right">' 
        (IF LOOKUP("customer",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Customer(s)")
        ELSE htmlib-SideLabel("Customer(s)"))
    '</td>'
     '<td valign=top colspan=7>' SKIP.
        
   
    
        
    {&out}  /*'<div id="customerdiv" style="display:block;">' skip
            '<span class="tableheading" >Please select customer(s)</span><br>' skip
            */
            '<select id="selectcustomer" name="selectcustomer" class="inputfield" ' skip
            'multiple="multiple" size=20 style="width:400px;" >' skip.
 
    {&out}
    '<option value="ALL" selected >Select All</option>' skip.

    FOR EACH customer NO-LOCK
        WHERE customer.company = lc-global-company
        BY customer.name:
 
        {&out}
        '<option value="'  customer.accountnumber '" ' '>'  html-encode(customer.name) '</option>' skip.
    END.
    {&out} '</select></td></tr>'.
   
      
      
                
    {&out}  htmlib-EndTable() SKIP '<br />'.


    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    {&out} '<center>' '<input class="submitbutton" type="submit" name="submitform" value="Report">' 
    '</center><br>' skip.

    {&out} htmlib-Hidden("submitsource","") SKIP
           '</div>' skip.
           

END PROCEDURE.

PROCEDURE ip-ReportWebPage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE ld-lo           AS DATE         NO-UNDO.
    DEFINE VARIABLE ld-hi           AS DATE         NO-UNDO.
    DEFINE VARIABLE lc-style        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE li-count        AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-tr           AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE lc-tot-style1   AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE lc-tot-style2   AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE lc-last-name    AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE lc-dates        AS CHARACTER    NO-UNDO.
    
    
    
        
    ASSIGN
        ld-lo = DATE(lc-lodate)
        ld-hi = DATE(lc-hiDate).
        
                
  
    {&out}
    htmlib-StartMntTable() SKIP
    '<tr>' 
    /*'<th colspan=7>&nbsp;</th><th colspan=6 valign="bottom" style="text-align:center;border-bottom:1px solid black;">'
    */
    '<th colspan=14 valign="bottom" style="text-align:center;border-bottom:1px solid black;">Dates: '
    STRING(ld-lo,'99/99/9999') ' - ' STRING(ld-hi,'99/99/9999')
    ' - Days ' ( ld-hi - ld-lo) + 1  
    '</th>' 
        
        
        '</tr>' SKIP
    htmlib-TableHeading(
    'Customer^left|Contract^left|Active^left|Contract Period^right|Contract Days^right|Revenue Days^right|Daily Rate^right|Gross Profit %^right|Contract Value</br>PA^right|Billable^right|Non Billable^right|Total^right|Revenue^right|Cost^right|Gross Profit^right' ) 
    SKIP.
        
                          
    FOR EACH tt-custp NO-LOCK BY tt-custp.SortField:
        
        /*
        li-count = li-count + 1.
        IF li-count MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE lc-tr = '<tr style="background: white;">'.          
        */
        
        IF tt-custp.ContractCode = cc-TotalKey
            THEN ASSIGN lc-tot-style1 = "border-top: 1px solid black;border-bottom: 1px solid black;"
                lc-tot-style2 = "font-weight: bold;"
                lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE ASSIGN lc-tot-style1 = ""
                lc-tot-style2 = ""
                lc-tr = '<tr style="background: white;">'.
            
        lc-tr = '<tr style="background: white;">'.
        
        ASSIGN 
            lc-dates = "".
            
        IF tt-custp.cbegin <> ? 
        THEN lc-dates = STRING(tt-custp.cbegin,'99/99/9999') + ' - ' +  string(tt-custp.cend,'99/99/9999').
        
               
        {&out} lc-tr SKIP
                 replib-RepField(IF tt-custp.ContractCode = cc-TotalKey OR lc-last-name = tt-custp.name THEN "" ELSE tt-custp.name ,'left','')
                 replib-RepField( IF tt-custp.ContractCode = cc-TotalKey AND tt-custp.AccountNumber = cc-totalKey THEN "Report Total" else
                 IF tt-custp.ContractCode = cc-TotalKey THEN "Total" else tt-custp.contractCode,
                 IF tt-custp.ContractCode = cc-TotalKey then 'right' ELSE 'left',lc-tot-style2)
                 replib-RepField(IF tt-custp.ContractCode = cc-TotalKey THEN "" ELSE string(tt-custp.ConActive) ,'left','')
                 replib-RepField(IF tt-custp.cbegin = ? THEN "" ELSE lc-dates ,'right',lc-tot-style2)
                 replib-RepField(IF tt-custp.cbegin = ? THEN "" ELSE string(tt-custp.ndays[1]) ,'right',lc-tot-style2)
                 replib-RepField(IF tt-custp.cbegin = ? THEN "" ELSE string(tt-custp.rdays[1]) ,'right',lc-tot-style2)
                 replib-RepField(IF tt-custp.cbegin = ? THEN "" ELSE dynamic-function("com-money",tt-custp.drate[1]),'right',lc-tot-style2)
                 replib-RepField(IF tt-custp.cbegin = ? THEN "" ELSE dynamic-function("com-money",tt-custp.GrossProfit%),'right',lc-tot-style2)
                 replib-RepField(dynamic-function("com-money",tt-custp.cvalue),'right',lc-tot-style1)
                 replib-RepField(string(tt-custp.hBill-Time[1]),'right',lc-tot-style1)
                 replib-RepField(string(tt-custp.hNonB-Time[1]),'right',lc-tot-style1)
                 replib-RepField(string(tt-custp.hBill-Time[1] + tt-custp.hNonB-Time[1]),'right',lc-tot-style1)
                 replib-RepField(dynamic-function("com-money",tt-custp.Revenue[1]),'right',lc-tot-style1)
                 replib-RepField(dynamic-function("com-money",tt-custp.Cost[1]),'right',lc-tot-style1)
                 replib-RepField(dynamic-function("com-money",tt-custp.GrossProfitV),'right',lc-tot-style1)
                 /*
                 replib-RepField('','right','')
                 
                 replib-RepField(string(tt-custp.hBill-Time[2]),'right',lc-tot-style1)
                 replib-RepField(string(tt-custp.hNonB-Time[2]),'right',lc-tot-style1)
                 replib-RepField(string(tt-custp.hBill-Time[2] + tt-custp.hNonB-Time[2]),'right',lc-tot-style1)
                 replib-RepField(dynamic-function("com-money",tt-custp.Revenue[2]),'right',lc-tot-style1)
                 replib-RepField(dynamic-function("com-money",tt-custp.Cost[2]),'right',lc-tot-style1)
                 replib-RepField(dynamic-function("com-money",tt-custp.Revenue[2] - tt-custp.cost[2]),'right',lc-tot-style1)
                 */
               '</tr>' SKIP.
        
        ASSIGN
            lc-last-name = tt-custp.name.
            
         IF tt-custp.ContractCode = cc-TotalKey THEN
         {&out} '<tr><td>&nbsp;</td></tr>' SKIP.   
                
                         

    END.
               

    {&out} '</table>' SKIP.

END PROCEDURE.

PROCEDURE ip-Validate:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    DEFINE VARIABLE ld-lodate   AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-hidate   AS DATE     NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-rowid    AS CHARACTER     NO-UNDO.

    ASSIGN
        ld-lodate = DATE(lc-lodate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-lodate = ?
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The from date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    ASSIGN
        ld-hidate = DATE(lc-hidate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-hidate = ?
        THEN RUN htmlib-AddErrorMessage(
            'hidate', 
            'The to date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF ld-lodate > ld-hidate 
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The date range is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-SelectCustomer = ""
        OR lc-SelectCustomer = ?
        THEN RUN htmlib-AddErrorMessage(
            'selectcustomer', 
            'The customer selection is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            


END PROCEDURE.

PROCEDURE outputHeader :
    /*------------------------------------------------------------------------------
      Purpose:     Output the MIME header, and any "cookie" information needed 
                   by this procedure.  
      Parameters:  <none>
      emails:       In the event that this Web object is state-aware, this is
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


PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
  Purpose:     Process the web request.
  Parameters:  <none>
  emails:       
------------------------------------------------------------------------------*/
   
    {lib/checkloggedin.i} 
  
    FIND webuser WHERE webuser.loginid = lc-global-user NO-LOCK NO-ERROR.
  
    IF request_method = "POST" THEN
    DO:
       
        ASSIGN 
            lc-lodate   = get-value("lodate")         
            lc-hidate   = get-value("hidate")
            lc-selectcustomer = get-value("selectcustomer")
            lc-output  = get-value("output")
            lc-cs       = get-value("cs")
            lc-co       = get-value("co")
            lc-admin    = get-value("admin")
            .
            
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).
            
        IF lc-error-msg = "" THEN
        DO:
            RUN rep/custprofit-build.p (
                lc-global-company,
                DATE(lc-lodate),
                DATE(lc-hiDate),
                lc-SelectCustomer,
                lc-cs,
                lc-co,
                lc-admin = "on",
                OUTPUT TABLE tt-custp ).
         
        END.          
        
          
      
    END.
    ELSE
    DO:
     
        ASSIGN 
            lc-lodate = STRING((TODAY - day(TODAY)) + 1, "99/99/9999") 
            lc-hidate = STRING(TODAY, "99/99/9999").
        
    END.

    RUN outputHeader.  
    
    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.
    
    {&out} htmlib-Header('Customer Profit Report') SKIP.
    
   
    {&out}
    htmlib-StartForm("mainform","post", appurl + '/rep/custprofit.p'  )
    htmlib-ProgramTitle("Customer Profit Report") skip.

    
    IF request_method = "GET"
        OR lc-error-msg <> ""
        THEN RUN ip-ReportSelectionHTML.
    ELSE
    DO:
        IF lc-output = "WEB"
            THEN RUN ip-ReportWebPage.
        ELSE
            IF lc-output = "CSV"
                THEN RUN ip-EmailCSV.
       
            
    END.
      
   
    {&out} htmlib-EndForm() skip.
    
    IF request_method = "GET"
        OR lc-error-msg <> ""
        THEN {&out} htmlib-CalendarScript("lodate") skip
           htmlib-CalendarScript("hidate") skip.
   
   
    
         
    {&out} htmlib-Footer() skip.
    

END PROCEDURE.


/* ************************  Function Implementations ***************** */

